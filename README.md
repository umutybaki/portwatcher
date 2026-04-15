<div align="center">
  <img src="logo.svg" width="160" alt="PortWatcher Logo">
  <h1>PortWatcher</h1>
</div>
PortWatcher is a lightweight, minimal macOS menubar utility designed for developers. It helps you quickly identify and terminate processes listening on `localhost` ports. This was designed precisely for closing unwanted and forgotten npm applications just by a click.

## ✨ Features

-   **Native macOS Aesthetic**: Designed specifically to perfectly replicate standard macOS system menus (like the Wi-Fi list) for a native feel, complete with compact spacing, system fonts, and dynamic row-hover effects.
-   **Frictionless Termination**: Quit buttons are permanently visible on the left side of every port for instant access.
    -   **Quit**: Sends a graceful `SIGTERM` to the process (blue button).
    -   **Force Quit**: Sends a `SIGKILL` for stubborn background processes (red button).
-   **Intelligent App Resolution**: Automatically identifies the parent application, e.g., "Visual Studio Code" or "node".
-   **Smart Filtering**: Automatically hides common macOS system services (like AirPlay or Control Center) to focus on your dev environment.
-   **Customizable Settings**: Toggle auto-refresh or system process filtering via the Preferences panel.
-   **Left/Right Click Mastery**:
    -   **Left-Click**: View and manage active ports.
    -   **Right-Click**: Access Settings or Quit PortWatcher.
-   **Fully Self-Contained and Native**: All code is self contained without any dependency and written completely with Swift and SwiftUI. 

## 🚀 Installation

### Download pre-built binary
The easiest way to install PortWatcher is to download the latest **.dmg** file from the [Releases](https://github.com/umutybaki/PortWatcher/releases) page. Just open the DMG and drag PortWatcher to your Applications folder.

> [!WARNING]
> **"App cannot be opened because the developer cannot be verified"**
> 
> Because PortWatcher is an open-source tool and not signed with a paid Apple Developer certificate, macOS Gatekeeper may block the app on its first launch. To bypass this:
> 1. Open **System Settings**.
> 2. Navigate to the **Privacy & Security** tab.
> 3. Scroll down to the bottom of the security section.
> 4. You will see a message saying *"PortWatcher" was blocked to protect your Mac.* Click the **Open Anyway** button next to it.
> 5. A prompt will appear. Click **Open** to launch the application.
> 
> You only need to do this once. After that, you can launch the app normally.


### Build from source
Alternatively, you can build it yourself if you have Xcode or the Swift toolchain installed.

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/umutybaki/PortWatcher.git
    cd PortWatcher
    ```

2.  **Run the Installer**:
    ```bash
    chmod +x install.sh
    ./install.sh
    ```

The installer will build the app, move it to your `/Applications` folder, and launch it automatically.

## 🛠️ Usage

-   **Check Ports**: Click the icon in your menubar to see what's running.
-   **Kill a Process**: Use the **Quit (blue cross)** or **Force Quit (red cross)** buttons next to any port.
-   **Configure**: Right-click the menubar icon and select **Settings...** to toggle auto-refresh or filtering.
-   **Manual Refresh**: Click the circular arrow icon in the top right of the popover.

## 🏗️ Requirements

-   macOS 13.0 (Ventura) or later.
-   Swift 5.7+ (for building from source).

## 📄 License

This project is licensed under the [MIT License](LICENSE).
