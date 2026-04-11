@echo off
:: [CRITICAL] Anchor to script folder for Admin runs and paths with spaces
cd /d "%~dp0"
chcp 65001 >nul
setlocal DisableDelayedExpansion
title SyncDevice - SyncTwoWay v39.0 (Locked Master)

:: ============================================================
:: SyncDevice - SyncTwoWay 
:: - Version: 39.0 (Final Locked Architecture & AutoWatcher)
:: ============================================================

set "CURRENT_VER=39.0"

:: PATH CONFIGURATION
set "PCFOLDER=C:\SyncDevice"
set "ENGINE_DIR=%PCFOLDER%\autoSyncEngine"
set "PHONEFOLDER=/sdcard/Download/SyncDevice"
set "IconBank=%~dp0ICO"

set "LOGDIR=%ENGINE_DIR%\logs"
set "TEMPDIR=%ENGINE_DIR%\temp"
set "CONFIGDIR=%ENGINE_DIR%\config"
set "SYNCLOG=%LOGDIR%\sync_log.txt"
set "FAILED_LOG=%LOGDIR%\failed_transfers.txt"

:: Initialize local system architecture
if not exist "%PCFOLDER%" mkdir "%PCFOLDER%"
if not exist "%LOGDIR%" mkdir "%LOGDIR%"
if not exist "%TEMPDIR%" mkdir "%TEMPDIR%"
if not exist "%CONFIGDIR%" mkdir "%CONFIGDIR%"

goto :main

:log_sync
>>"%SYNCLOG%" echo [%date% %time%] %*
goto :eof

:main
cls
echo ============================================================
echo   SyncDevice - SyncTwoWay v%CURRENT_VER%
echo ============================================================
echo Data folder   : %PCFOLDER%
echo Phone folder  : %PHONEFOLDER%
echo ============================================================
echo.

:: ---------------------------------------------------------
:: STEP 0: WORKSPACE ARCHITECT & SELF-PRESERVATION
:: ---------------------------------------------------------
echo [0] Architecting PC Workspace and Securing Engine...

:: Clean old master backups on PC
del /q "%CONFIGDIR%\SyncDevice_Master_v*.bat" >nul 2>&1
set "MASTER_BACKUP=%CONFIGDIR%\SyncDevice_Master_v%CURRENT_VER%.bat"
copy /Y "%~f0" "%MASTER_BACKUP%" >nul 2>&1

:: Apply Master Icon to the Root C:\SyncDevice Folder
if exist "%IconBank%\icon.ico" (
    if not exist "%PCFOLDER%\.assets\folder.ico" (
        echo      [+] Applying Main Icon to: %PCFOLDER%
        mkdir "%PCFOLDER%\.assets" >nul 2>&1
        copy /Y "%IconBank%\icon.ico" "%PCFOLDER%\.assets\folder.ico" >nul 2>&1
        attrib +h +s "%PCFOLDER%\.assets" >nul 2>&1
        attrib +h +s "%PCFOLDER%\.assets\folder.ico" >nul 2>&1
        powershell -NoProfile -Command "$path='%PCFOLDER%\desktop.ini'; $content = '[.ShellClassInfo]', 'IconResource=.assets\folder.ico,0', '[ViewState]', 'Mode=', 'Vid=', 'FolderType=Generic'; $content | Out-File -FilePath $path -Encoding ascii -Force"
        attrib +h +s "%PCFOLDER%\desktop.ini" >nul 2>&1
        attrib +r "%PCFOLDER%" >nul 2>&1
    )
)

:: Apply Icons to Subcategories
set "categories=Document Download Image Music Video"
for %%C in (%categories%) do (
    call :apply_folder_icon "%%C"
)
ie4uinit.exe -show >nul 2>&1
echo      Workspace Setup Complete.
echo.

:: ---------------------------------------------------------
:: STEP 1: DESKTOP SHORTCUT & WATCHER PROTOCOL
:: ---------------------------------------------------------
set "SHORTCUT_SYNC=%USERPROFILE%\Desktop\SyncDevice AutoSync.lnk"
set "SHORTCUT_DIR=%USERPROFILE%\Desktop\SyncDevice Folder.lnk"
set "SHORTCUT_WATCHER=%USERPROFILE%\Desktop\SyncDevice AutoWatcher.lnk"

if not exist "%SHORTCUT_SYNC%" (
    call :make_shortcuts
    echo      Shortcuts and AutoWatcher created on Desktop.
    echo.
) else if not exist "%SHORTCUT_WATCHER%" (
    call :make_shortcuts
    echo      Shortcuts and AutoWatcher created on Desktop.
    echo.
)

:: ---------------------------------------------------------
:: STEP 2: ADB COLD BOOT & STORAGE PERMISSION AUDIT
:: ---------------------------------------------------------
echo [2] Initializing Fresh ADB Bridge...
taskkill /F /IM adb.exe /T >nul 2>&1
timeout /t 2 >nul
adb start-server >nul 2>&1

:wait_device
:: Write to text file to prevent window freezing
adb devices > "%TEMPDIR%\adb_check.txt" 2>&1
set "device="
set "dev_state=missing"

for /f "tokens=1,2" %%A in ('type "%TEMPDIR%\adb_check.txt"') do (
    if "%%B"=="device" (
        set "device=%%A"
        set "dev_state=device"
    )
    if "%%B"=="unauthorized" set "dev_state=unauthorized"
    if "%%B"=="offline" set "dev_state=offline"
)

if "%device%"=="" (
    if "%dev_state%"=="unauthorized" (
        echo      [ACTION REQUIRED] Phone is UNAUTHORIZED. Tap "Allow USB Debugging" on phone screen.
    ) else (
        echo      Waiting for device... Ensure it is plugged in and USB Debugging is ON.
    )
    timeout /t 4 >nul & goto :wait_device
)

echo [3] Auditing Phone Storage Permissions...
adb shell "ls /sdcard >/dev/null 2>&1"
if errorlevel 1 (
    echo.
    echo [WARNING] Android Storage appears to be LOCKED.
    echo ------------------------------------------------------------
    echo 1. Tap ALLOW on the "Allow access to phone data?" popup.
    echo 2. Set USB mode to "File Transfer".
    echo ------------------------------------------------------------
    powershell -c "[console]::beep(400,1000)" >nul 2>&1
    choice /C RB /N /M "Press [R] to Retry check, or [B] to Bypass if you are sure it is unlocked: "
    if errorlevel 2 goto :bypass_audit
    if errorlevel 1 goto :main
)
:bypass_audit

for /f "usebackq tokens=*" %%B in (`adb shell getprop ro.product.brand 2^>nul`) do set "DEV_BRAND=%%B"
for /f "usebackq tokens=*" %%M in (`adb shell getprop ro.product.model 2^>nul`) do set "DEV_MODEL=%%M"
echo      Connected: %DEV_BRAND% %DEV_MODEL% (%device%)

:: Purge old engine backups on the phone to prevent ghost pulls
adb shell rm -f %PHONEFOLDER%/autoSyncEngine/config/SyncDevice_Master_v*.bat >nul 2>&1

:: Synchronize category structure to Phone
for %%C in (%categories%) do adb shell "mkdir -p \"%PHONEFOLDER%/%%C\"" >nul 2>&1
adb shell "mkdir -p \"%PHONEFOLDER%/autoSyncEngine\"" >nul 2>&1

:: ---------------------------------------------------------
:: STEP 3: TWO-WAY FUSION SCAN
:: ---------------------------------------------------------
echo.
echo [4] Compiling Mirror Matrix...
adb shell "find \"%PHONEFOLDER%\" -type f -exec stat -c '%%s|%%n' {} +" 2>nul > "%TEMPDIR%\phone_raw.txt"

:: .NET Fusion Engine
> "%TEMPDIR%\engine.ps1" echo param($pcDir, $phDir, $phRawF, $pcOut, $phOut, $pushOut, $pullOut)
>> "%TEMPDIR%\engine.ps1" echo $pcLen = $pcDir.Length; if (-not $pcDir.EndsWith('\')) { $pcLen += 1 }
>> "%TEMPDIR%\engine.ps1" echo $pcData = @{}; $phData = @{}
>> "%TEMPDIR%\engine.ps1" echo $pcList = [System.Collections.Generic.List[string]]::new()
>> "%TEMPDIR%\engine.ps1" echo try {
>> "%TEMPDIR%\engine.ps1" echo   $files = [System.IO.Directory]::EnumerateFiles($pcDir, '*.*', [System.IO.SearchOption]::AllDirectories)
>> "%TEMPDIR%\engine.ps1" echo   foreach ($f in $files) {
>> "%TEMPDIR%\engine.ps1" echo     if ($f -notmatch 'autoSyncEngine\\temp' -and $f -notmatch 'autoSyncEngine\\logs') {
>> "%TEMPDIR%\engine.ps1" echo       $fi = [System.IO.FileInfo]::new($f)
>> "%TEMPDIR%\engine.ps1" echo       $rel = $f.Substring($pcLen).Replace('\', '/')
>> "%TEMPDIR%\engine.ps1" echo       $pcData[$rel] = $fi.Length
>> "%TEMPDIR%\engine.ps1" echo       $pcList.Add($fi.Length.ToString() + '^|' + $rel)
>> "%TEMPDIR%\engine.ps1" echo     }
>> "%TEMPDIR%\engine.ps1" echo   }
>> "%TEMPDIR%\engine.ps1" echo } catch {}
>> "%TEMPDIR%\engine.ps1" echo [System.IO.File]::WriteAllLines($pcOut, $pcList)
>> "%TEMPDIR%\engine.ps1" echo $phRaw = [System.IO.File]::ReadAllLines($phRawF)
>> "%TEMPDIR%\engine.ps1" echo $phList = [System.Collections.Generic.List[string]]::new()
>> "%TEMPDIR%\engine.ps1" echo $phPref = $phDir; if (-not $phPref.EndsWith('/')) { $phPref += '/' }
>> "%TEMPDIR%\engine.ps1" echo foreach ($l in $phRaw) {
>> "%TEMPDIR%\engine.ps1" echo   if ($l -notmatch '/\.') {
>> "%TEMPDIR%\engine.ps1" echo     $p = $l.Split('^|', 2)
>> "%TEMPDIR%\engine.ps1" echo     if ($p.Length -eq 2) {
>> "%TEMPDIR%\engine.ps1" echo       $rel = $p[1]
>> "%TEMPDIR%\engine.ps1" echo       if ($rel.StartsWith($phPref)) { $rel = $rel.Substring($phPref.Length) }
>> "%TEMPDIR%\engine.ps1" echo       $phData[$rel] = [bigint]$p[0].Trim()
>> "%TEMPDIR%\engine.ps1" echo       $phList.Add($p[0].Trim() + '^|' + $rel)
>> "%TEMPDIR%\engine.ps1" echo     }
>> "%TEMPDIR%\engine.ps1" echo   }
>> "%TEMPDIR%\engine.ps1" echo }
>> "%TEMPDIR%\engine.ps1" echo [System.IO.File]::WriteAllLines($phOut, $phList)
>> "%TEMPDIR%\engine.ps1" echo $push = [System.Collections.Generic.List[string]]::new()
>> "%TEMPDIR%\engine.ps1" echo $pull = [System.Collections.Generic.List[string]]::new()
>> "%TEMPDIR%\engine.ps1" echo foreach ($k in $pcData.Keys) {
>> "%TEMPDIR%\engine.ps1" echo   if ($phData.Contains($k)) {
>> "%TEMPDIR%\engine.ps1" echo     if ($pcData[$k] -gt $phData[$k]) { $push.Add($k) }
>> "%TEMPDIR%\engine.ps1" echo     elseif ($phData[$k] -gt $pcData[$k]) { $pull.Add($k) }
>> "%TEMPDIR%\engine.ps1" echo   } else { $push.Add($k) }
>> "%TEMPDIR%\engine.ps1" echo }
>> "%TEMPDIR%\engine.ps1" echo foreach ($k in $phData.Keys) {
>> "%TEMPDIR%\engine.ps1" echo   if (-not $pcData.Contains($k)) { $pull.Add($k) }
>> "%TEMPDIR%\engine.ps1" echo }
>> "%TEMPDIR%\engine.ps1" echo [System.IO.File]::WriteAllLines($pushOut, $push)
>> "%TEMPDIR%\engine.ps1" echo [System.IO.File]::WriteAllLines($pullOut, $pull)

powershell -NoProfile -ExecutionPolicy Bypass -File "%TEMPDIR%\engine.ps1" "%PCFOLDER%" "%PHONEFOLDER%" "%TEMPDIR%\phone_raw.txt" "%TEMPDIR%\pc_list.txt" "%TEMPDIR%\phone_list.txt" "%TEMPDIR%\needs_push.txt" "%TEMPDIR%\needs_pull.txt"

for /f %%A in ('type "%TEMPDIR%\needs_push.txt" ^| find /c /v ""') do set "PUSH_COUNT=%%A"
for /f %%A in ('type "%TEMPDIR%\needs_pull.txt" ^| find /c /v ""') do set "PULL_COUNT=%%A"

set /a TOTAL_TASKS=%PUSH_COUNT% + %PULL_COUNT%

if %TOTAL_TASKS% EQU 0 (
    echo.
    echo ============================================================
    echo  [ SUCCESS ] Both sides are identical. Handshake OK.
    echo ============================================================
    pause >nul & exit /b
)

:: ---------------------------------------------------------
:: STEP 4: VICE-VERSA WORKFLOW (Circuit Breaker)
:: ---------------------------------------------------------
set /a CURRENT_TASK=0
set /a CIRCUIT_BREAKER=0
echo.
echo [5] Starting Vice-Versa Synchronization (%TOTAL_TASKS% files)...
echo.

> "%FAILED_LOG%" echo === FAILED TRANSFERS [%date% %time%] ===

if %PUSH_COUNT% GTR 0 (
    for /f "usebackq delims=" %%A in ("%TEMPDIR%\needs_push.txt") do (
        set /a CURRENT_TASK+=1
        call :do_push "%%A" "[PC -> PHONE]"
    )
)
if %PULL_COUNT% GTR 0 (
    for /f "usebackq delims=" %%A in ("%TEMPDIR%\needs_pull.txt") do (
        set /a CURRENT_TASK+=1
        call :do_pull "%%A" "[PHONE -> PC]"
    )
)

echo.
echo ============================================================
echo   SYNC COMPLETE
echo ============================================================
pause >nul
exit /b

:: ============================================================
:: TRANSFER SUBROUTINES
:: ============================================================

:do_push
if %CIRCUIT_BREAKER% GEQ 5 (
    echo.
    echo [FATAL ERROR] 5 consecutive failures. USB connection severed.
    pause >nul & exit /b
)
setlocal DisableDelayedExpansion
set "rel=%~1"
set "tag=%~2"
setlocal EnableDelayedExpansion
set "win_rel=!rel:/=\!"
set "pc_path=%PCFOLDER%\!win_rel!"
set "ph_path=%PHONEFOLDER%/!rel!"
set "temp_win_path=!ph_path:/=\!"
for %%F in ("!temp_win_path!") do set "ph_parent_win=%%~dpF"
set "ph_parent=!ph_parent_win:\=/!"
set "ph_parent=!ph_parent:~0,-1!"
adb shell "mkdir -p \"%ph_parent%\"" >nul 2>&1
echo [!CURRENT_TASK!/%TOTAL_TASKS%] !tag! "!rel!"
set "fail_count=0"
:retry_push
adb push "!pc_path!" "!ph_path!" > "%TEMPDIR%\adb_out.txt" 2>&1
if errorlevel 1 (
    set /a fail_count+=1
    if !fail_count! GEQ 3 (
        >>"%FAILED_LOG%" echo PUSH_FAILED: "!rel!"
        set /a CIRCUIT_BREAKER+=1
        endlocal & endlocal & goto :eof
    )
    adb kill-server & adb start-server & timeout /t 3 >nul & goto :retry_push
)
endlocal & endlocal & set /a CIRCUIT_BREAKER=0 & goto :eof

:do_pull
if %CIRCUIT_BREAKER% GEQ 5 (
    echo.
    echo [FATAL ERROR] 5 consecutive failures. USB connection severed.
    pause >nul & exit /b
)
setlocal DisableDelayedExpansion
set "rel=%~1"
set "tag=%~2"
setlocal EnableDelayedExpansion
set "win_rel=!rel:/=\!"
set "pc_path=%PCFOLDER%\!win_rel!"
set "ph_path=%PHONEFOLDER%/!rel!"
for %%F in ("!pc_path!") do set "pc_dir=%%~dpF"
if not exist "!pc_dir!" mkdir "!pc_dir!"
echo [!CURRENT_TASK!/%TOTAL_TASKS%] !tag! "!rel!"
set "fail_count=0"
:retry_pull
adb pull "!ph_path!" "!pc_path!" > "%TEMPDIR%\adb_out.txt" 2>&1
if errorlevel 1 (
    set /a fail_count+=1
    if !fail_count! GEQ 3 (
        >>"%FAILED_LOG%" echo PULL_FAILED: "!rel!"
        set /a CIRCUIT_BREAKER+=1
        endlocal & endlocal & goto :eof
    )
    adb kill-server & adb start-server & timeout /t 3 >nul & goto :retry_pull
)
endlocal & endlocal & set /a CIRCUIT_BREAKER=0 & goto :eof

:: ============================================================
:: ARCHITECT & SHORTCUT SUBROUTINES
:: ============================================================
:apply_folder_icon
set "CAT=%~1"
set "CAT=%CAT:"=%"
set "TARGET_DIR=%PCFOLDER%\%CAT%"
set "ASSET_DIR=%TARGET_DIR%\.assets"
set "ICO_SRC=%IconBank%\%CAT%.ico"

if not exist "%TARGET_DIR%" (
    echo      [+] Creating folder: %CAT%
    mkdir "%TARGET_DIR%"
)

if exist "%ICO_SRC%" (
    if not exist "%ASSET_DIR%\folder.ico" (
        echo      [*] Applying Custom Icon to: %CAT%
        mkdir "%ASSET_DIR%" >nul 2>&1
        copy /Y "%ICO_SRC%" "%ASSET_DIR%\folder.ico" >nul 2>&1
        attrib +h +s "%ASSET_DIR%" >nul 2>&1
        attrib +h +s "%ASSET_DIR%\folder.ico" >nul 2>&1
        
        > "%TEMPDIR%\apply_icon.ps1" echo $path='%TARGET_DIR%\desktop.ini'
        >> "%TEMPDIR%\apply_icon.ps1" echo $content = '[.ShellClassInfo]', 'IconResource=.assets\folder.ico,0', '[ViewState]', 'Mode=', 'Vid=', 'FolderType=Generic'
        >> "%TEMPDIR%\apply_icon.ps1" echo $content ^| Out-File -FilePath $path -Encoding ascii -Force
        powershell -NoProfile -ExecutionPolicy Bypass -File "%TEMPDIR%\apply_icon.ps1"
        
        attrib +h +s "%TARGET_DIR%\desktop.ini" >nul 2>&1
        attrib +r "%TARGET_DIR%" >nul 2>&1
    )
)
goto :eof

:make_shortcuts
echo [1] Generating Subsystem Shortcuts...
set "BASE_DIR=%~dp0"
if "%BASE_DIR:~-1%"=="\" set "BASE_DIR=%BASE_DIR:~0,-1%"

:: 1. Generate Background Watcher Daemon Script
> "%PCFOLDER%\SyncDevice_Watcher.bat" echo @echo off
>> "%PCFOLDER%\SyncDevice_Watcher.bat" echo title SyncDevice - AutoWatcher Daemon
>> "%PCFOLDER%\SyncDevice_Watcher.bat" echo echo ===================================================
>> "%PCFOLDER%\SyncDevice_Watcher.bat" echo echo   SyncDevice AutoWatcher is RUNNING...
>> "%PCFOLDER%\SyncDevice_Watcher.bat" echo echo   Waiting for phone to be plugged in...
>> "%PCFOLDER%\SyncDevice_Watcher.bat" echo echo ===================================================
>> "%PCFOLDER%\SyncDevice_Watcher.bat" echo adb start-server ^>nul 2^>^&1
>> "%PCFOLDER%\SyncDevice_Watcher.bat" echo :loop
>> "%PCFOLDER%\SyncDevice_Watcher.bat" echo timeout /t 3 /nobreak ^>nul
>> "%PCFOLDER%\SyncDevice_Watcher.bat" echo adb devices 2^>nul ^| find "device" ^| find /V "List" ^>nul
>> "%PCFOLDER%\SyncDevice_Watcher.bat" echo if %%errorlevel%%==0 (
>> "%PCFOLDER%\SyncDevice_Watcher.bat" echo     echo [%%time%%] Phone detected and unlocked! Launching Sync...
>> "%PCFOLDER%\SyncDevice_Watcher.bat" echo     start "" "%SHORTCUT_SYNC%"
>> "%PCFOLDER%\SyncDevice_Watcher.bat" echo     :wait_for_disconnect
>> "%PCFOLDER%\SyncDevice_Watcher.bat" echo     timeout /t 5 /nobreak ^>nul
>> "%PCFOLDER%\SyncDevice_Watcher.bat" echo     adb devices 2^>nul ^| find "device" ^| find /V "List" ^>nul
>> "%PCFOLDER%\SyncDevice_Watcher.bat" echo     if %%errorlevel%%==0 goto wait_for_disconnect
>> "%PCFOLDER%\SyncDevice_Watcher.bat" echo     echo [%%time%%] Phone disconnected. Resuming watch...
>> "%PCFOLDER%\SyncDevice_Watcher.bat" echo )
>> "%PCFOLDER%\SyncDevice_Watcher.bat" echo goto loop

> "%TEMPDIR%\shortcut.ps1" echo $WshShell = New-Object -comObject WScript.Shell
>> "%TEMPDIR%\shortcut.ps1" echo $iconFile = '%IconBank%\icon.ico'

:: 2. Generate Main Sync Script Shortcut
>> "%TEMPDIR%\shortcut.ps1" echo $Sc1 = $WshShell.CreateShortcut('%SHORTCUT_SYNC%')
>> "%TEMPDIR%\shortcut.ps1" echo $Sc1.TargetPath = '%~f0'
>> "%TEMPDIR%\shortcut.ps1" echo $Sc1.WorkingDirectory = '%BASE_DIR%'
>> "%TEMPDIR%\shortcut.ps1" echo if (Test-Path -LiteralPath $iconFile) { $Sc1.IconLocation = $iconFile + ',0' } else { $Sc1.IconLocation = 'imageres.dll,109' }
>> "%TEMPDIR%\shortcut.ps1" echo $Sc1.Save()

:: 3. Generate Directory Explorer Shortcut
>> "%TEMPDIR%\shortcut.ps1" echo $Sc2 = $WshShell.CreateShortcut('%SHORTCUT_DIR%')
>> "%TEMPDIR%\shortcut.ps1" echo $Sc2.TargetPath = '%PCFOLDER%'
>> "%TEMPDIR%\shortcut.ps1" echo if (Test-Path -LiteralPath $iconFile) { $Sc2.IconLocation = $iconFile + ',0' } else { $Sc2.IconLocation = 'imageres.dll,3' }
>> "%TEMPDIR%\shortcut.ps1" echo $Sc2.Save()

:: 4. Generate AutoWatcher Shortcut (Runs Minimized)
>> "%TEMPDIR%\shortcut.ps1" echo $Sc3 = $WshShell.CreateShortcut('%SHORTCUT_WATCHER%')
>> "%TEMPDIR%\shortcut.ps1" echo $Sc3.TargetPath = '%PCFOLDER%\SyncDevice_Watcher.bat'
>> "%TEMPDIR%\shortcut.ps1" echo if (Test-Path -LiteralPath $iconFile) { $Sc3.IconLocation = $iconFile + ',0' } else { $Sc3.IconLocation = 'imageres.dll,109' }
>> "%TEMPDIR%\shortcut.ps1" echo $Sc3.WindowStyle = 7
>> "%TEMPDIR%\shortcut.ps1" echo $Sc3.Save()

powershell -NoProfile -ExecutionPolicy Bypass -File "%TEMPDIR%\shortcut.ps1"
goto :eof