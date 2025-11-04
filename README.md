# Community TV Software

A Windows 11 application written in Rust that launches Google Chrome in fullscreen kiosk mode to display a web address.

## Features

- 🚀 Launches Chrome in fullscreen kiosk mode
- 🔍 Auto-detects Chrome installation path
- ⚙️ Configurable via command line or config file
- 🖥️ Optimized for Windows 11
- 🎯 Perfect for digital signage and community TV displays
- 🔝 **Always-on-top:** Keeps Chrome window on top at all times
- 👁️ **Window monitoring:** Automatically refocuses Chrome if interrupted
- 🔄 **Auto-start on boot:** Easy setup scripts for Windows startup
- 🛡️ **Interruption resistant:** Can't be covered by other windows

## Prerequisites

- Windows 11
- Google Chrome installed
- Rust toolchain (for building from source)

## Building

```bash
cargo build --release
```

The compiled executable will be in `target/release/community-tv-software.exe`

## Usage

### Option 1: Command Line Arguments

```bash
# Launch with default URL (Google)
community-tv-software.exe

# Launch with custom URL
community-tv-software.exe --url "https://www.example.com"

# Specify custom Chrome path
community-tv-software.exe --url "https://www.example.com" --chrome-path "C:\Path\To\chrome.exe"
```

### Option 2: Configuration File

1. Copy `config.example.toml` to `config.toml`
2. Edit `config.toml` with your desired URL
3. Run with config file:

```bash
community-tv-software.exe --config config.toml
```

## Command Line Options

- `-u, --url <URL>` - URL to display in fullscreen (default: https://www.google.com)
- `-c, --chrome-path <PATH>` - Path to Chrome executable (auto-detected if not specified)
- `-f, --config <FILE>` - Use config file instead of command line arguments
- `-h, --help` - Print help information
- `-V, --version` - Print version information

## Exiting Fullscreen Mode

To exit the fullscreen kiosk mode:
- Press `Alt+F4`
- Close the Chrome window using Task Manager

## Chrome Kiosk Mode Features

The application launches Chrome with the following flags:
- `--kiosk` - Fullscreen kiosk mode
- `--disable-infobars` - Removes info bars
- `--noerrdialogs` - Disables error dialogs
- `--disable-session-crashed-bubble` - Disables crash recovery bubble
- `--disable-features=TranslateUI` - Disables translate popup
- `--no-first-run` - Skips first run experience
- `--no-default-browser-check` - Skips default browser check

## Auto-Start on Windows Boot

For cafe/kiosk deployment, use the included setup scripts:

### Option 1: PowerShell Script (Recommended)

Run PowerShell as Administrator:

```powershell
.\setup-autostart.ps1
```

This will:
- Create a scheduled task to run on boot
- Disable lock screen and screen timeout
- Configure Windows for kiosk mode

To remove: `.\setup-autostart.ps1 -Remove`

### Option 2: Batch File (Simpler)

Right-click `install-autostart.bat` and select "Run as administrator"

This creates a shortcut in the Windows Startup folder.

### Manual Setup

1. Press `Win+R` and type `shell:startup`
2. Create a shortcut to `community-tv-software.exe` in the Startup folder
3. Right-click the shortcut → Properties → Add command line arguments if needed

**For complete cafe deployment instructions, see [DEPLOYMENT.md](DEPLOYMENT.md)**

## License

MIT

