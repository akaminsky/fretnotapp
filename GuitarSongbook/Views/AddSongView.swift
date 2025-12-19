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
    @State private var tuning = "EADGBE"
    @State private var selectedTuningOption = "Standard"
    @State private var customTuning = ""
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
    @State private var showingBulkImport = false
    @State private var isSaving = false

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
                        if track.id == "manual" {
                            manualEntryHeader
                        } else {
                            selectedTrackHeader(track)
                        }
                    } else if isEditing {
                        editingHeaderWithSpotify
                    }
                    
                    // Main form fields
                    formFields
                }
            }
            .padding()
        }
        .scrollDismissesKeyboard(.interactively)
        .onTapGesture {
            hideKeyboard()
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
                if isSaving {
                    ProgressView()
                } else {
                    Button(isEditing ? "Save" : "Add Song") {
                        saveSong()
                    }
                    .fontWeight(.semibold)
                    .disabled(title.isEmpty)
                }
            }
        }
        .onAppear {
            setupInitialValues()
        }
        .sheet(isPresented: $showingBulkImport) {
            BulkImportView()
                .environmentObject(songStore)
                .environmentObject(spotifyService)
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
                
                VStack(spacing: 12) {
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
                    
                    Button {
                        showingBulkImport = true
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("Import Spotify Playlist")
                        }
                        .font(.subheadline)
                        .foregroundColor(.appAccentText)
                    }
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
    
    // MARK: - Manual Entry Header with Spotify Options
    
    private var manualEntryHeader: some View {
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
                    Text("Adding manually")
                        .font(.headline)
                    Text("Fill in the details below")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
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
            // Guitar Info
            FormSection(title: "Guitar Info") {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Chords")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)

                    ChordPillInput(chords: $chords)
                }

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

                VStack(alignment: .leading, spacing: 6) {
                    Text("Tuning")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)

                    Picker("Tuning", selection: $selectedTuningOption) {
                        Text("Standard (EADGBE)").tag("Standard")
                        Text("Drop D (DADGBE)").tag("Drop D")
                        Text("Drop C (CGCFAD)").tag("Drop C")
                        Text("Half Step Down (D#G#C#F#A#D#)").tag("Half Step Down")
                        Text("Open D (DADF#AD)").tag("Open D")
                        Text("Open G (DGDGBD)").tag("Open G")
                        Text("Other...").tag("Other")
                    }
                    .pickerStyle(.menu)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)

                    if selectedTuningOption == "Other" {
                        TextField("Enter custom tuning", text: $customTuning)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                }
            }

            // Song Details
            FormSection(title: "Song Details") {
                VStack(spacing: 12) {
                    FormTextField(label: "Song Title *", text: $title, placeholder: "Enter song title")
                    FormTextField(label: "Artist *", text: $artist, placeholder: "Enter artist name")

                    if selectedTrack != nil && selectedTrack?.id != "manual" {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.caption2)
                            Text("Auto-filled from Spotify • Edit if needed")
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                }
            }
            
            // Categories
            FormSection(title: "Lists") {
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
                    
                    // Add new list inline
                    HStack {
                        Image(systemName: "plus.circle")
                            .foregroundColor(.secondary)
                        TextField("Create new list...", text: $newCategoryName)
                        
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
            
            // Tab URL (optional)
            FormSection(title: "Tab Link (Optional)") {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Tab URL")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    HStack {
                        TextField("https://ultimate-guitar.com/...", text: $tabUrl)
                        
                        if !tabUrl.isEmpty {
                            Button {
                                tabUrl = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Color(.tertiaryLabel))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
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
                            .foregroundColor(.red)
                        Text("Delete Song")
                            .foregroundColor(.red)
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
            tuning = song.tuning
            selectedTuningOption = tuningOption(for: song.tuning)
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

    private func tuningValue(for option: String) -> String {
        switch option {
        case "Standard": return "EADGBE"
        case "Drop D": return "DADGBE"
        case "Drop C": return "CGCFAD"
        case "Half Step Down": return "D#G#C#F#A#D#"
        case "Open D": return "DADF#AD"
        case "Open G": return "DGDGBD"
        case "Other": return customTuning.isEmpty ? "EADGBE" : customTuning.uppercased()
        default: return "EADGBE"
        }
    }

    private func tuningOption(for value: String) -> String {
        let normalized = value.uppercased()
        switch normalized {
        case "EADGBE": return "Standard"
        case "DADGBE": return "Drop D"
        case "CGCFAD": return "Drop C"
        case "D#G#C#F#A#D#": return "Half Step Down"
        case "DADF#AD": return "Open D"
        case "DGDGBD": return "Open G"
        default:
            customTuning = value
            return "Other"
        }
    }

    private func saveSong() {
        isSaving = true

        let parsedChords = chords
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        if var song = editingSong {
            song.title = title
            song.artist = artist
            song.chords = parsedChords
            song.capoPosition = capoPosition
            song.tuning = tuningValue(for: selectedTuningOption)
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
                tuning: tuningValue(for: selectedTuningOption),
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

        // Small delay to show feedback, then dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isSaving = false
            dismiss()
        }
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
            .onTapGesture {
                hideKeyboard()
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

// MARK: - Keyboard Dismissal

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Chord Pill Input

struct ChordPillInput: View {
    @Binding var chords: String
    var allowReordering: Bool = true
    @State private var inputText: String = ""
    @State private var validatedChords: [ValidatedChord] = []
    @FocusState private var isInputFocused: Bool
    @State private var draggingChord: ValidatedChord?

    private let chordLibrary = ChordLibrary.shared
    private let haptics = HapticManager.shared

    struct ValidatedChord: Identifiable, Equatable {
        let id = UUID()
        let name: String
        let isValid: Bool

        static func == (lhs: ValidatedChord, rhs: ValidatedChord) -> Bool {
            lhs.id == rhs.id
        }
    }

    private var chordSuggestions: [String] {
        guard !inputText.isEmpty else { return [] }

        let allChordNames = chordLibrary.allChordNames
        let searchText = inputText.lowercased()

        return allChordNames
            .filter { $0.lowercased().starts(with: searchText) }
            .filter { chordName in !validatedChords.contains(where: { $0.name.lowercased() == chordName.lowercased() }) }
            .prefix(5)
            .map { $0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Input field
            HStack {
                TextField("Type a chord (e.g. C or Am)", text: $inputText)
                    .textFieldStyle(.plain)
                    .focused($isInputFocused)
                    .disableAutocorrection(true)
                    .onSubmit {
                        addChord()
                    }

                if !inputText.isEmpty {
                    Button {
                        addChord()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.appAccent)
                    }
                }
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(8)

            // Autocomplete suggestions
            if !chordSuggestions.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(chordSuggestions, id: \.self) { suggestion in
                        Button {
                            inputText = suggestion
                            addChord()
                        } label: {
                            HStack {
                                Text(suggestion)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "arrow.turn.down.left")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color(.systemBackground))
                        }
                        .buttonStyle(.plain)

                        if suggestion != chordSuggestions.last {
                            Divider()
                                .padding(.leading, 12)
                        }
                    }
                }
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color(.systemGray4), lineWidth: 1)
                )
            }

            // Pills display
            if !validatedChords.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(validatedChords) { chord in
                        ChordPill(
                            name: chord.name,
                            isValid: chord.isValid,
                            showDragHandle: allowReordering,
                            onRemove: {
                                removeChord(chord)
                            }
                        )
                        .if(allowReordering) { view in
                            view
                                .onDrag {
                                    self.draggingChord = chord
                                    return NSItemProvider(object: chord.id.uuidString as NSString)
                                }
                                .onDrop(of: [.text], delegate: ChordDropDelegate(
                                    chord: chord,
                                    chords: $validatedChords,
                                    draggingChord: $draggingChord,
                                    onDrop: {
                                        haptics.light()
                                        updateBinding()
                                    }
                                ))
                                .opacity(draggingChord == chord ? 0.5 : 1.0)
                                .zIndex(draggingChord == chord ? 1 : 0)
                        }
                    }
                }
            }

            // Validation message
            if let invalidChord = validatedChords.first(where: { !$0.isValid }) {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption)
                    Text("\"\(invalidChord.name)\" is not in the chord library")
                        .font(.caption)
                }
                .foregroundColor(.red)
            }

            // Helper text
            if validatedChords.isEmpty {
                Text("Press the add button or hit return to add")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            loadExistingChords()
            // Auto-focus the input field
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isInputFocused = true
            }
        }
    }

    private func loadExistingChords() {
        guard validatedChords.isEmpty else { return }

        let existingChords = chords
            .split(whereSeparator: { $0 == "," || $0.isWhitespace })
            .map { String($0).trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        validatedChords = existingChords.map { chordName in
            ValidatedChord(
                name: chordName,
                isValid: chordLibrary.findChord(chordName) != nil
            )
        }

        updateBinding()
    }

    private func addChord() {
        let newChords = inputText
            .split(whereSeparator: { $0 == "," || $0.isWhitespace })
            .map { String($0).trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        var addedAny = false
        for chordName in newChords {
            // Check if not already added
            if !validatedChords.contains(where: { $0.name.lowercased() == chordName.lowercased() }) {
                let isValid = chordLibrary.findChord(chordName) != nil
                validatedChords.append(ValidatedChord(name: chordName, isValid: isValid))
                addedAny = true
            }
        }

        if addedAny {
            haptics.light()
        }

        inputText = ""
        updateBinding()

        // Keep focus in the input field
        isInputFocused = true
    }

    private func removeChord(_ chord: ValidatedChord) {
        validatedChords.removeAll { $0.id == chord.id }
        haptics.light()
        updateBinding()
    }

    private func updateBinding() {
        chords = validatedChords.map { $0.name }.joined(separator: ", ")
    }
}

// MARK: - Chord Pill

struct ChordPill: View {
    let name: String
    let isValid: Bool
    var showDragHandle: Bool = false
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            if showDragHandle {
                Image(systemName: "line.3.horizontal")
                    .font(.caption2)
                    .foregroundColor(.secondary.opacity(0.5))
            }

            if !isValid {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.caption2)
                    .foregroundColor(.red)
            }

            Text(name)
                .font(.subheadline)
                .fontWeight(.medium)

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(isValid ? .secondary : .red)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isValid ? Color.appAccent.opacity(0.15) : Color.red.opacity(0.15))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(isValid ? Color.appAccent.opacity(0.3) : Color.red.opacity(0.5), lineWidth: 1)
        )
    }
}

// MARK: - Chord Drop Delegate

struct ChordDropDelegate: DropDelegate {
    let chord: ChordPillInput.ValidatedChord
    @Binding var chords: [ChordPillInput.ValidatedChord]
    @Binding var draggingChord: ChordPillInput.ValidatedChord?
    let onDrop: () -> Void

    func performDrop(info: DropInfo) -> Bool {
        draggingChord = nil
        return true
    }

    func dropEntered(info: DropInfo) {
        guard let draggingChord = draggingChord,
              draggingChord != chord,
              let fromIndex = chords.firstIndex(of: draggingChord),
              let toIndex = chords.firstIndex(of: chord) else {
            return
        }

        withAnimation(.default) {
            chords.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
        }
        onDrop()
    }
}

// MARK: - View Extension for Conditional Modifiers

extension View {
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
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
