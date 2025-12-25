//
//  ChordDetailPageView.swift
//  GuitarSongbook
//
//  Chord detail page showing songs and ability to create variations
//

import SwiftUI

struct ChordDetailPageView: View {
    @EnvironmentObject var songStore: SongStore
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var customChordLibrary = CustomChordLibrary.shared

    let chordName: String

    @State private var showingAddVariation = false
    @State private var showingDeleteAlert = false
    @State private var selectedFingers: [Int] = [0, 0, 0, 0, 0, 0]

    private let chordLibrary = ChordLibrary.shared

    private var songsUsingChord: [Song] {
        songStore.songs.filter { $0.chords.contains(chordName) }
    }

    private var isCustomChord: Bool {
        chordLibrary.isCustomChord(chordName)
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                // Large chord diagram
                VStack(spacing: 12) {
                    ChordDiagramView(chordName: chordName)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
                }
                .id(customChordLibrary.customChords.count)

                // Add Variation button
                Button {
                    showingAddVariation = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "hand.raised.fingers.spread")
                        Text("Add Variation")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.appAccent)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)

                // Songs list
                if !songsUsingChord.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Used in \(songsUsingChord.count) \(songsUsingChord.count == 1 ? "song" : "songs")")
                            .font(.headline)
                            .padding(.horizontal)

                        VStack(spacing: 8) {
                            ForEach(songsUsingChord) { song in
                                NavigationLink(destination: SongDetailView(song: song)) {
                                    HStack(spacing: 12) {
                                        // Album cover
                                        AsyncImage(url: URL(string: song.albumCoverUrl ?? "")) { image in
                                            image.resizable().aspectRatio(contentMode: .fill)
                                        } placeholder: {
                                            Rectangle()
                                                .fill(Color(.systemGray5))
                                                .overlay {
                                                    Image(systemName: "music.note")
                                                        .font(.caption)
                                                        .foregroundColor(.gray)
                                                }
                                        }
                                        .frame(width: 50, height: 50)
                                        .cornerRadius(6)

                                        // Song info
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(song.title)
                                                .font(.body)
                                                .fontWeight(.medium)
                                                .foregroundColor(.primary)
                                                .lineLimit(1)

                                            Text(song.artist)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)
                                        }

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    .background(Color(.systemBackground))
                                    .cornerRadius(8)
                                    .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "music.note.list")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("Not used in any songs yet")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 40)
                }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle(chordName)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if isCustomChord {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            showingAddVariation = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }

                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.body)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddVariation) {
            AddVariationSheet(chordName: chordName, onSave: { newName in
                // If chord was renamed, dismiss this view to go back to chord list
                if newName != chordName {
                    dismiss()
                }
            })
            .environmentObject(songStore)
        }
        .alert("Delete Custom Chord?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteCustomChord()
            }
        } message: {
            if songsUsingChord.isEmpty {
                Text("This will permanently delete \"\(chordName)\".")
            } else {
                Text("\"\(chordName)\" is used in \(songsUsingChord.count) song(s). The chord will still appear in songs but will no longer have a custom fingering.")
            }
        }
        .onAppear {
            // Pre-fill with current chord fingering
            if let chordData = chordLibrary.findChord(chordName) {
                selectedFingers = chordData.fingers
            }
        }
    }

    private func deleteCustomChord() {
        if let customChord = CustomChordLibrary.shared.findCustomChord(byDisplayName: chordName) {
            CustomChordLibrary.shared.deleteCustomChord(customChord.id)
            // Delay dismiss slightly to ensure state updates propagate
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                dismiss()
            }
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.appAccent)

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Add Variation Sheet

struct AddVariationSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var songStore: SongStore
    let chordName: String
    let onSave: (String) -> Void

    @State private var selectedFingers: [Int] = [0, 0, 0, 0, 0, 0]
    @State private var customName = ""
    @State private var showingSaveConfirmation = false
    @State private var savedChordName = ""

    private let strings = ["E", "A", "D", "G", "B", "e"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Current chord preview
                    VStack(spacing: 12) {
                        if let chordData = ChordLibrary.shared.findChord(chordName) {
                            ChordDiagramView(chordName: chordName)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    Divider()

                    // Editable fretboard
                    VStack(spacing: 12) {
                        Text("Create Custom Variation")
                            .font(.headline)

                        TappableFretboard(selectedFingers: $selectedFingers, strings: strings)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(16)

                        TextField("Name for variation (e.g., G (Sweet Home))", text: $customName)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal)
                    }

                    Button {
                        saveCustomVariation()
                    } label: {
                        Text("Save as Custom Chord")
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.appAccent)
                    .disabled(customName.trimmingCharacters(in: .whitespaces).isEmpty)
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Add Variation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                // Pre-fill with chord name and fingering if it exists
                customName = chordName
                if let chordData = ChordLibrary.shared.findChord(chordName) {
                    selectedFingers = chordData.fingers
                }
            }
        }
        .alert("Custom Chord Saved", isPresented: $showingSaveConfirmation) {
            Button("OK") {
                onSave(savedChordName)
                dismiss()
            }
        } message: {
            Text("\"\(savedChordName)\" has been added to your custom chords.")
        }
    }

    private func saveCustomVariation() {
        let trimmedName = customName.trimmingCharacters(in: .whitespaces)

        // Check if we're editing an existing custom chord
        if let existingChord = CustomChordLibrary.shared.findCustomChord(byDisplayName: chordName) {
            // Update the existing chord
            let updatedChord = CustomChordData(
                id: existingChord.id,  // Keep the same ID
                fingers: selectedFingers,
                name: extractBaseChordName(trimmedName),
                displayName: trimmedName,
                barre: detectBarre(selectedFingers),
                dateCreated: existingChord.dateCreated  // Keep original date
            )
            CustomChordLibrary.shared.updateCustomChord(updatedChord)

            // If name changed, update all songs that reference the old name
            if trimmedName != chordName {
                for song in songStore.songs {
                    if song.chords.contains(chordName) {
                        var updatedSong = song
                        updatedSong.chords = song.chords.map { chord in
                            chord == chordName ? trimmedName : chord
                        }
                        songStore.updateSong(updatedSong)
                    }
                }
            }
        } else {
            // Create a new custom chord
            let customChord = CustomChordData(
                id: UUID(),
                fingers: selectedFingers,
                name: extractBaseChordName(trimmedName),
                displayName: trimmedName,
                barre: detectBarre(selectedFingers),
                dateCreated: Date()
            )
            CustomChordLibrary.shared.addCustomChord(customChord)
        }

        savedChordName = trimmedName
        showingSaveConfirmation = true
    }

    private func extractBaseChordName(_ displayName: String) -> String {
        if let parenIndex = displayName.firstIndex(of: "(") {
            return String(displayName[..<parenIndex]).trimmingCharacters(in: .whitespaces)
        }
        return displayName
    }

    private func detectBarre(_ fingers: [Int]) -> Int? {
        let playedFrets = fingers.filter { $0 > 0 }
        guard playedFrets.count >= 3 else { return nil }

        let minFret = playedFrets.min() ?? 0
        let sameFretCount = playedFrets.filter { $0 == minFret }.count

        return sameFretCount >= 3 ? minFret : nil
    }
}

#Preview {
    NavigationStack {
        ChordDetailPageView(chordName: "G")
            .environmentObject(SongStore())
    }
}
