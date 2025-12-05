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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(songStore)
                .environmentObject(spotifyService)
        }
    }
}

