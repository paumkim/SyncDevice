# SyncDevice: Ironclad Two-Way ADB Sync for Windows & Android

SyncDevice is an ultra-fast, highly resilient, two-way synchronization engine built entirely using Windows Batch and PowerShell. It leverages the Android Debug Bridge (ADB) to bypass the notoriously buggy Windows MTP file transfer system, allowing for massive, reliable file mirrors between your PC and your phone.

**⚠️ IMPORTANT DISCLAIMER:** This engine was specifically engineered for, and heavily tested on, **Samsung Galaxy devices running OneUI**. While it uses standard ADB commands and should work on any Android device, the specific "Storage Permission Audits" and connection handshake timings were optimized to bypass Samsung's specific USB security locks. 

---

## ✨ Key Features
* **Two-Way PowerShell Fusion Engine:** Scans and compares local and mobile directories in seconds using .NET processing arrays to calculate diffs instantly.
* **Workspace Architect:** Automatically builds a clean directory structure (`Document`, `Download`, `Image`, `Music`, `Video`) at the system root `C:\SyncDevice` and applies custom icons.
* **AutoWatcher Sentinel:** Generates a lightweight, minimized background daemon that monitors your USB ports and triggers a sync the moment your phone is plugged in and unlocked.
* **The Ironclad Bridge:** Features a "Cold Boot" ADB taskkill protocol to prevent the command line from freezing when switching Android USB modes.
* **Safety Circuit Breaker:** Automatically halts the sync if 5 consecutive transfers fail, preventing data corruption if the USB cable is bumped or disconnected.
* **Self-Sanitizing:** Automatically cleans up legacy script backups on both devices to ensure your environment stays clean.

---

## 🛠️ Prerequisites
1. **Windows 10 or 11** (PowerShell is built-in).
2. **ADB (Android Platform-Tools):** You must have ADB installed and added to your Windows system `PATH`.
3. **Developer Options:** Enabled on your Android phone.
4. **USB Debugging:** Enabled in your phone's Developer settings.

---

## 🚀 Installation & Setup
1. Download the latest release or clone this repository.
2. Extract the folder to your preferred location (the script will automatically anchor data to `C:\SyncDevice`).
3. **Add your Icons (Recommended):** See the *Customizing Icons* section below.
4. Double-click `SyncDevice.bat` to begin the first-run Handshake.
5. The script will generate three desktop shortcuts:
   * **SyncDevice AutoSync:** Manually trigger a two-way sync.
   * **SyncDevice Folder:** Opens your `C:\SyncDevice` directory.
   * **SyncDevice AutoWatcher:** Run this to have the PC automatically sync whenever the phone is plugged in.

---

## 🎨 Customizing Folder Icons
To keep the repository lightweight and respect licensing, original icons are not included. You can easily apply your own visual style:

1. Place your `.ico` files in the `ICO/` folder within the script directory.
2. **Naming Convention:** Files must be named exactly as follows for the script to detect them:
   * `icon.ico` (For the main SyncDevice root and shortcuts)
   * `Document.ico`
   * `Download.ico`
   * `Image.ico`
   * `Music.ico`
   * `Video.ico`
3. Run the script. The **Workspace Architect** will automatically apply these icons using the hidden `.assets` protocol.

---

## 📱 Troubleshooting (Samsung Users)
If the script reports that **Android Storage is LOCKED** even after you have tapped "Allow" on the phone:
1. Ensure your USB mode is set to **"File Transfer / Android Auto"**.
2. If the warning persists, press **[B]** in the terminal to **Bypass** the audit and force the bridge open.

---

## 🛠️ Credits & Vibe Coding
This project is the result of a **"vibe coding"** collaboration between the user and **Google Gemini**. All core logic, ADB bridge handling, and PowerShell fusion arrays were generated through iterative AI collaboration to solve real-world MTP transfer frustrations.

## 📄 License
Distributed under the MIT License. Feel free to fork and adapt for other Android variants (Pixel, OnePlus, etc.).
