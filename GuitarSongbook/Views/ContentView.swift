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
    
    @State private var showingAddSong = false
    @State private var selectedSong: Song?
    @State private var songToEdit: Song?
    @State private var showingCategoryManager = false
    @State private var showingTuner = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Category Pills
                    categoryPills
                    
                    // Filter Controls
                    FilterControlsView()
                        .padding(.horizontal)
                        .padding(.top, 4)
                    
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
            .navigationTitle("Never Fret")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingTuner = true
                    } label: {
                        Image(systemName: "tuningfork")
                            .foregroundColor(.appAccent)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingCategoryManager = true
                    } label: {
                        Image(systemName: "folder.badge.gearshape")
                            .foregroundColor(.secondary)
                    }
                }
            }
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
        .sheet(isPresented: $showingCategoryManager) {
            CategoryManagerView()
                .environmentObject(songStore)
        }
        .sheet(isPresented: $showingTuner) {
            TunerView()
        }
        .tint(.appAccent)
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
                    color: .appGold,
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
                        color: .blue
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
                } else {
                    Text("Never Fret")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("The songs you'll never forget.\nStart building your collection.")
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
                        onToggleFavorite: { songStore.toggleFavorite(song) }
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
                        
                        Button {
                            songToEdit = song
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.orange)
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            songStore.toggleFavorite(song)
                        } label: {
                            Label(song.isFavorite ? "Unfavorite" : "Favorite", systemImage: song.isFavorite ? "star.slash" : "star.fill")
                        }
                        .tint(.appGold)
                        
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
    
    @State private var showChords = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main Card Content
            mainCardContent
            
            // Expanded Chords Section
            if !song.chords.isEmpty {
                expandedChordsSection
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 8, y: 2)
    }
    
    // MARK: - Main Card Content
    
    private var mainCardContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with album art and info
            HStack(alignment: .top, spacing: 14) {
                // Album Cover
                AsyncImage(url: URL(string: song.albumCoverUrl ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    LinearGradient(
                        colors: [Color.appAccent.opacity(0.3), Color.appAccent.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .overlay {
                        Image(systemName: "music.note")
                            .font(.title2)
                            .foregroundColor(.appAccent.opacity(0.5))
                    }
                }
                .frame(width: 64, height: 64)
                .cornerRadius(8)
                
                // Song Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(song.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(song.artist)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    // Date
                    Text(song.formattedDate)
                        .font(.caption)
                        .foregroundColor(Color(.tertiaryLabel))
                }
                
                Spacer()
                
                // Favorite Button
                Button(action: onToggleFavorite) {
                    Image(systemName: song.isFavorite ? "star.fill" : "star")
                        .font(.title3)
                        .foregroundColor(song.isFavorite ? .appGold : Color(.tertiaryLabel))
                }
                .buttonStyle(.plain)
                
                // Context Menu
                Menu {
                    Button {
                        onTap()
                    } label: {
                        Label("View Details", systemImage: "eye")
                    }
                    
                    Button {
                        onEdit()
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button {
                        onToggleFavorite()
                    } label: {
                        Label(song.isFavorite ? "Remove from Favorites" : "Add to Favorites", systemImage: song.isFavorite ? "star.slash" : "star.fill")
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
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
            }
            
            // Properties Row
            HStack(spacing: 8) {
                // Chords - show actual chords
                if !song.chords.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: showChords ? "chevron.up" : "chevron.down")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text(song.chords.joined(separator: " · "))
                            .font(.caption)
                            .foregroundColor(.appAccentText)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.appAccent.opacity(0.1))
                    .cornerRadius(6)
                }
                
                // Capo
                if song.capoPosition > 0 {
                    PropertyBadge(
                        icon: "guitars",
                        text: "Capo \(song.capoPosition)",
                        color: .orange
                    )
                }
                
                // Spotify play button
                if let spotifyUrl = song.spotifyUrl,
                   let url = URL(string: spotifyUrl) {
                    Button {
                        UIApplication.shared.open(url)
                    } label: {
                        Image(systemName: "play.circle.fill")
                            .font(.body)
                            .foregroundColor(.green)
                            .padding(6)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(6)
                    }
                }
                
                // Notes indicator
                if song.notes != nil && !song.notes!.isEmpty {
                    PropertyBadge(
                        icon: "note.text",
                        text: nil,
                        color: .secondary
                    )
                }
                
                // Category indicators
                if !song.categories.isEmpty {
                    PropertyBadge(
                        icon: "folder",
                        text: "\(song.categories.count)",
                        color: .blue
                    )
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .contentShape(Rectangle())
        .onTapGesture {
            if !song.chords.isEmpty {
                // Use transaction to disable List's row animation
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    showChords.toggle()
                }
            }
        }
    }
    
    // MARK: - Expanded Chords Section
    
    private var expandedChordsSection: some View {
        VStack(spacing: 0) {
            if showChords {
                Divider()
                    .padding(.horizontal, 16)
                
                chordContent
                    .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showChords)
    }
    
    private var chordContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            FlowLayout(spacing: 8) {
                ForEach(song.chords, id: \.self) { chord in
                            Text(chord)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.appAccentText)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.appAccent.opacity(0.12))
                                .cornerRadius(6)
                }
            }
            
            ChordDiagramsGrid(chords: song.chords)
        }
        .padding(16)
        .background(Color(.systemGray6).opacity(0.5))
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
