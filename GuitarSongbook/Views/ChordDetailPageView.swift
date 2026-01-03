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
    @State private var showingAddToSong = false
    @State private var showingEnlargedDiagram = false
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
                .onTapGesture {
                    showingEnlargedDiagram = true
                }

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
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showingAddVariation = true
                    } label: {
                        Label("Add Variation", systemImage: "hand.raised.fingers.spread")
                    }

                    Button {
                        showingAddToSong = true
                    } label: {
                        Label("Add to Song", systemImage: "plus.circle")
                    }

                    if isCustomChord {
                        Divider()

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
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.body)
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
        .sheet(isPresented: $showingAddToSong) {
            SongSelectorSheet(chordName: chordName)
                .environmentObject(songStore)
        }
        .fullScreenCover(isPresented: $showingEnlargedDiagram) {
            EnlargedChordDiagramView(chordName: chordName)
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

// MARK: - Enlarged Chord Diagram View

struct EnlargedChordDiagramView: View {
    @Environment(\.dismiss) var dismiss
    let chordName: String

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }

            VStack(spacing: 20) {
                Spacer()

                // Large chord diagram
                ChordDiagramView(chordName: chordName)
                    .scaleEffect(1.8)
                    .padding(60)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.3), radius: 20)

                Spacer()

                // Dismiss hint
                Text("Tap anywhere to close")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, 40)
            }
            .padding()
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
    @State private var fingersForSave: FingerPosition?
    @State private var showingSaveConfirmation = false
    @State private var savedChordName = ""
    @State private var showingAddToSong = false

    private let strings = ["E", "A", "D", "G", "B", "e"]

    struct FingerPosition: Identifiable {
        let id = UUID()
        let fingers: [Int]
    }

    private var matchedChords: [(String, ChordData)] {
        ChordLibrary.shared.findChordsMatching(fingers: selectedFingers, barre: nil)
    }

    private var hasFingers: Bool {
        selectedFingers.contains { $0 > 0 }
    }

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

                    // Helper text
                    VStack(spacing: 8) {
                        Text("Tap fretboard to place fingers")
                            .font(.headline)
                            .foregroundColor(.primary)

                        Text("Tap string names to toggle open (O) or muted (×)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)

                    // Editable fretboard
                    TappableFretboard(selectedFingers: $selectedFingers, strings: strings)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)

                    // Clear button
                    Button {
                        selectedFingers = [0, 0, 0, 0, 0, 0]
                    } label: {
                        Label("Clear All", systemImage: "arrow.counterclockwise")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .buttonStyle(.bordered)

                    // Matching chords section
                    if hasFingers {
                        VStack(spacing: 12) {
                            if !matchedChords.isEmpty {
                                Text("Matches these known chords:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 12) {
                                    ForEach(matchedChords.prefix(6), id: \.0) { (name, _) in
                                        Text(name)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color.green.opacity(0.1))
                                            .cornerRadius(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                            )
                                    }
                                }
                            } else {
                                Text("No matching chords found")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }

                    Divider()
                }
                .padding()
            }
            .navigationTitle("Add Variation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        fingersForSave = FingerPosition(fingers: selectedFingers)
                    }
                    .disabled(!hasFingers)
                }
            }
            .onAppear {
                // Pre-fill with chord fingering if it exists
                if let chordData = ChordLibrary.shared.findChord(chordName) {
                    selectedFingers = chordData.fingers
                }
            }
        }
        .sheet(item: $fingersForSave) { position in
            SaveCustomChordSheet(fingers: position.fingers) { name in
                saveCustomVariation(name: name, fingers: position.fingers)
            }
        }
        .alert("Custom Chord Saved", isPresented: $showingSaveConfirmation) {
            Button("Done") {
                onSave(savedChordName)
                dismiss()
            }
            Button("Add to Song") {
                onSave(savedChordName)
                showingSaveConfirmation = false
                showingAddToSong = true
            }
        } message: {
            Text("\"\(savedChordName)\" has been added to your custom chords.")
        }
        .sheet(isPresented: $showingAddToSong) {
            // When SongSelectorSheet dismisses, also dismiss AddVariationSheet
            dismiss()
        } content: {
            SongSelectorSheet(chordName: savedChordName)
                .environmentObject(songStore)
        }
    }

    private func saveCustomVariation(name: String, fingers: [Int]) {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)

        // Check if we're editing an existing custom chord
        if let existingChord = CustomChordLibrary.shared.findCustomChord(byDisplayName: chordName) {
            // Update the existing chord
            let updatedChord = CustomChordData(
                id: existingChord.id,  // Keep the same ID
                fingers: fingers,
                name: extractBaseChordName(trimmedName),
                displayName: trimmedName,
                barre: detectBarre(fingers),
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
                fingers: fingers,
                name: extractBaseChordName(trimmedName),
                displayName: trimmedName,
                barre: detectBarre(fingers),
                dateCreated: Date()
            )
            Task { @MainActor in
                await CustomChordLibrary.shared.addCustomChord(customChord)
            }
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
