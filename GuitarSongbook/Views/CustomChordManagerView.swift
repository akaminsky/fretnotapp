//
//  CustomChordManagerView.swift
//  GuitarSongbook
//
//  Manage custom chords - view and delete
//

import SwiftUI

struct CustomChordManagerView: View {
    @EnvironmentObject var songStore: SongStore
    @ObservedObject var customLibrary = CustomChordLibrary.shared
    @State private var showingDeleteAlert = false
    @State private var chordToDelete: CustomChordData?
    @State private var songsUsingChord: [Song] = []

    var body: some View {
        List {
            if customLibrary.customChords.isEmpty {
                emptyStateView
            } else {
                ForEach(customLibrary.customChords) { chord in
                    CustomChordRow(
                        chord: chord,
                        songsUsingCount: songStore.songs.filter { $0.chords.contains(chord.displayName) }.count,
                        onDelete: {
                            checkChordUsageAndDelete(chord)
                        }
                    )
                }
            }
        }
        .navigationTitle("Custom Chords")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Custom Chord?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {
                chordToDelete = nil
                songsUsingChord = []
            }
            Button("Delete", role: .destructive) {
                if let chord = chordToDelete {
                    deleteCustomChord(chord)
                }
            }
        } message: {
            if let chord = chordToDelete {
                if songsUsingChord.isEmpty {
                    Text("This will permanently delete \"\(chord.displayName)\".")
                } else {
                    Text("\"\(chord.displayName)\" is used in \(songsUsingChord.count) song(s): \(songsUsingChord.map { $0.title }.joined(separator: ", ")). The chord will still appear in songs but will no longer have a custom fingering.")
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "hand.raised.slash")
                .font(.system(size: 50))
                .foregroundColor(.secondary)

            Text("No Custom Chords")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("Create custom chords from the Chord Identifier or by editing chord diagrams in songs.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .listRowBackground(Color.clear)
    }

    private func checkChordUsageAndDelete(_ chord: CustomChordData) {
        // Find songs using this chord
        songsUsingChord = songStore.songs.filter { song in
            song.chords.contains(chord.displayName)
        }

        chordToDelete = chord
        showingDeleteAlert = true
    }

    private func deleteCustomChord(_ chord: CustomChordData) {
        CustomChordLibrary.shared.deleteCustomChord(chord.id)
        chordToDelete = nil
        songsUsingChord = []
    }
}

// MARK: - Custom Chord Row

struct CustomChordRow: View {
    let chord: CustomChordData
    let songsUsingCount: Int
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Chord diagram
            ChordDiagramView(chordName: chord.displayName)
                .frame(width: 80)

            // Chord info
            VStack(alignment: .leading, spacing: 4) {
                Text(chord.displayName)
                    .font(.headline)

                Text("Created \(chord.dateCreated.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundColor(.secondary)

                // Fingering text
                Text(chord.fingers.map { $0 == -1 ? "×" : "\($0)" }.joined(separator: " "))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .monospaced()

                if songsUsingCount > 0 {
                    Text("Used in \(songsUsingCount) \(songsUsingCount == 1 ? "song" : "songs")")
                        .font(.caption)
                        .foregroundColor(.appAccent)
                }
            }

            Spacer()

            // Delete button
            Button(role: .destructive) {
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationStack {
        CustomChordManagerView()
            .environmentObject(SongStore())
    }
}
