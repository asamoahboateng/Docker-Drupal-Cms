# Chapter 10: Backups and restoring

A backup is a copy of your site you can go back to if something goes wrong: a bad update, an accidental deletion, a broken computer.

**Make a backup:**
- before updating Drupal or modules
- before big changes
- regularly, for example weekly, once the site is live

---

## What needs backing up?

Your site lives in **three places**:

| What | Where | Contains |
|------|-------|----------|
| **Database** | Docker volume `db_data` | All content, users, settings, menus |
| **Uploaded files** | `app/web/sites/default/files/` | Images, PDFs and documents people uploaded |
| **Your settings** | `.env` | Passwords, e-mail and Cloudflare settings |

The Drupal **code** (`app/`) can be re-downloaded with Composer, but backing up the whole `app/` folder is simple and safe too.

---

## Step 1: Back up the database

From the project folder:

```bash
./bin/drush sql:dump --gzip --result-file=/var/www/html/backup-$(date +%F).sql
```

**What each part means:**
- `sql:dump`: export the whole database as a text file of SQL commands
- `--gzip`: compress it, which makes it much smaller
- `--result-file=/var/www/html/…`: where to save it. `/var/www/html` *inside* the container is your `app/` folder on your computer.
- `$(date +%F)`: replaced automatically with today's date, e.g. `2026-10-12`

**What you see:**
```
 [success] Database dump saved to /var/www/html/backup-2026-10-12.sql.gz
```

The file is now on your computer at **`app/backup-2026-10-12.sql.gz`**.

---

## Step 2: Back up uploaded files

Create a compressed archive of the `files` folder:

```bash
tar -czf files-backup-$(date +%F).tar.gz -C app/web/sites/default files
```

- `tar -czf` creates (`c`) a gzip-compressed (`z`) archive file (`f`)
- `-C app/web/sites/default files` archives the `files` folder from that location

You now have `files-backup-2026-10-12.tar.gz` in the project folder.

---

## Step 3: Keep a copy of `.env`

```bash
cp .env env-backup-$(date +%F).txt
```

> ⚠️ This file contains passwords. Store it somewhere private.

---

## Step 4: Move your backups somewhere safe

A backup on the same computer won't help if that computer dies. **Copy the backup files** to:
- an external drive, **and/or**
- private cloud storage (iCloud Drive, Google Drive, Dropbox, OneDrive)

Then delete the copies from the project folder if you like, so they don't pile up.

---

## Restoring a backup

> ⚠️ **Warning:** restoring **replaces** your current database with the backup. Anything created after the backup was made will be lost. If unsure, make a fresh backup of the current state first (Step 1).

### Restore the database

Say your backup is `app/backup-2026-10-12.sql.gz`.

**1. Unzip it** (keeps the original `.gz` too):
```bash
gunzip -k app/backup-2026-10-12.sql.gz
```
You now also have `app/backup-2026-10-12.sql`.

**2. Empty the current database:**
```bash
./bin/drush sql:drop -y
```
`-y` answers "yes" to the confirmation automatically.

**3. Load the backup:**
```bash
./bin/drush sql:cli < app/backup-2026-10-12.sql
```
The `<` feeds the file into the database. This can take a minute for big sites. You may see a warning that it's "slow to pass large amounts of data via stdin". That's fine.

**4. Clear caches:**
```bash
./bin/drush cr
```

Reload your site. It's back to how it was at backup time. ✅

**5. Tidy up** the unzipped file:
```bash
rm app/backup-2026-10-12.sql
```

### Restore uploaded files

```bash
tar -xzf files-backup-2026-10-12.tar.gz -C app/web/sites/default
```

`-x` extracts. This puts the `files` folder back where it belongs, overwriting files with the same names.

---

## Moving the site to another computer

1. On the old computer, make all three backups (database, files, `.env`) and copy the `app/` folder's `composer.json` and `composer.lock`. Or simply copy the entire project folder **after** making the database backup.
2. On the new computer, install Docker ([Chapter 3](03-install-docker.md)), copy the project folder over, including `.env`, and run `./setup.sh`.
3. Restore the database as shown above.
4. Restore the uploaded files as shown above.

**Next:** [Chapter 11: Troubleshooting →](11-troubleshooting.md)
