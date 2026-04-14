# SyncDevice — AutoSync Engine

AutoSync is a robust, automated two-way file synchronization engine designed to seamlessly mirror media and documents between your Windows PC and your Android device. It uses ADB (Android Debug Bridge) and native TAR streaming to transfer files rapidly and securely.

## 🚀 Key Features

* **Two-Way Watchdog Synchronization:** Continuously monitors your PC (`C:\SyncDevice`) and your Android phone (`/sdcard/Download/SyncDevice`). It calculates file sizes and intelligently pushes or pulls only what is missing or updated.
* **The Deep Harvester:** Automatically sweeps loose camera media (DCIM) and sorts them into organized `Year-Month` folders.
* **Universal TAR Streaming:** Bypasses standard file-by-file copying limits by streaming data through memory, resulting in blazing-fast transfers.
* **Live UI:** Clean, self-overwriting console progress bars categorized by file type (Images, Videos, Documents, Misc).
* **Graceful Shutdown:** Includes a "Safe Stop" mechanism to abort transfers without corrupting files or locking up background ports.

## ⚙️ Prerequisites

1.  **Windows PC** (Windows 10/11 recommended for native ANSI console support).
2.  **Android Device** with **USB Debugging** enabled in Developer Options.
3.  **ADB (Android Debug Bridge)** installed and added to your Windows system PATH.

## 🛠️ Installation & Usage

1.  Connect your Android device to your PC via USB. Ensure the connection is set to "File Transfer" (MTP) and allow USB Debugging if prompted on your phone screen.
2.  Run the `SyncDevice.bat` script.
3.  The engine will automatically architect its workspace at `C:\SyncDevice`, generate necessary desktop/folder icons, and start the Watchdog loop.
4.  Drop files into the respective folders inside `C:\SyncDevice`, and they will automatically sync to your phone.

## 🛑 How to Stop the Engine Safely

**Do not close the console window using the "X" button.** Doing so will leave the ADB daemon running in the background, which can cause connection issues the next time you plug in your phone.

Instead, go to your `C:\SyncDevice` folder and double-click the **Safe Stop AutoSync** shortcut. This sends a signal to the engine to finish the current file and gracefully shut down the ADB server.