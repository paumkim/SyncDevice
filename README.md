# SyncDevice — AutoSync

AutoSync is a smart, automated tool that copies your photos, videos, and documents back and forth between your Windows PC and your Android phone. It uses ADB to make transfers super fast and secure.

---

## 🚀 Key Features

* **Smart Sync:** It constantly watches your PC (`C:\SyncDevice`) and your phone (`/sdcard/Download/SyncDevice`). It only copies files that are new or updated.
* **Auto-Sorter:** It automatically pulls loose photos and videos from your phone's camera folder and sorts them neatly into `Year-Month` folders on your PC.
* **Super Fast Transfers:** It streams data directly through memory, skipping normal Windows speed limits to move thousands of files quickly.
* **Live Progress Bars:** Clean, easy-to-read loading bars show you exactly what is happening for Images, Videos, Documents, and other files.
* **Safe Stop:** A special button lets you cancel the sync safely without breaking your files or freezing your connection.

---

## ⚙️ What You Need

1. **A Windows PC** (Windows 10 or 11 is best so the progress bars look right).
2. **An Android Phone** with **USB Debugging** turned on in your Developer Options.
3. **ADB (Android Debug Bridge)** installed and added to your Windows PATH.

---

## 📖 User Guide

### 1. First-Time Setup
1. Plug your Android phone into your PC with a USB cable. Make sure the phone is set to "File Transfer" (MTP) and allow USB Debugging if a message pops up on your screen.
2. Run the `SyncDevice.bat` script.
3. The tool will automatically create your workspace at `C:\SyncDevice`, make your shortcuts, set up your command line, and start running in the background.

### 2. How to Sync Files
Once the tool builds the `C:\SyncDevice` folder, you will see folders for `Image`, `Video`, and `Document`. 
* **To send to your phone:** Drop your files into the `From_PC` folder inside any category. The tool will automatically see them and send them to your phone.
* **To save to your PC:** Just take photos or save files on your phone. The tool will automatically pull them into the matching `From_Phone` folder on your PC.

### 3. How to Stop Safely
> **⚠️ WARNING:** **Do not click the "X" button to close the black console window!** Doing this will leave ADB running in the background, which can cause bugs the next time you plug your phone in.

Instead, go to your `C:\SyncDevice` folder and double-click the **Safe Stop AutoSync** shortcut. This sends a safe shutdown signal. It will finish whatever file it is currently working on, safely disconnect your phone, and close the window for you.

### 4. Command Line (CLI) For Power Users
If you like using the command line, SyncDevice sets up a global shortcut the first time you run it. You can open any Command Prompt or PowerShell window and type these commands:

* `syncdevice start` : Starts the normal background sync engine.
* `syncdevice push` : Does one quick sync sending files from your PC to your phone, then closes.
* `syncdevice pull` : Does one quick sync pulling files from your phone to your PC, then closes.

*(Note: If these commands do not work right after your first install, just close your Command Prompt window and open a new one to refresh it.)*