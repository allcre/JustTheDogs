//
//  JustTheDogsApp.swift
//  JustTheDogs
//
//  Created by Allison Cretel on 2025-07-26.
//

import SwiftUI

@main
struct JustTheDogsApp: App {
    @State private var dogManager = DogManager()

    var body: some Scene {
        MenuBarExtra("JustTheDogs", systemImage: "dog.fill") {
            ContentView(manager: dogManager)
        }
        .menuBarExtraStyle(.window)
        
        Settings {
            SettingsView()
        }
    }
}
