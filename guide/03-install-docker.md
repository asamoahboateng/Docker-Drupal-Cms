# Chapter 3: Install Docker

You only do this **once per computer**. If Docker Desktop is already installed and running, skip to [Step 4: Check that it works](#step-4-check-that-docker-works).

---

## On a Mac

### Step 1: Find out which chip your Mac has
1. Click the **Apple menu ** in the top-left corner of the screen.
2. Click **About This Mac**.
3. Look at the line called **Chip** or **Processor**:
   - **Apple M1 / M2 / M3 / M4…** → you need the **Apple Silicon** version
   - **Intel …** → you need the **Intel** version

**Why:** Docker is built separately for each type of processor, and the wrong one won't run.

### Step 2: Download Docker Desktop
1. Go to **https://www.docker.com/products/docker-desktop/**
2. Click **Download for Mac** and choose **Apple Silicon** or **Intel** from Step 1.
3. A file called `Docker.dmg` downloads.

### Step 3: Install it
1. Double-click `Docker.dmg` in your Downloads folder.
2. A window opens. **Drag the Docker whale icon onto the Applications folder.**
3. Open your **Applications** folder and double-click **Docker**.
4. macOS asks "Are you sure you want to open it?" Click **Open**.
5. Accept the license agreement.
6. If it asks to use **recommended settings**, choose that and enter your Mac password when asked.
7. Signing in to a Docker account is **optional**. You can click **Skip** or **Continue without signing in**.

Wait until you see a **whale icon 🐳 in the menu bar** at the top of the screen. When the whale stops animating, Docker is running.

> 💡 **Tip:** Docker must be **running** whenever you want your website to work. If you restart your Mac, open Docker Desktop again, or turn on *Settings → General → Start Docker Desktop when you sign in to your computer*.

---

## On Windows

Windows needs one extra part called **WSL 2** (Windows Subsystem for Linux). It lets Windows run Linux programs, and this project's scripts are Linux-style.

### Step 1: Install WSL and Ubuntu
1. Click **Start**, type `PowerShell`, right-click **Windows PowerShell** and choose **Run as administrator**.
2. Type this and press **Enter**:
   ```powershell
   wsl --install
   ```
3. **Restart your computer** when it finishes.
4. After the restart an **Ubuntu** window opens by itself. Choose a **username** and **password** for Linux (they can differ from your Windows login). When you type the password, nothing appears on screen. That's normal.

### Step 2: Install Docker Desktop
1. Download **Docker Desktop for Windows** from https://www.docker.com/products/docker-desktop/
2. Run the installer. Make sure **"Use WSL 2 instead of Hyper-V"** is ticked.
3. Restart if asked, then open **Docker Desktop**.
4. In Docker Desktop go to **Settings → Resources → WSL integration**, switch on **Ubuntu**, and click **Apply & restart**.

### Step 3: Always work inside Ubuntu
From now on, run every command in this guide inside the **Ubuntu** app, **not** in PowerShell or Command Prompt.

> 💡 **Tip:** For best speed, keep the project inside the Linux file system, for example `~/projects/drupalcms2`, not under `C:\`. Inside Ubuntu, `explorer.exe .` opens the current folder in Windows Explorer.

---

## On Linux (Ubuntu / Debian)

Follow the official guide at https://docs.docker.com/engine/install/ubuntu/ to install **Docker Engine** and the **Compose plugin**. Then let your user run Docker without `sudo`:

```bash
sudo usermod -aG docker $USER
```

**Log out and log back in** so the change takes effect.

---

## Step 4: Check that Docker works

Open the Terminal (or Ubuntu on Windows) and type:

```bash
docker --version
```

You should see something like:

```
Docker version 28.3.2, build 578ccf6
```

Then:

```bash
docker compose version
```

You should see something like:

```
Docker Compose version v2.39.1
```

And finally, a test run:

```bash
docker run --rm hello-world
```

You should see a message that includes **"Hello from Docker!"**. That means Docker can download images and run containers. ✅

### It didn't work?

| You see | Meaning | Fix |
|---------|---------|-----|
| `command not found: docker` | Docker isn't installed, or the Terminal was opened before installing | Close the Terminal, open a new one, try again. Otherwise reinstall Docker Desktop. |
| `Cannot connect to the Docker daemon` | Docker Desktop isn't running | Open Docker Desktop and wait for the whale to stop animating. |
| `permission denied … docker.sock` (Linux) | Your user isn't in the `docker` group | Run the `usermod` command above, then log out and back in. |

**Next:** [Chapter 4: First-time setup →](04-first-setup.md)
