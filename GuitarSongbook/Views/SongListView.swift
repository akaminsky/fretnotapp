//
//  SongListView.swift
//  GuitarSongbook
//
//  List view displaying all songs
//

import SwiftUI

struct SongListView: View {
    @EnvironmentObject var songStore: SongStore
    @Binding var selectedSong: Song?
    @Binding var songToEdit: Song?
    
    var body: some View {
        List {
            ForEach(songStore.filteredAndSortedSongs) { song in
                SongRowView(song: song)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedSong = song
                    }
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
                    .swipeActions(edge: .leading) {
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
    }
}

// MARK: - Song Row View

struct SongRowView: View {
    let song: Song
    @State private var showChords = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main Row Content - Fixed, doesn't move
            HStack(spacing: 12) {
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
                                .foregroundColor(.gray)
                        }
                }
                .frame(width: 50, height: 50)
                .cornerRadius(6)
                
                // Song Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(song.title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text(song.artist)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    // Chords and Capo
                    HStack(spacing: 8) {
                        if !song.chords.isEmpty {
                            Button {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    showChords.toggle()
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    ForEach(song.chords.prefix(4), id: \.self) { chord in
                                        ChordBadge(chord: chord, small: true)
                                    }
                                    if song.chords.count > 4 {
                                        Text("+\(song.chords.count - 4)")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    Image(systemName: showChords ? "chevron.up" : "chevron.down")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        
                        Spacer()
                        
                        CapoBadge(position: song.capoPosition)
                    }
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
            
            // Expanded Chord Diagrams - Slides open below
            if showChords && !song.chords.isEmpty {
                Divider()
                    .padding(.top, 4)
                
                ChordDiagramsGrid(chords: song.chords)
                    .padding(.vertical, 12)
            }
        }
    }
}

// MARK: - Chord Badge

struct ChordBadge: View {
    let chord: String
    var small: Bool = false
    
    var body: some View {
        Text(chord)
            .font(small ? .caption2 : .caption)
            .fontWeight(.semibold)
            .foregroundColor(.appAccentText)
            .padding(.horizontal, small ? 6 : 8)
            .padding(.vertical, small ? 2 : 4)
            .background(Color.appAccent.opacity(0.12))
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.appAccent.opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: - Capo Badge

struct CapoBadge: View {
    let position: Int
    
    var body: some View {
        Text(position == 0 ? "No Capo" : "Capo \(position)")
            .font(.caption2)
            .foregroundColor(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Color(.systemGray6))
            .cornerRadius(4)
    }
}

#Preview {
    NavigationStack {
        SongListView(selectedSong: .constant(nil), songToEdit: .constant(nil))
            .environmentObject(SongStore())
    }
}
