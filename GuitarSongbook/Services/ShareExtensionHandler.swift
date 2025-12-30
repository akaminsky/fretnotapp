//
//  ShareExtensionHandler.swift
//  GuitarSongbook
//
//  Handles data received from Share Extension
//

import Foundation
import Combine

struct SharedChordData {
    let capo: Int
    let chords: [String]
    let notes: String
}

class ShareExtensionHandler: ObservableObject {
    @Published var shouldShowAddSong = false
    @Published var sharedData: SharedChordData?

    private let sharedDefaults = UserDefaults(suiteName: "group.com.akaminsky.fretnot")

    init() {
        // Check for shared data on initialization
        checkForSharedData()
    }

    func checkForSharedData() {
        let timestamp = sharedDefaults?.double(forKey: "sharedTimestamp") ?? 0

        // Check if there's a share available
        guard timestamp > 0 else {
            return
        }

        // Read from shared UserDefaults
        let capo = sharedDefaults?.object(forKey: "sharedCapo") as? Int
        let chords = sharedDefaults?.array(forKey: "sharedChords") as? [String]
        let notes = sharedDefaults?.string(forKey: "sharedNotes")

        guard let capo = capo,
              let chords = chords,
              let notes = notes else {
            return
        }

        // Store for navigation BEFORE clearing
        sharedData = SharedChordData(
            capo: capo,
            chords: chords,
            notes: notes
        )

        // Clear shared storage AFTER setting sharedData
        clearSharedData()

        shouldShowAddSong = true
    }

    func handleURL(_ url: URL) {
        guard url.scheme == "fretnot",
              url.host == "share-extension" else {
            return
        }

        checkForSharedData()
    }

    private func clearSharedData() {
        sharedDefaults?.removeObject(forKey: "sharedCapo")
        sharedDefaults?.removeObject(forKey: "sharedChords")
        sharedDefaults?.removeObject(forKey: "sharedNotes")
        sharedDefaults?.removeObject(forKey: "sharedTimestamp")
        sharedDefaults?.synchronize()
    }
}
