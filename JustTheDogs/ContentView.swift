//
//  ContentView.swift
//  JustTheDogs
//

import SwiftUI

struct ContentView: View {
    var manager: DogManager
    @AppStorage("windowSizePreference") private var selectedSize: WindowSize = .small
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore = false
    
    var body: some View {
        // We use a container that hugs its content tightly.
        // By removing fixed min/max on the ZStack and using it on the image instead,
        // we ensure the window doesn't reserve extra space.
        ZStack {
            VStack(spacing: 0) {
                if let image = manager.currentImage {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: calculateFrame(for: image).width,
                               height: calculateFrame(for: image).height)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if hasLaunchedBefore {
                                manager.advanceToNextDog()
                            }
                        }
                        .contextMenu {
                            Button {
                                copyToClipboard(image: image)
                            } label: {
                                Label("Copy Image", systemImage: "doc.on.doc")
                            }
                            
                            Button {
                                saveToDownloads(image: image)
                            } label: {
                                Label("Save to Downloads", systemImage: "square.and.arrow.down")
                            }
                            
                            Divider()
                            
                            SettingsLink {
                                Label("Preferences...", systemImage: "gear")
                            }
                            
                            Button("Quit JustTheDogs") {
                                NSApplication.shared.terminate(nil)
                            }
                        }
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                        .id(image)
                } else if manager.isLoading {
                    ProgressView()
                        .controlSize(.regular)
                        .frame(width: 200, height: 200)
                } else if let error = manager.errorMessage {
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle")
                        Text(error)
                            .font(.caption)
                        Button("Retry") {
                            manager.advanceToNextDog()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                    .padding()
                    .frame(width: 200, height: 150)
                }
            }
            
            // Welcome Overlay
            if !hasLaunchedBefore {
                ZStack {
                    Color.black.opacity(0.7)
                    
                    VStack(spacing: 16) {
                        Text("Welcome to JustTheDogs")
                            .font(.headline)
                            .foregroundStyle(.white)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Click dog to refresh", systemImage: "hand.tap")
                            Label("Right-click for options", systemImage: "menucard")
                        }
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.9))
                        
                        Divider().background(.white.opacity(0.3))
                        
                        Text("Made by Allison")
                            .font(.caption2)
                            .italic()
                            .foregroundStyle(.white.opacity(0.7))
                        
                        Button("Got it!") {
                            withAnimation {
                                hasLaunchedBefore = true
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.white)
                        .foregroundStyle(.black)
                        .controlSize(.small)
                    }
                    .padding(24)
                }
                .transition(.opacity)
            }
        }
        // Fixed: Ensure the parent container has no padding and background color
        // that matches nothing (clear) to prevent "border" flashes during transitions.
        .background(Color.clear)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: manager.currentImage)
        .onDisappear {
            // Delay the swap slightly so the window fades out BEFORE the content changes.
            // This prevents the visual "snap" during the dismissal animation.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                manager.advanceToNextDog()
            }
        }
    }
    
    private func copyToClipboard(image: NSImage) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.writeObjects([image])
    }
    
    private func saveToDownloads(image: NSImage) {
        guard let data = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: data),
              let pngData = bitmap.representation(using: .png, properties: [:]) else { return }
        
        let filename = "dog-\(Int(Date().timeIntervalSince1970)).png"
        let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        let fileURL = downloadsURL.appendingPathComponent(filename)
        
        try? pngData.write(to: fileURL)
    }
    
    private func calculateFrame(for image: NSImage) -> CGSize {
        let imageSize = image.size
        guard imageSize.width > 0, imageSize.height > 0 else { return CGSize(width: 300, height: 300) }
        
        let aspectRatio = imageSize.width / imageSize.height
        
        // System popovers have a minimum width (approx 200-220px).
        // We enforce a slightly larger minimum to be safe and avoid "side bars".
        let minWidth: CGFloat = 225
        let maxWidth: CGFloat = selectedSize.maxWidth
        
        // Target a reasonable default width (e.g., 300), but clamp it.
        let targetWidth: CGFloat = max(minWidth, min(maxWidth, imageSize.width))
        
        // Calculate height based on the clamped width to maintain ratio
        let targetHeight = targetWidth / aspectRatio
        
        return CGSize(width: targetWidth, height: targetHeight)
    }
}