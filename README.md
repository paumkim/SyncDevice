# SyncDevice: Ironclad Two-Way ADB Sync for Windows & Android

SyncDevice is an ultra-fast, highly resilient, two-way synchronization engine built entirely in Windows Batch and PowerShell. It uses the Android Debug Bridge (ADB) to bypass the notoriously buggy Windows MTP file transfer system, allowing for massive, reliable file mirrors between your PC and your phone.

**⚠️ IMPORTANT DISCLAIMER:** This engine was specifically engineered for, and heavily tested on, **Samsung Galaxy devices running OneUI**. While it uses standard ADB commands and should work on any Android device, the specific "Storage Permission Audits" and connection handshake timings were optimized to bypass Samsung's specific USB security locks. 

## ✨ Key Features
* **Two-Way PowerShell Fusion Engine:** Scans tens of thousands of files in seconds, comparing PC and Android directories to instantly calculate diffs without copying unchanged files.
* **Workspace Architect:** Automatically builds a clean directory structure (`Document`, `Download`, `Image`, `Music`, `Video`) on your PC and applies custom `.ico` folder icons.
* **AutoWatcher Daemon:** Generates a lightweight, minimized background watcher that instantly triggers the sync process the moment you plug in your phone.
* **The Ironclad Bridge:** Features a "Cold Boot" ADB taskkill protocol to prevent the command line from freezing when switching Android USB modes.
* **Circuit Breaker:** Automatically halts the sync if 5 consecutive transfers fail, preventing endless error loops if the USB cable is bumped.
* **Self-Sanitizing:** Automatically cleans up legacy script backups on both devices to prevent ghost-pulling old configurations.

## 🛠️ Prerequisites
1. **Windows 10 or 11** (PowerShell is built-in).
2. **ADB (Android Platform-Tools):** You must have ADB installed and added to your Windows system `PATH`.
3. **Developer Options:** Enabled on your Android phone.
4. **USB Debugging:** Enabled in your phone's Developer Options.

## 🚀 Installation & Setup
1. Download the latest release or clone this repository.
2. Extract the folder and move it to your preferred location (the script will automatically anchor all data to `C:\SyncDevice` regardless of where you run the setup).
3. *(Optional)* Place your custom `.ico` files in the `ICO` folder (name them `Document.ico`, `Download.ico`, etc.).
4. Double-click `SyncDevice.bat` to begin the first-run Handshake.

## 📱 How to Use
1. Plug your phone into your PC.
2. Unlock your phone screen.
3. If prompted, tap **Allow USB Debugging** and set the USB mode to **File Transfer**.
4. The script will generate three desktop shortcuts for you:
   * **SyncDevice AutoSync:** Manually trigger a two-way sync.
   * **SyncDevice Folder:** Quickly open your `C:\SyncDevice` directory.
   * **SyncDevice AutoWatcher:** Run this to have the PC automatically sync whenever the phone is plugged in.

## 🤝 Contributing
Feel free to open issues or submit pull requests! If you test this on Google Pixel, OnePlus, or other Android variants and find bugs with the permission audit, PRs are welcome.

## 📄 License
Distributed under the MIT License. See `LICENSE` for more information.