//
//  QuickAddView.swift
//  GuitarSongbook
//
//  Quick add form for fast song entry
//

import SwiftUI

struct QuickAddView: View {
    @EnvironmentObject var songStore: SongStore
    @EnvironmentObject var spotifyService: SpotifyService
    @Binding var isPresented: Bool
    
    @State private var searchQuery = ""
    @State private var selectedTrack: SpotifyTrack?
    @State private var chords = ""
    @State private var capoPosition = 0
    @State private var dateAdded = Date()
    @State private var showingFullForm = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Add Song")
                    .font(.headline)
                    .foregroundColor(.appAccent)
                
                Spacer()
                
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.appAccent)
                        .padding(8)
                        .background(Color.appAccent.opacity(0.1))
                        .cornerRadius(6)
                }
            }
            .padding()
            .background(Color.appAccent.opacity(0.08))
            
            // Content
            VStack(spacing: 16) {
                if selectedTrack == nil {
                    // Spotify Search
                    SpotifySearchField(
                        query: $searchQuery,
                        onSearch: {
                            Task {
                                await spotifyService.search(query: searchQuery)
                            }
                        }
                    )
                    
                    // Search Results
                    if spotifyService.isSearching {
                        ProgressView("Searching...")
                            .padding()
                    } else if !spotifyService.searchResults.isEmpty {
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(spotifyService.searchResults) { track in
                                    SpotifyTrackRow(track: track) {
                                        selectedTrack = track
                                        spotifyService.clearResults()
                                        searchQuery = ""
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: 200)
                    }
                } else {
                    // Selected Song Form
                    selectedSongForm
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.appAccent, lineWidth: 2)
        )
        .padding(.horizontal)
        .shadow(color: Color.black.opacity(0.1), radius: 10, y: 5)
        .sheet(isPresented: $showingFullForm) {
            AddSongView(
                prefilledTitle: selectedTrack?.name ?? "",
                prefilledArtist: selectedTrack?.artistNames ?? "",
                prefilledSpotifyUrl: selectedTrack?.externalUrls.spotify,
                prefilledAlbumCover: selectedTrack?.albumCoverUrl,
                prefilledChords: chords,
                prefilledCapo: capoPosition,
                prefilledDate: dateAdded
            )
            .environmentObject(songStore)
            .environmentObject(spotifyService)
        }
    }
    
    // MARK: - Selected Song Form
    
    private var selectedSongForm: some View {
        VStack(spacing: 16) {
            // Selected Track Display
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: selectedTrack?.mediumAlbumCoverUrl ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color(.systemGray5))
                }
                .frame(width: 60, height: 60)
                .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedTrack?.name ?? "")
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text(selectedTrack?.artistNames ?? "")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Button {
                    selectedTrack = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.warmInputBackground)
            .cornerRadius(10)
            
            // Chords Input
            VStack(alignment: .leading, spacing: 4) {
                Text("CHORDS *")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                TextField("Am, F, C, G", text: $chords)
                    .textFieldStyle(.roundedBorder)
            }
            
            // Capo and Date Row
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("CAPO")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Picker("Capo", selection: $capoPosition) {
                        Text("No Capo").tag(0)
                        ForEach(1...7, id: \.self) { fret in
                            Text("\(fret)\(ordinalSuffix(fret))").tag(fret)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
                    .background(Color.warmInputBackground)
                    .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("DATE ADDED")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    DatePicker("", selection: $dateAdded, displayedComponents: .date)
                        .labelsHidden()
                }
            }
            
            // Actions
            HStack {
                Button {
                    showingFullForm = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.forward.square")
                        Text("Advanced Edit")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button("Cancel") {
                        selectedTrack = nil
                        isPresented = false
                    }
                    .foregroundColor(.secondary)
                    
                    Button {
                        addSong()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark")
                            Text("Add Song")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.appAccent)
                    .disabled(chords.isEmpty)
                }
            }
            .padding(.top, 8)
        }
    }
    
    // MARK: - Helpers
    
    private func ordinalSuffix(_ number: Int) -> String {
        switch number {
        case 1: return "st"
        case 2: return "nd"
        case 3: return "rd"
        default: return "th"
        }
    }
    
    private func addSong() {
        guard let track = selectedTrack else { return }
        
        let parsedChords = chords
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        let song = Song(
            title: track.name,
            artist: track.artistNames,
            chords: parsedChords,
            capoPosition: capoPosition,
            dateAdded: dateAdded,
            spotifyUrl: track.externalUrls.spotify,
            albumCoverUrl: track.albumCoverUrl
        )
        
        songStore.addSong(song)
        
        selectedTrack = nil
        chords = ""
        capoPosition = 0
        isPresented = false
    }
}

// MARK: - Spotify Search Field

struct SpotifySearchField: View {
    @Binding var query: String
    let onSearch: () -> Void
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack {
            TextField("Search Spotify for a song...", text: $query)
                .focused($isFocused)
                .textFieldStyle(.plain)
                .onSubmit(onSearch)

            Button(action: onSearch) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.appAccent)
                    .cornerRadius(6)
            }
        }
        .padding(8)
        .background(Color.warmInputBackground)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isFocused ? Color.appAccent.opacity(0.4) : Color.inputBorder, lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// MARK: - Spotify Track Row

struct SpotifyTrackRow: View {
    let track: SpotifyTrack
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 10) {
                AsyncImage(url: URL(string: track.smallAlbumCoverUrl ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color(.systemGray5))
                }
                .frame(width: 40, height: 40)
                .cornerRadius(4)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(track.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(track.artistNames)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.appAccent)
            }
            .padding(10)
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    QuickAddView(isPresented: .constant(true))
        .environmentObject(SongStore())
        .environmentObject(SpotifyService())
}
