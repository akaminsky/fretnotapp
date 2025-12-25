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

    var filteredChords: [String] {
        let allChords = songStore.allUniqueChords
        if searchText.isEmpty {
            return allChords
        }
        return allChords.filter { $0.lowercased().contains(searchText.lowercased()) }
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

                        TextField("Search chords", text: $searchText)
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
                if filteredChords.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.title)
                            .foregroundColor(.secondary)
                        Text("No chords match \"\(searchText)\"")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 28),
                        GridItem(.flexible(), spacing: 28),
                        GridItem(.flexible(), spacing: 28)
                    ], spacing: 28) {
                        ForEach(filteredChords, id: \.self) { chord in
                            NavigationLink(destination: ChordDetailPageView(chordName: chord).environmentObject(songStore)) {
                                ChordCard(chord: chord, songCount: songsWithChord(chord))
                            }
                            .buttonStyle(.plain)
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
        let count = filteredChords.count
        return count == 1 ? "1 chord" : "\(count) chords"
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

    var body: some View {
        ChordDiagramView(chordName: chord)
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

