# Chapter 13: Reset or remove everything

Sometimes you want a clean slate, for example after experimenting, or when you no longer need the project. This chapter goes from the **gentlest** option to the **most destructive**.

> ⚠️ **Read each warning carefully.** Options 2–4 permanently delete things. Make a backup first ([Chapter 10](10-backups.md)) if there's anything you might want later.

---

## Option 1: Just stop it (nothing is deleted)

```bash
docker compose down
```

Containers stop and disappear, but your **database, code, uploads and settings all stay**. Run `docker compose up -d` and everything is back exactly as it was.

Use this when you're done for the day, or want to free up computer resources.

---

## Option 2: Reinstall Drupal but keep the code

**Deletes:** the database (all content, users, settings).
**Keeps:** the code in `app/`, uploads, `.env`.

Use this when you want to run the Drupal CMS installer again from scratch.

```bash
docker compose down -v
```
`-v` also deletes **volumes**, which means the database.

```bash
rm -rf app/web/sites/default/files/*
```
Removes uploaded files that belonged to the old site (optional but tidy).

```bash
./setup.sh
```
Creates a new empty database and starts everything.

Then open `http://localhost:8080` and go through the installer again ([Chapter 5](05-install-drupal.md)).

---

## Option 3: Start completely from scratch

**Deletes:** the database, all Drupal code and uploads, and your `.env` (passwords, e-mail and Cloudflare settings).
**Keeps:** the Docker setup files (`docker-compose.yml`, `setup.sh`, `docker/`, this guide).

> ⚠️ Copy your `CLOUDFLARE_TUNNEL_TOKEN` and `SMTP_*` values somewhere first if you want to reuse them.

```bash
docker compose --profile tunnel --profile tools down -v --remove-orphans
```
Stops **every** service, including optional ones, and deletes the database.

```bash
rm -rf app .env
```
Deletes the Drupal code and your settings file.

> ⚠️ `rm -rf` deletes immediately. There is **no** Trash/Recycle Bin. Double-check you're in the project folder (`pwd`) before running it.

```bash
./setup.sh
```
A brand-new install, exactly like the first time ([Chapter 4](04-first-setup.md)).

---

## Option 4: Remove the project from your computer entirely

**1. Stop and delete everything Docker created for this project** (containers, database volume, network, the built image):
```bash
docker compose --profile tunnel --profile tools down -v --remove-orphans --rmi local
```
`--rmi local` also deletes the website image that was built for this project.

**2. Delete the project folder:**
```bash
cd ..
rm -rf drupalcms2
```

**3. (Optional) Free up space used by downloaded images** (MariaDB, Mailpit and others):
```bash
docker image prune -a
```
Docker asks for confirmation. This removes **all** images not used by any container, including other projects' images. They'll simply be re-downloaded when needed.

**4. (Optional) Delete the Cloudflare tunnel:**
Zero Trust dashboard → **Networks → Tunnels** → your tunnel → **Delete**. Also remove its public hostname / DNS record if one stays behind.

**5. (Optional) Uninstall Docker Desktop:**
- **Mac:** open Docker Desktop → 🐞 **Troubleshoot** → **Uninstall**, then drag Docker from Applications to the Trash.
- **Windows:** **Settings → Apps → Docker Desktop → Uninstall**.

---

## Quick reference

| I want to… | Command | Deletes data? |
|------------|---------|---------------|
| Pause for now | `docker compose down` | ❌ No |
| Fresh Drupal install, keep code | `docker compose down -v` then `./setup.sh` | ⚠️ Database |
| Start over completely | `docker compose down -v`, `rm -rf app .env`, `./setup.sh` | ⚠️ Everything |
| Remove project entirely | `docker compose down -v --rmi local`, delete folder | ⚠️ Everything |

---

**🎓 That's the end of the guide!** Go back to the [guide index](README.md) any time you need a refresher.
