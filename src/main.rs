use clap::Parser;
use std::process::Command;
use std::path::PathBuf;
use std::fs;
use std::thread;
use std::time::Duration;

#[cfg(windows)]
use winapi::um::winuser::{FindWindowA, SetWindowPos, GetForegroundWindow, SetForegroundWindow};
#[cfg(windows)]
use winapi::shared::windef::HWND;
#[cfg(windows)]
use winapi::um::winuser::{HWND_TOPMOST, SWP_NOMOVE, SWP_NOSIZE};

#[derive(Parser, Debug)]
#[command(author, version, about = "Community TV Software - Launch Chrome in fullscreen kiosk mode", long_about = None)]
struct Args {
    /// URL to display in fullscreen
    #[arg(short, long, default_value = "http://37.114.46.4")]
    url: String,

    /// Path to Chrome executable (auto-detected if not specified)
    #[arg(short, long)]
    chrome_path: Option<String>,

    /// Use config file instead of command line arguments
    #[arg(short = 'f', long)]
    config: Option<String>,
}

#[derive(serde::Deserialize, Debug)]
struct Config {
    url: String,
    chrome_path: Option<String>,
}

fn find_chrome_path() -> Option<PathBuf> {
    // Common Chrome installation paths on Windows
    let user_profile = std::env::var("USERPROFILE").unwrap_or_default();
    let user_chrome_path = format!(
        r"{}\AppData\Local\Google\Chrome\Application\chrome.exe",
        user_profile
    );

    let possible_paths = vec![
        r"C:\Program Files\Google\Chrome\Application\chrome.exe",
        r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
        &user_chrome_path,
    ];

    for path in possible_paths {
        let path_buf = PathBuf::from(path);
        if path_buf.exists() {
            return Some(path_buf);
        }
    }

    None
}

#[cfg(windows)]
fn find_chrome_window() -> Option<HWND> {
    use std::ffi::CString;

    // Try to find Chrome window by class name
    let class_names = vec![
        "Chrome_WidgetWin_1",
        "Chrome_WidgetWin_0",
    ];

    for class_name in class_names {
        if let Ok(c_str) = CString::new(class_name) {
            unsafe {
                let hwnd = FindWindowA(c_str.as_ptr(), std::ptr::null());
                if !hwnd.is_null() {
                    return Some(hwnd);
                }
            }
        }
    }

    None
}

#[cfg(windows)]
fn set_window_always_on_top(hwnd: HWND) {
    unsafe {
        SetWindowPos(
            hwnd,
            HWND_TOPMOST,
            0,
            0,
            0,
            0,
            SWP_NOMOVE | SWP_NOSIZE,
        );
    }
}

#[cfg(windows)]
fn bring_window_to_front(hwnd: HWND) {
    unsafe {
        SetForegroundWindow(hwnd);
    }
}

#[cfg(windows)]
fn monitor_chrome_window() {
    println!("Starting window monitor to keep Chrome always on top...");

    // Wait a bit for Chrome to fully start
    thread::sleep(Duration::from_secs(3));

    loop {
        if let Some(hwnd) = find_chrome_window() {
            // Set window to always on top
            set_window_always_on_top(hwnd);

            // Check if Chrome is the foreground window
            unsafe {
                let foreground = GetForegroundWindow();
                if foreground != hwnd {
                    // Bring Chrome back to front
                    bring_window_to_front(hwnd);
                }
            }
        }

        // Check every 2 seconds
        thread::sleep(Duration::from_secs(2));
    }
}

fn launch_chrome(url: &str, chrome_path: Option<String>) -> Result<(), Box<dyn std::error::Error>> {
    let chrome_exe = if let Some(path) = chrome_path {
        PathBuf::from(path)
    } else {
        find_chrome_path()
            .ok_or("Chrome executable not found. Please specify the path using --chrome-path")?
    };

    println!("Using Chrome at: {}", chrome_exe.display());
    println!("Opening URL: {}", url);

    // Launch Chrome in kiosk mode (fullscreen)
    // --kiosk: Opens Chrome in fullscreen kiosk mode
    // --disable-infobars: Removes info bars
    // --noerrdialogs: Disables error dialogs
    // --disable-session-crashed-bubble: Disables crash recovery bubble
    // --disable-features=TranslateUI: Disables translate popup
    let mut cmd = Command::new(&chrome_exe);
    cmd.arg("--kiosk")
        .arg(url)
        .arg("--disable-infobars")
        .arg("--noerrdialogs")
        .arg("--disable-session-crashed-bubble")
        .arg("--disable-features=TranslateUI")
        .arg("--disable-component-update")
        .arg("--no-first-run")
        .arg("--no-default-browser-check");

    let child = cmd.spawn()?;
    
    println!("Chrome launched successfully with PID: {}", child.id());
    println!("Press Alt+F4 or close the Chrome window to exit fullscreen mode.");

    Ok(())
}

fn load_config(config_path: &str) -> Result<Config, Box<dyn std::error::Error>> {
    let content = fs::read_to_string(config_path)?;
    let config: Config = toml::from_str(&content)?;
    Ok(config)
}

fn main() {
    let args = Args::parse();

    let (url, chrome_path) = if let Some(config_file) = args.config {
        match load_config(&config_file) {
            Ok(config) => {
                println!("Loaded configuration from: {}", config_file);
                (config.url, config.chrome_path)
            }
            Err(e) => {
                eprintln!("Error loading config file: {}", e);
                std::process::exit(1);
            }
        }
    } else {
        (args.url, args.chrome_path)
    };

    match launch_chrome(&url, chrome_path) {
        Ok(_) => {
            println!("\nChrome is now running in fullscreen mode.");
            println!("The application will monitor and keep Chrome always on top.");

            #[cfg(windows)]
            {
                // Start monitoring Chrome window in the main thread
                // This will run indefinitely, keeping Chrome on top
                monitor_chrome_window();
            }

            #[cfg(not(windows))]
            {
                println!("Window monitoring is only available on Windows.");
                println!("The application will now exit.");
            }
        }
        Err(e) => {
            eprintln!("Error launching Chrome: {}", e);
            std::process::exit(1);
        }
    }
}

