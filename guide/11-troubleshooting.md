# Chapter 11: Troubleshooting

Something's not working? Don't worry. Almost every problem has a simple fix. Work through this chapter from the top.

---

## First: the three-step check

Most problems are found with these three commands. Run them from the project folder.

**1. Is Docker running?**
```bash
docker info > /dev/null && echo "Docker OK"
```
No `Docker OK`? → Open Docker Desktop and wait for the whale 🐳 to settle.

**2. Are the containers up?**
```bash
docker compose ps
```
Every service should say `Up`. Missing or `Exited`? → `docker compose up -d`

**3. What do the logs say?**
```bash
docker compose logs --tail=50
```
Look for lines containing `error`, `fatal`, `denied` or `failed`.

Also try clearing Drupal's cache. It fixes a surprising number of problems:
```bash
./bin/drush cr
```

---

## Problems starting

### "Cannot connect to the Docker daemon"
**Why:** Docker Desktop isn't running.
**Fix:** open Docker Desktop, wait until it's ready, then try again.

### "port is already allocated" / "address already in use"
**Why:** another program on your computer already uses that port (8080, 8025 or 8091).
**Fix (easy):** run `./setup.sh`. It finds a free port automatically and tells you the new address.
**Fix (manual):** in `.env` change, for example, `HTTP_PORT=8080` to `HTTP_PORT=8090`, then run `docker compose up -d` and use `http://localhost:8090`.

**Which program is using the port?** (Mac/Linux)
```bash
lsof -i :8080
```

### "permission denied" when running `./setup.sh` or `./bin/drush`
**Why:** the files lost their "executable" mark.
**Fix:**
```bash
chmod +x setup.sh bin/*
```

### "Set DB_PASSWORD in .env" (or another required variable)
**Why:** `.env` is missing or a required line is empty.
**Fix:** run `./setup.sh`. It creates `.env` with the required values if it's missing. If `.env` exists, open it and make sure `DB_PASSWORD`, `DB_ROOT_PASSWORD` and `DRUPAL_HASH_SALT` all have values.

### "no configuration file provided: not found"
**Why:** you're not in the project folder.
**Fix:** `cd /Users/kwameboateng/Kalourmade/drupalcms2` and try again.

### The `db` container keeps restarting
Check its logs:
```bash
docker compose logs db
```
If you see `Access denied for user`, you probably changed `DB_PASSWORD` in `.env` **after** the database was first created. MariaDB only uses the password on its **very first** start. Either put the old password back, or, on a brand-new site with no content you care about, reset the database (see [Chapter 13](13-reset-and-remove.md)).

---

## Problems in the browser

### "This site can't be reached" / "connection refused" at localhost
- Is the `drupal` container `Up`? (`docker compose ps`)
- Are you using the right port? Check `HTTP_PORT` in `.env`:
  ```bash
  grep HTTP_PORT .env
  ```
- Wait 10 seconds after starting; Apache needs a moment.

### "The provided host name is not valid for this server"
**Why:** you're visiting a domain that isn't in Drupal's trusted list.
**Fix:** add it to `DRUPAL_TRUSTED_HOSTS` in `.env` (comma separated, no `https://`), then:
```bash
docker compose up -d
```

### "The website encountered an unexpected error"
Find the real error:
```bash
./bin/drush watchdog:show --count=20
```
or
```bash
docker compose logs --tail=50 drupal
```
Then try:
```bash
./bin/drush cr
./bin/drush updb -y
```

### White screen / page looks broken or unstyled
```bash
./bin/drush cr
```
Then force-reload the page: **Cmd + Shift + R** (Mac) or **Ctrl + Shift + R** (Windows/Linux).

### "Access denied" / locked out of admin
Get a one-time login link:
```bash
./bin/drush uli --uri=http://localhost:8080
```

### Too many failed logins: "There have been more than 5 failed login attempts"
```bash
./bin/drush sql:query "TRUNCATE flood;"
```

### Site is slow
- The **first** page after a cache clear is always slow, because Drupal rebuilds its caches.
- Docker on Mac is a little slower with large numbers of files. That's normal.
- Give Docker more resources in **Docker Desktop → Settings → Resources** (for example 4 CPUs, 4–8 GB memory).

---

## E-mail problems

See [Chapter 7, Step 6 and Step 7](07-sending-email.md#step-6-check-the-container-picked-up-the-change) for a detailed walkthrough. Quick checks:

```bash
grep '^MAIL_TRANSPORT' .env            # should be smtp for real e-mail
docker compose logs drupal | grep Mail: # last line shows the active mode
docker compose logs drupal | grep msmtp # errors from the mail sender
```

- Changed `.env` but nothing happened? → you need `docker compose up -d`, **not** `restart`.
- E-mails arrive in spam? → set up SPF/DKIM/DMARC ([Chapter 7, Step 9](07-sending-email.md#step-9-strongly-recommended-set-up-spf-dkim-and-dmarc)).

---

## Cloudflare Tunnel problems

See the troubleshooting table in [Chapter 8](08-cloudflare-tunnel.md#troubleshooting-the-tunnel). Quick checks:

```bash
docker compose ps cloudflared     # is it running?
docker compose logs cloudflared   # look for "Registered tunnel connection"
grep COMPOSE_PROFILES .env         # must include "tunnel"
```

---

## Composer problems

### "Your requirements could not be resolved to an installable set of packages"
**Why:** the module version you asked for doesn't work with your Drupal version.
**Fix:** check the module's page on drupal.org for a compatible version, or try:
```bash
./bin/composer require drupal/modulename -W
```
`-W` allows Composer to update related packages too.

### Composer runs out of memory
Unlikely, because memory is set to unlimited in the container. If it happens anyway, give Docker more memory in **Docker Desktop → Settings → Resources**.

---

## Still stuck?

1. Collect the details:
   ```bash
   docker compose ps
   docker compose logs --tail=100 > logs.txt
   ./bin/drush status
   ```
2. Note **exactly** what you did and what you expected.
3. Ask for help in the Drupal community (https://www.drupal.org/community, or Drupal Slack at https://www.drupal.org/slack) with that information.

> ⚠️ Before sharing `logs.txt` or any output, **remove passwords and your Cloudflare token**.

**Next:** [Chapter 12: Going live checklist →](12-going-live.md)
