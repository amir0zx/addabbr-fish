# addabbr — Ultra-Powerful Fish Shell Abbreviation Tool

`addabbr` is a **Fish shell function** that allows you to quickly create abbreviations (shortcuts) for your **last executed command**. Unlike typical Fish abbreviations, `addabbr` is:

- Fully **persistent** across all sessions.
- Handles **timestamps, special characters, and quotes** automatically.
- Detects and avoids **duplicate shortcuts**.
- Works **immediately** in your current session.
- Compatible with **any Fish config location**.

---

## Features

### 🔹 Key Features

- Add an abbreviation for the **last command** without typing it manually.
- Automatically escapes special characters and quotes.
- Prevents duplicate shortcuts and prompts before overwriting.
- Fully **persistent** using Fish’s `funcsave` system.
- Lightweight and simple — works out-of-the-box on Fish 4.x+.

### 🔹 Why `addabbr`?

Fish has abbreviations (`abbr`) but they normally require manual typing, do not persist without `funcsave`, and may break with commands containing quotes or timestamps. `addabbr` solves all these problems with a single, safe function.

---

## Installation

### Via `curl`

You can install `addabbr` with a single command:

```bash
curl -sSL https://raw.githubusercontent.com/<username>/addabbr/main/install.sh](https://raw.githubusercontent.com/amir0zx/addabbr-fish/refs/heads/main/addabbr-installer.sh | bash
