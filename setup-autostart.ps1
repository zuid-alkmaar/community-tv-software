# Community TV Software - Auto-Start Setup Script
# This script sets up the application to start automatically on Windows boot

param(
    [string]$Url = "http://37.114.46.4",
    [switch]$Remove
)

$AppName = "CommunityTVSoftware"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ExePath = Join-Path $ScriptDir "target\release\community-tv-software.exe"
$TaskName = "Community TV Software"

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator', then run this script again." -ForegroundColor Yellow
    exit 1
}

if ($Remove) {
    Write-Host "Removing auto-start configuration..." -ForegroundColor Yellow
    
    # Remove scheduled task
    $task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($task) {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        Write-Host "✓ Removed scheduled task" -ForegroundColor Green
    } else {
        Write-Host "No scheduled task found" -ForegroundColor Gray
    }
    
    Write-Host "`nAuto-start has been removed." -ForegroundColor Green
    exit 0
}

# Check if executable exists
if (-not (Test-Path $ExePath)) {
    Write-Host "ERROR: Executable not found at: $ExePath" -ForegroundColor Red
    Write-Host "Please build the project first with: cargo build --release" -ForegroundColor Yellow
    exit 1
}

Write-Host "Setting up Community TV Software to start on boot..." -ForegroundColor Cyan
Write-Host "Executable: $ExePath" -ForegroundColor Gray
Write-Host "URL: $Url" -ForegroundColor Gray
Write-Host ""

# Create scheduled task to run at startup
$action = New-ScheduledTaskAction -Execute $ExePath -Argument "--url `"$Url`""
$trigger = New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1)

# Remove existing task if it exists
$existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if ($existingTask) {
    Write-Host "Removing existing scheduled task..." -ForegroundColor Yellow
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
}

# Register the new task
Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description "Launches Community TV Software in fullscreen kiosk mode on startup" | Out-Null

Write-Host "✓ Scheduled task created successfully" -ForegroundColor Green

# Disable Windows Update restart notifications (optional but recommended for kiosk)
Write-Host "`nConfiguring Windows for kiosk mode..." -ForegroundColor Cyan

try {
    # Disable lock screen
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    Set-ItemProperty -Path $regPath -Name "NoLockScreen" -Value 1 -Type DWord
    Write-Host "✓ Disabled lock screen" -ForegroundColor Green
} catch {
    Write-Host "⚠ Could not disable lock screen: $_" -ForegroundColor Yellow
}

try {
    # Disable screen timeout
    powercfg /change monitor-timeout-ac 0
    powercfg /change monitor-timeout-dc 0
    Write-Host "✓ Disabled screen timeout" -ForegroundColor Green
} catch {
    Write-Host "⚠ Could not disable screen timeout: $_" -ForegroundColor Yellow
}

try {
    # Disable sleep
    powercfg /change standby-timeout-ac 0
    powercfg /change standby-timeout-dc 0
    Write-Host "✓ Disabled sleep mode" -ForegroundColor Green
} catch {
    Write-Host "⚠ Could not disable sleep mode: $_" -ForegroundColor Yellow
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "✓ Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "The Community TV Software will now start automatically when Windows boots." -ForegroundColor White
Write-Host ""
Write-Host "Additional recommendations for cafe deployment:" -ForegroundColor Yellow
Write-Host "  1. Set Windows to auto-login (netplwiz)" -ForegroundColor Gray
Write-Host "  2. Disable Windows updates during business hours" -ForegroundColor Gray
Write-Host "  3. Test by restarting the computer" -ForegroundColor Gray
Write-Host ""
Write-Host "To remove auto-start, run: .\setup-autostart.ps1 -Remove" -ForegroundColor Gray
Write-Host ""

