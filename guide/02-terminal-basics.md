# Chapter 2: Using the Terminal

The **Terminal** is a window where you type commands instead of clicking buttons. It looks intimidating, but you only need a handful of commands for this project.

---

## Step 1: Open the Terminal

**On a Mac**
1. Press **Cmd ⌘ + Space** to open Spotlight search.
2. Type `Terminal`.
3. Press **Enter**.

A window opens with a line ending in `%` or `$`. That line is called the **prompt**. It means "I'm waiting for you to type something."

**On Windows**
You'll use **Ubuntu (WSL)**, which [Chapter 3](03-install-docker.md) shows you how to install. After that: press the **Windows key**, type `Ubuntu`, and press **Enter**.

**On Linux**
Press **Ctrl + Alt + T**, or find "Terminal" in your applications.

---

## Step 2: Learn the five commands you need

### `pwd`: "where am I?"
```bash
pwd
```
Prints the folder you're currently in, for example `/Users/yourname`.

### `ls`: "what's in here?"
```bash
ls
```
Lists the files and folders in the current folder.
`ls -la` also shows hidden files, the ones whose names start with a dot, like `.env`.

### `cd`: "go into a folder"
```bash
cd Documents
```
Moves you into the `Documents` folder.

- `cd ..` goes **up** one folder
- `cd ~` goes back to your home folder
- `cd "/path/with spaces/in it"` handles folder names with spaces; use quotes

### `./something`: "run this script from here"
```bash
./setup.sh
```
The `./` means "the file called `setup.sh` in **this** folder."

### `clear`: tidy up the window
```bash
clear
```
Clears the screen. Your commands still ran; you just get a clean view.

---

## Step 3: Get into the project folder (you'll do this a lot)

Every command in this guide must be run **from inside the project folder** (`drupalcms2`). Here's the easiest way to get there:

1. Type `cd ` (the letters c and d, then **one space**). Don't press Enter yet.
2. Open **Finder** (Mac) or your file explorer, find the `drupalcms2` folder, and **drag it into the Terminal window**. The full path appears after `cd `.
3. Press **Enter**.

Check that it worked:

```bash
ls
```

You should see `docker-compose.yml`, `setup.sh`, `README.md` and the other project files. If you do, you're in the right place. ✅

> 💡 **Tip:** On this computer the project lives at `/Users/kwameboateng/Kalourmade/drupalcms2`, so you can also type:
> ```bash
> cd /Users/kwameboateng/Kalourmade/drupalcms2
> ```

---

## Step 4: Useful keyboard tricks

| Keys | What it does |
|------|--------------|
| **↑ (up arrow)** | Shows your previous command, so you don't have to retype it |
| **Tab** | Auto-completes file and folder names; start typing and press Tab |
| **Ctrl + C** | **Stops** whatever is running (for example, when watching logs) |
| **Cmd + V** / **Ctrl + Shift + V** | Paste into the Terminal (Mac / Linux and WSL) |
| **Cmd + K** (Mac) | Clears the screen |

---

## Step 5: Editing text files like `.env`

You'll need to edit the `.env` file a few times. Choose one way:

**Option A: TextEdit on a Mac (easiest)**
```bash
open -e .env
```
TextEdit opens the file. Make your changes, press **Cmd + S** to save, and close the window.

**Option B: VS Code (if installed)**
```bash
code .env
```

**Option C: nano, inside the Terminal (works everywhere)**
```bash
nano .env
```
- Use the arrow keys to move around and type to change text.
- To save: press **Ctrl + O**, then **Enter**.
- To exit: press **Ctrl + X**.

> ⚠️ **Warning:** in `.env`, write `KEY=value` with **no spaces around the `=`**, and don't wrap values in quotes unless a guide tells you to.
> ✅ `SMTP_PORT=587`
> ❌ `SMTP_PORT = 587`

---

## Step 6: Reading error messages

When something goes wrong, the Terminal prints a message. Don't panic:

1. Read the **last few lines**. The real reason is usually there.
2. Look for words like `Error`, `denied`, `not found` or `already allocated`.
3. Search for that phrase in [Chapter 11: Troubleshooting](11-troubleshooting.md).
4. Still stuck? Copy the whole message. It's exactly what someone helping you will need.

**Next:** [Chapter 3: Install Docker →](03-install-docker.md)
