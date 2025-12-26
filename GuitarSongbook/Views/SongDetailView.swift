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
    @EnvironmentObject var tabURLDetector: TabURLDetector
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var customChordLibrary = CustomChordLibrary.shared

    let song: Song
    @State private var showingEditSheet = false
    @State private var showingCategoryPicker = false
    @State private var showingTabSaveAlert = false
    @State private var showingSpotifyLink = false
    @State private var quickChordInput = ""
    @State private var displayMode: DisplayMode = .chords
    @State private var quickStrumLabel = "Verse"
    @State private var quickStrumPattern = "D-D-D-D"
    @State private var customStrumLabel = ""
    @State private var customStrumPattern = ""
    @State private var tempStrumPatterns: [StrumPattern] = []

    enum DisplayMode {
        case chords, tuning, strumming
    }

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

                        // Chord Diagrams, Tuning & Strum Patterns
                        VStack(spacing: 12) {
                            // Toggle between chords, tuning, and strumming
                            Picker("Display Mode", selection: $displayMode) {
                                Text("Chords").tag(DisplayMode.chords)
                                Text("Tuning").tag(DisplayMode.tuning)
                                Text("Strumming").tag(DisplayMode.strumming)
                            }
                            .pickerStyle(.segmented)

                            if displayMode == .tuning || !liveSong.chords.isEmpty || !liveSong.strumPatterns.isEmpty {
                                chordSection
                            } else {
                                emptyChordSection
                            }
                        }

                        // Divider
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(height: 1)

                        // Notes
                        if let notes = liveSong.notes, !notes.isEmpty {
                            notesSection(notes)
                        }

                        // Properties - Notion style (includes Key & BPM)
                        propertiesSection
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
                        // Spotify play button
                        if let spotifyUrl = liveSong.spotifyUrl, let url = URL(string: spotifyUrl) {
                            Button {
                                UIApplication.shared.open(url)
                            } label: {
                                Image(systemName: "play.circle.fill")
                                    .font(.body.weight(.medium))
                                    .foregroundColor(.green)
                            }
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

                Button {
                    songStore.toggleFavorite(liveSong)
                } label: {
                    Image(systemName: liveSong.isFavorite ? "star.fill" : "star")
                        .font(.title2)
                        .foregroundColor(liveSong.isFavorite ? .appAccent : Color(.tertiaryLabel))
                }
                .buttonStyle(.plain)
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

            // Categories
            PropertyRow(label: "Lists", icon: "folder") {
                HStack(spacing: 6) {
                    if liveSong.isFavorite {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                            Text("Favorites")
                        }
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray5))
                        .cornerRadius(6)
                    }
                    
                    ForEach(liveSong.categories, id: \.self) { category in
                        Text(category)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray5))
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

            // Tabs
            PropertyRow(label: "Tabs", icon: "doc.text") {
                if let tabUrl = liveSong.tabUrl, let url = URL(string: tabUrl) {
                    HStack(spacing: 12) {
                        Link(destination: url) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.up.right")
                                    .font(.caption)
                                    .foregroundColor(.appAccent)
                                Text("Saved")
                                    .foregroundColor(.appAccent)
                            }
                        }
                        .tint(.appAccent)
                        
                        // Remove tab link button
                        Button {
                            var updatedSong = liveSong
                            updatedSong.tabUrl = nil
                            songStore.updateSong(updatedSong)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(Color(.tertiaryLabel))
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    Button {
                        searchUltimateGuitar()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.caption)
                                .foregroundColor(.appAccent)
                            Text("Search & copy URL to save")
                                .foregroundColor(.appAccent)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .onReceive(tabURLDetector.$showingSavePrompt) { showing in
                if showing && tabURLDetector.pendingSongId == song.id {
                    showingTabSaveAlert = true
                }
            }
            .alert("Save Tab URL?", isPresented: $showingTabSaveAlert) {
                Button("Save") {
                    saveDetectedTabURL()
                }
                Button("Cancel", role: .cancel) {
                    tabURLDetector.clearDetection()
                }
            } message: {
                if let siteName = tabURLDetector.detectedSiteName {
                    Text("Found a \(siteName) link in your clipboard. Save it to \"\(liveSong.title)\"?")
                } else {
                    Text("Found a tab URL in your clipboard. Save it to this song?")
                }
            }

            // Key
            if let keyText = liveSong.keyDisplayText {
                PropertyRow(label: "Key", icon: "music.note") {
                    Text(keyText)
                        .foregroundColor(.primary)
                }
            }

            // Tempo
            if let tempoText = liveSong.tempoDisplayText {
                PropertyRow(label: "Tempo", icon: "metronome") {
                    Text(tempoText)
                        .foregroundColor(.primary)
                }
            }
        }
    }

    // MARK: - Chord Section

    private var chordSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: displayMode == .chords ? "hand.raised" : displayMode == .tuning ? "tuningfork" : "waveform")
                    .foregroundColor(.secondary)
                Text(displayMode == .chords ? "Chord Diagrams" : displayMode == .tuning ? "Tuning Info" : "Strumming Patterns")
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            // Content based on display mode
            if displayMode == .chords {
                if !liveSong.chords.isEmpty {
                    ChordDiagramsGrid(chords: liveSong.chords)
                } else {
                    VStack(spacing: 12) {
                        Text("No chords added yet")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        ChordPillInput(chords: $quickChordInput)

                        Button {
                            saveChords()
                        } label: {
                            Text("Save Chords")
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.appAccent)
                        .disabled(quickChordInput.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            } else if displayMode == .tuning {
                // Tuning section
                VStack(alignment: .leading, spacing: 12) {
                    // Capo
                    HStack(alignment: .top, spacing: 12) {
                        Text("Capo")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .frame(width: 100, alignment: .leading)

                        Text(liveSong.capoDisplayText)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Spacer()
                    }
                    .padding(12)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)

                    // Tuning
                    HStack(alignment: .top, spacing: 12) {
                        Text("Tuning")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .frame(width: 100, alignment: .leading)

                        Text(liveSong.tuning)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Spacer()
                    }
                    .padding(12)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                }
            } else {
                if !liveSong.strumPatterns.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(liveSong.strumPatterns) { pattern in
                            HStack(alignment: .top, spacing: 12) {
                                Text(pattern.label)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                    .frame(width: 100, alignment: .leading)

                                Text(pattern.pattern)
                                    .font(.system(.subheadline, design: .monospaced))
                                    .foregroundColor(.secondary)

                                Spacer()
                            }
                            .padding(12)
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                        }
                    }
                } else {
                    VStack(spacing: 12) {
                        if !tempStrumPatterns.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(tempStrumPatterns) { pattern in
                                    HStack(alignment: .top, spacing: 12) {
                                        Text(pattern.label)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                            .frame(width: 100, alignment: .leading)

                                        Text(pattern.pattern)
                                            .font(.system(.subheadline, design: .monospaced))
                                            .foregroundColor(.secondary)

                                        Spacer()

                                        Button {
                                            removeTempPattern(pattern)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .padding(12)
                                    .background(Color(.systemBackground))
                                    .cornerRadius(8)
                                }
                            }
                        }

                        HStack(spacing: 8) {
                            // Label picker
                            Picker("Label", selection: $quickStrumLabel) {
                                ForEach(StrumPattern.commonLabels, id: \.self) { label in
                                    Text(label).tag(label)
                                }
                                Text("Custom...").tag("Custom")
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(Color(.systemBackground))
                            .cornerRadius(6)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .fixedSize(horizontal: false, vertical: true)

                            // Pattern picker
                            Picker("Pattern", selection: $quickStrumPattern) {
                                ForEach(StrumPattern.commonPatterns, id: \.pattern) { preset in
                                    Text(preset.pattern).tag(preset.pattern)
                                }
                                Text("Custom...").tag("Custom")
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(Color(.systemBackground))
                            .cornerRadius(6)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .fixedSize(horizontal: false, vertical: true)
                        }

                        // Custom label field
                        if quickStrumLabel == "Custom" {
                            TextField("Enter custom label", text: $customStrumLabel)
                                .textFieldStyle(.roundedBorder)
                        }

                        // Custom pattern field
                        if quickStrumPattern == "Custom" {
                            TextField("Enter custom pattern (e.g., D-D-U-U-D-U)", text: $customStrumPattern)
                                .textFieldStyle(.roundedBorder)
                                .textInputAutocapitalization(.characters)
                                .autocorrectionDisabled()
                        }

                        Button {
                            addTempPattern()
                        } label: {
                            Text("Add Pattern")
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.appAccent)
                        .disabled(!isValidStrumPattern)

                        if !tempStrumPatterns.isEmpty {
                            Button {
                                saveAllStrumPatterns()
                            } label: {
                                Text("Save All Patterns")
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.appAccent)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(12)
    }

    private var emptyChordSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: displayMode == .chords ? "hand.raised" : "waveform")
                    .foregroundColor(.secondary)
                Text(displayMode == .chords ? "Chord Diagrams" : "Strumming Patterns")
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            // Content based on display mode
            if displayMode == .chords {
                VStack(spacing: 12) {
                    ChordPillInput(chords: $quickChordInput)

                    Button {
                        saveChords()
                    } label: {
                        Text("Save Chords")
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.appAccent)
                    .disabled(quickChordInput.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            } else {
                VStack(spacing: 12) {
                    if !tempStrumPatterns.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(tempStrumPatterns) { pattern in
                                HStack(alignment: .top, spacing: 12) {
                                    Text(pattern.label)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                        .frame(width: 100, alignment: .leading)

                                    Text(pattern.pattern)
                                        .font(.system(.subheadline, design: .monospaced))
                                        .foregroundColor(.secondary)

                                    Spacer()

                                    Button {
                                        removeTempPattern(pattern)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                }
                                .padding(12)
                                .background(Color(.systemBackground))
                                .cornerRadius(8)
                            }
                        }
                    }

                    HStack(spacing: 8) {
                        // Label picker
                        Picker("Label", selection: $quickStrumLabel) {
                            ForEach(StrumPattern.commonLabels, id: \.self) { label in
                                Text(label).tag(label)
                            }
                            Text("Custom...").tag("Custom")
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Color(.systemBackground))
                        .cornerRadius(6)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .fixedSize(horizontal: false, vertical: true)

                        // Pattern picker
                        Picker("Pattern", selection: $quickStrumPattern) {
                            ForEach(StrumPattern.commonPatterns, id: \.pattern) { preset in
                                Text(preset.pattern).tag(preset.pattern)
                            }
                            Text("Custom...").tag("Custom")
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Color(.systemBackground))
                        .cornerRadius(6)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .fixedSize(horizontal: false, vertical: true)
                    }

                    // Custom label field
                    if quickStrumLabel == "Custom" {
                        TextField("Enter custom label", text: $customStrumLabel)
                            .textFieldStyle(.roundedBorder)
                    }

                    // Custom pattern field
                    if quickStrumPattern == "Custom" {
                        TextField("Enter custom pattern (e.g., D-D-U-U-D-U)", text: $customStrumPattern)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                    }

                    Button {
                        addTempPattern()
                    } label: {
                        Text("Add Pattern")
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.appAccent)
                    .disabled(!isValidStrumPattern)

                    if !tempStrumPatterns.isEmpty {
                        Button {
                            saveAllStrumPatterns()
                        } label: {
                            Text("Save All Patterns")
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.appAccent)
                    }
                }
            }
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
                .foregroundColor(.primary)
                .lineSpacing(6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(12)
    }
    
    
    private func searchUltimateGuitar() {
        // Start watching for tab URLs when user returns
        tabURLDetector.startWatchingForSong(song.id)
        
        let query = "\(liveSong.artist) \(liveSong.title)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://www.ultimate-guitar.com/search.php?search_type=title&value=\(query)"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func saveDetectedTabURL() {
        guard let url = tabURLDetector.detectedURL else { return }

        var updatedSong = liveSong
        updatedSong.tabUrl = url
        songStore.updateSong(updatedSong)

        tabURLDetector.clearDetection()
    }

    private func saveChords() {
        let input = quickChordInput.trimmingCharacters(in: .whitespaces)
        guard !input.isEmpty else { return }

        // ChordPillInput formats chords as comma-separated, so parse them
        let newChords = input
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        guard !newChords.isEmpty else { return }

        // Update song with new chords
        var updatedSong = liveSong
        updatedSong.chords = newChords
        songStore.updateSong(updatedSong)

        // Clear input
        quickChordInput = ""
    }

    private var isValidStrumPattern: Bool {
        let label = quickStrumLabel == "Custom" ? customStrumLabel : quickStrumLabel
        let pattern = quickStrumPattern == "Custom" ? customStrumPattern : quickStrumPattern

        return !label.trimmingCharacters(in: .whitespaces).isEmpty &&
               !pattern.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func addTempPattern() {
        let label = quickStrumLabel == "Custom" ? customStrumLabel : quickStrumLabel
        let pattern = quickStrumPattern == "Custom" ? customStrumPattern.uppercased() : quickStrumPattern

        guard !label.trimmingCharacters(in: .whitespaces).isEmpty,
              !pattern.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        // Create new strum pattern and add to temp list
        let newPattern = StrumPattern(label: label, pattern: pattern)
        tempStrumPatterns.append(newPattern)

        // Reset to defaults for next pattern
        quickStrumLabel = "Verse"
        quickStrumPattern = "D-D-D-D"
        customStrumLabel = ""
        customStrumPattern = ""
    }

    private func removeTempPattern(_ pattern: StrumPattern) {
        tempStrumPatterns.removeAll { $0.id == pattern.id }
    }

    private func saveAllStrumPatterns() {
        guard !tempStrumPatterns.isEmpty else { return }

        // Update song with all temp patterns
        var updatedSong = liveSong
        updatedSong.strumPatterns = tempStrumPatterns
        songStore.updateSong(updatedSong)

        // Clear temp patterns
        tempStrumPatterns = []
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
                                .foregroundColor(.appAccent)
                            
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
                                    .foregroundColor(.secondary)
                                
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
                    Text("Lists")
                }
            }
            .navigationTitle("Add to List")
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

// MARK: - Spotify Link Sheet

struct SpotifyLinkSheet: View {
    @EnvironmentObject var songStore: SongStore
    @EnvironmentObject var spotifyService: SpotifyService
    @Environment(\.dismiss) var dismiss
    
    let song: Song
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
                        Text("Search for \"\(song.title)\" on Spotify")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(spotifyService.searchResults) { track in
                                Button {
                                    linkTrack(track)
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
                searchQuery = "\(song.artist) \(song.title)"
                searchSpotify()
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func searchSpotify() {
        Task {
            await spotifyService.search(query: searchQuery)
        }
    }
    
    private func linkTrack(_ track: SpotifyTrack) {
        var updatedSong = song
        updatedSong.spotifyUrl = track.externalUrls.spotify
        updatedSong.albumCoverUrl = track.albumCoverUrl
        songStore.updateSong(updatedSong)
        
        spotifyService.clearResults()
        dismiss()
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
    .environmentObject(TabURLDetector())
}
