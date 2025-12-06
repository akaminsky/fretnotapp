//
//  AddSongView.swift
//  GuitarSongbook
//
//  Full form for adding/editing songs - Quick Add style with Spotify search first
//

import SwiftUI

struct AddSongView: View {
    @EnvironmentObject var songStore: SongStore
    @EnvironmentObject var spotifyService: SpotifyService
    @Environment(\.dismiss) var dismiss
    
    // For editing existing song
    var editingSong: Song?
    
    // For prefilled values
    var prefilledTitle: String = ""
    var prefilledArtist: String = ""
    var prefilledSpotifyUrl: String? = nil
    var prefilledAlbumCover: String? = nil
    var prefilledChords: String = ""
    var prefilledCapo: Int = 0
    var prefilledDate: Date = Date()
    
    @State private var title = ""
    @State private var artist = ""
    @State private var chords = ""
    @State private var capoPosition = 0
    @State private var dateAdded = Date()
    @State private var spotifyUrl = ""
    @State private var tabUrl = ""
    @State private var notes = ""
    @State private var albumCoverUrl: String?
    
    @State private var searchQuery = ""
    @State private var showingDeleteConfirmation = false
    @State private var selectedTrack: SpotifyTrack?
    @State private var showSpotifySearch = false
    @State private var isFavorite = false
    @State private var selectedCategories: Set<String> = []
    @State private var newCategoryName = ""
    
    var isEditing: Bool {
        editingSong != nil
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // STEP 1: Spotify Search (if no track selected and not editing)
                if selectedTrack == nil && !isEditing && title.isEmpty {
                    spotifySearchSection
                } else {
                    // Show selected song header or editing header
                    if let track = selectedTrack {
                        selectedTrackHeader(track)
                    } else if isEditing {
                        editingHeaderWithSpotify
                    }
                    
                    // Main form fields
                    formFields
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(isEditing ? "Edit Song" : "Add Song")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button(isEditing ? "Save" : "Add Song") {
                    saveSong()
                }
                .fontWeight(.semibold)
                .disabled(title.isEmpty || artist.isEmpty)
            }
        }
        .onAppear {
            setupInitialValues()
        }
        .alert("Delete Song", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let song = editingSong {
                    songStore.deleteSong(song)
                    dismiss()
                }
            }
        } message: {
            Text("Are you sure you want to delete this song?")
        }
    }
    
    // MARK: - Spotify Search Section (Initial Add)
    
    private var spotifySearchSection: some View {
        VStack(spacing: 16) {
            // Search header
            VStack(spacing: 8) {
                Image(systemName: "music.note")
                    .font(.system(size: 40))
                    .foregroundColor(.appAccent)
                
                Text("Search Spotify")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Find a song you'll never forget")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)
            
            // Search field
            searchField
            
            // Search results
            searchResults
            
            // Or add manually
            VStack(spacing: 12) {
                HStack {
                    Rectangle()
                        .fill(Color(.systemGray4))
                        .frame(height: 1)
                    Text("or")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Rectangle()
                        .fill(Color(.systemGray4))
                        .frame(height: 1)
                }
                .padding(.top, 20)
                
                Button {
                    // Switch to manual entry
                    selectedTrack = SpotifyTrack(
                        id: "manual",
                        name: "",
                        artists: [SpotifyArtist(name: "")],
                        album: SpotifyAlbum(name: "", images: []),
                        externalUrls: SpotifyExternalUrls(spotify: "")
                    )
                } label: {
                    Text("Add song manually")
                        .font(.subheadline)
                        .foregroundColor(.appAccentText)
                }
            }
        }
    }
    
    // MARK: - Spotify Link Search (for editing/linking)
    
    private var spotifyLinkSearchSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Link to Spotify")
                    .font(.headline)
                Spacer()
                Button("Cancel") {
                    showSpotifySearch = false
                    spotifyService.clearResults()
                    searchQuery = ""
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            
            searchField
            searchResults
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Search Components
    
    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search for a song...", text: $searchQuery)
                .textFieldStyle(.plain)
                .onSubmit {
                    searchSpotify()
                }
            
            if !searchQuery.isEmpty {
                Button {
                    searchQuery = ""
                    spotifyService.clearResults()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
            
            Button {
                searchSpotify()
            } label: {
                Text("Search")
                    .fontWeight(.medium)
            }
            .buttonStyle(.borderedProminent)
            .tint(.appAccent)
            .disabled(searchQuery.isEmpty)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private var searchResults: some View {
        if spotifyService.isSearching {
            ProgressView("Searching...")
                .padding()
        } else if !spotifyService.searchResults.isEmpty {
            VStack(spacing: 8) {
                ForEach(spotifyService.searchResults) { track in
                    SpotifySearchResultRow(track: track) {
                        if showSpotifySearch {
                            // Just link the Spotify data, don't replace title/artist
                            spotifyUrl = track.externalUrls.spotify
                            albumCoverUrl = track.albumCoverUrl
                            showSpotifySearch = false
                            spotifyService.clearResults()
                            searchQuery = ""
                        } else {
                            selectTrack(track)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Selected Track Header
    
    private func selectedTrackHeader(_ track: SpotifyTrack) -> some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: track.albumCoverUrl ?? albumCoverUrl ?? "")) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .overlay {
                        Image(systemName: "music.note")
                            .foregroundColor(.gray)
                    }
            }
            .frame(width: 70, height: 70)
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                if track.id == "manual" {
                    Text("Adding manually")
                        .font(.headline)
                    Text("Fill in the details below")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    Text(track.name)
                        .font(.headline)
                        .lineLimit(1)
                    Text(track.artistNames)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Button {
                selectedTrack = nil
                title = ""
                artist = ""
                spotifyUrl = ""
                albumCoverUrl = nil
                spotifyService.clearResults()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Editing Header with Spotify Options
    
    private var editingHeaderWithSpotify: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Album Cover with remove option
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: URL(string: albumCoverUrl ?? "")) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .overlay {
                                Image(systemName: "music.note")
                                    .foregroundColor(.gray)
                            }
                    }
                    .frame(width: 70, height: 70)
                    .cornerRadius(8)
                    
                    // Remove album cover button
                    if albumCoverUrl != nil {
                        Button {
                            albumCoverUrl = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .background(Circle().fill(Color.black.opacity(0.6)))
                        }
                        .offset(x: 6, y: -6)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title.isEmpty ? editingSong?.title ?? "" : title)
                        .font(.headline)
                        .lineLimit(1)
                    Text(artist.isEmpty ? editingSong?.artist ?? "" : artist)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
            }
            
            // Spotify Link Section
            if !spotifyUrl.isEmpty {
                HStack {
                    Image(systemName: "link")
                        .foregroundColor(.green)
                    Text("Linked to Spotify")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button {
                        spotifyUrl = ""
                        albumCoverUrl = nil
                    } label: {
                        Text("Remove")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            } else {
                Button {
                    showSpotifySearch = true
                } label: {
                    HStack {
                        Image(systemName: "link.badge.plus")
                        Text("Link to Spotify")
                            .font(.subheadline)
                    }
                    .foregroundColor(.appAccentText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.appAccent.opacity(0.12))
                    .cornerRadius(8)
                }
            }
        }
        .sheet(isPresented: $showSpotifySearch) {
            SpotifyLinkSheetForEdit(
                title: title,
                artist: artist,
                onSelect: { track in
                    spotifyUrl = track.externalUrls.spotify
                    albumCoverUrl = track.albumCoverUrl
                    showSpotifySearch = false
                }
            )
            .environmentObject(spotifyService)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Form Fields
    
    private var formFields: some View {
        VStack(spacing: 16) {
            // Song Details
            FormSection(title: "Song Details") {
                FormTextField(label: "Song Title", text: $title, placeholder: "Enter song title")
                FormTextField(label: "Artist", text: $artist, placeholder: "Enter artist name")
            }
            
            // Guitar Info
            FormSection(title: "Guitar Info") {
                FormTextField(label: "Chords", text: $chords, placeholder: "Am, F, C, G")
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Capo Position")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    Picker("Capo", selection: $capoPosition) {
                        Text("No Capo").tag(0)
                        ForEach(1...7, id: \.self) { fret in
                            Text("\(fret)\(ordinalSuffix(fret)) Fret").tag(fret)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            
            // Categories
            FormSection(title: "Categories") {
                VStack(alignment: .leading, spacing: 12) {
                    // Favorites toggle
                    Button {
                        isFavorite.toggle()
                    } label: {
                        HStack {
                            Image(systemName: isFavorite ? "star.fill" : "star")
                                .foregroundColor(.appAccent)
                            Text("Favorites")
                                .foregroundColor(.primary)
                            Spacer()
                            if isFavorite {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.appAccent)
                                    .fontWeight(.semibold)
                            }
                        }
                        .padding(12)
                        .background(isFavorite ? Color.appAccent.opacity(0.15) : Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    
                    // Custom categories
                    if !songStore.categories.isEmpty {
                        ForEach(songStore.categories, id: \.self) { category in
                            Button {
                                if selectedCategories.contains(category) {
                                    selectedCategories.remove(category)
                                } else {
                                    selectedCategories.insert(category)
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "folder.fill")
                                        .foregroundColor(.secondary)
                                    Text(category)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    if selectedCategories.contains(category) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.appAccent)
                                            .fontWeight(.semibold)
                                    }
                                }
                                .padding(12)
                                .background(selectedCategories.contains(category) ? Color(.systemGray4) : Color(.systemGray6))
                                .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    // Add new category inline
                    HStack {
                        Image(systemName: "plus.circle")
                            .foregroundColor(.secondary)
                        TextField("Create new category...", text: $newCategoryName)
                        
                        if !newCategoryName.isEmpty {
                            Button {
                                songStore.createCategory(newCategoryName)
                                selectedCategories.insert(newCategoryName)
                                newCategoryName = ""
                            } label: {
                                Text("Add")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.appAccentText)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
            
            // Date
            FormSection(title: "Date Added") {
                DatePicker("", selection: $dateAdded, displayedComponents: .date)
                    .labelsHidden()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            
            // Notes (optional)
            FormSection(title: "Notes (Optional)") {
                TextField("Any notes about this song...", text: $notes, axis: .vertical)
                    .lineLimit(3...6)
                    .padding(12)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
            }
            
            // Delete button for editing
            if isEditing {
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete Song")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.top, 20)
            }
        }
    }
    
    // MARK: - Helpers
    
    private func searchSpotify() {
        Task {
            await spotifyService.search(query: searchQuery)
        }
    }
    
    private func setupInitialValues() {
        if let song = editingSong {
            title = song.title
            artist = song.artist
            chords = song.chords.joined(separator: ", ")
            capoPosition = song.capoPosition
            dateAdded = song.dateAdded
            spotifyUrl = song.spotifyUrl ?? ""
            tabUrl = song.tabUrl ?? ""
            notes = song.notes ?? ""
            albumCoverUrl = song.albumCoverUrl
            isFavorite = song.isFavorite
            selectedCategories = Set(song.categories)
        } else if !prefilledTitle.isEmpty {
            title = prefilledTitle
            artist = prefilledArtist
            chords = prefilledChords
            capoPosition = prefilledCapo
            dateAdded = prefilledDate
            spotifyUrl = prefilledSpotifyUrl ?? ""
            albumCoverUrl = prefilledAlbumCover
        }
    }
    
    private func selectTrack(_ track: SpotifyTrack) {
        selectedTrack = track
        title = track.name
        artist = track.artistNames
        spotifyUrl = track.externalUrls.spotify
        albumCoverUrl = track.albumCoverUrl
        spotifyService.clearResults()
        searchQuery = ""
    }
    
    private func ordinalSuffix(_ number: Int) -> String {
        switch number {
        case 1: return "st"
        case 2: return "nd"
        case 3: return "rd"
        default: return "th"
        }
    }
    
    private func saveSong() {
        let parsedChords = chords
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        if var song = editingSong {
            song.title = title
            song.artist = artist
            song.chords = parsedChords
            song.capoPosition = capoPosition
            song.dateAdded = dateAdded
            song.spotifyUrl = spotifyUrl.isEmpty ? nil : spotifyUrl
            song.tabUrl = tabUrl.isEmpty ? nil : tabUrl
            song.notes = notes.isEmpty ? nil : notes
            song.albumCoverUrl = albumCoverUrl
            song.isFavorite = isFavorite
            song.categories = Array(selectedCategories)
            songStore.updateSong(song)
        } else {
            let song = Song(
                title: title,
                artist: artist,
                chords: parsedChords,
                capoPosition: capoPosition,
                dateAdded: dateAdded,
                spotifyUrl: spotifyUrl.isEmpty ? nil : spotifyUrl,
                tabUrl: tabUrl.isEmpty ? nil : tabUrl,
                albumCoverUrl: albumCoverUrl,
                notes: notes.isEmpty ? nil : notes,
                isFavorite: isFavorite,
                categories: Array(selectedCategories)
            )
            songStore.addSong(song)
        }
        
        dismiss()
    }
}

// MARK: - Supporting Views

struct SpotifySearchResultRow: View {
    let track: SpotifyTrack
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: track.smallAlbumCoverUrl ?? "")) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle().fill(Color(.systemGray5))
                }
                .frame(width: 50, height: 50)
                .cornerRadius(6)
                
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
                    .font(.title2)
                    .foregroundColor(.appAccent)
            }
            .padding(12)
            .background(Color(.systemBackground))
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}

struct FormSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            
            content
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct FormTextField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            
            TextField(placeholder, text: $text)
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
    }
}

// MARK: - Spotify Link Sheet for Edit

struct SpotifyLinkSheetForEdit: View {
    @EnvironmentObject var spotifyService: SpotifyService
    @Environment(\.dismiss) var dismiss
    
    let title: String
    let artist: String
    let onSelect: (SpotifyTrack) -> Void
    
    @State private var searchQuery: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Search field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search Spotify...", text: $searchQuery)
                        .textFieldStyle(.plain)
                        .onSubmit {
                            searchSpotify()
                        }
                    
                    if !searchQuery.isEmpty {
                        Button {
                            searchQuery = ""
                            spotifyService.clearResults()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button("Search") {
                        searchSpotify()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.appAccent)
                    .disabled(searchQuery.isEmpty)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Results
                if spotifyService.isSearching {
                    Spacer()
                    ProgressView("Searching...")
                    Spacer()
                } else if spotifyService.searchResults.isEmpty && !searchQuery.isEmpty {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No results found")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else if spotifyService.searchResults.isEmpty {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "music.note")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("Search for a song on Spotify")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(spotifyService.searchResults) { track in
                                Button {
                                    onSelect(track)
                                    spotifyService.clearResults()
                                    dismiss()
                                } label: {
                                    HStack(spacing: 12) {
                                        AsyncImage(url: URL(string: track.smallAlbumCoverUrl ?? "")) { image in
                                            image.resizable().aspectRatio(contentMode: .fill)
                                        } placeholder: {
                                            Rectangle().fill(Color(.systemGray5))
                                        }
                                        .frame(width: 50, height: 50)
                                        .cornerRadius(6)
                                        
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
                                            .font(.title2)
                                            .foregroundColor(.appAccent)
                                    }
                                    .padding(12)
                                    .background(Color(.systemBackground))
                                    .cornerRadius(10)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Link to Spotify")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        spotifyService.clearResults()
                        dismiss()
                    }
                }
            }
            .onAppear {
                // Pre-fill with song info
                if !artist.isEmpty || !title.isEmpty {
                    searchQuery = "\(artist) \(title)".trimmingCharacters(in: .whitespaces)
                    searchSpotify()
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    private func searchSpotify() {
        Task {
            await spotifyService.search(query: searchQuery)
        }
    }
}

#Preview {
    NavigationStack {
        AddSongView()
            .environmentObject(SongStore())
            .environmentObject(SpotifyService())
    }
}
