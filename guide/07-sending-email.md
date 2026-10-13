# Chapter 7: Sending e-mail

Your site sends e-mails for password resets, new-account welcomes, contact forms and notifications. This chapter explains the **two modes** and walks you through switching to **real e-mail** step by step.

---

## The two modes

You choose the mode with **one line** in `.env`:

| `MAIL_TRANSPORT=` | What happens to e-mails | Use it when |
|---|---|---|
| `mailpit` *(default)* | **Caught** by Mailpit. Nothing leaves your computer. Read them at `http://localhost:8025`. | Building and testing. No risk of e-mailing real people by accident. |
| `smtp` | **Really sent** through your e-mail provider to real inboxes. | The site is live and real people need the e-mails. |

**How it works behind the scenes:** Drupal hands every e-mail to a small program called **msmtp** inside the website container. Each time the container starts, it reads `MAIL_TRANSPORT` and the `SMTP_*` settings from `.env` and tells msmtp where to deliver: Mailpit, or your provider.

---

## Part A: Testing with Mailpit (already working)

1. Open `http://localhost:8025`.
2. In Drupal, do anything that sends an e-mail, for example request a password reset at `http://localhost:8080/user/password`.
3. The e-mail appears in Mailpit within a second. Click it to see how it looks, including the HTML version and headers.

Nothing to configure. It works out of the box.

---

## Part B: Sending real e-mail

### Step 1: Pick an e-mail provider and get its SMTP details

**What is a provider?** A company whose mail servers send e-mail on your behalf. You can't reliably send e-mail straight from your own computer, because mailboxes like Gmail and Outlook block or spam-folder it. A provider has a good reputation with them.

**Any provider that offers SMTP works**, for example:
- Brevo, SendGrid, Mailgun, Postmark, Amazon SES (transactional e-mail services)
- Google Workspace / Gmail (with an *App Password*)
- Microsoft 365 / Outlook
- The mailbox that came with your web hosting or domain

Sign up, then look in its dashboard for **"SMTP"**, **"SMTP relay"** or **"SMTP credentials"**. Write down these **four things**:

| What | Example | Goes into |
|------|---------|-----------|
| SMTP server / host | `smtp.example-provider.com` | `SMTP_HOST` |
| Port | `587` (most common) or `465` | `SMTP_PORT` |
| Username / login | often your e-mail address or an ID | `SMTP_USER` |
| Password / SMTP key / API key | a long random string | `SMTP_PASSWORD` |

> 💡 **Gmail users:** your normal Gmail password **won't** work. Turn on 2-Step Verification on your Google account, then create an **App Password** at https://myaccount.google.com/apppasswords and use that 16-character password.

### Step 2: Verify your sending address or domain with the provider

Providers only send e-mail **from** addresses or domains they know belong to you. In the provider's dashboard, look for **"Senders"**, **"Domains"** or **"Verified identities"** and:

- verify a single address, like `noreply@yourdomain.com`, **or**
- verify your whole domain (recommended, see Step 8)

If you skip this, the provider will usually **reject** your e-mails.

### Step 3: Open `.env`

From the project folder:

```bash
open -e .env        # Mac (TextEdit)
# or
nano .env           # any system
```

Scroll to the section that starts with `# ---------------- Outgoing e-mail ----------------`.

### Step 4: Fill in the e-mail settings

Change the lines so they look like this, using **your** values from Step 1:

```dotenv
MAIL_TRANSPORT=smtp

SMTP_HOST=smtp.example-provider.com
SMTP_PORT=587
SMTP_USER=your-smtp-username
SMTP_PASSWORD=your-smtp-password
SMTP_TLS=on
SMTP_STARTTLS=on
SMTP_FROM=noreply@yourdomain.com
```

**What each line means:**

| Setting | Meaning |
|---------|---------|
| `MAIL_TRANSPORT=smtp` | The switch: "send for real" instead of "catch in Mailpit" |
| `SMTP_HOST` | Address of your provider's mail server |
| `SMTP_PORT` | Which "door" on that server to use |
| `SMTP_USER` / `SMTP_PASSWORD` | Your login for that server |
| `SMTP_TLS` | Encrypt the connection so nobody can read your password or e-mails on the way. Keep it `on`. |
| `SMTP_STARTTLS` | *How* the encryption starts, which depends on the port (table below) |
| `SMTP_FROM` | The "envelope sender" address. Must be verified with your provider (Step 2). |

**Matching the port and TLS settings:**

| Your provider says | `SMTP_PORT` | `SMTP_TLS` | `SMTP_STARTTLS` |
|--------------------|-------------|------------|-----------------|
| Port 587 / "STARTTLS" / "TLS" | `587` | `on` | `on` |
| Port 465 / "SSL" / "implicit TLS" | `465` | `on` | `off` |

> ⚠️ **Warning:**
> - No spaces around `=`.
> - If your password contains `#` or spaces, ask your provider for a new SMTP key without them. Special characters can confuse the config file.

Save the file.

### Step 5: Apply the change

```bash
docker compose up -d
```

You should see:
```
 ✔ Container drupalcms-drupal-1  Started
```

The website container is **recreated** with your new settings. Your site and content are untouched.

### Step 6: Check the container picked up the change

```bash
docker compose logs drupal | grep Mail:
```

✅ **Good:**
```
drupal-1  | Mail: sending for real via smtp.example-provider.com:587
```

❌ **Still on Mailpit:**
```
drupal-1  | Mail: caught by Mailpit (set MAIL_TRANSPORT=smtp in .env to send for real)
```
→ `MAIL_TRANSPORT` isn't exactly `smtp`. Check spelling, then run `docker compose up -d` again.

❌ **Host missing:**
```
drupal-1  | WARNING: MAIL_TRANSPORT=smtp but SMTP_HOST is empty in .env, falling back to Mailpit.
```
→ Fill in `SMTP_HOST`, then run `docker compose up -d` again.

> 💡 If you've restarted several times you'll see several `Mail:` lines. The **last** one is the current setting.

### Step 7: Send yourself a test e-mail

Replace `you@yourmail.com` with **your real address**:

```bash
docker compose exec -u www-data drupal php -r 'var_dump(mail("you@yourmail.com","Test from Drupal","If you can read this, real e-mail works!"));'
```

**Reading the result:**
- `bool(true)` → your provider **accepted** the e-mail. Check your inbox, and your **spam folder** too. It can take a minute.
- `bool(false)` → it failed. See the logs for the reason:
  ```bash
  docker compose logs --tail=30 drupal
  ```
  Look for lines starting with `msmtp:`:

  | msmtp says | Usually means |
  |------------|---------------|
  | `authentication failed` | Wrong `SMTP_USER` or `SMTP_PASSWORD` |
  | `cannot connect` / `timed out` | Wrong `SMTP_HOST` or `SMTP_PORT`, or your network blocks that port |
  | `TLS handshake failed` / `server does not support STARTTLS` | Wrong TLS combination; check the port table in Step 4 |
  | `sender address rejected` / `not verified` | `SMTP_FROM` isn't verified with your provider (Step 2) |

### Step 8: Tell Drupal which address to send from

1. In Drupal go to **Configuration → System → Basic site settings** (`/admin/config/system/site-information`).
2. Set **Email address** to the same address as `SMTP_FROM` (or another verified one).
3. Click **Save configuration**.

**Why:** Drupal puts this address in the "From:" line of every e-mail. If it isn't verified with your provider, e-mails may be rejected or land in spam.

Then test from Drupal itself: log out, request a password reset at `/user/password`, and check your real inbox.

### Step 9 (strongly recommended): Set up SPF, DKIM and DMARC

These are DNS records that prove to Gmail, Outlook and others that your provider is **allowed** to send e-mail for your domain. Without them, your e-mails often go to **spam**.

1. In your provider's dashboard, open **domain verification / authentication**. It lists a few DNS records to add (usually `TXT` and `CNAME` records).
2. Log in to wherever your domain's DNS is managed. If you use Cloudflare (see [Chapter 8](08-cloudflare-tunnel.md)), that's **Cloudflare dashboard → your domain → DNS → Records**.
3. Add each record **exactly** as shown by the provider.
4. Go back to the provider and click **Verify**. DNS changes can take from a few minutes up to 24 hours.

> 💡 For e-mail records in Cloudflare, leave the proxy status as **DNS only** (grey cloud) when a record type allows it.

---

## Switching back to Mailpit

Change one line in `.env`:

```dotenv
MAIL_TRANSPORT=mailpit
```

Then:

```bash
docker compose up -d
```

Your `SMTP_*` values can **stay** in `.env`. They're ignored in Mailpit mode, so switching back to `smtp` later is a one-line change.

**Next:** [Chapter 8: Putting the site online →](08-cloudflare-tunnel.md)
