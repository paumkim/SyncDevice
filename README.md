# SyncDevice — AutoSync v40.40

AutoSync is a smart, automated tool that copies your photos, videos, and documents back and forth between your Windows PC and your Android phone. It uses ADB to make transfers super fast and secure.

---

## 🚀 Key Features

* **Smart Sync:** It constantly watches your PC (`C:\SyncDevice`) and your phone (`/sdcard/Download/SyncDevice`). It only copies files that are new or updated.
* **Wireless Wi-Fi Sync:** Seamlessly switch from a physical USB connection to a wireless connection over Wi-Fi. The engine can auto-detect your phone's IP address and automatically switch ADB to TCP mode over port 5555.
* **Live Phone Notifications:** Keeps you in the loop by pushing live progress notifications directly to your phone when transferring files and when the sync completes.
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
3. The tool will automatically architect a clean workspace at `C:\SyncDevice`, generate your shortcuts, silently install the CLI to your Windows PATH, and start the engine in the background.

### 2. How to Sync Files
Once the tool builds the `C:\SyncDevice` folder, you will see folders for `Image`, `Video`, and `Document`. 
* **To send to your phone:** Drop your files into the `From_PC` folder inside any category. The tool will automatically see them and send them to your phone.
* **To save to your PC:** Just take photos or save files on your phone. The tool will automatically pull them into the matching `From_Phone` folder on your PC.

### 3. Going Wireless
You don't need to stay tethered to your desk! Once you are initially connected via USB:
1. Open Command Prompt or PowerShell.
2. Type `syncdevice wifi` and hit Enter.
3. The background engine will automatically detect your phone's Wi-Fi IP and establish a wireless pairing.
4. Wait for the CLI to confirm success, and then you may unplug the USB cable.

### 4. How to Stop Safely
> **⚠️ WARNING:** **Do not click the "X" button to close the black console window!** Doing this will leave ADB running in the background, which can cause bugs the next time you plug your phone in.

Instead, go to your `C:\SyncDevice` folder and double-click the **Safe Stop AutoSync** shortcut. This sends a safe shutdown signal. It will finish whatever file it is currently working on, gracefully shut down ADB, and close the window for you.

### 5. Command Line (CLI) For Power Users
If you like using the command line, SyncDevice automatically installs its CLI into your system so you can manage your syncs from anywhere. Open any Command Prompt or PowerShell window and type:

* `syncdevice start` or `syncdevice -s` : Starts the continuous background engine.
* `syncdevice push` : Launches a one-time push from your PC to your phone.
* `syncdevice pull` : Launches a one-time pull from your phone to your PC.
* `syncdevice wifi` : Seamlessly tells the background engine to switch to a Wi-Fi connection. It will auto-detect your IP, but you can also manually target an IP like `syncdevice wifi 192.168.1.15`.
* `syncdevice usb` : Signals the engine to kill the wireless connection and seamlessly switch back to a physical cable.

*(Note: If these commands do not work right after your first install, just close your Command Prompt window and open a new one to refresh it.)*