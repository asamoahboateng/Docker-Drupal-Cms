# Chapter 8: Putting the site online (Cloudflare Tunnel)

Right now only **your computer** can open the site at `http://localhost:8080`. This chapter gives it a **public address** like `https://www.yourdomain.com` that anyone in the world can visit.

---

## How it works (and why it's safe)

Normally, putting a site online from your own computer means opening ports on your home router, dealing with changing IP addresses and setting up HTTPS certificates. A **Cloudflare Tunnel** avoids all of that:

```
Visitor ──https──► Cloudflare ◄──outgoing connection── [cloudflared container] ──► [drupal container]
```

1. The `cloudflared` container makes an **outgoing** connection from your computer to Cloudflare, like your browser does when it opens a website.
2. When someone visits your domain, Cloudflare sends the request **back through that connection** to your Drupal container.
3. Cloudflare handles **HTTPS** (the padlock 🔒) for you, for free.

**No router ports are opened**, and your home IP address stays hidden.

> ⚠️ **Important:** the site is only online while your computer (or server) is **on**, Docker is **running** and the containers are **up**. For a site that must always be available, run this project on an always-on machine or a cloud server.

---

## What you need

1. **A domain name** you own, for example `yourdomain.com`. You can buy one from Cloudflare itself or any registrar (Namecheap, GoDaddy, …).
2. **A free Cloudflare account**: https://dash.cloudflare.com/sign-up
3. **Your domain added to Cloudflare** (Step 1 below).

---

## Step 1: Add your domain to Cloudflare

*Skip this step if your domain already shows in your Cloudflare dashboard, or you bought it from Cloudflare.*

1. Log in at https://dash.cloudflare.com
2. Click **Add a domain** (or **Add site**).
3. Type your domain, e.g. `yourdomain.com`, and continue.
4. Choose the **Free** plan.
5. Cloudflare scans your existing DNS records. Review them and continue.
6. Cloudflare shows you **two nameservers**, e.g. `ada.ns.cloudflare.com` and `bob.ns.cloudflare.com`.
7. Log in to the company where you **bought** the domain, find **Nameservers** (often under "DNS" or "Domain settings"), choose **custom nameservers**, and replace the existing ones with Cloudflare's two.
8. Back in Cloudflare, click **Check nameservers**.

**Why:** nameservers decide who controls your domain's DNS. Pointing them to Cloudflare lets Cloudflare route visitors to your tunnel.

This can take from a few minutes up to 24 hours. Cloudflare e-mails you when your domain is **Active**.

---

## Step 2: Create the tunnel

1. Go to the **Zero Trust** dashboard: https://one.dash.cloudflare.com
   (Or, in the normal Cloudflare dashboard, click **Zero Trust** in the left menu.)
2. The first time, you may be asked to pick a **team name** and a **plan**. Choose the **Free** plan. It may ask for a payment method, but the Free plan isn't charged.
3. In the left menu, click **Networks → Tunnels**.
4. Click **Create a tunnel**.
5. Choose **Cloudflared** as the connector type and click **Next**.
6. Give the tunnel a name, e.g. `drupal-site`, and click **Save tunnel**.

---

## Step 3: Copy your tunnel token

You're now on the **"Install and run connectors"** page.

1. Under "Choose your environment", click **Docker**.
2. You'll see a command like this:
   ```
   docker run cloudflare/cloudflared:latest tunnel --no-autoupdate run --token eyJhIjoiNzY1...very-long-text...In0=
   ```
3. Copy **only the long text after `--token `**. It starts with `eyJ` and is very long. That's your **tunnel token**.

> ⚠️ **Warning:** the token is like a password. Anyone who has it can connect their own computer to your tunnel. Don't share it or post it online.

> 💡 You **don't** need to run that `docker run` command. This project's `docker-compose.yml` already includes the `cloudflared` service; it just needs the token.

Click **Next** at the bottom of the page.

---

## Step 4: Connect your domain to the Drupal container

You're now on the **"Route traffic"** / **"Public Hostnames"** page.

Fill in:

| Field | What to enter | Explanation |
|-------|---------------|-------------|
| **Subdomain** | `www` (or leave **empty** for the bare domain) | `www` → `www.yourdomain.com`; empty → `yourdomain.com` |
| **Domain** | pick `yourdomain.com` from the list | Only domains active in your Cloudflare account appear |
| **Path** | leave empty | |
| **Service → Type** | `HTTP` | The tunnel talks to Drupal over plain HTTP *inside* Docker. Visitors still get HTTPS from Cloudflare. |
| **Service → URL** | `drupal:80` | **Exactly this.** `drupal` is the service name in `docker-compose.yml` and `80` is the port Apache listens on inside the container. |

> ⚠️ **Common mistake:** do **not** enter `localhost:8080`. Inside the `cloudflared` container, `localhost` means the cloudflared container itself, not your computer. Use `drupal:80`.

Click **Save tunnel** (or **Save hostname**).

**Want both `yourdomain.com` and `www.yourdomain.com`?** Open the tunnel again → **Public Hostname** tab → **Add a public hostname**, and add the other one with the same service `HTTP` / `drupal:80`.

---

## Step 5: Put the token and domain in `.env`

Open `.env`:

```bash
open -e .env     # or: nano .env
```

Make two changes:

**1. Paste your token:**
```dotenv
CLOUDFLARE_TUNNEL_TOKEN=eyJhIjoiNzY1...your-whole-token...In0=
```

**2. Add your domain(s) to the trusted hosts list:**
```dotenv
DRUPAL_TRUSTED_HOSTS=localhost,127.0.0.1,www.yourdomain.com,yourdomain.com
```

**Why the trusted hosts list?** As a security measure, Drupal only answers requests for domain names you've approved. Without this, visitors would see *"The provided host name is not valid for this server."* List every address people will use, separated by commas, with no spaces and no `https://`.

Save the file.

---

## Step 6: Start the tunnel

```bash
./setup.sh
```

**What happens:** the script sees your token and adds `tunnel` to the `COMPOSE_PROFILES` line in `.env`, which switches on the `cloudflared` service. Then it starts it.

You'll see a line like:
```
Cloudflare token found, enabled the 'tunnel' profile.
```
and at the end:
```
  Tunnel:   running -> check your public hostname in the Cloudflare dashboard
```

> 💡 **Doing it by hand instead:** set `COMPOSE_PROFILES=tunnel` in `.env` and run `docker compose up -d`.

---

## Step 7: Check the tunnel connected

```bash
docker compose logs cloudflared
```

✅ Look for lines like:
```
cloudflared-1  | INF Registered tunnel connection connIndex=0 ... location=ams01 protocol=quic
cloudflared-1  | INF Registered tunnel connection connIndex=1 ...
```

Also, in the Zero Trust dashboard under **Networks → Tunnels**, your tunnel's status should be **HEALTHY** (green).

---

## Step 8: Visit your site 🎉

Open `https://www.yourdomain.com` in your browser, or try it on your phone using mobile data to be sure it's really public.

You should see your Drupal site with a 🔒 padlock.

---

## Troubleshooting the tunnel

| What you see | Cause | Fix |
|--------------|-------|-----|
| *"The provided host name is not valid for this server"* | Domain missing from `DRUPAL_TRUSTED_HOSTS` | Add it to `.env`, then `docker compose up -d` |
| Cloudflare **Error 502 / Bad gateway** | Tunnel can't reach Drupal | Service URL must be `http://drupal:80`. Check `docker compose ps` shows `drupal` is `Up`. |
| Cloudflare **Error 1033** | Tunnel isn't running | `docker compose ps`: is `cloudflared` listed? If not, check `COMPOSE_PROFILES` includes `tunnel`, then `docker compose up -d`. |
| `cloudflared` logs say `Unauthorized` / `invalid token` | Token copied incompletely | Copy the whole token again (Step 3), paste into `.env`, `docker compose up -d` |
| *"DNS_PROBE_FINISHED_NXDOMAIN"* / site not found | Domain not active on Cloudflare yet, or hostname not saved | Wait for nameservers to update (Step 1); check the Public Hostname exists |
| Site works but looks unstyled or has mixed-content warnings | Old cached pages | `./bin/drush cr` and reload |

---

## Turning the tunnel off

1. In `.env`, remove `tunnel` from `COMPOSE_PROFILES`, e.g. change `COMPOSE_PROFILES=tunnel` to `COMPOSE_PROFILES=`.
2. Run:
   ```bash
   docker compose up -d --remove-orphans
   ```
   `--remove-orphans` stops containers that are no longer switched on.

To turn it back on, put `tunnel` back and run `docker compose up -d`.

**Next:** [Chapter 9: Looking inside the database →](09-database.md)
