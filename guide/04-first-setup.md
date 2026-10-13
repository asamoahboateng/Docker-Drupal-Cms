# Chapter 4: First-time setup

In this chapter you run **one script** that builds everything: it creates your settings file, starts the containers, downloads Drupal CMS and connects it to the database.

**Time needed:** about 10 minutes the first time (mostly waiting for downloads).
**Before you start:** Docker Desktop must be **running**: the whale 🐳 is in your menu bar and not animating.

---

## Step 1: Open the Terminal and go to the project folder

```bash
cd /Users/kwameboateng/Kalourmade/drupalcms2
```

(Or use the drag-and-drop trick from [Chapter 2](02-terminal-basics.md#step-3-get-into-the-project-folder-youll-do-this-a-lot).)

Check you're in the right place:

```bash
ls
```

You should see `setup.sh` in the list.

---

## Step 2: Allow the scripts to run (one time only)

```bash
chmod +x setup.sh bin/*
```

**What this does:** `chmod +x` marks files as "executable", which means "this is a program you may run." Files sometimes lose this mark when they're copied or downloaded. Running it again does no harm.

You won't see any output. No news is good news.

---

## Step 3: Run the setup script

```bash
./setup.sh
```

Now sit back. The script prints its progress in six numbered steps. Here's what each one means.

---

### 1/6 Checking Docker

```
==> 1/6 Checking Docker
Docker is ready.
```

**What's happening:** the script checks three things:
1. Docker is installed
2. Docker Desktop is running
3. `docker compose` is available

**If it stops here**, it tells you exactly which one is missing. Fix it (see [Chapter 3](03-install-docker.md)) and run `./setup.sh` again.

---

### 2/6 Preparing .env

```
==> 2/6 Preparing .env
Created .env with random passwords.
```

**What's happening:**
- If you don't have a `.env` file yet, the script **copies `.env.example` to `.env`**.
- It generates **random, strong passwords** for the database and a random **hash salt**, a secret Drupal uses to protect logins and links.
- It records your computer's **user ID** (`HOST_UID`/`HOST_GID`). That way files Drupal creates in `app/` belong to **you**, and you can edit or delete them normally.
- It checks whether ports **8080** (website) and **8025** (Mailpit) are free. If another program is already using one, it picks the next free number and tells you:
  ```
  Port 8080 is already in use, trying 8081
  ```
- If you've already put a Cloudflare token in `.env`, it switches the tunnel on automatically.
- It creates the empty `app/` folder where Drupal will live.

If `.env` already exists, the script **keeps it** and never overwrites your passwords.

---

### 3/6 Building and starting containers

```
==> 3/6 Building and starting containers (first time takes a few minutes)
...lots of lines...
 Container drupalcms-db-1       Healthy
 Container drupalcms-drupal-1   Started
Waiting for the database....
Containers are up.
```

**What's happening:**
1. **Building the website image.** Docker reads `docker/php/Dockerfile` and builds a box containing PHP 8.3, Apache, Composer, the PHP extensions Drupal needs (images, database, translations, caching) and the e-mail sender `msmtp`. **This is the slowest part the first time**, often 3–5 minutes. Later runs reuse the result and take seconds.
2. **Downloading the other images**: MariaDB (database) and Mailpit (mail catcher).
3. **Creating a private network** so the containers can talk to each other by name. The website reaches the database simply as `db`.
4. **Creating the `db_data` volume**, where your database is stored permanently.
5. **Starting the containers** in the right order: the database first, then the website once the database reports it's **healthy** (ready to accept connections).

You'll see a lot of scrolling text with `#1`, `#2` and so on. That's Docker reporting build progress, and it's normal.

---

### 4/6 Downloading Drupal CMS

```
==> 4/6 Downloading Drupal CMS
Creating a "drupal/cms" project at "/tmp/cms"
  - Installing drupal/core (11.x.x)
  ...hundreds of lines...
  You're all set to get started with Drupal CMS!
Drupal CMS downloaded into ./app
```

**What's happening:** inside the website container, **Composer** downloads Drupal CMS: Drupal core plus all the modules, themes and recipes that make up Drupal CMS. That's a few hundred packages, so it takes **2–5 minutes** depending on your internet speed. The result is copied into your `app/` folder.

It also makes sure **Drush** (the Drupal command-line tool) is installed.

If `app/composer.json` already exists, this step is **skipped**, so re-running the script never re-downloads or overwrites your site.

---

### 5/6 Configuring Drupal

```
==> 5/6 Configuring Drupal
settings.php is wired to .env
```

**What's happening:**
- It creates `app/web/sites/default/settings.php`, Drupal's main settings file.
- It adds a small piece at the bottom of that file that loads `settings.docker.php`. That file reads the **database name, user, password, hash salt and trusted domains from your `.env`**. This is why the Drupal installer won't ask you for database details.
- It creates the folders Drupal needs: `files/` for uploads, `private/` and `config/sync/`.

---

### 6/6 Done

```
==> 6/6 Done

Your Drupal CMS stack is running!

  Website:  http://localhost:8080
  Mailpit:  http://localhost:8025   (all e-mails sent by the site land here)

Next: open http://localhost:8080 in your browser and follow the Drupal CMS installer.
(The database step is already filled in for you.)
```

**Write down the Website address.** If the script changed the port in step 2, it'll be different, for example `http://localhost:8081`. You'll use this address every day.

---

## Step 4: Check everything is running

```bash
docker compose ps
```

You should see something like:

```
NAME                  IMAGE                    SERVICE   STATUS                   PORTS
drupalcms-db-1        mariadb:11.4             db        Up 2 minutes (healthy)   3306/tcp
drupalcms-drupal-1    drupalcms-php:latest     drupal    Up 2 minutes             127.0.0.1:8080->80/tcp
drupalcms-mailpit-1   axllent/mailpit:latest   mailpit   Up 2 minutes (healthy)   127.0.0.1:8025->8025/tcp
```

**How to read it:**
- **STATUS `Up`** means the container is running. ✅
- **`(healthy)`** means the container's self-check passes.
- **PORTS `127.0.0.1:8080->80/tcp`** means door 8080 on your computer leads to door 80 inside the container. `127.0.0.1` means only *your* computer can reach it, which is safer.

You can also see all of this in the **Docker Desktop** app under **Containers → drupalcms**.

---

## Can I run `setup.sh` again?

**Yes, any time.** It's designed to be safe to repeat:
- It keeps your existing `.env` and passwords
- It doesn't re-download Drupal if it's already there
- It doesn't touch your database content

Run it again whenever you're unsure whether everything is set up, or after adding a Cloudflare token.

---

## Something went wrong?

| Message | What to do |
|---------|-----------|
| `Docker is installed but not running` | Open Docker Desktop, wait for the whale to settle, run `./setup.sh` again. |
| `permission denied: ./setup.sh` | Run `chmod +x setup.sh bin/*` (Step 2). |
| `port is already allocated` | Run `./setup.sh` again; it will find a free port. |
| The download in step 4 fails with a network error | Check your internet connection and run `./setup.sh` again. It continues where it can. |
| Anything else | See [Chapter 11: Troubleshooting](11-troubleshooting.md). |

**Next:** [Chapter 5: Install Drupal in your browser →](05-install-drupal.md)
