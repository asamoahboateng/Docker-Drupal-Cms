#!/usr/bin/env bash
#
# One-command setup for the Drupal CMS Docker stack.
#
#   ./setup.sh
#
# Safe to run again: it skips anything that is already done.

set -euo pipefail
cd "$(dirname "$0")"

green() { printf '\033[32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[33m%s\033[0m\n' "$*"; }
red() { printf '\033[31m%s\033[0m\n' "$*"; }
step() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }

# Edit KEY=value in .env (works with both macOS and Linux sed).
set_env() {
  local key="$1" value="$2"
  if grep -q "^${key}=" .env; then
    sed -i.bak "s|^${key}=.*|${key}=${value}|" .env && rm -f .env.bak
  else
    echo "${key}=${value}" >> .env
  fi
}
get_env() { grep "^$1=" .env | head -n1 | cut -d= -f2-; }
random() { LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c "$1"; }

# --------------------------------------------------------------------------
step "1/6 Checking Docker"
if ! command -v docker >/dev/null 2>&1; then
  red "Docker is not installed. Install Docker Desktop: https://www.docker.com/products/docker-desktop/"
  exit 1
fi
if ! docker info >/dev/null 2>&1; then
  red "Docker is installed but not running. Start Docker Desktop and run ./setup.sh again."
  exit 1
fi
if ! docker compose version >/dev/null 2>&1; then
  red "'docker compose' is missing. Update Docker Desktop (or install the compose plugin)."
  exit 1
fi
green "Docker is ready."

# --------------------------------------------------------------------------
step "2/6 Preparing .env"
if [ ! -f .env ]; then
  cp .env.example .env
  set_env DB_PASSWORD "$(random 24)"
  set_env DB_ROOT_PASSWORD "$(random 24)"
  set_env DRUPAL_HASH_SALT "$(random 64)"
  green "Created .env with random passwords."
else
  green ".env already exists, keeping it."
fi
set_env HOST_UID "$(id -u)"
set_env HOST_GID "$(id -g)"

# Turn the tunnel on automatically once a token is present.
profiles="$(get_env COMPOSE_PROFILES)"
if [ -n "$(get_env CLOUDFLARE_TUNNEL_TOKEN)" ] && [[ ",${profiles}," != *",tunnel,"* ]]; then
  set_env COMPOSE_PROFILES "${profiles:+${profiles},}tunnel"
  green "Cloudflare token found, enabled the 'tunnel' profile."
fi

# If a port is taken by another program, move to the next free one.
port_busy() { (exec 3<>"/dev/tcp/127.0.0.1/$1") 2>/dev/null; }
pick_port() {
  local key="$1" service="$2" default="$3" port
  port="$(get_env "$key")"; port="${port:-$default}"
  if [ -n "$(docker compose ps -q --status running "$service" 2>/dev/null)" ]; then
    return  # it's our own container already using it
  fi
  while port_busy "$port"; do
    yellow "Port $port is already in use, trying $((port + 1))"
    port=$((port + 1))
  done
  set_env "$key" "$port"
}
pick_port HTTP_PORT drupal 8080
pick_port MAILPIT_PORT mailpit 8025
if [[ ",$(get_env COMPOSE_PROFILES)," == *",tools,"* ]]; then
  pick_port ADMINER_PORT adminer 8091
fi

# Create ./app ourselves so it is owned by you, not root.
mkdir -p app

# --------------------------------------------------------------------------
step "3/6 Building and starting containers (first time takes a few minutes)"
docker compose up -d --build

echo -n "Waiting for the database"
for _ in $(seq 1 60); do
  if [ "$(docker inspect -f '{{.State.Health.Status}}' "$(docker compose ps -q db)")" = "healthy" ]; then
    break
  fi
  echo -n "."
  sleep 2
done
echo
green "Containers are up."

dc_exec() { docker compose exec -T -u www-data drupal "$@"; }

# --------------------------------------------------------------------------
step "4/6 Downloading Drupal CMS"
if [ -f app/composer.json ]; then
  green "Drupal code already in ./app, skipping download."
else
  version="$(get_env DRUPAL_CMS_VERSION)"
  dc_exec bash -c "rm -rf /tmp/cms \
    && composer create-project drupal/cms${version:+:$version} /tmp/cms --no-interaction \
    && cp -a /tmp/cms/. /var/www/html/ \
    && rm -rf /tmp/cms"
  green "Drupal CMS downloaded into ./app"
fi

if [ ! -d app/vendor ]; then
  # Code was copied without its dependencies (e.g. moved to a new computer).
  dc_exec composer install --no-interaction
fi
if [ ! -x app/vendor/bin/drush ]; then
  dc_exec composer require drush/drush --no-interaction
fi

# --------------------------------------------------------------------------
step "5/6 Configuring Drupal"
dc_exec bash -c '
  set -e
  cd /var/www/html
  mkdir -p config/sync private web/sites/default/files
  if [ ! -f web/sites/default/settings.php ]; then
    cp web/sites/default/default.settings.php web/sites/default/settings.php
  fi
  if ! grep -q "settings.docker.php" web/sites/default/settings.php; then
    chmod u+w web/sites/default web/sites/default/settings.php
    cat >> web/sites/default/settings.php <<'"'"'EOF'"'"'

// Docker: database, hash salt, trusted hosts etc. come from .env.
if (file_exists($app_root . "/" . $site_path . "/settings.docker.php")) {
  include $app_root . "/" . $site_path . "/settings.docker.php";
}
EOF
  fi
'
cp docker/drupal/settings.docker.php app/web/sites/default/settings.docker.php
green "settings.php is wired to .env"

# --------------------------------------------------------------------------
step "6/6 Done"
port="$(get_env HTTP_PORT)"
mail_port="$(get_env MAILPIT_PORT)"
installed="no"
if dc_exec drush status --field=bootstrap 2>/dev/null | grep -q Successful; then
  installed="yes"
fi

echo
green "Your Drupal CMS stack is running!"
echo
echo "  Website:  http://localhost:${port:-8080}"
echo "  Mailpit:  http://localhost:${mail_port:-8025}   (all e-mails sent by the site land here)"
if [[ ",$(get_env COMPOSE_PROFILES)," == *",tools,"* ]]; then
  echo "  Adminer:  http://localhost:$(get_env ADMINER_PORT)   (server: db, user/pass in .env)"
fi
if [[ ",$(get_env COMPOSE_PROFILES)," == *",tunnel,"* ]]; then
  echo "  Tunnel:   running -> check your public hostname in the Cloudflare dashboard"
fi
echo
if [ "$installed" = "no" ]; then
  yellow "Next: open http://localhost:${port:-8080} in your browser and follow the Drupal CMS installer."
  yellow "(The database step is already filled in for you.)"
fi
