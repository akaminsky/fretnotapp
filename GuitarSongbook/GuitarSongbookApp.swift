//
//  GuitarSongbookApp.swift
//  GuitarSongbook
//
//  A native iOS app for managing guitar songs with chord diagrams
//

import SwiftUI

@main
struct GuitarSongbookApp: App {
    @StateObject private var songStore = SongStore()
    @StateObject private var spotifyService = SpotifyService()
    @StateObject private var tabURLDetector = TabURLDetector()

    init() {
        // Initialize custom chord library on app launch
        _ = CustomChordLibrary.shared
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(songStore)
                .environmentObject(spotifyService)
                .environmentObject(tabURLDetector)
        }
    }
}

