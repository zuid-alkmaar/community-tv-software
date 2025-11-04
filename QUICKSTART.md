# Quick Start Guide

Get your cafe TV display running in 5 minutes!

## Step 1: Build (1 minute)

Open PowerShell in this folder:

```powershell
cargo build --release
```

## Step 2: Test (30 seconds)

```powershell
.\target\release\community-tv-software.exe
```

Chrome should open in fullscreen showing `http://37.114.46.4`

Press `Ctrl+C` to stop.

## Step 3: Install Auto-Start (1 minute)

Right-click PowerShell → "Run as Administrator":

```powershell
.\setup-autostart.ps1
```

## Step 4: Configure Auto-Login (2 minutes)

1. Press `Win+R`, type `netplwiz`, press Enter
2. Uncheck "Users must enter a user name and password"
3. Click OK, enter password
4. Restart to test

## Done! 🎉

Your cafe display will now:
- ✅ Start automatically when Windows boots
- ✅ Display in fullscreen
- ✅ Stay always on top
- ✅ Automatically refocus if interrupted

---

**Need more details?** See [DEPLOYMENT.md](DEPLOYMENT.md)

**Having issues?** Check the Troubleshooting section in DEPLOYMENT.md

