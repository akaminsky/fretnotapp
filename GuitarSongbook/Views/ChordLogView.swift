//
//  ChordLogView.swift
//  GuitarSongbook
//
//  Shows all chords learned across songs
//

import SwiftUI

struct ChordLogView: View {
    @EnvironmentObject var songStore: SongStore
    @ObservedObject private var customChordLibrary = CustomChordLibrary.shared
    @State private var searchText = ""
    @State private var showingIdentifier = false
    @FocusState private var searchFieldFocused: Bool

    private struct ChordItem: Identifiable {
        let id = UUID()
        let name: String
        let songCount: Int
        let isInUserSongs: Bool
    }

    private var displayedChords: [ChordItem] {
        if searchText.isEmpty {
            // Default: Only show user's chords (no change from current)
            return songStore.allUniqueChords.map { chord in
                ChordItem(
                    name: chord,
                    songCount: songsWithChord(chord),
                    isInUserSongs: true
                )
            }
        } else {
            // Searching: Show user chords + library chords
            let userChords = Set(songStore.allUniqueChords)
            let libraryChords = ChordLibrary.shared.allChordNamesIncludingCustom

            // Combine and filter by search
            let allChords = Set(userChords + libraryChords)
            let filtered = allChords.filter {
                $0.lowercased().contains(searchText.lowercased())
            }

            // Map to ChordItem with metadata
            let items = filtered.map { chord in
                ChordItem(
                    name: chord,
                    songCount: songsWithChord(chord),
                    isInUserSongs: userChords.contains(chord)
                )
            }

            // Sort: user's chords first, then library chords, alphabetically within each group
            return items.sorted { a, b in
                if a.isInUserSongs != b.isInUserSongs {
                    return a.isInUserSongs // true (user's chords) comes before false
                }
                return a.name < b.name // alphabetical within each group
            }
        }
    }

    private var userChordsInSearch: [ChordItem] {
        displayedChords.filter { $0.isInUserSongs }
    }

    private var libraryChordsInSearch: [ChordItem] {
        displayedChords.filter { !$0.isInUserSongs }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // Dismiss keyboard when tapping navigation area
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }

                VStack(spacing: 0) {
                    // Custom search bar
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        TextField("Search your chords and library", text: $searchText)
                            .font(.subheadline)
                            .focused($searchFieldFocused)

                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.subheadline)
                                    .foregroundColor(Color(.tertiaryLabel))
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                    .padding()

                    // Content
                    if songStore.allUniqueChords.isEmpty {
                        emptyState
                    } else {
                        chordGrid
                    }
                }

                // Floating Identify Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        identifyButton
                    }
                }
            }
            .navigationTitle("Chords")
            .sheet(isPresented: $showingIdentifier) {
                NavigationStack {
                    ChordIdentifierView()
                        .navigationTitle("Identify and add a chord")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("Done") {
                                    showingIdentifier = false
                                }
                            }
                        }
                        .environmentObject(songStore)
                }
            }
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

                Image(systemName: "hand.raised.fingers.spread")
                    .font(.system(size: 40))
                    .foregroundColor(.appAccent)
            }

            VStack(spacing: 8) {
                Text("No Chords Yet")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Add songs with chords to build\nyour chord library")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                showingIdentifier = true
            } label: {
                Text("Identify a Chord")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.appAccent)
                    .cornerRadius(10)
            }

            Spacer()
        }
        .padding()
    }
    
    // MARK: - Chord Grid
    
    private var chordGrid: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Simple chord count header (matching songs page style)
                HStack {
                    Text(chordCountText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 4)

                // Chord cards
                if displayedChords.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.title)
                            .foregroundColor(.secondary)
                        Text("No chords match \"\(searchText)\"")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else if searchText.isEmpty {
                    // Default view: single grid of user's chords
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 28),
                        GridItem(.flexible(), spacing: 28),
                        GridItem(.flexible(), spacing: 28)
                    ], spacing: 28) {
                        ForEach(displayedChords) { item in
                            NavigationLink(destination: ChordDetailPageView(chordName: item.name).environmentObject(songStore)) {
                                ChordCard(
                                    chord: item.name,
                                    songCount: item.songCount,
                                    isInUserSongs: item.isInUserSongs
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                } else {
                    // Search view: separate grids with divider
                    VStack(spacing: 20) {
                        // User's chords section
                        if !userChordsInSearch.isEmpty {
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 28),
                                GridItem(.flexible(), spacing: 28),
                                GridItem(.flexible(), spacing: 28)
                            ], spacing: 28) {
                                ForEach(userChordsInSearch) { item in
                                    NavigationLink(destination: ChordDetailPageView(chordName: item.name).environmentObject(songStore)) {
                                        ChordCard(
                                            chord: item.name,
                                            songCount: item.songCount,
                                            isInUserSongs: item.isInUserSongs
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        // Divider between sections (only if both sections exist)
                        if !userChordsInSearch.isEmpty && !libraryChordsInSearch.isEmpty {
                            Divider()
                                .padding(.vertical, 8)
                        }

                        // Library chords section
                        if !libraryChordsInSearch.isEmpty {
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 28),
                                GridItem(.flexible(), spacing: 28),
                                GridItem(.flexible(), spacing: 28)
                            ], spacing: 28) {
                                ForEach(libraryChordsInSearch) { item in
                                    NavigationLink(destination: ChordDetailPageView(chordName: item.name).environmentObject(songStore)) {
                                        ChordCard(
                                            chord: item.name,
                                            songCount: item.songCount,
                                            isInUserSongs: item.isInUserSongs
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .scrollDismissesKeyboard(.interactively)
        .simultaneousGesture(
            TapGesture()
                .onEnded { _ in
                    // Dismiss keyboard when tapping on scroll view
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
        )
    }

    private var chordCountText: String {
        let count = displayedChords.count
        if searchText.isEmpty {
            // Default view: make it clear these are user's chords
            return count == 1 ? "1 chord in your songs" : "\(count) chords in your songs"
        } else {
            // Search view: show how many are used
            let userCount = displayedChords.filter { $0.isInUserSongs }.count
            return "\(count) chord\(count == 1 ? "" : "s") (\(userCount) used in your songs)"
        }
    }

    private var identifyButton: some View {
        Button {
            showingIdentifier = true
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

    private func songsWithChord(_ chord: String) -> Int {
        songStore.songs.filter { $0.chords.contains(chord) }.count
    }
}

// MARK: - Chord Card

struct ChordCard: View {
    let chord: String
    let songCount: Int
    let isInUserSongs: Bool

    private var displayInfo: (name: String, hasVoicing: Bool) {
        let (baseName, fingerprint) = ChordLibrary.shared.parseVoicingNotation(chord)
        return (baseName, fingerprint != nil)
    }

    var body: some View {
        VStack(spacing: 4) {
            ChordDiagramView(chordName: chord)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color(.systemGray5), lineWidth: 0.5)
        )
    }
}

#Preview {
    ChordLogView()
        .environmentObject(SongStore())
}

