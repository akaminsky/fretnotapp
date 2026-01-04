//
//  GuitarSongbookApp.swift
//  GuitarSongbook
//
//  A native iOS app for managing guitar songs with chord diagrams
//

import SwiftUI
import FirebaseCore

@main
struct GuitarSongbookApp: App {
    @StateObject private var songStore = SongStore()
    @StateObject private var spotifyService = SpotifyService()
    @StateObject private var resourceLinkDetector = ResourceLinkDetector()
    @StateObject private var shareExtensionHandler = ShareExtensionHandler()

    init() {
        // Initialize Firebase
        FirebaseApp.configure()

        // Initialize custom chord library on app launch
        _ = CustomChordLibrary.shared

        // Request notification permission on app launch
        Task {
            await NotificationManager.shared.requestPermission()
        }
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(songStore)
                .environmentObject(spotifyService)
                .environmentObject(resourceLinkDetector)
                .environmentObject(shareExtensionHandler)
                .onOpenURL { url in
                    shareExtensionHandler.handleURL(url)
                }
        }
    }
}

