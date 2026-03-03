# Morphe CLI Helper

> Lightweight helper script for running **Morphe CLI** on Windows 11.

This project simplifies the setup and usage of Morphe CLI by automating dependency handling and providing a more convenient command-line workflow.

---

## ✨ Features

- Automatic download of required components
- Simple interactive menu (press **1–4** to select actions)
- Batch/Automatic mode support (maintainer.cmd)

---

## 📦 Requirements

Before using this tool, install:

- **Azul Zulu JRE 25 (x64)**  
  https://www.azul.com/downloads/?version=java-25-lts&os=windows&architecture=x86-64-bit&package=jre#zulu

After installation, ensure `java` is accessible from your system `PATH`.

---

## 🚀 Installation

1. Download `morphe.cmd`
2. Create a folder (e.g., `Morphe`)
3. Place `morphe.cmd` inside that folder
4. Run `morphe.cmd`
5. (Optional) Download `maintainer.cmd` and place it there too.

Required files will be downloaded automatically on first launch.

---

## 🛠 Usage

### Option 1 — Interactive Mode (morphe.cmd)
Run the script and press:
- `1` Patch a supported apk/apkm
- `2` List all current supported patches
- `3` Cleanup to fix any errors
- `4` Exit batch

to select the desired action.

### Option 2 — Batch/Automatic Mode (maintainer.cmd)
Run the script and wait until it's done.

---

## 📜 Third-Party Software

This project bundles the following third-party component:

### 7-Zip Zstandard Edition (7-Zip-zstd)  
Repository: https://github.com/mcmilk/7-Zip-zstd  

- Licensed under **GNU LGPL v2.1** and other applicable licenses  
- Copyright (c) Igor Pavlov and contributors  
- Distributed in unmodified form
