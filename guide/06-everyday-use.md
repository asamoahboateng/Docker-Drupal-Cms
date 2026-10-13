# Chapter 6: Everyday use

This chapter covers the commands you'll use regularly. **Run all of them from the project folder**:

```bash
cd /Users/kwameboateng/Kalourmade/drupalcms2
```

---

## Starting the site

```bash
docker compose up -d
```

**What it means:**
- `docker compose` uses the `docker-compose.yml` in this folder
- `up` creates and starts all the services
- `-d` means "detached": run in the background and give me my Terminal back

**What you see:**
```
 ✔ Container drupalcms-db-1       Healthy
 ✔ Container drupalcms-mailpit-1  Started
 ✔ Container drupalcms-drupal-1   Started
```

Then open `http://localhost:8080`.

> 💡 **Tip:** containers are set to `restart: unless-stopped`. If they were running when Docker Desktop closed, they **start again by themselves** when Docker Desktop opens.

---

## Stopping the site

```bash
docker compose down
```

**What it does:** stops and removes the containers and their network.

**Is my content safe?** ✅ **Yes.** The database lives in the `db_data` **volume** and your code and uploads live in `app/`. Neither is deleted by `down`.

> ⚠️ **Warning:** **never** add `-v` (as in `docker compose down -v`) unless you really want to **delete the database**. `-v` means "also remove volumes."

---

## Checking what's running

```bash
docker compose ps
```

Each service should show `Up`. If one shows `Exited` or `Restarting`, look at its logs (next section).

---

## Reading the logs

Logs are the messages each container prints: errors, warnings, information. They're your best friend when something is wrong.

All services, following live:
```bash
docker compose logs -f
```

Just one service:
```bash
docker compose logs -f drupal
docker compose logs -f db
docker compose logs -f cloudflared
```

Only the last 50 lines:
```bash
docker compose logs --tail=50 drupal
```

Press **Ctrl + C** to stop watching. That stops only the log view, not the site.

---

## After editing `.env`: apply the changes

Whenever you change `.env` (e-mail settings, ports, Cloudflare token, trusted domains):

```bash
docker compose up -d
```

**Why this and not `restart`?** Settings from `.env` are given to a container **when it's created**. `docker compose up -d` notices which settings changed and **recreates** only those containers. `docker compose restart` restarts the **old** containers with the **old** settings, so your change would be ignored.

---

## Drush: the Drupal command-line tool

The project includes a helper, `./bin/drush`, that runs Drush **inside** the website container for you.

> 💡 Most Drush commands only work **after** you've finished the installer in [Chapter 5](05-install-drupal.md). Before that the database is empty, and Drush prints errors like `Drush was unable to query the database`. That's expected.

| Command | What it does |
|---------|--------------|
| `./bin/drush cr` | **Clear all caches.** Try this first whenever something looks wrong or a change doesn't show up. |
| `./bin/drush uli --uri=http://localhost:8080` | Prints a one-time admin login link |
| `./bin/drush status` | Shows Drupal version, database connection, paths |
| `./bin/drush updb` | Runs database updates (needed after updating modules or core) |
| `./bin/drush pm:list --status=enabled` | Lists enabled modules |
| `./bin/drush en pathauto` | Enables a module |
| `./bin/drush pmu pathauto` | Uninstalls a module |
| `./bin/drush watchdog:show` | Shows recent Drupal log messages (errors etc.) |
| `./bin/drush cex` | Exports site configuration to `app/config/sync` |
| `./bin/drush cim` | Imports configuration from `app/config/sync` |

---

## Composer: adding modules and updating Drupal

`./bin/composer` runs Composer **inside** the website container.

### Add a module (example: Pathauto)

1. Find the module on https://www.drupal.org/project/project_module. The project page shows the command, for example `composer require 'drupal/pathauto:^1.12'`.
2. Download it:
   ```bash
   ./bin/composer require drupal/pathauto
   ```
3. Enable it:
   ```bash
   ./bin/drush en pathauto
   ```
4. Clear the cache:
   ```bash
   ./bin/drush cr
   ```

> 💡 Many add-ons can also be installed from inside Drupal CMS through **Extend → Recommended add-ons**, without the Terminal.

### Update Drupal and all modules

> ⚠️ **Make a backup first**, see [Chapter 10](10-backups.md).

```bash
./bin/composer update
./bin/drush updb -y
./bin/drush cr
```

1. `composer update` downloads newer versions of everything allowed by `composer.json`.
2. `drush updb` applies any database changes the new versions need.
3. `drush cr` clears caches.

---

## Opening a shell inside the website container

Sometimes you want to "step inside" the container and run commands directly:

```bash
docker compose exec -u www-data drupal bash
```

- `exec` runs a command in an already-running container
- `-u www-data` runs it as the web server user, so file ownership stays correct
- `bash` starts a shell

Your prompt changes to something like `www-data@abc123:/var/www/html$`. Inside, `drush` and `composer` work directly. Type `exit` to leave.

---

## Editing your Drupal code

The `app/` folder **is** your Drupal site. Edit files there with any editor and the changes are live immediately.

- Custom modules: `app/web/modules/custom/`
- Custom themes: `app/web/themes/custom/`
- Uploaded files: `app/web/sites/default/files/`

If a change doesn't show up, run `./bin/drush cr`.

---

## Rebuilding the website container

You only need this if you change files in `docker/php/`, such as `php.ini` or the `Dockerfile`:

```bash
docker compose up -d --build
```

`--build` tells Docker to rebuild the image from the `Dockerfile` before starting.

**Next:** [Chapter 7: Sending e-mail →](07-sending-email.md)
