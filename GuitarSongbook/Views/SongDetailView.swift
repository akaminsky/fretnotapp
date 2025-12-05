//
//  SongDetailView.swift
//  GuitarSongbook
//
//  Detailed view of a single song - Notion page style
//

import SwiftUI

struct SongDetailView: View {
    @EnvironmentObject var songStore: SongStore
    @EnvironmentObject var spotifyService: SpotifyService
    @Environment(\.dismiss) var dismiss
    
    let song: Song
    @State private var showingEditSheet = false
    @State private var showingCategoryPicker = false
    
    // Get the live version of the song from the store
    private var liveSong: Song {
        songStore.songs.first { $0.id == song.id } ?? song
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Cover Image - Notion style
                    coverSection
                    
                    // Content
                    VStack(alignment: .leading, spacing: 24) {
                        // Title Section
                        titleSection
                        
                        // Properties - Notion style
                        propertiesSection
                        
                        // Divider
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(height: 1)
                        
                        // Chord Diagrams
                        if !liveSong.chords.isEmpty {
                            chordSection
                        }
                        
                        // Notes
                        if let notes = liveSong.notes, !notes.isEmpty {
                            notesSection(notes)
                        }
                        
                        // Actions
                        actionsSection
                    }
                    .padding(20)
                }
            }
            .ignoresSafeArea(edges: .top)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.body.weight(.medium))
                            .foregroundColor(.secondary)
                            .frame(width: 32, height: 32)
                            .background(Color(.systemBackground).opacity(0.8))
                            .clipShape(Circle())
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        // Favorite button
                        Button {
                            songStore.toggleFavorite(liveSong)
                        } label: {
                            Image(systemName: liveSong.isFavorite ? "star.fill" : "star")
                                .font(.body.weight(.medium))
                                .foregroundColor(liveSong.isFavorite ? .appGold : .secondary)
                        }
                        
                        Button {
                            showingEditSheet = true
                        } label: {
                            Text("Edit")
                                .font(.body.weight(.medium))
                                .foregroundColor(.appAccent)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                NavigationStack {
                    AddSongView(editingSong: liveSong)
                        .environmentObject(songStore)
                        .environmentObject(spotifyService)
                }
            }
            .sheet(isPresented: $showingCategoryPicker) {
                CategoryPickerView(song: liveSong)
                    .environmentObject(songStore)
            }
        }
    }
    
    // MARK: - Cover Section
    
    private var coverSection: some View {
        ZStack(alignment: .bottom) {
            AsyncImage(url: URL(string: liveSong.albumCoverUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                LinearGradient(
                    colors: [Color.appAccent.opacity(0.4), Color.appAccent.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            .frame(height: 280)
            .clipped()
            
            LinearGradient(
                colors: [.clear, Color(.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 120)
        }
    }
    
    // MARK: - Title Section
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(liveSong.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                if liveSong.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundColor(.appGold)
                }
            }
            
            Text(liveSong.artist)
                .font(.title3)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Properties Section
    
    private var propertiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Date Added
            PropertyRow(label: "Added", icon: "calendar") {
                Text(liveSong.formattedDate)
                    .foregroundColor(.primary)
            }
            
            // Capo
            PropertyRow(label: "Capo", icon: "guitars") {
                Text(liveSong.capoDisplayText)
                    .foregroundColor(.primary)
            }
            
            // Chords
            if !liveSong.chords.isEmpty {
                PropertyRow(label: "Chords", icon: "music.note.list") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(liveSong.chords, id: \.self) { chord in
                                Text(chord)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.appAccentText)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.appAccent.opacity(0.12))
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
            }
            
            // Categories
            PropertyRow(label: "Categories", icon: "folder") {
                HStack(spacing: 6) {
                    if liveSong.isFavorite {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                            Text("Favorites")
                        }
                        .font(.subheadline)
                        .foregroundColor(.appGoldText)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.appGold.opacity(0.15))
                        .cornerRadius(6)
                    }
                    
                    ForEach(liveSong.categories, id: \.self) { category in
                        Text(category)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(6)
                    }
                    
                    Button {
                        showingCategoryPicker = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(6)
                            .background(Color(.systemGray5))
                            .cornerRadius(6)
                    }
                }
            }
            
            // Spotify Link
            if liveSong.spotifyUrl != nil {
                PropertyRow(label: "Spotify", icon: "play.circle.fill") {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("Linked")
                            .foregroundColor(.green)
                    }
                }
            }
        }
    }
    
    // MARK: - Chord Section
    
    private var chordSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "hand.raised")
                    .foregroundColor(.secondary)
                Text("Chord Diagrams")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            ChordDiagramsGrid(chords: liveSong.chords)
        }
        .padding(20)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(12)
    }
    
    // MARK: - Notes Section
    
    private func notesSection(_ notes: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "note.text")
                    .foregroundColor(.secondary)
                Text("Notes")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            Text(notes)
                .font(.body)
                .foregroundColor(.secondary)
                .lineSpacing(6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(12)
    }
    
    // MARK: - Actions Section
    
    private var actionsSection: some View {
        VStack(spacing: 12) {
            if let spotifyUrl = liveSong.spotifyUrl, let url = URL(string: spotifyUrl) {
                Link(destination: url) {
                    HStack {
                        Image(systemName: "play.fill")
                            .font(.body.weight(.semibold))
                        Text("Play on Spotify")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
            
            if let tabUrl = liveSong.tabUrl, let url = URL(string: tabUrl) {
                Link(destination: url) {
                    HStack {
                        Image(systemName: "doc.text")
                        Text("View Tabs")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(.systemGray6))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
                }
            } else {
                Button {
                    searchUltimateGuitar()
                } label: {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text("Search for Tabs")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(.systemGray6))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
                }
            }
        }
        .padding(.top, 8)
    }
    
    private func searchUltimateGuitar() {
        let query = "\(liveSong.artist) \(liveSong.title)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://www.ultimate-guitar.com/search.php?search_type=title&value=\(query)"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Property Row

struct PropertyRow<Content: View>: View {
    let label: String
    let icon: String
    @ViewBuilder let content: Content
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 16)
                
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(width: 100, alignment: .leading)
            
            content
                .font(.subheadline)
            
            Spacer()
        }
    }
}

// MARK: - Category Picker

struct CategoryPickerView: View {
    @EnvironmentObject var songStore: SongStore
    @Environment(\.dismiss) var dismiss
    
    let song: Song
    @State private var newCategoryName = ""
    
    // Get live version of the song
    private var liveSong: Song {
        songStore.songs.first { $0.id == song.id } ?? song
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Favorites section
                Section {
                    Button {
                        songStore.toggleFavorite(liveSong)
                    } label: {
                        HStack {
                            Image(systemName: liveSong.isFavorite ? "star.fill" : "star")
                                .foregroundColor(.appGold)
                            
                            Text("Favorites")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if liveSong.isFavorite {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.appAccent)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
                
                // Quick add new category
                Section {
                    HStack {
                        TextField("Create new category...", text: $newCategoryName)
                        
                        if !newCategoryName.isEmpty {
                            Button {
                                songStore.createCategory(newCategoryName)
                                songStore.addCategory(liveSong, category: newCategoryName)
                                newCategoryName = ""
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.appAccent)
                            }
                        }
                    }
                } header: {
                    Text("Create New")
                }
                
                // Existing categories
                Section {
                    ForEach(songStore.categories, id: \.self) { category in
                        Button {
                            toggleCategory(category)
                        } label: {
                            HStack {
                                Image(systemName: "folder.fill")
                                    .foregroundColor(.blue)
                                
                                Text(category)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if liveSong.categories.contains(category) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.appAccent)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    }
                    
                    if songStore.categories.isEmpty {
                        HStack {
                            Spacer()
                            VStack(spacing: 8) {
                                Image(systemName: "folder")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                                Text("No custom categories yet")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 20)
                            Spacer()
                        }
                    }
                } header: {
                    Text("Categories")
                }
            }
            .navigationTitle("Add to Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    private func toggleCategory(_ category: String) {
        if liveSong.categories.contains(category) {
            songStore.removeCategory(liveSong, category: category)
        } else {
            songStore.addCategory(liveSong, category: category)
        }
    }
}

#Preview {
    SongDetailView(song: Song(
        title: "Wonderwall",
        artist: "Oasis",
        chords: ["Am", "G", "C", "D"],
        capoPosition: 2,
        spotifyUrl: "https://open.spotify.com/track/2CT3r93YuSHtm57mjxvjhH",
        notes: "Great for beginners! Use a light strumming pattern.",
        isFavorite: true,
        categories: ["Learning", "Campfire"]
    ))
    .environmentObject(SongStore())
    .environmentObject(SpotifyService())
}
