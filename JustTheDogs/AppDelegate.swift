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
    private var windowSize = CGSize(width: 300, height: 200) // Default size

    // Create the dog image service at app level
    private var dogImageService: DogImageService!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide the app from the dock since it's a menu bar app
        NSApp.setActivationPolicy(.accessory)

        // Initialize the dog image service and start fetching immediately
        dogImageService = DogImageService()

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

        // Listen for when image and size are ready for next window show
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(imageReadyForNextShow(_:)),
            name: NSNotification.Name("ImageReadyForNextShow"),
            object: nil
        )
    }

    @objc func imageReadyForNextShow(_ notification: Notification) {
        if let newSize = notification.object as? CGSize {
            windowSize = newSize
            print("Window size updated to: \(newSize)")
        }
    }

    @objc func statusBarButtonClicked(_ sender: NSStatusBarButton) {
        print("Menu item clicked")

        // If window exists and is visible, hide it
        if let window = window, window.isVisible {
            window.orderOut(nil)
            // Clear current image and start preparing next image for subsequent opening
            Task { @MainActor in
                dogImageService.clearCurrentImage()
                await dogImageService.prepareNextImage()
            }
            return
        }

        // Update to prepared image BEFORE showing window (eliminates flash)
        Task { @MainActor in
            dogImageService.showCurrentImage()
            // Show window with the new image already set - no need for DispatchQueue since we're on MainActor
            self.showWindowNow(sender)
        }
    }

    private func showWindowNow(_ sender: NSStatusBarButton) {
        // Get the button's position in screen coordinates
        guard let buttonWindow = sender.window else { return }
        let buttonFrame = sender.frame
        let buttonScreenFrame = buttonWindow.convertToScreen(buttonFrame)

        // Position at left side of button
        let windowX = buttonScreenFrame.minX
        let windowY = buttonScreenFrame.minY - windowSize.height

        // Create window if it doesn't exist
        if window == nil {
            let windowRect = NSRect(x: windowX, y: windowY, width: windowSize.width, height: windowSize.height)
            window = getOrBuildWindow(size: windowRect)
        }

        // Position and show window with the correct size immediately
        let windowRect = NSRect(x: windowX, y: windowY, width: windowSize.width, height: windowSize.height)
        window?.setFrame(windowRect, display: false)
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func getOrBuildWindow(size: NSRect) -> NSWindow {
        if window != nil {
            return window.unsafelyUnwrapped
        }

        // Pass the shared dog image service to the content view
        let contentView = ContentView(dogImageService: dogImageService)
        window = NSWindow(
            contentRect: size,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window?.contentView = NSHostingView(rootView: contentView)
        window?.isReleasedWhenClosed = false
        window?.collectionBehavior = [.moveToActiveSpace, .fullScreenAuxiliary]
        window?.level = .floating
        window?.hasShadow = true

        // Make window background transparent so SwiftUI content controls the appearance
        window?.backgroundColor = NSColor.clear
        window?.isOpaque = false

        return window.unsafelyUnwrapped
    }

    // Add method to handle clicks outside the window to close it
    func applicationDidResignActive(_ notification: Notification) {
        if let window = window, window.isVisible {
            window.orderOut(nil)
            // Clear current image and start preparing next image for subsequent opening
            Task { @MainActor in
                dogImageService.clearCurrentImage()
                await dogImageService.prepareNextImage()
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
