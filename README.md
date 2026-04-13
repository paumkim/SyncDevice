# SyncDevice: Fast & Easy File Sync for PC and Android

SyncDevice is a tool that makes copying files between your Windows PC and your Android phone fast and reliable. 

If you've ever been frustrated by Windows freezing or crashing when you plug in your phone to transfer photos or music, this tool fixes that. It uses a secure developer connection (ADB) to bypass those common Windows bugs so your transfers actually finish.

**⚠️ Good to know:** This was built and tested heavily on Samsung phones, but it will work perfectly on any Android device!

---

## ✨ What It Does
* **Smart Syncing:** It quickly looks at your phone and your PC, figures out what files are missing, and copies only what is needed.
* **Auto-Organizer:** It automatically grabs your messy, loose photos or documents and puts them into neat folders sorted by the year and month.
* **Priority Transfer:** It makes sure your pictures are moved first, then your videos, and then your documents.
* **Easy Setup:** Just run it once, and it will build a clean `C:\SyncDevice` folder on your computer with custom icons, ready to use.
* **Fixes Bad Connections:** If another app on your computer is blocking your phone from connecting, SyncDevice forces the connection open automatically.
* **Safe to Unplug:** If you accidentally pull the USB cable out while it's copying, it safely stops without breaking or corrupting your files.
* **Background Watcher:** It can run quietly in the background. The moment you plug your phone in, it syncs your files and goes back to sleep.

---

## 🛠️ What You Need First
1. **Windows 10 or 11**.
2. **ADB Installed:** You need to have Android Platform-Tools (ADB) installed on your computer.
3. **USB Debugging:** You must turn on "Developer Options" and enable "USB Debugging" in your phone's settings.

---

## 🚀 How to Use It
1. Download this project to your computer.
2. Put your custom icons in the `ICO` folder (optional).
3. Double-click `SyncDevice.bat`.
4. The script will set everything up and put two shortcuts on your desktop:
   * **SyncDevice:** Opens your main folder where you drop files you want to send to your phone.
   * **Start AutoSync Engine:** Runs the sync tool manually whenever you want.

---

## 📱 Troubleshooting (Samsung Users)
If the black screen says **Android Storage is LOCKED** even after you tapped "Allow" on your phone:
1. Make sure your phone's USB connection is set to **"File Transfer"**.
2. If it still says locked, press **[B]** on your keyboard to force the script to skip the check and connect anyway.

---

## 📄 License
Free to use, share, and change (MIT License).