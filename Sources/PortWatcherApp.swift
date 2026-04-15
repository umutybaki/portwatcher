import SwiftUI
import AppKit

@main
struct PortWatcherApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var rightClickMenu: NSMenu!
    var settingsWindow: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let contentView = PortListMenuBarView()
        
        popover = NSPopover()
        popover.behavior = .transient
        popover.animates = false
        popover.contentViewController = NSHostingController(rootView: contentView)
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = createMenuBarImage()
            button.action = #selector(statusBarButtonClicked(sender:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        setupMenu()
    }

    private func createMenuBarImage() -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size)
        image.isTemplate = true
        
        image.lockFocus()
        let rect = NSRect(origin: .zero, size: size).insetBy(dx: 1, dy: 1)
        
        // Circular Rim
        let circle = NSBezierPath(ovalIn: rect)
        circle.lineWidth = 1.5
        circle.stroke()
        
        // Crosshair Lines
        let path = NSBezierPath()
        let center = NSPoint(x: size.width / 2, y: size.height / 2)
        
        // Horizontal
        path.move(to: NSPoint(x: rect.minX, y: center.y))
        path.line(to: NSPoint(x: rect.maxX, y: center.y))
        
        // Vertical
        path.move(to: NSPoint(x: center.x, y: rect.minY))
        path.line(to: NSPoint(x: center.x, y: rect.maxY))
        
        path.lineWidth = 1.2
        path.stroke()
        
        // Center Dot
        let dotRect = NSRect(x: center.x - 2.5, y: center.y - 2.5, width: 5, height: 5)
        NSBezierPath(ovalIn: dotRect).fill()
        
        image.unlockFocus()
        return image
    }
    
    func setupMenu() {
        rightClickMenu = NSMenu(title: "Options")
        rightClickMenu.addItem(NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ","))
        rightClickMenu.addItem(NSMenuItem.separator())
        rightClickMenu.addItem(NSMenuItem(title: "Quit PortWatcher", action: #selector(quitApp), keyEquivalent: "q"))
    }
    
    @objc func statusBarButtonClicked(sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        
        if event.type == .rightMouseUp {
            statusItem.menu = rightClickMenu
            statusItem.button?.performClick(nil)
            statusItem.menu = nil
        } else {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: NSRectEdge.minY)
                popover.contentViewController?.view.window?.makeKey()
            }
        }
    }
    
    @objc func openSettings() {
        if settingsWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 350, height: 200),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            window.title = "PortWatcher Settings"
            window.center()
            window.isReleasedWhenClosed = false
            window.contentViewController = NSHostingController(rootView: SettingsView())
            settingsWindow = window
        }
        
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
