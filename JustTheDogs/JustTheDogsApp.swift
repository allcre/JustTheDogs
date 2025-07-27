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
        Settings {
            Text("Settings or main app window")
        }
    }
}
