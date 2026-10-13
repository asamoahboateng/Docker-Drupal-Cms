# Drupal CMS on Docker

> 📘 **New to Docker or the Terminal?** Start with the step-by-step beginner's guide in the [`guide/`](guide/README.md) folder. This page is the short reference.

Run Drupal CMS on your computer with Docker, catch its e-mails, and put it online with a Cloudflare Tunnel. You don't need PHP, MySQL or Apache installed on your computer.

---

## What's inside

| Service       | What it does                                                | Where you see it          |
|---------------|-------------------------------------------------------------|---------------------------|
| `drupal`      | Your website (PHP 8.3 + Apache, Composer and Drush included) | http://localhost:8080     |
| `db`          | The database (MariaDB 11.4)                                  | none, used by Drupal      |
| `mailpit`     | Catches e-mails while you test (`MAIL_TRANSPORT=mailpit`). Switch to real sending in Part 5 | http://localhost:8025 |
| `cloudflared` | Puts your site on the internet with HTTPS (optional)         | your own domain           |
| `adminer`     | A web page for looking inside the database (optional)        | http://localhost:8091     |

> If port 8080 (or 8025) is already in use on your computer, `setup.sh` picks the next free port and shows you the right address at the end.

### Files

```
.
├── docker-compose.yml        ← describes all the services above
├── .env.example              ← settings template (setup.sh copies it to .env)
├── .env                      ← YOUR settings and passwords (never share or commit this!)
├── setup.sh                  ← the one-command installer
├── bin/
│   ├── drush                 ← runs Drush inside the container
│   └── composer              ← runs Composer inside the container
├── docker/
│   ├── php/                  ← how the website container is built
│   └── drupal/settings.docker.php  ← connects Drupal to the values in .env
└── app/                      ← your Drupal CMS code (created by setup.sh)
```

---

## Part 1: Install Docker (one time only)

1. Go to https://www.docker.com/products/docker-desktop/
2. Download **Docker Desktop** for your system (Mac: choose Apple chip or Intel chip) and install it.
3. Open Docker Desktop. Wait until the whale icon in your menu bar or taskbar stops animating, which means it is running.
4. Open a **Terminal** (Mac: press `Cmd + Space`, type `Terminal`, press Enter).
5. Type this and press Enter:
   ```bash
   docker --version
   ```
   If it prints something like `Docker version 28.x`, Docker is installed.

> **Windows users:** install Docker Desktop with WSL 2 turned on, then run every command in this guide inside an **Ubuntu (WSL)** terminal, not in PowerShell.

---

## Part 2: Start your Drupal site

### Step 1: Go to the project folder

```bash
cd /path/to/drupalcms2
```

(Tip: type `cd ` with a space after it, then drag the project folder into the Terminal window and press Enter.)

### Step 2: Run the setup script

```bash
./setup.sh
```

If you see `permission denied`, run this once and try again:

```bash
chmod +x setup.sh bin/*
```

The script does six things for you:

1. Checks that Docker is installed and running.
2. Creates your `.env` file with random, secure passwords.
3. Builds and starts the containers. **The first run takes 5–10 minutes**, later runs take seconds.
4. Downloads Drupal CMS into the `app/` folder.
5. Connects Drupal to the database.
6. Prints the addresses you can open.

When it finishes you will see something like:

```
Your Drupal CMS stack is running!

  Website:  http://localhost:8080
  Mailpit:  http://localhost:8025
```

### Step 3: Finish the installer in your browser

1. Open the **Website** address it printed, for example http://localhost:8080.
2. The Drupal CMS installer opens. The database step is already done for you.
3. Give your site a name, pick the features you want, and create your admin account.
4. Done 🎉. You are now logged in to your new site.

---

## Part 3: Everyday commands

Run all of these from the project folder.

| I want to…                         | Command                                   |
|------------------------------------|-------------------------------------------|
| Start the site                     | `docker compose up -d`                    |
| Stop the site (your data is kept)  | `docker compose down`                     |
| See what is running                | `docker compose ps`                       |
| See the logs (Ctrl+C to quit)      | `docker compose logs -f`                  |
| Logs of one service                | `docker compose logs -f drupal`           |
| Clear Drupal's cache               | `./bin/drush cr`                          |
| Get a one-time admin login link    | `./bin/drush uli`                         |
| Install a module                   | `./bin/composer require drupal/pathauto` then `./bin/drush en pathauto` |
| Open a shell inside the container  | `docker compose exec -u www-data drupal bash` |
| Run the setup again (safe)         | `./setup.sh`                              |

> **After changing `.env`**, run `docker compose up -d`. It recreates only the services whose settings changed. `docker compose restart` does **not** load new `.env` values.

---

## Part 4: Put the site online with Cloudflare Tunnel

A tunnel gives your site a public HTTPS address (like `https://www.mysite.com`) **without** opening ports on your router. Your computer, or server, has to stay on for the site to be reachable.

### What you need

- A free Cloudflare account: https://dash.cloudflare.com/sign-up
- A domain added to Cloudflare. If you bought it somewhere else, follow Cloudflare's "Add a site" steps and change your domain's nameservers to the ones Cloudflare gives you.

### Step 1: Create the tunnel

1. Log in to https://one.dash.cloudflare.com (Cloudflare **Zero Trust**). If it asks you to choose a plan, pick the **Free** plan.
2. In the left menu go to **Networks → Tunnels**.
3. Click **Create a tunnel**, then choose **Cloudflared** and click **Next**.
4. Give it a name, for example `drupal`, and click **Save tunnel**.
5. On the "Install and run connectors" page, click the **Docker** tab. You will see a command like this:
   ```
   docker run cloudflare/cloudflared:latest tunnel --no-autoupdate run --token eyJhIjoi...LONG...TEXT
   ```
   Copy **only the long text after `--token `**. That is your token. Keep it secret.
   You don't need to run that command, our `docker-compose.yml` already does it.

### Step 2: Point a domain at your site

1. Click **Next** to go to **Public Hostnames** (or open the tunnel later and use the **Public Hostname** tab).
2. Fill in:
   - **Subdomain:** `www` (or leave it empty to use the bare domain)
   - **Domain:** pick your domain
   - **Service → Type:** `HTTP`
   - **Service → URL:** `drupal:80`  ← exactly this, it is the container name, not localhost
3. Click **Save**.

### Step 3: Add the token to your `.env`

Open `.env` in any text editor (for example `open -e .env` on a Mac) and change these lines:

```dotenv
CLOUDFLARE_TUNNEL_TOKEN=eyJhIjoi...paste-your-token-here
DRUPAL_TRUSTED_HOSTS=localhost,127.0.0.1,www.mysite.com
```

`DRUPAL_TRUSTED_HOSTS` must list every domain the site uses, separated by commas. If a domain is missing, Drupal shows *"The provided host name is not valid for this server"*.

### Step 4: Start the tunnel

```bash
./setup.sh
```

The script sees the token and turns the tunnel on for you by adding `tunnel` to `COMPOSE_PROFILES` in `.env`. Check that it connected:

```bash
docker compose logs cloudflared
```

Look for `Registered tunnel connection`. Then open `https://www.mysite.com` 🎉

To turn the tunnel off again, remove `tunnel` from `COMPOSE_PROFILES` in `.env` and run `docker compose up -d --remove-orphans`.

---

## Part 5: E-mail

One switch in `.env` decides where e-mails go:

| `MAIL_TRANSPORT=` | What happens |
|---|---|
| `mailpit` (default) | Nothing leaves your computer. Every e-mail is caught by Mailpit at http://localhost:8025. Use this while you build and test. |
| `smtp` | E-mails are **really sent** to people's inboxes, using your provider's `SMTP_*` settings. |

### Send real e-mail (step by step)

1. **Get SMTP details from your e-mail provider.** Any provider works, for example Brevo, SendGrid, Mailgun, Amazon SES, Gmail/Google Workspace (use an *App Password*) or your web host's mailbox. Look for "SMTP settings" in their dashboard. You need four things: **host**, **port**, **username** and **password**.

2. **Open `.env`** in a text editor (Mac: `open -e .env`) and fill in the e-mail section:

   ```dotenv
   MAIL_TRANSPORT=smtp

   SMTP_HOST=smtp.your-provider.com
   SMTP_PORT=587
   SMTP_USER=your-smtp-username
   SMTP_PASSWORD=your-smtp-password
   SMTP_TLS=on
   SMTP_STARTTLS=on
   SMTP_FROM=noreply@mysite.com
   ```

   - Port **587** → `SMTP_TLS=on` and `SMTP_STARTTLS=on`
   - Port **465** → `SMTP_TLS=on` and `SMTP_STARTTLS=off`
   - `SMTP_FROM` must be an address or domain your provider has verified.

3. **Apply the change:**

   ```bash
   docker compose up -d
   ```

4. **Check that it picked up the change:**

   ```bash
   docker compose logs drupal | grep Mail:
   ```

   You should see `Mail: sending for real via smtp.your-provider.com:587`.
   If you see `falling back to Mailpit`, then `SMTP_HOST` is empty.

5. **Send yourself a test e-mail.** Replace the address with your real one:

   ```bash
   docker compose exec -u www-data drupal php -r 'var_dump(mail("you@yourmail.com","Test from Drupal","It works!"));'
   ```

   `bool(true)` means the provider accepted it. Check your inbox, and your spam folder too.
   `bool(false)` means something is wrong. Run `docker compose logs drupal` and look for `msmtp` errors, which usually mean a wrong password, port or TLS setting.

6. **In Drupal**, go to **Configuration → System → Basic site settings** and set **Email address** to the same address as `SMTP_FROM`.

### Go back to Mailpit

Set `MAIL_TRANSPORT=mailpit` in `.env` and run `docker compose up -d`. Your `SMTP_*` values can stay where they are; they are ignored in this mode.

> **Getting into inboxes instead of spam:** in your provider's dashboard, verify your domain and add the SPF, DKIM and DMARC DNS records it gives you. If your domain is on Cloudflare, add those records under **DNS** in the Cloudflare dashboard.

---

## Part 6: Look inside the database (optional)

1. In `.env`, set `COMPOSE_PROFILES=tools` (or `tunnel,tools` if you also use the tunnel).
2. Run `docker compose up -d`.
3. Open http://localhost:8091 and log in with:
   - System: `MySQL / MariaDB`
   - Server: `db`
   - Username / Password: `DB_USER` / `DB_PASSWORD` from `.env`
   - Database: `drupal`

---

## Part 7: Backups

**Back up the database** to a file:

```bash
./bin/drush sql:dump --gzip --result-file=/var/www/html/backup-$(date +%F).sql
```

The file lands in `app/` as `backup-YYYY-MM-DD.sql.gz`.

**Restore** a backup:

```bash
gunzip -k app/backup-2026-01-31.sql.gz
./bin/drush sql:drop -y
./bin/drush sql:cli < app/backup-2026-01-31.sql
./bin/drush cr
```

**Uploaded files** (images, documents) live in `app/web/sites/default/files/`. Copy that folder too.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `Cannot connect to the Docker daemon` | Docker Desktop isn't running. Open it, wait, and try again. |
| `port is already allocated` | Another program uses that port. Run `./setup.sh` again (it finds a free port), or set `HTTP_PORT=8090` in `.env` and run `docker compose up -d`. |
| "The provided host name is not valid for this server" | Add the domain to `DRUPAL_TRUSTED_HOSTS` in `.env`, then `docker compose up -d`. |
| Site is slow on Mac | Normal on the first page load after a cache clear. Docker on Mac is a bit slower with many files. |
| Tunnel shows Cloudflare error 502 | In the Cloudflare dashboard, the service URL must be `http://drupal:80`, not `localhost`. Check `docker compose ps` to see that `drupal` is running. |
| E-mails don't arrive | Check `MAIL_TRANSPORT=smtp` in `.env`, then run `docker compose up -d`. Look in `docker compose logs drupal` for `Mail:` and `msmtp` lines. Also check your spam folder. |
| Something is weird | `docker compose logs -f` shows what every service is doing. |

### Start completely from scratch

⚠️ **This deletes your site, its database and its code for good.** Back up first.

```bash
docker compose down -v      # stops everything and deletes the database
rm -rf app .env             # deletes the Drupal code and your settings
./setup.sh                  # fresh install
```

---

## Going to production: checklist

- [ ] Strong random passwords in `.env` (`setup.sh` creates them) and `.env` never committed
- [ ] Your domain added to `DRUPAL_TRUSTED_HOSTS`
- [ ] `MAIL_TRANSPORT=smtp` with a real provider, domain verified (SPF/DKIM/DMARC)
- [ ] Regular database and `files/` backups
- [ ] In `docker/php/php.ini`, set `opcache.validate_timestamps = 0` for speed (then `docker compose up -d --build`; after code changes you'll need `docker compose restart drupal`)
- [ ] Keep `HTTP_BIND=127.0.0.1` so the site is only public through Cloudflare
