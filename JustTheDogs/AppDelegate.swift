//
//  AppDelegate.swift
//  JustTheDogs
//
//  Created by Allison Cretel on 2025-07-26.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem?
    var window: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBarItem = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.variableLength
        )
        if let button = statusBarItem?.button {
            button.action = #selector(statusBarButtonClicked(_:))
            button.target = self
            button.image = NSImage(
                systemSymbolName: "dog.fill",
                accessibilityDescription: "Dog"
            )
        }
    }

    @objc func statusBarButtonClicked(_ sender: NSStatusBarButton) {
        print("Menu item clicked")
        let windowWidth: CGFloat = 300
        let windowHeight: CGFloat = 200

        // Get the actual button position
        guard let buttonWindow = sender.window else { return }
        let buttonFrame = buttonWindow.frame
        
        // Position window centered under the button
        let windowX = buttonFrame.minX
        let windowY = buttonFrame.maxY 
        
        print("Window position: x=\(windowX), y=\(windowY)")
        print("menu bar height \(getMenuBarHeight())")

        window = getOrBuildWindow(
            size: NSRect(
                x: windowX,
                y: windowY,
                width: windowWidth,
                height: windowHeight
            )
        )
        toggleWindowVisibility(location: NSPoint(x: windowX, y: windowY))
    }

    @objc func getOrBuildWindow(size: NSRect) -> NSWindow {
        if window != nil {
            return window.unsafelyUnwrapped
        }
        let contentView = ContentView()
        window = NSWindow(
            contentRect: size,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window?.contentView = NSHostingView(rootView: contentView)
        window?.isReleasedWhenClosed = false
        window?.collectionBehavior = .moveToActiveSpace
        window?.level = .floating
        
        return window.unsafelyUnwrapped
    }

    func toggleWindowVisibility(location: NSPoint) {
        // window hasn't been built yet, don't do anything
        if window == nil {
            return
        }
        if window!.isVisible {
            // window is visible, hide it
            window?.orderOut(nil)
        } else {
            // window is hidden. Position and show it on top of other windows
            window?.setFrameOrigin(location)
            window?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    func getMenuBarHeight() -> CGFloat {
        return NSApplication.shared.mainMenu?.menuBarHeight ?? 24
    }
}
