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
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(songStore.filteredAndSortedSongs) { song in
                    SongRowView(song: song)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedSong = song
                        }
                        .contextMenu {
                            Button {
                                songToEdit = song
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
                                songStore.deleteSong(song)
                            } label: {
                                Label("Delete", systemImage: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    
                    Divider()
                        .padding(.leading, 74)
                }
            }
        }
    }
}

// MARK: - Song Row View

struct SongRowView: View {
    let song: Song
    @State private var showChords = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main Row Content
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
                                showChords.toggle()
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
            
            // Expanded Chord Diagrams - smooth slide animation
            if !song.chords.isEmpty {
                VStack(spacing: 0) {
                    Divider()
                    
                    ChordDiagramsGrid(chords: song.chords)
                        .padding(.vertical, 12)
                }
                .frame(maxHeight: showChords ? nil : 0, alignment: .top)
                .clipped()
                .opacity(showChords ? 1 : 0)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showChords)
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
            .foregroundColor(.primary)
            .padding(.horizontal, small ? 6 : 8)
            .padding(.vertical, small ? 2 : 4)
            .background(Color(.systemGray5))
            .cornerRadius(4)
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
