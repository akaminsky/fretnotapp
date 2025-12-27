//
//  ContentView.swift
//  GuitarSongbook
//
//  Main content view - Day One / Notion inspired design
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var songStore: SongStore
    @EnvironmentObject var spotifyService: SpotifyService
    @ObservedObject private var customChordLibrary = CustomChordLibrary.shared

    @State private var showingAddSong = false
    @State private var selectedSong: Song?
    @State private var songToEdit: Song?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // Dismiss keyboard when tapping navigation area
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }

                VStack(spacing: 0) {
                    // Category Pills
                    categoryPills
                    
                    // Filter Controls
                    FilterControlsView()
                        .padding(.horizontal)
                        .padding(.top, 4)
                        .animation(nil, value: songStore.filterChord)
                        .animation(nil, value: songStore.filterCapo)
                    
                    // Song List or Empty State
                    if songStore.filteredAndSortedSongs.isEmpty {
                        emptyState
                    } else {
                        songList
                    }
                }
                
                // Floating Add Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        addButton
                    }
                }
            }
            .navigationTitle("Songs")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingAddSong) {
            NavigationStack {
                AddSongView()
                    .environmentObject(songStore)
                    .environmentObject(spotifyService)
            }
        }
        .sheet(item: $songToEdit) { song in
            NavigationStack {
                AddSongView(editingSong: song)
                    .environmentObject(songStore)
                    .environmentObject(spotifyService)
            }
        }
        .sheet(item: $selectedSong) { song in
            SongDetailView(song: song)
                .environmentObject(songStore)
                .environmentObject(spotifyService)
        }
    }
    
    // MARK: - Category Pills
    
    private var categoryPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // All songs
                CategoryPill(
                    title: "All",
                    count: songStore.songs.count,
                    isSelected: songStore.filterCategory.isEmpty,
                    color: .appAccent
                ) {
                    songStore.filterCategory = ""
                }
                
                // Favorites
                CategoryPill(
                    title: "Favorites",
                    count: songStore.favoritesCount,
                    isSelected: songStore.filterCategory == "favorites",
                    color: .appAccent,
                    icon: "star.fill"
                ) {
                    songStore.filterCategory = songStore.filterCategory == "favorites" ? "" : "favorites"
                }
                
                // Custom categories
                ForEach(songStore.categories, id: \.self) { category in
                    CategoryPill(
                        title: category,
                        count: songStore.songsInCategory(category),
                        isSelected: songStore.filterCategory == category,
                        color: .appAccent
                    ) {
                        songStore.filterCategory = songStore.filterCategory == category ? "" : category
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.appAccent.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: songStore.filterCategory == "favorites" ? "star" : "guitars")
                    .font(.system(size: 40))
                    .foregroundColor(.appAccent)
            }
            
            VStack(spacing: 8) {
                if songStore.filterCategory == "favorites" {
                    Text("No Favorites Yet")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Tap the star on any song to add it\nto your favorites.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                } else if !songStore.filterCategory.isEmpty {
                    Text("No Songs in \(songStore.filterCategory)")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Add songs to this category from\nthe song details.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                } else if !songStore.searchText.isEmpty {
                    Text("No songs match \"\(songStore.searchText)\"")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)

                    Text("Try a different search term")
                        .font(.body)
                        .foregroundColor(.secondary)
                } else {
                    Text("Fret Not")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Never forget a song again.\nStart building your collection.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                    
                    Button {
                        showingAddSong = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                                .fontWeight(.semibold)
                            Text("Add Your First Song")
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(Color.appAccent)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.top, 8)
                }
            }
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 40)
    }
    
    // MARK: - Song List
    
    private var songList: some View {
        VStack(spacing: 0) {
            // Song count header
            HStack {
                Text(songStore.songCountText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            // Songs list
            List {
                ForEach(songStore.filteredAndSortedSongs) { song in
                    SongCard(
                        song: song,
                        onTap: { selectedSong = song },
                        onEdit: { songToEdit = song },
                        onDelete: { songStore.deleteSong(song) },
                        onToggleFavorite: { songStore.toggleFavorite(song) },
                        onUpdateChords: { newChords in
                            var updatedSong = song
                            updatedSong.chords = newChords
                            songStore.updateSong(updatedSong)
                        }
                    )
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            songStore.deleteSong(song)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.red)
                        
                        Button {
                            songToEdit = song
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.appAccent)
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        if let spotifyUrl = song.spotifyUrl,
                           let url = URL(string: spotifyUrl) {
                            Button {
                                UIApplication.shared.open(url)
                            } label: {
                                Label("Play", systemImage: "play.fill")
                            }
                            .tint(.green)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .simultaneousGesture(
                TapGesture()
                    .onEnded { _ in
                        // Dismiss keyboard when tapping on list
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
            )
            .animation(nil, value: songStore.filterChord)
            .animation(nil, value: songStore.filterCapo)
            .animation(nil, value: songStore.filterCategory)
            .animation(nil, value: songStore.searchText)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Add Button
    
    private var addButton: some View {
        Button {
            showingAddSong = true
        } label: {
            Image(systemName: "plus")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(Color.appAccent)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.2), radius: 8, y: 4)
        }
        .padding(.trailing, 16)
        .padding(.bottom, 16)
    }
}

// MARK: - Category Pill

struct CategoryPill: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let color: Color
    var icon: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                        .foregroundColor(isSelected ? .white : color)
                }
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(count)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? color : Color(.systemBackground))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.clear : Color(.systemGray4), lineWidth: 1)
            )
        }
    }
}

// MARK: - Song Card

struct SongCard: View {
    let song: Song
    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onToggleFavorite: () -> Void
    let onUpdateChords: ([String]) -> Void

    @State private var showChords = false
    @State private var showQuickAddChords = false
    @State private var quickChordInput = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main Card Content
            mainCardContent
            
            // Chords Section or Add Chords Button
            if !song.chords.isEmpty && showChords {
                VStack(spacing: 0) {
                    Divider()
                        .padding(.horizontal, 14)

                    chordContent
                }
            } else if song.chords.isEmpty {
                VStack(spacing: 0) {
                    Divider()
                        .padding(.horizontal, 14)

                    if showQuickAddChords {
                        quickAddChordsSection
                    } else {
                        Button {
                            showQuickAddChords = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.appAccent)
                                Text("Add Chords")
                                    .foregroundColor(.appAccent)
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
    }
    
    // MARK: - Main Card Content
    
    private var mainCardContent: some View {
        HStack(alignment: .center, spacing: 14) {
            // Album Cover
            AsyncImage(url: URL(string: song.albumCoverUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .overlay {
                        Image(systemName: "music.note")
                            .font(.title3)
                            .foregroundColor(Color(.systemGray3))
                    }
            }
            .frame(width: 56, height: 56)
            .cornerRadius(8)
            
            // Song Info
            VStack(alignment: .leading, spacing: 3) {
                Text(song.title)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(song.artist)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                // Chords and Capo as simple text
                if !song.chords.isEmpty || song.capoPosition > 0 {
                    HStack(spacing: 4) {
                        if !song.chords.isEmpty {
                            Text(song.chords.joined(separator: " · "))
                                .font(.caption)
                                .foregroundColor(Color(.tertiaryLabel))
                                .lineLimit(1)
                        }
                        
                        if song.capoPosition > 0 {
                            if !song.chords.isEmpty {
                                Text("•")
                                    .font(.caption)
                                    .foregroundColor(Color(.tertiaryLabel))
                            }
                            Text("Capo \(song.capoPosition)")
                                .font(.caption)
                                .foregroundColor(Color(.tertiaryLabel))
                        }
                    }
                }
            }
            
            Spacer()
            
            // Favorite Button
            Button(action: onToggleFavorite) {
                Image(systemName: song.isFavorite ? "star.fill" : "star")
                    .font(.body)
                    .foregroundColor(song.isFavorite ? .appAccent : Color(.quaternaryLabel))
            }
            .buttonStyle(.plain)
            
            // View Details Button
            Button(action: onTap) {
                HStack(spacing: 4) {
                    Text("View")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                }
                .foregroundColor(.appAccent)
            }
            .buttonStyle(.plain)

            // Context Menu (accessible via long-press on card)
            .contextMenu {
                Button {
                    onEdit()
                } label: {
                    Label("Edit", systemImage: "pencil")
                }

                if let spotifyUrl = song.spotifyUrl,
                   let url = URL(string: spotifyUrl) {
                    Button {
                        UIApplication.shared.open(url)
                    } label: {
                        Label("Play on Spotify", systemImage: "play.fill")
                    }
                }

                Divider()

                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .padding(14)
        .frame(minHeight: 84)
        .contentShape(Rectangle())
        .onTapGesture {
            if !song.chords.isEmpty {
                showChords.toggle()
            }
        }
    }
    
    // MARK: - Chord Content

    private var chordContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            FlowLayout(spacing: 8) {
                ForEach(song.chords, id: \.self) { chord in
                    Text(chord)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray5))
                        .cornerRadius(6)
                }
            }

            ChordDiagramsGrid(chords: song.chords)
        }
        .padding(14)
        .background(Color(.systemGray6).opacity(0.5))
    }

    // MARK: - Quick Add Chords Section

    private var quickAddChordsSection: some View {
        VStack(spacing: 12) {
            ChordPillInput(chords: $quickChordInput, allowReordering: false)

            HStack(spacing: 8) {
                Button {
                    showQuickAddChords = false
                    quickChordInput = ""
                } label: {
                    Text("Cancel")
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.secondary)

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
        .padding(14)
        .background(Color(.systemGray6).opacity(0.5))
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

        // Update song with new chords via callback
        onUpdateChords(newChords)

        // Reset state
        quickChordInput = ""
        showQuickAddChords = false
    }
}

// MARK: - Property Badge

struct PropertyBadge: View {
    let icon: String
    let text: String?
    let color: Color
    var showChevron: Bool = false
    var isExpanded: Bool = false
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            
            if let text = text {
                Text(text)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if showChevron {
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .cornerRadius(6)
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return CGSize(width: proposal.width ?? 0, height: result.height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                       y: bounds.minY + result.positions[index].y),
                          proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var positions: [CGPoint] = []
        var height: CGFloat = 0
        
        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > width && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }
            
            height = y + rowHeight
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SongStore())
        .environmentObject(SpotifyService())
}
