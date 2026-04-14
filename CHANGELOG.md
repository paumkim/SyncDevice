# Changelog

All notable changes to the SyncDevice project will be documented in this file.

## [v39.30] - Command Line Interface (CLI) Integration
### Added
* **Global CLI Wrapper:** Introduced a dedicated `syncdevice.bat` wrapper generated dynamically in `C:\SyncDevice\CLI`.
* **Path Injection:** The engine now uses a safe PowerShell command on first run to silently add the CLI directory to the Windows User `%PATH%`, allowing global terminal access.
* **CLI Routing Engine:** The main script now intercepts `push` and `pull` arguments, performing one-time isolated syncs and exiting cleanly without triggering the infinite Watchdog loop.

## [v39.20] - Safe Stop & UI Polish
### Added
* **Safe Stop Mechanism:** Introduced a dedicated `Safe Stop AutoSync.lnk` generated dynamically in the `C:\SyncDevice` folder. Clicking this sets a `.flag` file that gracefully aborts the sync loop and safely kills the ADB server to prevent background port locking.
* **Advanced UI Rendering:** Upgraded the command console UI to use ANSI Escape Sequences (`ESC[1G` and `ESC[2K`). This ensures the category progress bars cleanly overwrite themselves on a single line in modern Windows Terminal environments.
### Changed
* **Decluttered Desktop:** Removed the automatic generation of shortcuts on the Windows Desktop. All control shortcuts and dynamic icons are now localized entirely within the `C:\SyncDevice` workspace for a minimal, cleaner user experience.
* **Progress UI:** Progress bars now fully lock in at 100% before dropping to a new line for the next file category.

## [v39.10] - Universal Streaming & Watchdog Optimizations
### Added
* **Per-Category Progress Bars:** Split the transfer queue into Images, Videos, Documents, and Misc files, with individual progress counters and visual bars for each category.
* **PID Hunter:** Added an aggressive best-effort port clearing script on startup to kill any stuck tasks holding port 5037, ensuring a fresh ADB bridge on launch.
### Changed
* **Universal TAR Engine:** Swapped standard ADB push/pull commands for piped `tar` streaming (`tar -cf | adb exec-in` and `adb exec-out | tar -xf`). This significantly increases transfer speeds for directories with thousands of small files.

## [v38.x] - Deep Harvester Integration
### Added
* **Mirror Matrix:** Implemented a PowerShell and ADB `stat` script to compile an instant text-based matrix of file sizes between the PC and Phone, drastically reducing the time it takes to figure out what needs to be synced.
* **Deep Harvester:** Added an automated sweep that grabs loose media from the Android `/sdcard/DCIM/Camera` folder and sorts it into `Year-Month` organized directories inside `From_Phone`.