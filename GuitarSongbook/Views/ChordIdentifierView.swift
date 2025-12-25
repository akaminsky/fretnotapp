//
//  ChordIdentifierView.swift
//  GuitarSongbook
//
//  Interactive chord identifier - tap to place fingers and identify the chord
//

import SwiftUI

struct ChordIdentifierView: View {
    @EnvironmentObject var songStore: SongStore
    @State private var selectedFingers: [Int] = [0, 0, 0, 0, 0, 0] // [E, A, D, G, B, e] - default to open

    private let strings = ["E", "A", "D", "G", "B", "e"]
    private let chordLibrary = ChordLibrary.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Instructions
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

                // Interactive Fretboard
                TappableFretboard(selectedFingers: $selectedFingers, strings: strings)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)

                // Control button
                Button {
                    selectedFingers = [0, 0, 0, 0, 0, 0]
                } label: {
                    Label("Clear All", systemImage: "arrow.counterclockwise")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .buttonStyle(.bordered)

                // Results
                ChordResultsView(selectedFingers: selectedFingers, chordLibrary: chordLibrary)
                    .environmentObject(songStore)
            }
            .padding()
        }
    }
}

// MARK: - Tappable Fretboard

struct TappableFretboard: View {
    @Binding var selectedFingers: [Int]
    let strings: [String]

    private let numFrets = 5
    private let cellHeight: CGFloat = 55

    var body: some View {
        VStack(spacing: 0) {
            // String headers
            stringHeaderView
                .padding(.bottom, 12)

            Divider()
                .padding(.bottom, 8)

            // Fretboard grid - explicit rows to avoid ForEach closure issues
            VStack(spacing: 2) {
                fretRow(fret: 1)
                fretRow(fret: 2)
                fretRow(fret: 3)
                fretRow(fret: 4)
                fretRow(fret: 5)
            }
        }
    }

    private var stringHeaderView: some View {
        HStack(spacing: 0) {
            Text("")
                .font(.caption2)
                .frame(width: 45)

            stringHeader(index: 0)
            stringHeader(index: 1)
            stringHeader(index: 2)
            stringHeader(index: 3)
            stringHeader(index: 4)
            stringHeader(index: 5)
        }
    }

    private func stringHeader(index: Int) -> some View {
        VStack(spacing: 4) {
            Text(strings[index])
                .font(.caption)
                .fontWeight(.bold)

            statusIndicator(for: index)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            toggleOpenMuted(stringIndex: index)
        }
    }

    @ViewBuilder
    private func statusIndicator(for stringIndex: Int) -> some View {
        if selectedFingers[stringIndex] == 0 {
            Circle()
                .stroke(Color.green, lineWidth: 2)
                .frame(width: 14, height: 14)
        } else if selectedFingers[stringIndex] == -1 {
            Text("×")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.red)
        } else {
            Text(" ")
                .font(.caption)
        }
    }

    private func fretRow(fret: Int) -> some View {
        HStack(spacing: 2) {
            Text("\(fret)")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 45)

            fretCell(stringIndex: 0, fret: fret)
            fretCell(stringIndex: 1, fret: fret)
            fretCell(stringIndex: 2, fret: fret)
            fretCell(stringIndex: 3, fret: fret)
            fretCell(stringIndex: 4, fret: fret)
            fretCell(stringIndex: 5, fret: fret)
        }
        .frame(height: cellHeight)
    }

    private func fretCell(stringIndex: Int, fret: Int) -> some View {
        ZStack {
            Rectangle()
                .fill(Color(.systemGray6))
                .overlay(
                    Rectangle()
                        .stroke(Color.primary.opacity(0.15), lineWidth: 0.5)
                )

            if selectedFingers[stringIndex] == fret {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 26, height: 26)
                    .overlay(
                        Text("\(fret)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    )
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            tapFret(stringIndex: stringIndex, fret: fret)
        }
    }

    private func tapFret(stringIndex: Int, fret: Int) {
        if selectedFingers[stringIndex] == fret {
            selectedFingers[stringIndex] = 0  // Reset to open instead of muted
        } else {
            selectedFingers[stringIndex] = fret
        }
    }

    private func toggleOpenMuted(stringIndex: Int) {
        let current = selectedFingers[stringIndex]
        if current == 0 {
            selectedFingers[stringIndex] = -1
        } else {
            selectedFingers[stringIndex] = 0
        }
    }
}

// MARK: - Chord Results

struct IdentifiableString: Identifiable {
    let id = UUID()
    let value: String
}

struct ChordResultsView: View {
    @EnvironmentObject var songStore: SongStore
    let selectedFingers: [Int]
    let chordLibrary: ChordLibrary

    @State private var selectedChordForAdding: IdentifiableString?
    @State private var selectedChordIndex: Int?
    @State private var showingSaveCustomChord = false

    private var hasFingers: Bool {
        selectedFingers.contains { $0 >= 0 }
    }

    private var matchedChords: [(String, ChordData)] {
        chordLibrary.findChordsMatching(fingers: selectedFingers, barre: nil)
    }

    var body: some View {
        Group {
            if hasFingers {
                if matchedChords.isEmpty {
                    emptyResultView
                } else {
                    matchedChordsView
                }
            } else {
                placeholderView
            }
        }
        .sheet(item: $selectedChordForAdding) { identifiableChord in
            SongSelectorSheet(chordName: identifiableChord.value)
                .environmentObject(songStore)
        }
        .sheet(isPresented: $showingSaveCustomChord) {
            SaveCustomChordSheet(
                fingers: selectedFingers,
                onSave: { name in
                    saveCustomChord(name: name)
                }
            )
        }
    }

    private var emptyResultView: some View {
        VStack(spacing: 12) {
            Image(systemName: "questionmark.circle")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text("No matching chord found")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Try adjusting finger positions or save as custom")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showingSaveCustomChord = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                    Text("Save Custom Chord")
                        .fontWeight(.medium)
                }
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.appAccent)
                .cornerRadius(8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func saveCustomChord(name: String) {
        let customChord = CustomChordData(
            id: UUID(),
            fingers: selectedFingers,
            name: extractBaseChordName(name),
            displayName: name,
            barre: detectBarre(selectedFingers),
            dateCreated: Date()
        )

        CustomChordLibrary.shared.addCustomChord(customChord)

        selectedChordForAdding = IdentifiableString(value: name)
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

    private var matchedChordsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with title and Add to Songs button
            HStack {
                Text("Matched Chord")
                    .font(.headline)

                Spacer()

                Button {
                    // Use first match if nothing selected
                    let index = selectedChordIndex ?? 0
                    if index < matchedChords.count {
                        let chordName = matchedChords[index].0
                        selectedChordForAdding = IdentifiableString(value: chordName)
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add to Songs")
                            .fontWeight(.medium)
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.appAccent)
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)

            ForEach(0..<min(matchedChords.count, 10), id: \.self) { index in
                let chordTuple = matchedChords[index]
                let chordName = chordTuple.0
                let chordData = chordTuple.1
                let isSelected = (selectedChordIndex ?? 0) == index

                VStack(spacing: 12) {
                    // Chord diagram (includes name)
                    ChordDiagramView(chordName: chordName)
                        .frame(height: 140)

                    if let barre = chordData.barre {
                        Text("Barre at fret \(barre)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isSelected ? Color.appAccent.opacity(0.15) : Color(.systemGray6))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.appAccent : Color.clear, lineWidth: 2)
                )
                .onTapGesture {
                    selectedChordIndex = index
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .onAppear {
            // Auto-select first chord
            if selectedChordIndex == nil && !matchedChords.isEmpty {
                selectedChordIndex = 0
            }
        }
    }

    private var placeholderView: some View {
        VStack(spacing: 12) {
            Image(systemName: "hand.raised.fingers.spread")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text("Tap fretboard to identify chord")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Song Selector Sheet

struct SongSelectorSheet: View {
    @EnvironmentObject var songStore: SongStore
    @Environment(\.dismiss) var dismiss

    let chordName: String
    @State private var selectedSongIds: Set<UUID> = []

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if songStore.songs.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "music.note.list")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        Text("No songs yet")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Add songs to your library first")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                } else {
                    // Song list
                    List {
                        ForEach(songStore.songs) { song in
                            Button {
                                toggleSongSelection(song.id)
                            } label: {
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

                                        // Show if chord already exists
                                        if song.chords.contains(chordName) {
                                            Text("Already has \(chordName)")
                                                .font(.caption)
                                                .foregroundColor(.orange)
                                        }
                                    }

                                    Spacer()

                                    // Checkbox
                                    Image(systemName: selectedSongIds.contains(song.id) ? "checkmark.circle.fill" : "circle")
                                        .font(.title3)
                                        .foregroundColor(selectedSongIds.contains(song.id) ? .appAccent : .secondary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Add \(chordName) to Songs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        addChordToSelectedSongs()
                    } label: {
                        if selectedSongIds.isEmpty {
                            Text("Done")
                        } else {
                            Text("Add to \(selectedSongIds.count)")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(selectedSongIds.isEmpty)
                }
            }
        }
    }

    private func toggleSongSelection(_ songId: UUID) {
        if selectedSongIds.contains(songId) {
            selectedSongIds.remove(songId)
        } else {
            selectedSongIds.insert(songId)
        }
    }

    private func addChordToSelectedSongs() {
        // Ensure updates happen on main thread
        DispatchQueue.main.async {
            for songId in self.selectedSongIds {
                if let song = self.songStore.songs.first(where: { $0.id == songId }) {
                    var updatedSong = song

                    // Add chord if it doesn't already exist
                    if !updatedSong.chords.contains(self.chordName) {
                        updatedSong.chords.append(self.chordName)
                        self.songStore.updateSong(updatedSong)
                    }
                }
            }

            // Small delay to ensure updates propagate before dismissing
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.dismiss()
            }
        }
    }
}

// MARK: - Save Custom Chord Sheet

struct SaveCustomChordSheet: View {
    @Environment(\.dismiss) var dismiss
    let fingers: [Int]
    let onSave: (String) -> Void

    @State private var chordName = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack {
                        Text("Your Custom Chord")
                            .font(.headline)
                            .padding(.top, 8)

                        MiniChordDiagramPreview(fingers: fingers)
                            .frame(height: 80)
                            .padding(.vertical, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                }

                Section {
                    TextField("Chord name (e.g., G (Sweet Home))", text: $chordName)
                        .autocapitalization(.words)
                        .autocorrectionDisabled()
                } header: {
                    Text("Chord Name")
                } footer: {
                    Text("Give your chord a unique name. Include variations in parentheses (e.g., 'G (alt)', 'C (Sweet Home)').")
                }

                Section {
                    Button("G (variation)") { chordName = "G (variation)" }
                    Button("C (alt)") { chordName = "C (alt)" }
                    Button("D (custom)") { chordName = "D (custom)" }
                } header: {
                    Text("Quick Templates")
                }
            }
            .navigationTitle("Save Custom Chord")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(chordName)
                        dismiss()
                    }
                    .disabled(chordName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

// MARK: - Mini Chord Diagram Preview

struct MiniChordDiagramPreview: View {
    let fingers: [Int]
    private let strings = ["E", "A", "D", "G", "B", "e"]

    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<6, id: \.self) { stringIndex in
                VStack(spacing: 4) {
                    Text(strings[stringIndex])
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    if fingers[stringIndex] == -1 {
                        Text("×")
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(width: 24, height: 24)
                    } else if fingers[stringIndex] == 0 {
                        Circle()
                            .stroke(Color.green, lineWidth: 2)
                            .frame(width: 20, height: 20)
                    } else {
                        Text("\(fingers[stringIndex])")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 24, height: 24)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChordIdentifierView()
            .navigationTitle("Identify Chord")
            .environmentObject(SongStore())
    }
}
