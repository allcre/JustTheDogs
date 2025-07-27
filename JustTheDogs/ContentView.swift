//
//  ContentView.swift
//  JustTheDogs
//
//  Created by Allison Cretel on 2025-07-26.
//

import SwiftUI

// MARK: - API Models
struct DogAPIResponse: Codable {
    let message: String // This contains the image URL
    let status: String
}

// MARK: - Dog Image with Dimensions
struct DogImageData {
    let url: URL
    let size: CGSize
}

// MARK: - Dog Image Service
@MainActor
class DogImageService: ObservableObject {
    @Published var currentImageData: DogImageData?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiURL = "https://dog.ceo/api/breeds/image/random"
    private var preparedImageData: DogImageData? // Image prepared for next window show

    // Window size constraints
    private let minWidth: CGFloat = 200
    private let maxWidth: CGFloat = 500
    private let minHeight: CGFloat = 150
    private let maxHeight: CGFloat = 400

    init() {
        // Start preparing the first image on initialization
        Task {
            await prepareFirstImage()
        }
    }

    func prepareFirstImage() async {
        print("Preparing first image...")
        isLoading = true
        errorMessage = nil

        if let imageData = await fetchImageWithDimensions() {
            preparedImageData = imageData
            currentImageData = imageData // Show this immediately if window is opened

            // Calculate and notify window size
            let windowSize = calculateOptimalWindowSize(for: imageData.size)
            NotificationCenter.default.post(
                name: NSNotification.Name("ImageReadyForNextShow"),
                object: windowSize
            )

            print("First image prepared with size: \(windowSize)")
        } else {
            errorMessage = "Failed to load initial image"
        }

        isLoading = false
    }

    func prepareNextImage() async {
        print("Preparing next image...")

        if let imageData = await fetchImageWithDimensions() {
            preparedImageData = imageData

            // Calculate and notify window size for next show
            let windowSize = calculateOptimalWindowSize(for: imageData.size)
            NotificationCenter.default.post(
                name: NSNotification.Name("ImageReadyForNextShow"),
                object: windowSize
            )

            print("Next image prepared with size: \(windowSize)")
        } else {
            print("Failed to prepare next image")
        }
    }

    func showCurrentImage() {
        print("Showing current image")

        // Use the prepared image if available
        if let prepared = preparedImageData {
            currentImageData = prepared
            preparedImageData = nil // Clear it since we're now using it
            print("Displayed prepared image")
        } else {
            print("No prepared image available")
        }
    }

    func clearCurrentImage() {
        print("Clearing current image")
        currentImageData = nil
    }

    private func fetchImageWithDimensions() async -> DogImageData? {
        do {
            // Fetch image URL from API
            guard let url = URL(string: apiURL) else { return nil }
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(DogAPIResponse.self, from: data)

            guard let imageURL = URL(string: response.message) else { return nil }

            // Load image to get dimensions
            let (imageData, _) = try await URLSession.shared.data(from: imageURL)

            #if canImport(AppKit)
            guard let nsImage = NSImage(data: imageData) else { return nil }
            let imageSize = nsImage.size
            #else
            guard let uiImage = UIImage(data: imageData) else { return nil }
            let imageSize = uiImage.size
            #endif

            return DogImageData(url: imageURL, size: imageSize)

        } catch {
            print("Error fetching image: \(error)")
            return nil
        }
    }

    private func calculateOptimalWindowSize(for imageSize: CGSize) -> CGSize {
        // Calculate aspect ratio
        let aspectRatio = imageSize.width / imageSize.height

        // Start with a target height and calculate width
        let targetHeight: CGFloat = 300
        let calculatedWidth = targetHeight * aspectRatio

        // Apply constraints
        let constrainedWidth = min(max(calculatedWidth, minWidth), maxWidth)
        let constrainedHeight = min(max(constrainedWidth / aspectRatio, minHeight), maxHeight)

        return CGSize(width: constrainedWidth, height: constrainedHeight)
    }

    func retryFetch() async {
        await prepareFirstImage()
    }
}

// MARK: - Content View
struct ContentView: View {
    @ObservedObject var dogImageService: DogImageService

    // Constructor that accepts the shared dog image service
    init(dogImageService: DogImageService) {
        self.dogImageService = dogImageService
    }

    var body: some View {
        Group {
            if dogImageService.isLoading && dogImageService.currentImageData == nil {
                // Loading state - only show when no image is available
                VStack {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Fetching a good dog...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)
                }
                .frame(width: 300, height: 200)
                .background(Color(NSColor.controlBackgroundColor))
            } else if let errorMessage = dogImageService.errorMessage, dogImageService.currentImageData == nil {
                // Error state - only show when no image is available
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 30))
                        .foregroundStyle(.orange)
                    Text("Oops!")
                        .font(.headline)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Try Again") {
                        Task {
                            await dogImageService.retryFetch()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
                .padding(20)
                .frame(width: 300, height: 200)
                .background(Color(NSColor.controlBackgroundColor))
            } else if let imageData = dogImageService.currentImageData {
                // Success state - show dog image without cropping
                AsyncImage(url: imageData.url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            ProgressView()
                                .scaleEffect(1.2)
                        )
                }
            } else {
                // Fallback state - empty when current image is cleared
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 300, height: 200)
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 0)
    }
}

#Preview {
    ContentView(dogImageService: DogImageService())
}
