//
//  BulkImportView.swift
//  GuitarSongbook
//
//  Bulk import songs from Spotify playlist
//

import SwiftUI

struct BulkImportView: View {
    @EnvironmentObject var songStore: SongStore
    @EnvironmentObject var spotifyService: SpotifyService
    @Environment(\.dismiss) var dismiss
    
    @State private var playlistURL = ""
    @State private var isImporting = false
    @State private var importProgress: Double = 0
    @State private var importedCount = 0
    @State private var skippedCount = 0
    @State private var totalTracks = 0
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Instructions
                VStack(alignment: .leading, spacing: 12) {
                    Text("Import from Spotify Playlist")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Paste a Spotify playlist link to automatically add all songs. You can add chords later by editing each song.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // URL Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Playlist URL")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)

                    TextField("https://open.spotify.com/playlist/...", text: $playlistURL)
                        .padding(Spacing.md)
                        .background(Color.warmInputBackground)
                        .cornerRadius(CornerRadius.input)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.inputBorder, lineWidth: 1)
                        )
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                        .disabled(isImporting)
                }
                
                // Import Button
                Button {
                    importPlaylist()
                } label: {
                    HStack {
                        if isImporting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "square.and.arrow.down")
                        }
                        Text(isImporting ? "Importing..." : "Import Playlist")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(playlistURL.isEmpty || isImporting ? Color.gray : Color.appAccent)
                    .foregroundColor(.white)
                    .cornerRadius(CornerRadius.card)
                }
                .disabled(playlistURL.isEmpty || isImporting)
                
                // Progress
                if isImporting && totalTracks > 0 {
                    VStack(spacing: 8) {
                        ProgressView(value: importProgress, total: 1.0)
                        
                        VStack(spacing: 2) {
                            Text("\(importedCount) of \(totalTracks) songs imported")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if skippedCount > 0 {
                                Text("\(skippedCount) already in library")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Import Playlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isImporting)
                }
            }
            .alert("Import Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .background(Color.warmBackground)
        }
    }
    
    private func importPlaylist() {
        guard !playlistURL.isEmpty else { return }
        
        isImporting = true
        importedCount = 0
        skippedCount = 0
        totalTracks = 0
        importProgress = 0
        
        Task {
            do {
                let tracks = await spotifyService.fetchPlaylistTracks(playlistURL: playlistURL)
                
                guard !tracks.isEmpty else {
                    await MainActor.run {
                        errorMessage = "No tracks found. Please check the playlist URL."
                        showError = true
                        isImporting = false
                    }
                    return
                }
                
                totalTracks = tracks.count
                var processedCount = 0
                
                // Import tracks one by one to show progress
                for track in tracks {
                    // Check if song already exists (by title and artist, case-insensitive)
                    let songExists = songStore.songs.contains { existingSong in
                        existingSong.title.lowercased().trimmingCharacters(in: .whitespaces) == track.name.lowercased().trimmingCharacters(in: .whitespaces) &&
                        existingSong.artist.lowercased().trimmingCharacters(in: .whitespaces) == track.artistNames.lowercased().trimmingCharacters(in: .whitespaces)
                    }
                    
                    if !songExists {
                        let song = Song(
                            title: track.name,
                            artist: track.artistNames,
                            chords: [], // Empty - user adds chords later
                            capoPosition: 0,
                            dateAdded: Date(),
                            spotifyUrl: track.externalUrls.spotify,
                            albumCoverUrl: track.albumCoverUrl
                        )
                        
                        await MainActor.run {
                            songStore.addSong(song)
                            importedCount += 1
                        }
                    } else {
                        await MainActor.run {
                            skippedCount += 1
                        }
                    }
                    
                    processedCount += 1
                    
                    await MainActor.run {
                        importProgress = Double(processedCount) / Double(totalTracks)
                    }
                    
                    // Small delay for smoother UI
                    try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
                }
                
                await MainActor.run {
                    isImporting = false
                    playlistURL = ""
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    BulkImportView()
        .environmentObject(SongStore())
        .environmentObject(SpotifyService())
}

