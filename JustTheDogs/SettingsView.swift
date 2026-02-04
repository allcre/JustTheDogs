//
//  SettingsView.swift
//  JustTheDogs
//

import SwiftUI

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
    
    var body: some View {
        Form {
            Picker("Window Size:", selection: $selectedSize) {
                ForEach(WindowSize.allCases) { size in
                    Text(size.rawValue).tag(size)
                }
            }
            .pickerStyle(.inline)
            
            Text("Controls the maximum width of the dog image.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
        .padding(20)
        .frame(width: 350, height: 150)
    }
}

#Preview {
    SettingsView()
}
