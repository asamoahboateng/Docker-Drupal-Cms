# The Beginner's Guide to Your Drupal CMS Docker Project

Welcome! This guide is for you if you have **never used Docker before**, aren't comfortable with the Terminal yet, and just want your Drupal website running, online, and sending e-mails.

Every chapter tells you:

- **What** you are about to do
- **Why** you are doing it
- **Exactly what to type or click**
- **What you should see** when it worked
- **What to do if it didn't**

Take your time. Read each chapter from top to bottom the first time. You can't break anything that can't be fixed.

---

## Chapters

Read them in this order the first time:

| #  | Chapter | What you'll learn |
|----|---------|-------------------|
| 1  | [What is all this?](01-what-is-all-this.md) | Docker, containers and the other words you'll see, in plain English |
| 2  | [Using the Terminal](02-terminal-basics.md) | How to open the Terminal and type commands without fear |
| 3  | [Install Docker](03-install-docker.md) | Getting Docker Desktop onto your computer |
| 4  | [First-time setup](04-first-setup.md) | Running `setup.sh` and understanding what it does |
| 5  | [Install Drupal in your browser](05-install-drupal.md) | Finishing the Drupal CMS installer and logging in |
| 6  | [Everyday use](06-everyday-use.md) | Starting, stopping, logs, Drush, Composer, editing `.env` |
| 7  | [Sending e-mail](07-sending-email.md) | Mailpit for testing, and real e-mail through an SMTP provider |
| 8  | [Putting the site online (Cloudflare Tunnel)](08-cloudflare-tunnel.md) | Getting a real `https://` address for your site |
| 9  | [Looking inside the database](09-database.md) | Using Adminer (optional) |
| 10 | [Backups and restoring](10-backups.md) | Keeping your work safe |
| 11 | [Troubleshooting](11-troubleshooting.md) | Common problems and how to fix them |
| 12 | [Going live checklist](12-going-live.md) | Things to check before real visitors arrive |
| 13 | [Reset or remove everything](13-reset-and-remove.md) | Starting over, or cleaning up completely |

---

## The short version (for later)

Once you've done everything once, this is all you'll need day to day:

```bash
cd /path/to/drupalcms2      # go to the project folder
docker compose up -d        # start the site
docker compose down         # stop the site
./bin/drush cr              # clear Drupal's cache
```

---

## How to read the boxes in this guide

```bash
this is a command
```
→ Type this into the Terminal, or copy and paste it, then press **Enter**.

```
this is example output
```
→ This is what the computer prints back. Yours may differ a little, and that's fine.

> 💡 **Tip:** helpful extra information.

> ⚠️ **Warning:** read this carefully, it can save you from losing work.
