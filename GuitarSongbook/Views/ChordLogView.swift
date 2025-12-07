//
//  ChordLogView.swift
//  GuitarSongbook
//
//  Shows all chords learned across songs
//

import SwiftUI

struct ChordLogView: View {
    @EnvironmentObject var songStore: SongStore
    @State private var searchText = ""
    
    var filteredChords: [String] {
        let allChords = songStore.allUniqueChords
        if searchText.isEmpty {
            return allChords
        }
        return allChords.filter { $0.lowercased().contains(searchText.lowercased()) }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if songStore.allUniqueChords.isEmpty {
                    emptyState
                } else {
                    chordGrid
                }
            }
            .navigationTitle("Chord Log")
            .searchable(text: $searchText, prompt: "Search chords")
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
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Chord Grid
    
    private var chordGrid: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Stats header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(songStore.allUniqueChords.count)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.appAccent)
                        
                        Text("chords learned")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                
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
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 12) {
                        ForEach(filteredChords, id: \.self) { chord in
                            ChordCard(chord: chord, songCount: songsWithChord(chord))
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
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
        // Chord diagram (includes chord name at top)
        ChordDiagramView(chordName: chord)
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(Color(.systemBackground))
            .cornerRadius(12)
    }
}

#Preview {
    ChordLogView()
        .environmentObject(SongStore())
}

