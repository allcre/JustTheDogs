//
//  SettingsView.swift
//  JustTheDogs
//

import SwiftUI
import ServiceManagement

enum WindowSize: String, CaseIterable, Identifiable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    
    var id: String { rawValue }
    
    var maxWidth: CGFloat {
        switch self {
        case .small: return 350
        case .medium: return 500
        case .large: return 700
        }
    }
}

struct SettingsView: View {
    @AppStorage("windowSizePreference") private var selectedSize: WindowSize = .small
    @State private var launchAtLogin = false
    
    var body: some View {
        Form {
            Section {
                Picker("Window Size:", selection: $selectedSize) {
                    ForEach(WindowSize.allCases) { size in
                        Text(size.rawValue).tag(size)
                    }
                }
                .pickerStyle(.inline)
                
                Text("Controls the maximum width of the dog image.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Section {
                Toggle("Launch at Login", isOn: Binding(
                    get: { launchAtLogin },
                    set: { newValue in
                        launchAtLogin = newValue
                        toggleLaunchAtLogin(enabled: newValue)
                    }
                ))
            }
        }
        .padding(20)
        .frame(width: 350, height: 200)
        .onAppear {
            checkLaunchAtLoginStatus()
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    private func checkLaunchAtLoginStatus() {
        launchAtLogin = SMAppService.mainApp.status == .enabled
    }
    
    private func toggleLaunchAtLogin(enabled: Bool) {
        do {
            if enabled {
                if SMAppService.mainApp.status == .enabled { return }
                try SMAppService.mainApp.register()
            } else {
                if SMAppService.mainApp.status == .notRegistered { return }
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to toggle Launch at Login: \(error.localizedDescription)")
            // Revert UI if operation failed
            launchAtLogin = !enabled
        }
    }
}

#Preview {
    SettingsView()
}