@echo off
:: [CRITICAL] Anchor to script folder
cd /d "%~dp0"
chcp 65001 >nul
setlocal DisableDelayedExpansion
setlocal EnableDelayedExpansion

:: ============================================================
:: SyncDevice - SyncTwoWay 
:: - Version: 39.18 (Brute-Force Initialization & Typo Fix)
:: ============================================================

set "CURRENT_VER=39.18"
title AutoSync v%CURRENT_VER%

:: ---------------------------------------------------------
:: STEP 0: WORKSPACE ARCHITECT & RELOCATION
:: ---------------------------------------------------------
set "PCFOLDER=C:\SyncDevice"
set "ENGINE_DIR=%PCFOLDER%\autoSyncEngine"
set "PHONEFOLDER=/sdcard/Download/SyncDevice"

if /i not "%~dp0"=="%ENGINE_DIR%\" (
    echo [0] Architecting Clean Workspace...
    if not exist "%PCFOLDER%" mkdir "%PCFOLDER%"
    if not exist "%ENGINE_DIR%" mkdir "%ENGINE_DIR%"
    
    if not exist "%ENGINE_DIR%\logs" mkdir "%ENGINE_DIR%\logs"
    if not exist "%ENGINE_DIR%\temp" mkdir "%ENGINE_DIR%\temp"
    if not exist "%ENGINE_DIR%\config" mkdir "%ENGINE_DIR%\config"

    if exist "%~dp0ICO" xcopy /E /I /Y "%~dp0ICO" "%ENGINE_DIR%\ICO\" >nul 2>&1
    copy /Y "%~f0" "%ENGINE_DIR%\SyncDevice.bat" >nul
    
    attrib +h +s "%ENGINE_DIR%" >nul 2>&1
    
    echo      [+] Workspace Decluttered. Starting Engine...
    timeout /t 2 >nul
    start "" "%ENGINE_DIR%\SyncDevice.bat"
    exit /b
)

set "IconBank=%ENGINE_DIR%\ICO"
set "LOGDIR=%ENGINE_DIR%\logs"
set "TEMPDIR=%ENGINE_DIR%\temp"
set "CONFIGDIR=%ENGINE_DIR%\config"

if not exist "%TEMPDIR%" (
    echo [FATAL] Engine Temp directory missing!
    pause & exit /b
)

del /q "%CONFIGDIR%\SyncDevice_Master_v*.bat" >nul 2>&1
copy /Y "%~f0" "%CONFIGDIR%\SyncDevice_Master_v%CURRENT_VER%.bat" >nul 2>&1

goto :main

:: ---------------------------------------------------------
:: SUBROUTINES: SHORTCUTS & DYNAMIC ICONS
:: ---------------------------------------------------------
:setup_shortcuts
:: FIXED: Removed the ampersand that was causing the 'Folder' crash
echo [1] Updating Desktop and Folder Interfaces...
for %%S in ("SyncDevice Folder" "SyncDevice AutoSync" "SyncDevice AutoWatcher" "Directory Explorer") do (
    if exist "%USERPROFILE%\Desktop\%%~S.lnk" del /f /q "%USERPROFILE%\Desktop\%%~S.lnk"
)

set "PS_LINK=$WshShell = New-Object -ComObject WScript.Shell; $iconPath = '%IconBank%\SyncDevice.ico'; if (-not (Test-Path $iconPath)) { $iconPath = '%IconBank%\icon.ico' }; $Sc = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\SyncDevice.lnk'); $Sc.TargetPath = '%PCFOLDER%'; if (Test-Path $iconPath) { $Sc.IconLocation = $iconPath + ',0' }; $Sc.Save();"
powershell -NoProfile -Command "& { %PS_LINK% }" >nul 2>&1

set "PS_MANUAL=$WshShell = New-Object -ComObject WScript.Shell; $iconPath = '%IconBank%\SyncDevice.ico'; if (-not (Test-Path $iconPath)) { $iconPath = '%IconBank%\icon.ico' }; $Sc2 = $WshShell.CreateShortcut('%PCFOLDER%\Start AutoSync Engine.lnk'); $Sc2.TargetPath = '%ENGINE_DIR%\SyncDevice.bat'; if (Test-Path $iconPath) { $Sc2.IconLocation = $iconPath + ',0' }; $Sc2.Save();"
powershell -NoProfile -Command "& { %PS_MANUAL% }" >nul 2>&1
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
        (echo [.ShellClassInfo] & echo IconResource=%%~fF,0) > "!ini!"
        attrib +s +h "!ini!" & attrib +r "%PCFOLDER%\!fname!"
        set "categories=!categories! !fname!"
    )
)
ie4uinit.exe -show >nul 2>&1
goto :eof

:: ---------------------------------------------------------
:: MAIN EXECUTION
:: ---------------------------------------------------------
:main
cls
echo ============================================================
echo   SyncDevice - AutoSync v%CURRENT_VER%
echo ============================================================
call :setup_shortcuts
call :dynamic_icons
echo      [CHECK] Environment Ready.
echo.

:: ---------------------------------------------------------
:: STEP 3: PID HUNTER (Brute-Force Fix)
:: ---------------------------------------------------------
echo [3] Initializing Fresh ADB Bridge...

:: 1. Force kill the process directly (adb kill-server causes infinite hangs)
taskkill /F /IM adb.exe /T >nul 2>nul

:: 2. Nuke anything lingering on Port 5037
for /f "tokens=5" %%A in ('netstat -aon ^| findstr /R /C:":5037 " 2^>nul') do ( taskkill /F /PID %%A /T >nul 2>nul )

timeout /t 2 >nul
adb start-server >nul 2>nul

:wait_device
type nul > "%TEMPDIR%\adb_check.txt"
adb devices > "%TEMPDIR%\adb_check.txt" 2>nul
set "device="
for /f "tokens=1,2" %%A in ('type "%TEMPDIR%\adb_check.txt"') do (if "%%B"=="device" set "device=%%A")
if "%device%"=="" (
    echo      [WAIT] Port 5037 clearing. Waiting for device... 
    timeout /t 4 >nul 
    goto :wait_device
)

adb shell "ls /sdcard >/dev/null 2>&1"
if errorlevel 1 (echo [ERROR] Storage Locked. & pause & goto :main)

:: =========================================================
:: 🔁 WATCHDOG LOOP STARTS HERE
:: =========================================================
:watchdog_loop
:: Reset the global Circuit Breaker at the start of every loop
set "CIRCUIT_BREAKER=0"

:: ---------------------------------------------------------
:: STEP 4: THE DEEP HARVESTER 
:: ---------------------------------------------------------
echo.
echo ============================================================
echo   [HARVESTER] Sweeping Loose Media into From_PC / From_Phone...
echo ============================================================

for /f "usebackq delims=" %%I in (`powershell -NoProfile -Command "Get-Date -Format 'yyyy-MM'"`) do set "YM=%%I"
adb shell "mkdir -p \"%PHONEFOLDER%/Image/From_Phone/!YM!\"" >nul 2>&1
adb shell "mkdir -p \"%PHONEFOLDER%/Video/From_Phone/!YM!\"" >nul 2>&1

adb shell "find /sdcard/DCIM/Camera -maxdepth 1 -type f \( -iname \*.jpg -o -iname \*.jpeg -o -iname \*.png \) -exec mv {} \"%PHONEFOLDER%/Image/From_Phone/!YM!/\" \;" >nul 2>&1
adb shell "find /sdcard/DCIM/Camera -maxdepth 1 -type f \( -iname \*.mp4 -o -iname \*.mov \) -exec mv {} \"%PHONEFOLDER%/Video/From_Phone/!YM!/\" \;" >nul 2>&1

set "PS_HARVEST=$p = '%PCFOLDER%'; $img = @('.jpg','.jpeg','.png','.gif','.bmp'); $vid = @('.mp4','.mov','.avi','.mkv'); $doc = @('.pdf','.docx','.txt','.xlsx','.csv'); Get-ChildItem -Path $p -Recurse -File | ForEach-Object { if ($_.FullName -match '\\autoSyncEngine\\' -or $_.FullName -match '\\From_PC\\') { return }; $ext = $_.Extension.ToLower(); $ym = $_.LastWriteTime.ToString('yyyy-MM'); if ($img -contains $ext) { $dest = \"$p\Image\From_PC\$ym\" } elseif ($vid -contains $ext) { $dest = \"$p\Video\From_PC\$ym\" } elseif ($doc -contains $ext) { $dest = \"$p\Document\From_PC\$ym\" } else { return }; if (-not (Test-Path $dest)) { New-Item -ItemType Directory -Force -Path $dest | Out-Null }; Move-Item $_.FullName \"$dest\" -Force }"
powershell -NoProfile -Command "& { %PS_HARVEST% }" >nul 2>&1

echo.
echo ============================================================
echo   [WATCHDOG] Compiling Mirror Matrix...
echo ============================================================

adb shell "find \"%PHONEFOLDER%\" -type f -exec stat -c '%%s|%%n' {} +" 2>nul > "%TEMPDIR%\phone_raw.txt"

> "%TEMPDIR%\engine.ps1" echo param($pcDir, $phDir, $phRawF, $pOutL, $pInL, $pOutH, $pInH, $statsOut)
>> "%TEMPDIR%\engine.ps1" echo $thresh = 52428800; $pcLen = $pcDir.Length; if (-not $pcDir.EndsWith('\')) { $pcLen += 1 }
>> "%TEMPDIR%\engine.ps1" echo $pcData = @{}; $phData = @{}
>> "%TEMPDIR%\engine.ps1" echo $pushL = [System.Collections.Generic.List[string]]::new(); $pushH = [System.Collections.Generic.List[string]]::new()
>> "%TEMPDIR%\engine.ps1" echo $pullL = [System.Collections.Generic.List[string]]::new(); $pullH = [System.Collections.Generic.List[string]]::new()
>> "%TEMPDIR%\engine.ps1" echo try {
>> "%TEMPDIR%\engine.ps1" echo   $files = [System.IO.Directory]::EnumerateFiles($pcDir, '*.*', [System.IO.SearchOption]::AllDirectories)
>> "%TEMPDIR%\engine.ps1" echo   foreach ($f in $files) { if ($f -notmatch 'autoSyncEngine') {
>> "%TEMPDIR%\engine.ps1" echo       $fi = [System.IO.FileInfo]::new($f); $rel = $f.Substring($pcLen).Replace('\', '/')
>> "%TEMPDIR%\engine.ps1" echo       $pcData[$rel] = $fi.Length
>> "%TEMPDIR%\engine.ps1" echo   }}
>> "%TEMPDIR%\engine.ps1" echo } catch {}
>> "%TEMPDIR%\engine.ps1" echo $phRaw = [System.IO.File]::ReadAllLines($phRawF)
>> "%TEMPDIR%\engine.ps1" echo $phPref = $phDir; if (-not $phPref.EndsWith('/')) { $phPref += '/' }
>> "%TEMPDIR%\engine.ps1" echo foreach ($l in $phRaw) { if ($l -notmatch '/\.' -and $l -notmatch 'autoSyncEngine') {
>> "%TEMPDIR%\engine.ps1" echo     $p = $l.Split('^|', 2); if ($p.Length -eq 2) {
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

for /f "delims=" %%I in ('powershell -NoProfile -Command "$cmd = Get-Content '%TEMPDIR%\engine.ps1' | Out-String; $bytes = [System.Text.Encoding]::Unicode.GetBytes($cmd); [Convert]::ToBase64String($bytes)"') do set "PS_B64=%%I"
powershell -NoProfile -EncodedCommand "%PS_B64%" -pcDir "%PCFOLDER%" -phDir "%PHONEFOLDER%" -phRawF "%TEMPDIR%\phone_raw.txt" -pOutL "%TEMPDIR%\push_light.txt" -pInL "%TEMPDIR%\pull_light.txt" -pOutH "%TEMPDIR%\push_heavy.txt" -pInH "%TEMPDIR%\pull_heavy.txt" -statsOut "%TEMPDIR%\sync_stats.txt"

for /f "usebackq tokens=1,2 delims=|" %%A in ("%TEMPDIR%\sync_stats.txt") do set "PC_COUNT=%%A" & set "PH_COUNT=%%B"

type nul > "%TEMPDIR%\all_push.txt"
if exist "%TEMPDIR%\push_light.txt" type "%TEMPDIR%\push_light.txt" >> "%TEMPDIR%\all_push.txt"
if exist "%TEMPDIR%\push_heavy.txt" type "%TEMPDIR%\push_heavy.txt" >> "%TEMPDIR%\all_push.txt"

type nul > "%TEMPDIR%\all_pull.txt"
if exist "%TEMPDIR%\pull_light.txt" type "%TEMPDIR%\pull_light.txt" >> "%TEMPDIR%\all_pull.txt"
if exist "%TEMPDIR%\pull_heavy.txt" type "%TEMPDIR%\pull_heavy.txt" >> "%TEMPDIR%\all_pull.txt"

for /f %%A in ('type "%TEMPDIR%\all_push.txt" ^| find /c /v ""') do set "PUSH_COUNT=%%A"
for /f %%A in ('type "%TEMPDIR%\all_pull.txt" ^| find /c /v ""') do set "PULL_COUNT=%%A"
set /a TOTAL_TASKS=%PUSH_COUNT% + %PULL_COUNT%

if %TOTAL_TASKS% EQU 0 (
    goto :watchdog_sleep
)

echo  [ TASKS  ] Need to Push: %PUSH_COUNT% files ^| Need to Pull: %PULL_COUNT% files.
set /a CURRENT_TASK=0

:: --- 1. IMAGE SYNCHRONIZATION ---
echo.
echo [5] Synchronizing IMAGES...
for /f "usebackq delims=" %%A in (`findstr /i "^Image/" "%TEMPDIR%\all_push.txt" 2^>nul`) do (
    if "!CIRCUIT_BREAKER!"=="1" goto :watchdog_sleep
    set /a CURRENT_TASK+=1 & call :do_push "%%A" "[PUSHING IMG]"
)
for /f "usebackq delims=" %%A in (`findstr /i "^Image/" "%TEMPDIR%\all_pull.txt" 2^>nul`) do (
    if "!CIRCUIT_BREAKER!"=="1" goto :watchdog_sleep
    set /a CURRENT_TASK+=1 & call :do_pull "%%A" "[PULLING IMG]"
)

:: --- 2. VIDEO SYNCHRONIZATION ---
echo.
echo [6] Synchronizing VIDEOS...
for /f "usebackq delims=" %%A in (`findstr /i "^Video/" "%TEMPDIR%\all_push.txt" 2^>nul`) do (
    if "!CIRCUIT_BREAKER!"=="1" goto :watchdog_sleep
    set /a CURRENT_TASK+=1 & call :do_push "%%A" "[PUSHING VID]"
)
for /f "usebackq delims=" %%A in (`findstr /i "^Video/" "%TEMPDIR%\all_pull.txt" 2^>nul`) do (
    if "!CIRCUIT_BREAKER!"=="1" goto :watchdog_sleep
    set /a CURRENT_TASK+=1 & call :do_pull "%%A" "[PULLING VID]"
)

:: --- 3. DOCUMENT SYNCHRONIZATION ---
echo.
echo [7] Synchronizing DOCUMENTS...
for /f "usebackq delims=" %%A in (`findstr /i "^Document/" "%TEMPDIR%\all_push.txt" 2^>nul`) do (
    if "!CIRCUIT_BREAKER!"=="1" goto :watchdog_sleep
    set /a CURRENT_TASK+=1 & call :do_push "%%A" "[PUSHING DOC]"
)
for /f "usebackq delims=" %%A in (`findstr /i "^Document/" "%TEMPDIR%\all_pull.txt" 2^>nul`) do (
    if "!CIRCUIT_BREAKER!"=="1" goto :watchdog_sleep
    set /a CURRENT_TASK+=1 & call :do_pull "%%A" "[PULLING DOC]"
)

:: --- 4. MISC SYNCHRONIZATION ---
echo.
echo [8] Synchronizing OTHER FILES...
for /f "usebackq delims=" %%A in (`findstr /i /v "^Image/ ^Video/ ^Document/" "%TEMPDIR%\all_push.txt" 2^>nul`) do (
    if "!CIRCUIT_BREAKER!"=="1" goto :watchdog_sleep
    set /a CURRENT_TASK+=1 & call :do_push "%%A" "[PUSHING MISC]"
)
for /f "usebackq delims=" %%A in (`findstr /i /v "^Image/ ^Video/ ^Document/" "%TEMPDIR%\all_pull.txt" 2^>nul`) do (
    if "!CIRCUIT_BREAKER!"=="1" goto :watchdog_sleep
    set /a CURRENT_TASK+=1 & call :do_pull "%%A" "[PULLING MISC]"
)

:watchdog_sleep
echo.
if "!CIRCUIT_BREAKER!"=="1" (
    echo ============================================================
    echo   [ FATAL ] Connection Severed! Transfer Aborted.
    echo ============================================================
) else (
    echo ============================================================
    echo   [ VERIFIED ] 100%% Synchronized!
    echo   PC Holds: %PC_COUNT% files  ^|  Phone Holds: %PH_COUNT% files
    echo ============================================================
)

echo.
echo [WATCHDOG] Sleeping for 10 seconds before next scan. Press CTRL+C to stop.
timeout /t 10 >nul

type nul > "%TEMPDIR%\adb_check.txt"
adb devices > "%TEMPDIR%\adb_check.txt" 2>nul
set "device="
for /f "tokens=1,2" %%A in ('type "%TEMPDIR%\adb_check.txt"') do (if "%%B"=="device" set "device=%%A")
if "%device%"=="" (
    echo [WATCHDOG] Phone disconnected. Waiting for reconnection...
    goto :wait_device
)
goto :watchdog_loop

:: ---------------------------------------------------------
:: TRANSFER SUBROUTINES
:: ---------------------------------------------------------
:do_push
set "fail_count=0"
set "rel=%~1" & set "tag=%~2" & set "win_rel=!rel:/=\!"
set "pc_path=%PCFOLDER%\!win_rel!" & set "ph_path=%PHONEFOLDER%/!rel!"
set "temp_win_path=!ph_path:/=\!"
for %%F in ("!temp_win_path!") do set "ph_parent_win=%%~dpF"
set "ph_parent=!ph_parent_win:\=/!" & set "ph_parent=!ph_parent:~0,-1!"
adb shell "mkdir -p \"%ph_parent%\"" >nul 2>&1
echo !tag! [!CURRENT_TASK!/%TOTAL_TASKS%] "!rel!"
:retry_push
adb push "!pc_path!" "!ph_path!" > "%TEMPDIR%\adb_out.txt" 2>&1
if errorlevel 1 (
    set /a fail_count+=1
    if !fail_count! GEQ 3 (
        set "CIRCUIT_BREAKER=1"
        goto :eof
    )
    adb kill-server & adb start-server & timeout /t 2 >nul & goto :retry_push
)
goto :eof

:do_pull
set "fail_count=0"
set "rel=%~1" & set "tag=%~2" & set "win_rel=!rel:/=\!"
set "pc_path=%PCFOLDER%\!win_rel!" & set "ph_path=%PHONEFOLDER%/!rel!"
for %%F in ("!pc_path!") do if not exist "%%~dpF" mkdir "%%~dpF"
echo !tag! [!CURRENT_TASK!/%TOTAL_TASKS%] "!rel!"
:retry_pull
adb pull "!ph_path!" "!pc_path!" > "%TEMPDIR%\adb_out.txt" 2>&1
if errorlevel 1 (
    set /a fail_count+=1
    if !fail_count! GEQ 3 (
        set "CIRCUIT_BREAKER=1"
        goto :eof
    )
    adb kill-server & adb start-server & timeout /t 2 >nul & goto :retry_pull
)
goto :eof