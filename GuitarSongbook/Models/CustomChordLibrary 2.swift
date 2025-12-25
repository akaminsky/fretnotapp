//
//  CustomChordLibrary.swift
//  GuitarSongbook
//
//  Manages custom chord variations with iCloud sync
//

import Foundation
import SwiftUI

struct CustomChordData: Codable, Identifiable, Equatable {
    let id: UUID
    let fingers: [Int]  // [E, A, D, G, B, e] - -1 = don't play, 0 = open, 1-15 = fret
    let name: String  // Base chord name (e.g., "G")
    let displayName: String  // Full name shown to users (e.g., "G (Sweet Home)")
    let barre: Int?
    let dateCreated: Date

    // Convert to ChordData for rendering
    var asChordData: ChordData {
        ChordData(fingers: fingers, name: displayName, barre: barre)
    }
}

class CustomChordLibrary: ObservableObject {
    static let shared = CustomChordLibrary()

    @Published private(set) var customChords: [CustomChordData] = []

    private let customChordsKey = "customChords"
    private let iCloudStore = NSUbiquitousKeyValueStore.default
    private var iCloudEnabled: Bool = false

    private init() {
        setupiCloudSync()
        loadCustomChords()
    }

    // MARK: - iCloud Setup

    private func setupiCloudSync() {
        if FileManager.default.ubiquityIdentityToken != nil {
            iCloudEnabled = true

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(iCloudDataDidChange),
                name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                object: iCloudStore
            )

            iCloudStore.synchronize()
        } else {
            iCloudEnabled = false
            print("iCloud not available for custom chords - using local storage only")
        }
    }

    @objc private func iCloudDataDidChange(_ notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.loadCustomChords()
        }
    }

    // MARK: - CRUD Operations

    func addCustomChord(_ chord: CustomChordData) {
        customChords.append(chord)
        saveCustomChords()
    }

    func deleteCustomChord(_ id: UUID) -> CustomChordData? {
        guard let index = customChords.firstIndex(where: { $0.id == id }) else {
            return nil
        }
        let removed = customChords.remove(at: index)
        saveCustomChords()
        return removed
    }

    func updateCustomChord(_ chord: CustomChordData) {
        if let index = customChords.firstIndex(where: { $0.id == chord.id }) {
            customChords[index] = chord
            saveCustomChords()
        }
    }

    func findCustomChord(byDisplayName name: String) -> CustomChordData? {
        customChords.first { $0.displayName == name }
    }

    func findCustomChord(byId id: UUID) -> CustomChordData? {
        customChords.first { $0.id == id }
    }

    func isCustomChordName(_ name: String) -> Bool {
        customChords.contains { $0.displayName == name }
    }

    // MARK: - Persistence

    private func saveCustomChords() {
        guard let encoded = try? JSONEncoder().encode(customChords) else {
            print("Failed to encode custom chords")
            return
        }

        // Save to local UserDefaults (always)
        UserDefaults.standard.set(encoded, forKey: customChordsKey)

        // Save to iCloud if available
        if iCloudEnabled {
            iCloudStore.set(encoded, forKey: customChordsKey)
            iCloudStore.synchronize()
        }
    }

    private func loadCustomChords() {
        var data: Data?

        // Try iCloud first if available
        if iCloudEnabled {
            data = iCloudStore.data(forKey: customChordsKey)
        }

        // Fall back to local storage
        if data == nil {
            data = UserDefaults.standard.data(forKey: customChordsKey)
        }

        // Decode and validate
        if let data = data {
            do {
                let decoded = try JSONDecoder().decode([CustomChordData].self, from: data)
                // Validate entries
                customChords = decoded.filter { chord in
                    chord.fingers.count == 6 &&  // Must have 6 strings
                    !chord.displayName.isEmpty   // Must have name
                }
            } catch {
                print("Failed to decode custom chords: \(error)")
                customChords = []
            }
        }
    }
}
