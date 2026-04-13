# SyncDevice: Ironclad Two-Way ADB Sync for Windows & Android

SyncDevice is an ultra-fast, highly resilient, two-way synchronization engine built entirely using Windows Batch and PowerShell. It leverages the Android Debug Bridge (ADB) to bypass the notoriously buggy Windows MTP file transfer system, allowing for massive, reliable file mirrors between your PC and your phone.

**⚠️ IMPORTANT DISCLAIMER:** This engine was specifically engineered for, and heavily tested on, **Samsung Galaxy devices running OneUI**. While it uses standard ADB commands and should work on any Android device, the specific "Storage Permission Audits" and connection handshake timings were optimized to bypass Samsung's specific USB security locks. 

---

## ✨ Key Features
* **Two-Way In-Memory Matrix:** Scans and compares local and mobile directories using .NET processing arrays. It executes directly in system memory, completely bypassing strict Windows PowerShell Execution Policies.
* **The Deep Harvester:** Automatically sweeps loose files (Images, Videos, Documents) from your PC dropzone and your Phone's Camera Roll, and neatly organizes them into `YYYY-MM` date folders before syncing.
* **Category Triage Routing:** Synchronizes files systematically by category (Images first, then Videos, then Documents) so you get immediate access to priority files.
* **Workspace Architect:** Automatically builds a clean, hidden directory structure at the system root `C:\SyncDevice` and applies custom UI icons.
* **The Ironclad Bridge:** Features a brute-force `netstat` and PID-hunting protocol to instantly resolve Port 5037 collisions with other background Android emulators.
* **Safety Circuit Breaker:** Automatically halts the entire sync if 3 consecutive ADB transfers fail, preventing data corruption if the USB cable is bumped or disconnected.
* **Watchdog Sentinel:** A continuous 10-second loop that automatically detects when your phone is plugged in, syncs, and goes back to sleep when unplugged.

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
4. Double-click `SyncDevice.bat` to begin the Workspace Architect setup.
5. The script will automatically clean up your desktop and generate two shortcuts:
   * **SyncDevice:** Opens your `C:\SyncDevice` dropzone folder.
   * **Start AutoSync Engine:** A manual trigger inside the folder to restart the daemon if closed.

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
Distributed under the MIT License. Feel free to fork and adapt for other Android variants.