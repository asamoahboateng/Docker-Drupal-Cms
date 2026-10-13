# Chapter 5: Install Drupal in your browser

The code is downloaded and the database is ready, but the database is still **empty**. In this chapter the Drupal CMS installer creates your site's tables, your admin account and the features you choose.

---

## Step 1: Open the website

Open your web browser (Chrome, Safari, Firefox, Edge) and go to the **Website** address that `setup.sh` printed, usually:

```
http://localhost:8080
```

**What you should see:** the Drupal CMS installer. Its first screen asks you to **give your site a name**.

> 💡 **Why didn't it ask for database details?** `setup.sh` already connected Drupal to the database through `settings.docker.php` and your `.env`, so the installer skips that step.

---

## Step 2: Choose your features

Drupal CMS asks what kind of site you're building and which features you want, for example blog, events, forms, search or SEO tools. Tick what you need.

> 💡 **Tip:** don't worry about choosing perfectly. You can add more features later from inside Drupal under **Extend → Recipes** (or **Recommended add-ons** on the dashboard).

Click **Next**.

---

## Step 3: Name your site

Type your site's name, for example *Kalourmade*. It appears in the browser tab and in e-mails. You can change it later.

---

## Step 4: Create your admin account

You'll be asked for:

- **Email address**: use a real one. Password-reset e-mails go here.
- **Password**: choose a strong one and **save it in a password manager**.

This account is the **administrator**. It can change everything on the site.

> ⚠️ **Warning:** if you plan to put the site online, never use simple passwords like `admin` or `123456`.

Click the button to **finish / install**.

---

## Step 5: Wait for the installation

A progress bar appears while Drupal creates hundreds of database tables and applies your chosen recipes. This takes **1–5 minutes**. **Don't close the browser tab** while it runs.

---

## Step 6: You're in! 🎉

When it finishes you land on your new site's **dashboard**, already logged in as the administrator.

Try these to get familiar:
- **Content → Add content** to create your first page
- **Appearance** to see your theme
- **Configuration → System → Basic site settings** to change the site name and the site's e-mail address

---

## Step 7: Log out and back in (practice)

1. Click your username (top right) and choose **Log out**.
2. Go to `http://localhost:8080/user/login`.
3. Log in with the e-mail and password from Step 4.

---

## Forgot your password? Use a one-time login link

From the project folder in the Terminal:

```bash
./bin/drush uli
```

**What this does:** `uli` stands for "user login". Drush prints a special link that logs you in as the administrator once:

```
http://default/user/reset/1/1730000000/AbCdEf.../login
```

The link says `http://default`. **Replace `http://default` with your website address**, so it becomes `http://localhost:8080/user/reset/1/…`, and open it in your browser. You'll be logged in and can set a new password.

> 💡 **Tip:** to get a ready-to-click link, tell Drush your address:
> ```bash
> ./bin/drush uli --uri=http://localhost:8080
> ```

---

## Test that e-mails work

1. Log out.
2. Go to `http://localhost:8080/user/password` and enter your admin e-mail.
3. Open **Mailpit** at `http://localhost:8025`.
4. The password-reset e-mail is there. 📬

This proves Drupal can send e-mail. Right now it's caught by Mailpit so nothing reaches real inboxes. [Chapter 7](07-sending-email.md) shows how to send for real.

**Next:** [Chapter 6: Everyday use →](06-everyday-use.md)
