@echo off
REM Community TV Software - Simple Auto-Start Installer
REM This creates a shortcut in the Windows Startup folder

echo ========================================
echo Community TV Software - Auto-Start Setup
echo ========================================
echo.

REM Check for admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: This script must be run as Administrator!
    echo Right-click this file and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

set "STARTUP_FOLDER=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "APP_PATH=%~dp0target\release\community-tv-software.exe"
set "SHORTCUT_PATH=%STARTUP_FOLDER%\CommunityTV.lnk"

REM Check if executable exists
if not exist "%APP_PATH%" (
    echo ERROR: Executable not found!
    echo Please build the project first with: cargo build --release
    echo.
    pause
    exit /b 1
)

echo Creating startup shortcut...
echo Target: %APP_PATH%
echo Location: %STARTUP_FOLDER%
echo.

REM Create VBS script to create shortcut
echo Set oWS = WScript.CreateObject("WScript.Shell") > CreateShortcut.vbs
echo sLinkFile = "%SHORTCUT_PATH%" >> CreateShortcut.vbs
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> CreateShortcut.vbs
echo oLink.TargetPath = "%APP_PATH%" >> CreateShortcut.vbs
echo oLink.Arguments = "--url http://37.114.46.4" >> CreateShortcut.vbs
echo oLink.WorkingDirectory = "%~dp0" >> CreateShortcut.vbs
echo oLink.Description = "Community TV Software - Fullscreen Kiosk" >> CreateShortcut.vbs
echo oLink.Save >> CreateShortcut.vbs

cscript //nologo CreateShortcut.vbs
del CreateShortcut.vbs

if exist "%SHORTCUT_PATH%" (
    echo.
    echo ========================================
    echo SUCCESS! Auto-start configured.
    echo ========================================
    echo.
    echo The application will start automatically when Windows boots.
    echo.
    echo To remove auto-start, delete this file:
    echo %SHORTCUT_PATH%
    echo.
) else (
    echo ERROR: Failed to create shortcut
    echo.
)

pause

