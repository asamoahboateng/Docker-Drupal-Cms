# Chapter 9: Looking inside the database (optional)

Most of the time you'll never need to look inside the database. Drupal manages it for you. But for curiosity or troubleshooting, the project includes **Adminer**, a simple web page for browsing database tables.

It's **off by default**. Turn it on only when you need it.

---

## Step 1: Switch on the `tools` profile

Open `.env` and find the `COMPOSE_PROFILES` line. Add `tools`:

- If it was empty: `COMPOSE_PROFILES=tools`
- If it already had `tunnel`: `COMPOSE_PROFILES=tunnel,tools` (comma, no space)

Save the file.

**Why a profile?** Profiles keep optional services from starting unless you ask for them. Adminer is a powerful tool, so it shouldn't run all the time.

---

## Step 2: Start it

```bash
docker compose up -d
```

You'll see `Container drupalcms-adminer-1 Started`.

---

## Step 3: Find your database password

The database username and password are in your `.env`. Show them with:

```bash
grep '^DB_' .env
```

You'll see something like:

```
DB_NAME=drupal
DB_USER=drupal
DB_PASSWORD=Xk29fLmQ...
DB_ROOT_PASSWORD=...
```

---

## Step 4: Log in to Adminer

Open **http://localhost:8091** and fill in:

| Field | Value |
|-------|-------|
| System | **MySQL / MariaDB** |
| Server | `db` |
| Username | the `DB_USER` value (usually `drupal`) |
| Password | the `DB_PASSWORD` value |
| Database | the `DB_NAME` value (usually `drupal`) |

Click **Login**.

**Why is the server `db`?** Adminer runs in its own container. Inside Docker's private network, the database container is reachable by its service name, `db`.

---

## Step 5: Look around (carefully)

You'll see a long list of tables. Some interesting ones:
- `users_field_data`: user accounts
- `node_field_data`: your content (pages, articles)
- `watchdog`: Drupal's log messages

> ⚠️ **Warning:** editing or deleting data directly here can **break your site**. Look, don't touch, unless you know exactly what you're doing, and always make a backup first ([Chapter 10](10-backups.md)).

---

## Step 6: Turn Adminer off again

Remove `tools` from `COMPOSE_PROFILES` in `.env`, then:

```bash
docker compose up -d --remove-orphans
```

---

## Alternative: the database command line

Without Adminer, you can open a database prompt with Drush:

```bash
./bin/drush sql:cli
```

You'll get a `MariaDB [drupal]>` prompt where you can type SQL like `SHOW TABLES;`. Type `exit` to leave.

**Next:** [Chapter 10: Backups and restoring →](10-backups.md)
