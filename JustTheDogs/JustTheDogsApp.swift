//
//  JustTheDogsApp.swift
//  JustTheDogs
//
//  Created by Allison Cretel on 2025-07-26.
//

import SwiftUI

@main
struct JustTheDogsApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Use Settings scene which doesn't auto-show a window
        // Perfect for menu bar apps that only show windows on demand
        Settings {
            EmptyView()
        }
    }
}
