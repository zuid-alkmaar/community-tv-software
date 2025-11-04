# Cafe Deployment Guide - Community TV Software

This guide will help you set up the Community TV Software on a Windows 11 machine in your cafe to display content in fullscreen mode that starts automatically on boot and stays always on top.

## 🎯 What This Does

- Launches Chrome in fullscreen kiosk mode
- Displays your content at `http://37.114.46.4`
- Starts automatically when Windows boots
- Keeps Chrome always on top (can't be interrupted by other windows)
- Monitors and refocuses Chrome if anything tries to take focus

## 📋 Prerequisites

1. Windows 11 machine
2. Google Chrome installed
3. Administrator access to the computer
4. Rust toolchain (only needed for initial build)

## 🚀 Quick Setup (3 Steps)

### Step 1: Build the Application

Open PowerShell in this directory and run:

```powershell
cargo build --release
```

This creates the executable at `target\release\community-tv-software.exe`

### Step 2: Test the Application

Before setting up auto-start, test that it works:

```powershell
.\target\release\community-tv-software.exe
```

You should see Chrome launch in fullscreen mode displaying your content. The application will keep running and monitoring Chrome to keep it always on top.

**To exit:** Press `Ctrl+C` in the PowerShell window, or use Task Manager to close Chrome.

### Step 3: Set Up Auto-Start

Choose **ONE** of these methods:

#### Option A: PowerShell Script (Recommended)

Right-click PowerShell and select "Run as Administrator", then:

```powershell
.\setup-autostart.ps1
```

This will:
- Create a scheduled task to run on boot
- Disable lock screen
- Disable screen timeout and sleep
- Configure Windows for kiosk mode

To remove auto-start later:
```powershell
.\setup-autostart.ps1 -Remove
```

#### Option B: Batch File (Simpler)

Right-click `install-autostart.bat` and select "Run as administrator"

This creates a shortcut in the Windows Startup folder.

## 🔧 Additional Windows Configuration

For a reliable cafe deployment, configure these Windows settings:

### 1. Enable Auto-Login

So the computer doesn't require a password on boot:

1. Press `Win+R` and type `netplwiz`
2. Uncheck "Users must enter a user name and password to use this computer"
3. Click OK and enter the password
4. Restart to test

### 2. Disable Windows Updates During Business Hours

1. Open Settings → Windows Update → Advanced options
2. Set "Active hours" to your cafe's operating hours
3. This prevents Windows from restarting during the day

### 3. Disable Notifications

1. Open Settings → System → Notifications
2. Turn off "Notifications"
3. This prevents popups from interrupting the display

### 4. Set Power Options

1. Open Settings → System → Power
2. Set "Screen and sleep" to "Never" for both options
3. This keeps the display always on

### 5. Disable Screen Saver

1. Search for "screen saver" in Windows search
2. Set to "None"

## 🧪 Testing the Setup

1. **Restart the computer** to test auto-start
2. The computer should:
   - Boot to Windows
   - Auto-login (if configured)
   - Automatically launch the Community TV Software
   - Display Chrome in fullscreen with your content
   - Keep Chrome always on top

3. **Test interruption resistance:**
   - Try opening another application
   - Chrome should stay on top and regain focus within 2 seconds

## 🛠️ Troubleshooting

### Chrome doesn't launch

**Problem:** "Chrome executable not found"

**Solution:** Specify Chrome path manually:
```powershell
.\target\release\community-tv-software.exe --chrome-path "C:\Program Files\Google\Chrome\Application\chrome.exe"
```

Update the auto-start script with the correct path.

### Application doesn't start on boot

**Check:**
1. Open Task Scheduler (search in Windows)
2. Look for "Community TV Software" task
3. Right-click → Run to test manually
4. Check "Last Run Result" for errors

**Alternative:** Use the batch file method instead of PowerShell script.

### Chrome loses focus / other windows appear

The application monitors Chrome every 2 seconds. If Chrome loses focus, it should automatically regain it within 2 seconds. If this doesn't work:

1. Make sure the application is still running (check Task Manager)
2. Restart the application
3. Check Windows Event Viewer for errors

### Content doesn't load

**Check:**
1. Is the URL `http://37.114.46.4` accessible from the cafe network?
2. Test in a regular Chrome window first
3. Check firewall settings

**Change URL:** Edit `src/main.rs` line 10 to change the default URL, then rebuild.

## 🔄 Updating the URL

To change the displayed URL:

### Method 1: Edit source code
1. Open `src/main.rs`
2. Change line 10: `default_value = "http://your-new-url.com"`
3. Rebuild: `cargo build --release`
4. Re-run the auto-start setup

### Method 2: Use config file
1. Copy `config.example.toml` to `config.toml`
2. Edit the URL in `config.toml`
3. Update auto-start to use: `--config config.toml`

## 🔒 Security Considerations

Since this is a public-facing kiosk:

1. **Use a limited user account** - Don't run as Administrator in production
2. **Disable keyboard shortcuts** - Consider using Windows Kiosk Mode for extra security
3. **Physical security** - Consider hiding the keyboard or using a locked cabinet
4. **Network isolation** - Use a separate network VLAN if possible

## 📱 Remote Management

For remote management of the cafe display:

1. Use Windows Remote Desktop to access the machine
2. Stop the application from Task Manager if needed
3. Make changes and restart

## 🆘 Emergency Stop

If you need to stop the application immediately:

1. Press `Ctrl+Alt+Del`
2. Open Task Manager
3. End these processes:
   - `community-tv-software.exe`
   - `chrome.exe`

## 📞 Support

For issues or questions, check the main README.md or the application logs.

## ✅ Deployment Checklist

- [ ] Application built successfully
- [ ] Tested manually - Chrome launches in fullscreen
- [ ] Auto-start configured (PowerShell or batch file)
- [ ] Auto-login enabled
- [ ] Windows updates configured for active hours
- [ ] Notifications disabled
- [ ] Power settings set to never sleep
- [ ] Screen saver disabled
- [ ] Tested full restart - application starts automatically
- [ ] Tested interruption resistance - Chrome stays on top
- [ ] URL displays correct content
- [ ] Network connectivity verified

---

**Ready for deployment!** 🎉

