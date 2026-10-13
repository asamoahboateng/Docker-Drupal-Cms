# Chapter 12: Going live checklist

Before you share your site's address with real visitors, go through this list. Each item explains **why** it matters and **how** to do it.

---

## Security

### ☐ Strong, unique passwords in `.env`
**Why:** weak database passwords are an easy way in for attackers.
**How:** `setup.sh` already generated random ones. Check that none still say `change-me`:
```bash
grep -i 'change-me' .env && echo "⚠️ Fix these!" || echo "✅ OK"
```

### ☐ `.env` is private
**Why:** it contains every secret: database password, SMTP password, tunnel token.
**How:** never e-mail it, paste it into chats or commit it to Git. It's in `.gitignore`. Check with:
```bash
git check-ignore .env && echo "✅ ignored by git"
```
(Only meaningful if you use Git.)

### ☐ Strong admin password
**Why:** the admin account controls the whole site.
**How:** log in, then go to your **user profile → Edit** and set a long password from a password manager.

### ☐ Site only reachable through Cloudflare
**Why:** with `HTTP_BIND=127.0.0.1`, nobody on your network can bypass Cloudflare and reach the site directly.
**How:** confirm in `.env`:
```dotenv
HTTP_BIND=127.0.0.1
```

### ☐ Trusted hosts list is correct
**Why:** stops attackers abusing your site with fake domain names.
**How:** `DRUPAL_TRUSTED_HOSTS` in `.env` should list **only** the domains you use, e.g.:
```dotenv
DRUPAL_TRUSTED_HOSTS=localhost,127.0.0.1,www.yourdomain.com,yourdomain.com
```

### ☐ Keep Drupal updated
**Why:** security fixes are released regularly.
**How:** check **Reports → Available updates** in Drupal. To update (after a backup!):
```bash
./bin/composer update
./bin/drush updb -y
./bin/drush cr
```
Optionally subscribe to security announcements at https://www.drupal.org/security.

---

## E-mail

### ☐ Real e-mail switched on
**How:** `MAIL_TRANSPORT=smtp` with your provider's details. See [Chapter 7](07-sending-email.md).

### ☐ Site e-mail address set and verified
**How:** **Configuration → System → Basic site settings → Email address** should match an address verified with your provider.

### ☐ SPF, DKIM and DMARC records added
**Why:** without them, your e-mails land in spam.
**How:** [Chapter 7, Step 9](07-sending-email.md#step-9-strongly-recommended-set-up-spf-dkim-and-dmarc).

### ☐ Tested a real password reset
**How:** log out → `/user/password` → check that the e-mail reaches a real inbox (Gmail, Outlook).

---

## Online access

### ☐ Tunnel healthy
**How:** Zero Trust dashboard → **Networks → Tunnels** shows **HEALTHY**, and `docker compose logs cloudflared` shows `Registered tunnel connection`.

### ☐ Site opens on your phone over mobile data
**Why:** proves it's truly public, not just working on your home network.

### ☐ The machine stays on
**Why:** the site is only online while the computer, Docker and the containers are running.
**How:**
- **Docker Desktop → Settings → General → "Start Docker Desktop when you sign in"**: turn on
- Disable sleep for this computer (Mac: **System Settings → Energy** / **Battery → Options → Prevent automatic sleeping…**)
- Containers already restart automatically (`restart: unless-stopped`)

---

## Backups

### ☐ First backup made
**How:** [Chapter 10](10-backups.md).

### ☐ Backup routine decided
**Why:** a backup you never make doesn't help.
**How:** pick a schedule, e.g. every Monday, and **store copies off this computer**.

### ☐ Restore tested once
**Why:** a backup is only useful if restoring it works. Try it once on a quiet day so you know the steps.

---

## Performance (optional)

### ☐ Turn on Drupal's page caching
**How:** **Configuration → Development → Performance**: set "Browser and proxy cache maximum age" (e.g. 15 minutes) and make sure CSS/JS aggregation is ticked.

### ☐ Faster PHP for a live site
**Why:** by default PHP re-checks files for changes every 2 seconds, which is handy while developing. On a live site that rarely changes you can switch this off.
**How:** in `docker/php/php.ini` change:
```ini
opcache.validate_timestamps = 0
```
then rebuild:
```bash
docker compose up -d --build
```
> ⚠️ After this, code changes (new modules, updates) only take effect after `docker compose restart drupal`.

---

## Done? 🎉

Share your address with the world. And keep making backups!

**Next:** [Chapter 13: Reset or remove everything →](13-reset-and-remove.md)
