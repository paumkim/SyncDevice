@echo off
:: [CRITICAL] Anchor to script folder
cd /d "%~dp0"
chcp 65001 >nul
setlocal DisableDelayedExpansion
setlocal EnableDelayedExpansion

:: Create an ESC character for ANSI escape sequences
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"

:: ============================================================
:: SyncDevice - SyncTwoWay
:: - Version: 40.40 (The Live Sync Notification Update)
:: ============================================================

set "CURRENT_VER=40.40"
title AutoSync v%CURRENT_VER%

:: ---------------------------------------------------------
:: 1. CONFIG & PATHS
:: ---------------------------------------------------------
set "PCFOLDER=C:\SyncDevice"
set "ENGINE_DIR=%PCFOLDER%\autoSyncEngine"
set "PHONEFOLDER=/sdcard/Download/SyncDevice"
set "CLI_DIR=%PCFOLDER%\CLI"

set "IconBank=%ENGINE_DIR%\ICO"
set "LOGDIR=%ENGINE_DIR%\logs"
set "TEMPDIR=%ENGINE_DIR%\temp"
set "CONFIGDIR=%ENGINE_DIR%\config"

:: ---------------------------------------------------------
:: 2. CLI ROUTER & FORK BOMB SHIELD
:: ---------------------------------------------------------
set "CLI_RUN_MODE="
if /i "%~1"=="push" set "CLI_RUN_MODE=PUSH" & goto :engine_boot
if /i "%~1"=="pull" set "CLI_RUN_MODE=PULL" & goto :engine_boot
if /i "%~1"=="--engine" goto :engine_boot

:: ---------------------------------------------------------
:: 3. WORKSPACE ARCHITECT (Runs once on double-click)
:: ---------------------------------------------------------
if /i not "%~dp0"=="%ENGINE_DIR%\" (
    echo [0] Architecting Clean Workspace...
    if not exist "%PCFOLDER%" mkdir "%PCFOLDER%"
    if not exist "%ENGINE_DIR%" mkdir "%ENGINE_DIR%"
    if not exist "%CLI_DIR%" mkdir "%CLI_DIR%"
    
    if not exist "%ENGINE_DIR%\logs" mkdir "%ENGINE_DIR%\logs"
    if not exist "%ENGINE_DIR%\temp" mkdir "%ENGINE_DIR%\temp"
    if not exist "%ENGINE_DIR%\config" mkdir "%ENGINE_DIR%\config"

    if exist "%~dp0ICO" xcopy /E /I /Y "%~dp0ICO" "%ENGINE_DIR%\ICO\" >nul 2>&1
    copy /Y "%~f0" "%ENGINE_DIR%\SyncDevice.bat" >nul 2>&1
    attrib +h +s "%ENGINE_DIR%" >nul 2>&1
    
    echo      [+] Workspace Decluttered.
    echo [0] Starting Engine...
    timeout /t 2 >nul
    start "" "%ENGINE_DIR%\SyncDevice.bat" --engine
    exit /b
)

goto :engine_boot

:: =========================================================
:: MAIN ENGINE LOGIC STARTS HERE
:: =========================================================
:engine_boot
cls
if not exist "%TEMPDIR%" mkdir "%TEMPDIR%" 2>nul
if not exist "%CONFIGDIR%" mkdir "%CONFIGDIR%" 2>nul
if not exist "%CLI_DIR%" mkdir "%CLI_DIR%" 2>nul

del /q "%CONFIGDIR%\SyncDevice_Master_v*.bat" >nul 2>&1
copy /Y "%~f0" "%CONFIGDIR%\SyncDevice_Master_v%CURRENT_VER%.bat" >nul 2>&1

:: [CRITICAL FIX] Rebuild Ghost CLI (No duplicate windows, no terminal closing)
type nul > "%CLI_DIR%\syncdevice.bat"
>>"%CLI_DIR%\syncdevice.bat" echo @echo off
>>"%CLI_DIR%\syncdevice.bat" echo setlocal enabledelayedexpansion
>>"%CLI_DIR%\syncdevice.bat" echo set "ENGINE_DIR=C:\SyncDevice\autoSyncEngine"
>>"%CLI_DIR%\syncdevice.bat" echo set "TEMPDIR=C:\SyncDevice\autoSyncEngine\temp"
>>"%CLI_DIR%\syncdevice.bat" echo set "TARGET=C:\SyncDevice\CLI"
>>"%CLI_DIR%\syncdevice.bat" echo echo %%PATH%% ^| find /I "%%TARGET%%" ^>nul
>>"%CLI_DIR%\syncdevice.bat" echo if %%errorlevel%%==0 goto continue_cli
>>"%CLI_DIR%\syncdevice.bat" echo echo Installing SyncDevice CLI...
>>"%CLI_DIR%\syncdevice.bat" echo powershell -NoProfile -ExecutionPolicy Bypass -Command "$p=[Environment]::GetEnvironmentVariable('PATH','User'); if($p -notmatch [regex]::Escape('C:\SyncDevice\CLI')){ [Environment]::SetEnvironmentVariable('PATH',$p+';C:\SyncDevice\CLI','User') }" ^>nul 2^>^&1
>>"%CLI_DIR%\syncdevice.bat" echo timeout /t 2 ^>nul
>>"%CLI_DIR%\syncdevice.bat" echo exit /b
>>"%CLI_DIR%\syncdevice.bat" echo :continue_cli
>>"%CLI_DIR%\syncdevice.bat" echo if /i "%%~1"=="" goto help
>>"%CLI_DIR%\syncdevice.bat" echo set "CMD=%%~1"
>>"%CLI_DIR%\syncdevice.bat" echo if /i "%%CMD%%"=="-s" goto do_start
>>"%CLI_DIR%\syncdevice.bat" echo if /i "%%CMD%%"=="start" goto do_start
>>"%CLI_DIR%\syncdevice.bat" echo if /i "%%CMD%%"=="push"  goto do_push
>>"%CLI_DIR%\syncdevice.bat" echo if /i "%%CMD%%"=="pull"  goto do_pull
>>"%CLI_DIR%\syncdevice.bat" echo if /i "%%CMD%%"=="wifi"  goto do_wifi
>>"%CLI_DIR%\syncdevice.bat" echo if /i "%%CMD%%"=="usb"   goto do_usb
>>"%CLI_DIR%\syncdevice.bat" echo echo [ERROR] Unknown command: %%CMD%%
>>"%CLI_DIR%\syncdevice.bat" echo goto help
>>"%CLI_DIR%\syncdevice.bat" echo :do_wifi
>>"%CLI_DIR%\syncdevice.bat" echo if "%%~2"=="" (echo AUTO^>"%%TEMPDIR%%\wifi_request.flag") else (echo %%~2^>"%%TEMPDIR%%\wifi_request.flag")
>>"%CLI_DIR%\syncdevice.bat" echo echo [CLI] Signal sent! The background engine will now switch to Wi-Fi.
>>"%CLI_DIR%\syncdevice.bat" echo exit /b
>>"%CLI_DIR%\syncdevice.bat" echo :do_usb
>>"%CLI_DIR%\syncdevice.bat" echo echo USB^>"%%TEMPDIR%%\wifi_request.flag"
>>"%CLI_DIR%\syncdevice.bat" echo echo [CLI] Signal sent! The background engine will now switch to USB.
>>"%CLI_DIR%\syncdevice.bat" echo exit /b
>>"%CLI_DIR%\syncdevice.bat" echo :do_start
>>"%CLI_DIR%\syncdevice.bat" echo echo [CLI] Starting AutoSync Engine...
>>"%CLI_DIR%\syncdevice.bat" echo start "" "%%ENGINE_DIR%%\SyncDevice.bat" --engine
>>"%CLI_DIR%\syncdevice.bat" echo exit /b
>>"%CLI_DIR%\syncdevice.bat" echo :do_push
>>"%CLI_DIR%\syncdevice.bat" echo echo [CLI] Launching one-time Push...
>>"%CLI_DIR%\syncdevice.bat" echo call "%%ENGINE_DIR%%\SyncDevice.bat" push
>>"%CLI_DIR%\syncdevice.bat" echo exit /b
>>"%CLI_DIR%\syncdevice.bat" echo :do_pull
>>"%CLI_DIR%\syncdevice.bat" echo echo [CLI] Launching one-time Pull...
>>"%CLI_DIR%\syncdevice.bat" echo call "%%ENGINE_DIR%%\SyncDevice.bat" pull
>>"%CLI_DIR%\syncdevice.bat" echo exit /b
>>"%CLI_DIR%\syncdevice.bat" echo :help
>>"%CLI_DIR%\syncdevice.bat" echo echo.
>>"%CLI_DIR%\syncdevice.bat" echo echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
>>"%CLI_DIR%\syncdevice.bat" echo echo   SyncDevice Command Line Interface
>>"%CLI_DIR%\syncdevice.bat" echo echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
>>"%CLI_DIR%\syncdevice.bat" echo echo Usage: syncdevice [command]
>>"%CLI_DIR%\syncdevice.bat" echo echo.
>>"%CLI_DIR%\syncdevice.bat" echo echo Commands:
>>"%CLI_DIR%\syncdevice.bat" echo echo   -s, start   Start continuous background engine
>>"%CLI_DIR%\syncdevice.bat" echo echo   push        One-time push ^(PC -^> Phone^)
>>"%CLI_DIR%\syncdevice.bat" echo echo   pull        One-time pull ^(Phone -^> PC^)
>>"%CLI_DIR%\syncdevice.bat" echo echo   wifi        Seamlessly switch to Wi-Fi connection
>>"%CLI_DIR%\syncdevice.bat" echo echo   usb         Seamlessly switch back to physical cable
>>"%CLI_DIR%\syncdevice.bat" echo echo.
>>"%CLI_DIR%\syncdevice.bat" echo exit /b
powershell -NoProfile -ExecutionPolicy Bypass -Command "$p=[Environment]::GetEnvironmentVariable('PATH','User'); if($p -notmatch [regex]::Escape('%CLI_DIR%')){ [Environment]::SetEnvironmentVariable('PATH',$p+';%CLI_DIR%','User') }" >nul 2>&1

:: Clear leftover flags
del /q "%TEMPDIR%\stop.flag" >nul 2>&1
del /q "%TEMPDIR%\wifi_request.flag" >nul 2>&1

echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo   SyncDevice — AutoSync v%CURRENT_VER%
if defined CLI_RUN_MODE echo   Mode        : CLI One-Time %CLI_RUN_MODE%
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo   Engine Path : %ENGINE_DIR%
echo   PC Folder   : %PCFOLDER%
echo   Phone Root  : %PHONEFOLDER%
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
set "LOOP_COUNT=0"

if not defined CLI_RUN_MODE (
    call :setup_shortcuts
    call :dynamic_icons
)
echo      [CHECK] Environment Ready.
echo.

:: ---------------------------------------------------------
:: STEP 3: FAST ADB INIT & TARGET LOCK
:: ---------------------------------------------------------
echo [3] Initializing Fresh ADB Bridge...

:: Only clear processes on a full background startup, not CLI Push/Pull
if not defined CLI_RUN_MODE (
    adb kill-server >nul 2>&1
    taskkill /F /IM adb.exe /T >nul 2>&1
    :: [CRITICAL] Give Windows TCP stack time to fully release Port 5037
    timeout /t 2 >nul
)
adb start-server >nul 2>&1

:device_discovery
set "DEV_COUNT=0"
for /f "tokens=1" %%A in ('adb devices ^| findstr /i "device$" ^| findstr /v "List"') do (
    set /a DEV_COUNT+=1
    set "DEV_!DEV_COUNT!_ID=%%A"
)

if !DEV_COUNT! EQU 0 (
    echo      [WAIT] No devices found. Waiting for USB or Wi-Fi connection...
    adb wait-for-device
    goto :device_discovery
)

:: Auto-Lock to a requested Wi-Fi IP if we just made a seamless switch
if defined TARGET_WIFI_IP (
    for /L %%I in (1,1,!DEV_COUNT!) do (
        echo !DEV_%%I_ID! | findstr "!TARGET_WIFI_IP!" >nul
        if not errorlevel 1 (
            set "ANDROID_SERIAL=!DEV_%%I_ID!"
            set "TARGET_WIFI_IP="
            echo      [OK] Seamlessly Locked to Wi-Fi Device: !ANDROID_SERIAL!
            goto :storage_check
        )
    )
    set "TARGET_WIFI_IP="
)

if !DEV_COUNT! EQU 1 (
    echo      [OK] Single device detected: !DEV_1_ID!
    set "ANDROID_SERIAL=!DEV_1_ID!"
    goto :storage_check
)

:: Multiple Devices Menu
echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo   [ MULTIPLE DEVICES DETECTED ] - Choose Target
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
for /L %%I in (1,1,!DEV_COUNT!) do (
    echo   [%%I] !DEV_%%I_ID!
)
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
set /p "DEV_CHOICE= Select device (1-!DEV_COUNT!): "
set "ANDROID_SERIAL=!DEV_%DEV_CHOICE%_ID!"
if "!ANDROID_SERIAL!"=="" (
    echo [ERROR] Invalid selection. Try again.
    goto :device_discovery
)
echo      [OK] Locked onto Device: !ANDROID_SERIAL!

:storage_check
adb shell "ls /sdcard >/dev/null 2>&1"
if errorlevel 1 (
    echo [ERROR] Storage Locked or Device Offline. Retrying...
    timeout /t 2 >nul
    goto :device_discovery
)

echo      [OK] Storage accessible.

:: =========================================================
:: 🔁 WATCHDOG LOOP STARTS HERE
:: =========================================================
:watchdog_loop
set "CIRCUIT_BREAKER=0"

:: ---------------------------------------------------------
:: STEP 4: THE DEEP HARVESTER
:: ---------------------------------------------------------
echo.
echo ============================================================
echo   [HARVESTER] Sweeping Loose Media into From_PC / From_Phone...
echo ============================================================

for /f "usebackq delims=" %%I in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-Date -Format 'yyyy-MM'"`) do set "YM=%%I"

adb shell "mkdir -p \"%PHONEFOLDER%/Image/From_Phone/!YM!\"" >nul 2>&1
adb shell "mkdir -p \"%PHONEFOLDER%/Video/From_Phone/!YM!\"" >nul 2>&1

adb shell "find /sdcard/DCIM/Camera -maxdepth 1 -type f \( -iname \*.jpg -o -iname \*.jpeg -o -iname \*.png \) -exec mv {} \"%PHONEFOLDER%/Image/From_Phone/!YM!/\" \;" >nul 2>&1
adb shell "find /sdcard/DCIM/Camera -maxdepth 1 -type f \( -iname \*.mp4 -o -iname \*.mov \) -exec mv {} \"%PHONEFOLDER%/Video/From_Phone/!YM!/\" \;" >nul 2>&1

set "HAS_LOOSE_FILES=0"
for %%F in ("%PCFOLDER%\*.*") do set "HAS_LOOSE_FILES=1"

if "!HAS_LOOSE_FILES!"=="1" (
    set "PS_HARVEST=$p = '%PCFOLDER%'; $img = @('.jpg','.jpeg','.png','.gif','.bmp'); $vid = @('.mp4','.mov','.avi','.mkv'); $doc = @('.pdf','.docx','.txt','.xlsx','.csv'); Get-ChildItem -Path $p -File | ForEach-Object { $ext = $_.Extension.ToLower(); $ym = $_.LastWriteTime.ToString('yyyy-MM'); if ($img -contains $ext) { $dest = \"$p\Image\From_PC\$ym\" } elseif ($vid -contains $ext) { $dest = \"$p\Video\From_PC\$ym\" } elseif ($doc -contains $ext) { $dest = \"$p\Document\From_PC\$ym\" } else { return }; if (-not (Test-Path $dest)) { New-Item -ItemType Directory -Force -Path $dest | Out-Null }; Move-Item $_.FullName \"$dest\" -Force }"
    powershell -NoProfile -ExecutionPolicy Bypass -Command "& { !PS_HARVEST! }" >nul 2>&1
)

echo.
echo ============================================================
echo   [WATCHDOG] Compiling Mirror Matrix...
echo ============================================================

adb shell "find \"%PHONEFOLDER%\" -type f -exec stat -c '%%s|%%n' {} +" 2>nul > "%TEMPDIR%\phone_raw.txt"

> "%TEMPDIR%\engine.ps1" echo param($pcDir, $phDir, $phRawF, $pOutL, $pInL, $pOutH, $pInH, $statsOut)
>> "%TEMPDIR%\engine.ps1" echo $thresh = 52428800;
>> "%TEMPDIR%\engine.ps1" echo $pcLen = $pcDir.Length; if (-not $pcDir.EndsWith('\')) { $pcLen += 1 }
>> "%TEMPDIR%\engine.ps1" echo $pcData = @{}; $phData = @{}
>> "%TEMPDIR%\engine.ps1" echo $pushL = [System.Collections.Generic.List[string]]::new(); $pushH = [System.Collections.Generic.List[string]]::new()
>> "%TEMPDIR%\engine.ps1" echo $pullL = [System.Collections.Generic.List[string]]::new(); $pullH = [System.Collections.Generic.List[string]]::new()
>> "%TEMPDIR%\engine.ps1" echo try {
>> "%TEMPDIR%\engine.ps1" echo   $files = [System.IO.Directory]::EnumerateFiles($pcDir, '*.*', [System.IO.SearchOption]::AllDirectories)
>> "%TEMPDIR%\engine.ps1" echo   foreach ($f in $files) { if ($f -notmatch 'autoSyncEngine' -and $f -notmatch 'CLI') {
>> "%TEMPDIR%\engine.ps1" echo       $fi = [System.IO.FileInfo]::new($f);
>> "%TEMPDIR%\engine.ps1" echo       $rel = $f.Substring($pcLen).Replace('\', '/')
>> "%TEMPDIR%\engine.ps1" echo       $pcData[$rel] = $fi.Length
>> "%TEMPDIR%\engine.ps1" echo   }}
>> "%TEMPDIR%\engine.ps1" echo } catch {}
>> "%TEMPDIR%\engine.ps1" echo $phRaw = [System.IO.File]::ReadAllLines($phRawF)
>> "%TEMPDIR%\engine.ps1" echo $phPref = $phDir; if (-not $phPref.EndsWith('/')) { $phPref += '/' }
>> "%TEMPDIR%\engine.ps1" echo foreach ($l in $phRaw) { if ($l -notmatch '/\.' -and $l -notmatch 'autoSyncEngine' -and $l -notmatch 'CLI') {
>> "%TEMPDIR%\engine.ps1" echo     $p = $l.Split('^|', 2);
>> "%TEMPDIR%\engine.ps1" echo     if ($p.Length -eq 2) {
>> "%TEMPDIR%\engine.ps1" echo       $rel = $p[1]; if ($rel.StartsWith($phPref)) { $rel = $rel.Substring($phPref.Length) }
>> "%TEMPDIR%\engine.ps1" echo       $phData[$rel] = [bigint]$p[0].Trim()
>> "%TEMPDIR%\engine.ps1" echo   }}}
>> "%TEMPDIR%\engine.ps1" echo foreach ($k in $pcData.Keys) { $size = $pcData[$k]
>> "%TEMPDIR%\engine.ps1" echo   if ($phData.Contains($k)) {
>> "%TEMPDIR%\engine.ps1" echo     if ($pcData[$k] -gt $phData[$k]) { if ($size -lt $thresh) { $pushL.Add($k) } else { $pushH.Add($k) } }
>> "%TEMPDIR%\engine.ps1" echo     elseif ($phData[$k] -gt $pcData[$k]) { $phSize = $phData[$k]; if ($phSize -lt $thresh) { $pullL.Add($k) } else { $pullH.Add($k) } }
>> "%TEMPDIR%\engine.ps1" echo   } else { if ($size -lt $thresh) { $pushL.Add($k) } else { $pushH.Add($k) } }
>> "%TEMPDIR%\engine.ps1" echo }
>> "%TEMPDIR%\engine.ps1" echo foreach ($k in $phData.Keys) {
>> "%TEMPDIR%\engine.ps1" echo   if (-not $pcData.Contains($k)) { $phSize = $phData[$k]; if ($phSize -lt $thresh) { $pullL.Add($k) } else { $pullH.Add($k) } }
>> "%TEMPDIR%\engine.ps1" echo }
>> "%TEMPDIR%\engine.ps1" echo [System.IO.File]::WriteAllLines($pOutL, $pushL); [System.IO.File]::WriteAllLines($pInL, $pullL)
>> "%TEMPDIR%\engine.ps1" echo [System.IO.File]::WriteAllLines($pOutH, $pushH); [System.IO.File]::WriteAllLines($pInH, $pullH)
>> "%TEMPDIR%\engine.ps1" echo [System.IO.File]::WriteAllText($statsOut, $pcData.Count.ToString() + '^|' + $phData.Count.ToString())

powershell -NoProfile -ExecutionPolicy Bypass -File "%TEMPDIR%\engine.ps1" ^
    -pcDir "%PCFOLDER%" ^
    -phDir "%PHONEFOLDER%" ^
    -phRawF "%TEMPDIR%\phone_raw.txt" ^
    -pOutL "%TEMPDIR%\push_light.txt" ^
    -pInL "%TEMPDIR%\pull_light.txt" ^
    -pOutH "%TEMPDIR%\push_heavy.txt" ^
    -pInH "%TEMPDIR%\pull_heavy.txt" ^
    -statsOut "%TEMPDIR%\sync_stats.txt"

for /f "usebackq tokens=1,2 delims=|" %%A in ("%TEMPDIR%\sync_stats.txt") do (
    set "PC_COUNT=%%A"
    set "PH_COUNT=%%B"
)

type nul > "%TEMPDIR%\all_push.txt"
if exist "%TEMPDIR%\push_light.txt" type "%TEMPDIR%\push_light.txt" >> "%TEMPDIR%\all_push.txt"
if exist "%TEMPDIR%\push_heavy.txt" type "%TEMPDIR%\push_heavy.txt" >> "%TEMPDIR%\all_push.txt"

type nul > "%TEMPDIR%\all_pull.txt"
if exist "%TEMPDIR%\pull_light.txt" type "%TEMPDIR%\pull_light.txt" >> "%TEMPDIR%\all_pull.txt"
if exist "%TEMPDIR%\pull_heavy.txt" type "%TEMPDIR%\pull_heavy.txt" >> "%TEMPDIR%\all_pull.txt"

:: ---------------------------------------------------------
:: CLI MODE OVERRIDES
:: ---------------------------------------------------------
if "%CLI_RUN_MODE%"=="PUSH" type nul > "%TEMPDIR%\all_pull.txt"
if "%CLI_RUN_MODE%"=="PULL" type nul > "%TEMPDIR%\all_push.txt"

for /f %%A in ('type "%TEMPDIR%\all_push.txt" ^| find /c /v ""') do set "PUSH_COUNT=%%A"
for /f %%A in ('type "%TEMPDIR%\all_pull.txt" ^| find /c /v ""') do set "PULL_COUNT=%%A"
set /a TOTAL_TASKS=%PUSH_COUNT% + %PULL_COUNT%

if %TOTAL_TASKS% EQU 0 (
    if defined CLI_RUN_MODE (
        echo  [ CLI ] Everything is up to date. Nothing to %CLI_RUN_MODE%.
        timeout /t 3 >nul
        exit /b
    )
    goto :watchdog_sleep_init
)

:: [VISIBILITY UPDATE] - Send Initial Waking Notification
set "DID_WORK=1"
adb shell cmd notification post -t "SyncDevice" "AutoSync Engine" "Transferring %TOTAL_TASKS% files with PC..." >nul 2>&1

echo  [ TASKS  ] Need to Push: %PUSH_COUNT% files ^| Need to Pull: %PULL_COUNT% files.
if not defined CLI_RUN_MODE echo  [ NOTICE ] To safely stop the sync at any time, run the "Safe Stop AutoSync" shortcut in %PCFOLDER%.
set /a CURRENT_TASK=0

:: ---------------------------------------------------------
:: CATEGORY COUNTS FOR PROGRESS BARS
:: ---------------------------------------------------------
for /f %%C in ('findstr /i "^Image/" "%TEMPDIR%\all_push.txt" ^| find /c /v ""') do set "IMG_PUSH=%%C"
for /f %%C in ('findstr /i "^Image/" "%TEMPDIR%\all_pull.txt" ^| find /c /v ""') do set "IMG_PULL=%%C"
set /a IMG_TOTAL=%IMG_PUSH% + %IMG_PULL%

for /f %%C in ('findstr /i "^Video/" "%TEMPDIR%\all_push.txt" ^| find /c /v ""') do set "VID_PUSH=%%C"
for /f %%C in ('findstr /i "^Video/" "%TEMPDIR%\all_pull.txt" ^| find /c /v ""') do set "VID_PULL=%%C"
set /a VID_TOTAL=%VID_PUSH% + %VID_PULL%

for /f %%C in ('findstr /i "^Document/" "%TEMPDIR%\all_push.txt" ^| find /c /v ""') do set "DOC_PUSH=%%C"
for /f %%C in ('findstr /i "^Document/" "%TEMPDIR%\all_pull.txt" ^| find /c /v ""') do set "DOC_PULL=%%C"
set /a DOC_TOTAL=%DOC_PUSH% + %DOC_PULL%

for /f %%C in ('findstr /i /v "^Image/ ^Video/ ^Document/" "%TEMPDIR%\all_push.txt" ^| find /c /v ""') do set "MISC_PUSH=%%C"
for /f %%C in ('findstr /i /v "^Image/ ^Video/ ^Document/" "%TEMPDIR%\all_pull.txt" ^| find /c /v ""') do set "MISC_PULL=%%C"
set /a MISC_TOTAL=%MISC_PUSH% + %MISC_PULL%

:: ---------------------------------------------------------
:: 1. IMAGE SYNCHRONIZATION
:: ---------------------------------------------------------
echo.
echo [5] Synchronizing IMAGES...
set "IMG_DONE=0"
set "LAST_NOTIF_PERC=-1"
if %IMG_TOTAL% GTR 0 (
    for /f "usebackq delims=" %%A in (`findstr /i "^Image/" "%TEMPDIR%\all_push.txt" 2^>nul`) do (
        if exist "%TEMPDIR%\stop.flag" goto :graceful_abort
        if exist "%TEMPDIR%\wifi_request.flag" goto :process_remote_request
        set /a IMG_DONE+=1
        
        set /a "perc=(IMG_DONE*100)/IMG_TOTAL"
        if "!LAST_NOTIF_PERC!" NEQ "!perc!" (
            set "LAST_NOTIF_PERC=!perc!"
            adb shell cmd notification post -t "SyncDevice" "AutoSync: IMAGES" "Syncing: !perc!%% (!IMG_DONE!/!IMG_TOTAL!)" >nul 2>&1
        )

        call :progress_bar_category !IMG_DONE! !IMG_TOTAL! IMAGES
        call :do_push "%%A" "MEDIA"
    )
    for /f "usebackq delims=" %%A in (`findstr /i "^Image/" "%TEMPDIR%\all_pull.txt" 2^>nul`) do (
        if exist "%TEMPDIR%\stop.flag" goto :graceful_abort
        if exist "%TEMPDIR%\wifi_request.flag" goto :process_remote_request
        set /a IMG_DONE+=1

        set /a "perc=(IMG_DONE*100)/IMG_TOTAL"
        if "!LAST_NOTIF_PERC!" NEQ "!perc!" (
            set "LAST_NOTIF_PERC=!perc!"
            adb shell cmd notification post -t "SyncDevice" "AutoSync: IMAGES" "Syncing: !perc!%% (!IMG_DONE!/!IMG_TOTAL!)" >nul 2>&1
        )

        call :progress_bar_category !IMG_DONE! !IMG_TOTAL! IMAGES
        call :do_pull "%%A" "MEDIA"
    )
) else ( call :progress_bar_category 0 0 IMAGES )
echo.

:: ---------------------------------------------------------
:: 2. VIDEO SYNCHRONIZATION
:: ---------------------------------------------------------
echo.
echo [6] Synchronizing VIDEOS...
set "VID_DONE=0"
set "LAST_NOTIF_PERC=-1"
if %VID_TOTAL% GTR 0 (
    for /f "usebackq delims=" %%A in (`findstr /i "^Video/" "%TEMPDIR%\all_push.txt" 2^>nul`) do (
        if exist "%TEMPDIR%\stop.flag" goto :graceful_abort
        if exist "%TEMPDIR%\wifi_request.flag" goto :process_remote_request
        set /a VID_DONE+=1

        set /a "perc=(VID_DONE*100)/VID_TOTAL"
        if "!LAST_NOTIF_PERC!" NEQ "!perc!" (
            set "LAST_NOTIF_PERC=!perc!"
            adb shell cmd notification post -t "SyncDevice" "AutoSync: VIDEOS" "Syncing: !perc!%% (!VID_DONE!/!VID_TOTAL!)" >nul 2>&1
        )

        call :progress_bar_category !VID_DONE! !VID_TOTAL! VIDEOS
        call :do_push "%%A" "MEDIA"
    )
    for /f "usebackq delims=" %%A in (`findstr /i "^Video/" "%TEMPDIR%\all_pull.txt" 2^>nul`) do (
        if exist "%TEMPDIR%\stop.flag" goto :graceful_abort
        if exist "%TEMPDIR%\wifi_request.flag" goto :process_remote_request
        set /a VID_DONE+=1

        set /a "perc=(VID_DONE*100)/VID_TOTAL"
        if "!LAST_NOTIF_PERC!" NEQ "!perc!" (
            set "LAST_NOTIF_PERC=!perc!"
            adb shell cmd notification post -t "SyncDevice" "AutoSync: VIDEOS" "Syncing: !perc!%% (!VID_DONE!/!VID_TOTAL!)" >nul 2>&1
        )

        call :progress_bar_category !VID_DONE! !VID_TOTAL! VIDEOS
        call :do_pull "%%A" "MEDIA"
    )
) else ( call :progress_bar_category 0 0 VIDEOS )
echo.

:: ---------------------------------------------------------
:: 3. DOCUMENT SYNCHRONIZATION
:: ---------------------------------------------------------
echo.
echo [7] Synchronizing DOCUMENTS...
set "DOC_DONE=0"
set "LAST_NOTIF_PERC=-1"
if %DOC_TOTAL% GTR 0 (
    for /f "usebackq delims=" %%A in (`findstr /i "^Document/" "%TEMPDIR%\all_push.txt" 2^>nul`) do (
        if exist "%TEMPDIR%\stop.flag" goto :graceful_abort
        if exist "%TEMPDIR%\wifi_request.flag" goto :process_remote_request
        set /a DOC_DONE+=1

        set /a "perc=(DOC_DONE*100)/DOC_TOTAL"
        if "!LAST_NOTIF_PERC!" NEQ "!perc!" (
            set "LAST_NOTIF_PERC=!perc!"
            adb shell cmd notification post -t "SyncDevice" "AutoSync: DOCUMENTS" "Syncing: !perc!%% (!DOC_DONE!/!DOC_TOTAL!)" >nul 2>&1
        )

        call :progress_bar_category !DOC_DONE! !DOC_TOTAL! DOCUMENTS
        call :do_push "%%A" "DOC"
    )
    for /f "usebackq delims=" %%A in (`findstr /i "^Document/" "%TEMPDIR%\all_pull.txt" 2^>nul`) do (
        if exist "%TEMPDIR%\stop.flag" goto :graceful_abort
        if exist "%TEMPDIR%\wifi_request.flag" goto :process_remote_request
        set /a DOC_DONE+=1

        set /a "perc=(DOC_DONE*100)/DOC_TOTAL"
        if "!LAST_NOTIF_PERC!" NEQ "!perc!" (
            set "LAST_NOTIF_PERC=!perc!"
            adb shell cmd notification post -t "SyncDevice" "AutoSync: DOCUMENTS" "Syncing: !perc!%% (!DOC_DONE!/!DOC_TOTAL!)" >nul 2>&1
        )

        call :progress_bar_category !DOC_DONE! !DOC_TOTAL! DOCUMENTS
        call :do_pull "%%A" "DOC"
    )
) else ( call :progress_bar_category 0 0 DOCUMENTS )
echo.

:: ---------------------------------------------------------
:: 4. MISC SYNCHRONIZATION
:: ---------------------------------------------------------
echo.
echo [8] Synchronizing OTHER FILES...
set "MISC_DONE=0"
set "LAST_NOTIF_PERC=-1"
if %MISC_TOTAL% GTR 0 (
    for /f "usebackq delims=" %%A in (`findstr /i /v "^Image/ ^Video/ ^Document/" "%TEMPDIR%\all_push.txt" 2^>nul`) do (
        if exist "%TEMPDIR%\stop.flag" goto :graceful_abort
        if exist "%TEMPDIR%\wifi_request.flag" goto :process_remote_request
        set /a MISC_DONE+=1

        set /a "perc=(MISC_DONE*100)/MISC_TOTAL"
        if "!LAST_NOTIF_PERC!" NEQ "!perc!" (
            set "LAST_NOTIF_PERC=!perc!"
            adb shell cmd notification post -t "SyncDevice" "AutoSync: OTHER" "Syncing: !perc!%% (!MISC_DONE!/!MISC_TOTAL!)" >nul 2>&1
        )

        call :progress_bar_category !MISC_DONE! !MISC_TOTAL! OTHER
        call :do_push "%%A" "DOC"
    )
    for /f "usebackq delims=" %%A in (`findstr /i /v "^Image/ ^Video/ ^Document/" "%TEMPDIR%\all_pull.txt" 2^>nul`) do (
        if exist "%TEMPDIR%\stop.flag" goto :graceful_abort
        if exist "%TEMPDIR%\wifi_request.flag" goto :process_remote_request
        set /a MISC_DONE+=1

        set /a "perc=(MISC_DONE*100)/MISC_TOTAL"
        if "!LAST_NOTIF_PERC!" NEQ "!perc!" (
            set "LAST_NOTIF_PERC=!perc!"
            adb shell cmd notification post -t "SyncDevice" "AutoSync: OTHER" "Syncing: !perc!%% (!MISC_DONE!/!MISC_TOTAL!)" >nul 2>&1
        )

        call :progress_bar_category !MISC_DONE! !MISC_TOTAL! OTHER
        call :do_pull "%%A" "DOC"
    )
) else ( call :progress_bar_category 0 0 OTHER )
echo.

:: ---------------------------------------------------------
:: CHECK FOR CLI MODE EXIT
:: ---------------------------------------------------------
if defined CLI_RUN_MODE (
    echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    echo   [ CLI ] One-Time %CLI_RUN_MODE% Transfer Complete!
    echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    timeout /t 3 >nul
    exit /b
)

:watchdog_sleep_init
:: [VISIBILITY UPDATE] - Tell the user the sync just finished
if "!DID_WORK!"=="1" (
    adb shell cmd notification post -t "SyncDevice" "AutoSync Engine" "Sync Complete! PC and Phone are matched." >nul 2>&1
    set "DID_WORK=0"
)

echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo   [ VERIFIED ] 100%% Synchronized!
echo   PC Holds: %PC_COUNT% files  ^|  Phone Holds: %PH_COUNT% files
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if %TOTAL_TASKS% GTR 0 (
    set "SLEEP_SECONDS=5"
    set "IDLE_CYCLES=0"
) else (
    if not defined IDLE_CYCLES set "IDLE_CYCLES=0"
    set /a IDLE_CYCLES+=1
    if !IDLE_CYCLES! LSS 10 ( set "SLEEP_SECONDS=10" ) else if !IDLE_CYCLES! LSS 50 ( set "SLEEP_SECONDS=30" ) else ( set "SLEEP_SECONDS=60" )
)

echo.
echo [WATCHDOG] Sleeping for %SLEEP_SECONDS% seconds before next scan.
set "SLEEP_REMAINING=%SLEEP_SECONDS%"

:: ---------------------------------------------------------
:: THE SMART HANDOFF LOOP (Instant Remote Control Response)
:: ---------------------------------------------------------
:sleep_tick
if exist "%TEMPDIR%\wifi_request.flag" goto :process_remote_request
if exist "%TEMPDIR%\stop.flag" goto :graceful_abort

:: HEARTBEAT SENSOR: Check if our specifically targeted device is still alive
adb get-state 2>nul | findstr "device" >nul
if errorlevel 1 (
    echo [WATCHDOG] Connection lost to %ANDROID_SERIAL%. Waiting for reconnection...
    set "ANDROID_SERIAL="
    goto :device_discovery
)

timeout /t 1 >nul
set /a SLEEP_REMAINING-=1
if !SLEEP_REMAINING! GTR 0 goto :sleep_tick

if not defined LOOP_COUNT set "LOOP_COUNT=0"
set /a LOOP_COUNT+=1
if %LOOP_COUNT% GEQ 10000 (
    echo.
    echo [SAFETY] Watchdog reached 10,000 cycles. Exiting to prevent runaway loop.
    pause
    exit /b
)
goto :watchdog_loop

:: =========================================================
:: REMOTE CONTROL SWITCHING (Handles Wi-Fi and USB Switches)
:: =========================================================
:process_remote_request
set /p REMOTE_REQ=<"%TEMPDIR%\wifi_request.flag"
del /q "%TEMPDIR%\wifi_request.flag" >nul 2>&1

if "!REMOTE_REQ!"=="USB" (
    echo.
    echo !ESC![1G!ESC![2K━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    echo   [ SWITCHING TO USB MODE ]
    echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    echo   - Disconnecting Wi-Fi and clearing ports...
    adb kill-server >nul 2>&1
    taskkill /F /IM adb.exe /T >nul 2>&1
    timeout /t 2 >nul
    adb start-server >nul 2>&1
    echo   - Falling back to physical cable...
    set "ANDROID_SERIAL="
    timeout /t 2 >nul
    goto :device_discovery
)

echo.
echo !ESC![1G!ESC![2K━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo   [ SWITCHING TO WI-FI MODE ]
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if "!REMOTE_REQ!"=="AUTO" (
    echo   - Auto-detecting Wi-Fi IP from current connection...
    set "WIFI_IP="
    for /f "tokens=2 delims= " %%A in ('adb shell "ip -f inet addr show wlan0" 2^>nul ^| findstr "inet "') do (
        set "WIFI_IP_RAW=%%A"
    )
    for /f "tokens=1 delims=/" %%A in ("!WIFI_IP_RAW!") do set "WIFI_IP=%%A"
) else (
    set "WIFI_IP=!REMOTE_REQ!"
)

if "!WIFI_IP!"=="" (
    echo   [ERROR] Could not find a Wi-Fi IP. Make sure phone is connected to Wi-Fi.
    goto :watchdog_sleep_init
)

echo   - IP Target: !WIFI_IP!
echo   - Restarting ADB in TCP mode (Port 5555)...
adb tcpip 5555 >nul 2>&1
timeout /t 3 >nul

:: Kill active USB connections cleanly before forcing the Wi-Fi pairing
echo   - Clearing background ports...
adb kill-server >nul 2>&1
taskkill /F /IM adb.exe /T >nul 2>&1
timeout /t 2 >nul
adb start-server >nul 2>&1

echo   - Connecting wirelessly...
adb connect !WIFI_IP!:5555 >nul 2>&1

echo.
echo   [ SUCCESS ] Phone paired wirelessly!
echo   You may now UNPLUG the USB cable.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
set "TARGET_WIFI_IP=!WIFI_IP!"
timeout /t 3 >nul
goto :device_discovery

:: ---------------------------------------------------------
:: TRANSFER SUBROUTINES
:: ---------------------------------------------------------
:setup_shortcuts
echo [1] Updating Desktop and Folder Interfaces...
for %%S in ("SyncDevice Folder" "SyncDevice AutoSync" "SyncDevice AutoWatcher" "Directory Explorer" "Safe Stop AutoSync") do (
    if exist "%USERPROFILE%\Desktop\%%~S.lnk" del /f /q "%USERPROFILE%\Desktop\%%~S.lnk"
)
set "PS_LINK=$WshShell = New-Object -ComObject WScript.Shell; $iconPath = '%IconBank%\SyncDevice.ico'; if (-not (Test-Path $iconPath)) { $iconPath = '%IconBank%\icon.ico' }; $Sc = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\SyncDevice.lnk'); $Sc.TargetPath = '%PCFOLDER%'; if (Test-Path $iconPath) { $Sc.IconLocation = $iconPath + ',0' }; $Sc.Save();"
powershell -NoProfile -ExecutionPolicy Bypass -Command "& { %PS_LINK% }" >nul 2>&1

set "PS_MANUAL=$WshShell = New-Object -ComObject WScript.Shell; $iconPath = '%IconBank%\SyncDevice.ico'; if (-not (Test-Path $iconPath)) { $iconPath = '%IconBank%\icon.ico' }; $Sc2 = $WshShell.CreateShortcut('%PCFOLDER%\Start AutoSync Engine.lnk'); $Sc2.TargetPath = '%ENGINE_DIR%\SyncDevice.bat'; if (Test-Path $iconPath) { $Sc2.IconLocation = $iconPath + ',0' }; $Sc2.Save();"
powershell -NoProfile -ExecutionPolicy Bypass -Command "& { %PS_MANUAL% }" >nul 2>&1

set "PS_STOP=$WshShell = New-Object -ComObject WScript.Shell; $Sc4 = $WshShell.CreateShortcut('%PCFOLDER%\Safe Stop AutoSync.lnk'); $Sc4.TargetPath = 'cmd.exe'; $Sc4.Arguments = '/c echo STOP > ""%TEMPDIR%\stop.flag""'; $Sc4.IconLocation = 'shell32.dll,27'; $Sc4.Save();"
powershell -NoProfile -ExecutionPolicy Bypass -Command "& { %PS_STOP% }" >nul 2>&1
goto :eof

:dynamic_icons
echo [2] Scanning ICO Library...
set "categories="
for %%F in ("%IconBank%\*.ico") do (
    set "fname=%%~nF"
    set "ignore=0"
    if /i "!fname!"=="icon" set "ignore=1"
    if /i "!fname!"=="SyncDevice" set "ignore=1"
    if "!ignore!"=="0" (
        if not exist "%PCFOLDER%\!fname!" mkdir "%PCFOLDER%\!fname!"
        set "ini=%PCFOLDER%\!fname!\desktop.ini"
        attrib -s -h "!ini!" >nul 2>&1
        (echo [.ShellClassInfo] 
        echo IconResource=%%~fF,0) > "!ini!"
        attrib +s +h "!ini!" & attrib +r "%PCFOLDER%\!fname!"
        set "categories=!categories! !fname!"
    )
)
ie4uinit.exe -show >nul 2>&1
goto :eof

:progress_bar_category
setlocal EnableDelayedExpansion
set "cur=%~1"
set "max=%~2"
set "label=%~3"
set "pad=         "
set "label=!label!!pad!"
set "label=!label:~0,9!"

if "%max%"=="0" (
    set "bar=-------------------------"
    <nul set /p="!ESC![1G!ESC![2K[!label!] !bar! 100%%   "
    endlocal
    goto :eof
)

set /a perc=(cur*100)/max
if !perc! GTR 100 set perc=100
set /a bars=perc/4

set "bar="
for /L %%A in (1,1,!bars!) do set "bar=!bar!#"
set /a empty=25-bars
if !empty! GTR 0 (
    for /L %%A in (1,1,!empty!) do set "bar=!bar!-"
)

<nul set /p="!ESC![1G!ESC![2K[!label!] !bar! !perc!%%   "
endlocal
goto :eof

:do_push
set "rel=%~1"
set "TYPE=%~2"
set "Z="
if "%TYPE%"=="DOC" set "Z=z"

set "win_rel=!rel:/=\!"
set "pc_path=%PCFOLDER%\!win_rel!"
set "ph_path=%PHONEFOLDER%/!rel!"
set "ph_parent=!ph_path!/.."
adb shell "mkdir -p \"!ph_parent!\"" >nul 2>&1

tar -c!Z!f - "!pc_path!" 2>nul | adb exec-in "tar -x!Z!f - -C \"%PHONEFOLDER%\"" 2>nul
goto :eof

:do_pull
set "rel=%~1"
set "TYPE=%~2"
set "Z="
if "%TYPE%"=="DOC" set "Z=z"

set "win_rel=!rel:/=\!"
set "pc_path=%PCFOLDER%\!win_rel!"
for %%F in ("!pc_path!") do if not exist "%%~dpF" mkdir "%%~dpF"

adb exec-out "tar -c!Z!f - -C \"%PHONEFOLDER%\" \"!rel!\"" 2>nul | tar -x!Z!f - -C "%PCFOLDER%" 2>nul
goto :eof

:graceful_abort
echo.
echo !ESC![1G!ESC![2K━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo   [ 🛑 ABORT ] Safe Stop Requested!
echo   Finishing current file, gracefully shutting down ADB...
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
del /q "%TEMPDIR%\stop.flag" >nul 2>&1
adb kill-server >nul 2>&1
taskkill /F /IM adb.exe /T >nul 2>&1
timeout /t 3 >nul
exit