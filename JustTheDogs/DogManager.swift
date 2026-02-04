//
//  DogManager.swift
//  JustTheDogs
//

import SwiftUI
import Observation

@Observable
class DogManager {
    /// The image currently displayed to the user
    var currentImage: NSImage?
    
    /// A buffer holding the NEXT image, ready to be promoted to 'current' instantly
    private var nextImage: NSImage?
    
    var isLoading = false
    var errorMessage: String?
    
    private let apiURL = "https://dog.ceo/api/breeds/image/random"
    
    init() {
        Task {
            // Initial load: Get the first dog for display, and preload the second
            await fetchInitialDogs()
        }
    }
    
    /// Called once on app launch to populate both slots
    @MainActor
    private func fetchInitialDogs() async {
        isLoading = true
        // 1. Fetch current visible dog
        if let dog = await fetchSingleDog() {
            currentImage = dog
        } else {
            errorMessage = "Failed to load initial dog."
        }
        isLoading = false
        
        // 2. Preload the next one in the background
        if let nextDog = await fetchSingleDog() {
            nextImage = nextDog
        }
    }
    
    /// Swaps the preloaded image to current, then fetches a replacement in the background.
    /// Call this when the window closes or user clicks "Refresh".
    @MainActor
    func advanceToNextDog() {
        // If we have a buffered image, swap it in instantly!
        if let buffered = nextImage {
            currentImage = buffered
            nextImage = nil // Buffer is now empty
            
            // Replenish buffer in background
            Task {
                if let newDog = await fetchSingleDog() {
                    self.nextImage = newDog
                }
            }
        } else {
            // Buffer empty (race condition or initial failure)? Fetch directly to current.
            isLoading = true
            Task {
                if let dog = await fetchSingleDog() {
                    self.currentImage = dog
                } else {
                    self.errorMessage = "Failed to fetch dog."
                }
                self.isLoading = false
                
                // Try to fill buffer again after recovery
                if let nextDog = await fetchSingleDog() {
                    self.nextImage = nextDog
                }
            }
        }
    }
    
    /// Helper to fetch a single dog image
    @MainActor
    private func fetchSingleDog() async -> NSImage? {
        do {
            // 1. Get URL
            guard let url = URL(string: apiURL) else { return nil }
            let (json, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(DogAPIResponse.self, from: json)
            
            guard let imageURL = URL(string: response.message) else { return nil }
            
            // 2. Get Data
            let (imageData, _) = try await URLSession.shared.data(from: imageURL)
            
            // 3. Decode Image
            return NSImage(data: imageData)
        } catch {
            print("Dog fetch failed: \(error.localizedDescription)")
            return nil
        }
    }
}

// API Model
struct DogAPIResponse: Codable {
    let message: String
    let status: String
}
