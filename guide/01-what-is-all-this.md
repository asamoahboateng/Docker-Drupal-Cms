# Chapter 1: What is all this?

Before typing anything, it helps to understand what the pieces are. This chapter has no commands, just explanations. Feel free to come back to it whenever a word confuses you.

---

## The problem Docker solves

A Drupal website needs several programs to work:

- **PHP**: the programming language Drupal is written in
- **A web server (Apache)**: receives visitors' requests and hands them to PHP
- **A database (MariaDB)**: stores your content, users and settings

Installing all of these directly on your computer is fiddly. Versions clash, settings differ between Mac, Windows and Linux, and "it works on my computer" becomes a real problem.

**Docker** solves this by putting each program into its own sealed, pre-configured box. You don't install PHP or MariaDB yourself. Docker downloads ready-made boxes and runs them for you, and they behave the same on every computer.

---

## The words you'll see

### Image
A **template** for a box: a frozen, read-only package containing a program and everything it needs. Think of it like an installer file or a recipe.
*Example: `mariadb:11.4` is an image of the MariaDB database, version 11.4.*

### Container
A **running box** made from an image. If the image is the recipe, the container is the cake. You can start, stop and delete containers. Deleting a container doesn't delete the image, and with this project it doesn't delete your data either (see "Volume" below).

### Docker Desktop
The app you install on your Mac or Windows PC. It runs Docker in the background and gives you a window where you can see your containers.

### Docker Compose
A tool that starts **several containers together** from one description file. Instead of starting the website, database and mail catcher one by one, you type `docker compose up -d` and Compose starts all of them, in the right order, connected to each other.

### `docker-compose.yml`
The description file Compose reads. It lists every service (container), which image it uses, which ports it opens and which settings it gets. It's already written for you.

### Service
One entry in `docker-compose.yml`, which usually becomes one container. This project has these services:

| Service       | Plain-English job |
|---------------|-------------------|
| `drupal`      | The website itself: PHP + Apache, with Composer and Drush |
| `db`          | The database where all content is saved |
| `mailpit`     | A fake mailbox that catches e-mails while you test |
| `cloudflared` | Connects your site to the internet through Cloudflare (optional) |
| `adminer`     | A web page for peeking into the database (optional) |

### Volume
A storage area Docker keeps **outside** the containers, so data survives when a container is deleted or rebuilt. Your database lives in a volume called `db_data`. Stopping or recreating the `db` container doesn't erase your content.

### Bind mount
A folder on **your computer** that is shared with a container. The `app/` folder in this project is shared with the `drupal` container. When Drupal writes a file, you see it in `app/`. When you edit a file in `app/`, Drupal sees the change immediately.

### Port
A numbered "door" on your computer. When you open `http://localhost:8080`, your browser knocks on door 8080, and Docker forwards that to the website container.
- `localhost` means "this computer"
- `8080` is the website, `8025` is Mailpit, `8091` is Adminer

### `.env` file
A plain text file holding **your personal settings and passwords**: database password, ports, e-mail settings, Cloudflare token. `docker-compose.yml` reads its values from here. You'll edit it several times.

> ⚠️ **Warning:** `.env` contains secrets. Never send it to anyone, post it online or commit it to Git. It's already listed in `.gitignore`, so Git ignores it.

### `.env.example`
A **template** for `.env` with safe placeholder values. The setup script copies it to `.env` and fills in random passwords.

### Profile
An optional group of services that only starts when you ask for it. `cloudflared` is in the `tunnel` profile and `adminer` is in the `tools` profile. You turn profiles on with the `COMPOSE_PROFILES` line in `.env`.

### Composer
The tool PHP projects use to download their code and add-ons. In Drupal you use it to add modules: `./bin/composer require drupal/pathauto`.

### Drush
The Drupal command-line tool. It does things like clearing the cache, creating login links and making database backups: `./bin/drush cr`.

### Cloudflare Tunnel
A free service that gives your site a public `https://` address **without** opening any ports on your home router. The `cloudflared` container makes an outgoing connection to Cloudflare, and Cloudflare sends visitors back through it.

### SMTP
The standard way programs send e-mail. To send real e-mail you sign up with an e-mail provider, and it gives you SMTP details: a server address, port, username and password.

### Mailpit
A pretend mail server that **catches** every e-mail instead of delivering it. You read the caught e-mails at `http://localhost:8025`. It's perfect for testing without accidentally e-mailing real people.

---

## How the pieces connect

```
 Your browser ──► localhost:8080 ──► [drupal container] ──► [db container]
                                            │
                                            ├──► e-mail ──► [mailpit]         (MAIL_TRANSPORT=mailpit)
                                            │          └──► your SMTP provider (MAIL_TRANSPORT=smtp)
                                            │
 Internet visitor ──► Cloudflare ──► [cloudflared container] ──► drupal:80
```

---

## The project folder, explained

```
drupalcms2/
├── docker-compose.yml          The list of services. You rarely need to touch it.
├── .env.example                Settings template.
├── .env                        YOUR settings and passwords. Created by setup.sh.
├── setup.sh                    The one-command installer.
├── README.md                   Short reference sheet.
├── guide/                      This guide.
├── bin/
│   ├── drush                   Runs Drush inside the container for you.
│   └── composer                Runs Composer inside the container for you.
├── docker/
│   ├── php/
│   │   ├── Dockerfile          Recipe for the website image (PHP, Apache, extensions).
│   │   ├── php.ini             PHP settings (memory, upload size, …).
│   │   ├── apache-drupal.conf  Web server settings.
│   │   └── entrypoint.sh       Runs at container start; sets up e-mail.
│   └── drupal/
│       └── settings.docker.php Tells Drupal to read database etc. from .env.
└── app/                        YOUR Drupal website code (created by setup.sh).
    ├── composer.json           List of Drupal add-ons installed.
    ├── web/                    The public website folder.
    │   └── sites/default/files/  Uploaded images and documents.
    ├── config/sync/            Exported configuration (optional).
    └── private/                Private files.
```

**Next:** [Chapter 2: Using the Terminal →](02-terminal-basics.md)
