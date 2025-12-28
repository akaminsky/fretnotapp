//
//  ChordDiagramView.swift
//  GuitarSongbook
//
//  SVG-style chord diagram view
//

import SwiftUI

struct ChordDiagramView: View {
    let chordName: String
    var onEditRequest: (() -> Void)? = nil

    @State private var showingEditSheet = false
    @ObservedObject private var customChordLibrary = CustomChordLibrary.shared

    private let strings = ["E", "A", "D", "G", "B", "e"]
    private let chordLibrary = ChordLibrary.shared

    private var displayName: String {
        let (baseName, _) = chordLibrary.parseVoicingNotation(chordName)
        return baseName
    }

    var body: some View {
        VStack(spacing: 6) {
            Text(displayName)
                .font(.title3)
                .fontWeight(.bold)
                .lineLimit(1)

            if let chordData = chordLibrary.findChord(chordName) {
                let range = chordData.fretRange
                let dynamicHeight: CGFloat = 30 + CGFloat(range.numFrets) * 18
                ChordDiagramCanvas(chordData: chordData, strings: strings)
                    .frame(width: 90, height: dynamicHeight)
            } else {
                VStack(spacing: 8) {
                    Text("Diagram not available")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Button {
                        if let onEditRequest = onEditRequest {
                            onEditRequest()
                        } else {
                            showingEditSheet = true
                        }
                    } label: {
                        Text("Add Diagram")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.appAccent)
                            .cornerRadius(4)
                    }
                    .buttonStyle(.plain)
                }
                .frame(width: 90, height: 110)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 4)
        .if(onEditRequest == nil) { view in
            // Only enable long press and content shape when NOT in a grid/list context
            view
                .contentShape(Rectangle())
                .onLongPressGesture {
                    showingEditSheet = true
                }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditChordSheet(chordName: chordName)
        }
        .id("\(chordName)-\(customChordLibrary.customChords.count)")
    }
}

// MARK: - Chord Diagram Canvas

struct ChordDiagramCanvas: View {
    let chordData: ChordData
    let strings: [String]
    
    private let stringSpacing: CGFloat = 12
    private let fretSpacing: CGFloat = 18
    private let startX: CGFloat = 25  // Increased to make room for fret labels
    private let startY: CGFloat = 20
    
    var body: some View {
        Canvas { context, size in
            // Calculate dynamic fret range
            let range = chordData.fretRange
            let startFret = range.startFret
            let numFrets = range.numFrets

            // Draw strings (vertical lines)
            for i in 0..<6 {
                let x = startX + CGFloat(i) * stringSpacing
                var path = Path()
                path.move(to: CGPoint(x: x, y: startY))
                path.addLine(to: CGPoint(x: x, y: startY + CGFloat(numFrets) * fretSpacing))
                context.stroke(path, with: .color(.primary), lineWidth: 1)
            }

            // Draw frets (horizontal lines)
            for i in 0...numFrets {
                let y = startY + CGFloat(i) * fretSpacing
                var path = Path()
                path.move(to: CGPoint(x: startX, y: y))
                path.addLine(to: CGPoint(x: startX + 5 * stringSpacing, y: y))
                // Thick nut line only when starting at fret 0
                let isNut = (i == 0 && startFret == 0)
                context.stroke(path, with: .color(.primary), lineWidth: isNut ? 3 : 1)
            }

            // Draw fret number labels on the left (one per fret space)
            for fretSpace in 1...numFrets {
                // When startFret = 0, fret space 1 = fret 1
                // When startFret > 0, fret space 1 = fret startFret (not startFret + 1)
                let fretNumber = (startFret == 0) ? fretSpace : (startFret + fretSpace - 1)
                let labelY = startY + (CGFloat(fretSpace) - 0.5) * fretSpacing
                let text = Text("\(fretNumber)")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                context.draw(text, at: CGPoint(x: 10, y: labelY))
            }

            // Draw barre if present
            if let barre = chordData.barre {
                // Convert absolute fret to relative position
                let relativeBarre = barre - startFret
                guard relativeBarre >= 0 && relativeBarre < numFrets else { return }

                // Calculate which fret space the barre goes in (same logic as finger positions)
                let fretSpaceIndex = (startFret == 0) ? relativeBarre : (relativeBarre + 1)
                let y = startY + (CGFloat(fretSpaceIndex) - 0.5) * fretSpacing
                let rect = CGRect(x: startX - 3, y: y - 2, width: 5 * stringSpacing + 6, height: 4)
                context.fill(Path(roundedRect: rect, cornerRadius: 2), with: .color(.primary))
            }

            // Draw finger positions
            for (stringIndex, fret) in chordData.fingers.enumerated() {
                let x = startX + CGFloat(stringIndex) * stringSpacing

                if fret == -1 {
                    // X - don't play
                    let text = Text("×")
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                    context.draw(text, at: CGPoint(x: x, y: 10))
                } else if fret == 0 {
                    // O - open string
                    var circle = Path()
                    circle.addArc(center: CGPoint(x: x, y: 10), radius: 4, startAngle: .zero, endAngle: .degrees(360), clockwise: true)
                    context.stroke(circle, with: .color(.green), lineWidth: 2)
                } else {
                    // Finger position - convert to relative position
                    let relativeFret = fret - startFret
                    guard relativeFret >= 0 && relativeFret < numFrets else { continue }

                    // Calculate which fret space this finger goes in
                    // When startFret = 0: fret 1 goes in space 1
                    // When startFret > 0: fret startFret goes in space 1
                    let fretSpaceIndex = (startFret == 0) ? relativeFret : (relativeFret + 1)
                    let y = startY + (CGFloat(fretSpaceIndex) - 0.5) * fretSpacing

                    var circle = Path()
                    circle.addArc(center: CGPoint(x: x, y: y), radius: 5, startAngle: .zero, endAngle: .degrees(360), clockwise: true)
                    context.fill(circle, with: .color(.primary))
                }
            }
        }
    }
}

// MARK: - Chord Diagrams Grid

struct EditableChord: Identifiable {
    let id = UUID()
    let name: String
}

struct ChordDiagramsGrid: View {
    let chords: [String]
    @State private var chordToEdit: EditableChord?
    @State private var selectedChordForVoicingChange: String?
    @ObservedObject private var customChordLibrary = CustomChordLibrary.shared
    @EnvironmentObject var songStore: SongStore

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            ForEach(chords, id: \.self) { chord in
                ChordDiagramView(chordName: chord, onEditRequest: {
                    chordToEdit = EditableChord(name: chord)
                })
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
                .onTapGesture {
                    selectedChordForVoicingChange = chord
                }
            }
        }
        .sheet(item: $chordToEdit) { editableChord in
            EditChordSheet(chordName: editableChord.name)
                .environmentObject(songStore)
                .onDisappear {
                    // Clear state when sheet dismisses
                    chordToEdit = nil
                }
        }
        .sheet(item: Binding(
            get: { selectedChordForVoicingChange.map { VoicingSelection(originalChord: $0) } },
            set: { selectedChordForVoicingChange = $0?.originalChord }
        )) { selection in
            ChangeVoicingSheet(
                originalChordName: selection.originalChord,
                onVoicingSelected: { newVoicing in
                    updateSongChord(from: selection.originalChord, to: newVoicing)
                }
            )
            .environmentObject(songStore)
        }
    }

    private func updateSongChord(from oldName: String, to newName: String) {
        // Find the song containing this chord and update it
        if let song = songStore.songs.first(where: { $0.chords.contains(oldName) }) {
            var updatedSong = song
            updatedSong.chords = song.chords.map { chord in
                chord == oldName ? newName : chord
            }
            songStore.updateSong(updatedSong)
        }
        selectedChordForVoicingChange = nil
    }
}

// MARK: - Voicing Selection Helper

struct VoicingSelection: Identifiable {
    let id = UUID()
    let originalChord: String
}

// MARK: - Change Voicing Sheet

struct ChangeVoicingSheet: View {
    let originalChordName: String
    let onVoicingSelected: (String) -> Void
    @Environment(\.dismiss) var dismiss

    private var baseName: String {
        ChordLibrary.shared.parseVoicingNotation(originalChordName).baseName
    }

    private var currentFingerprint: String? {
        ChordLibrary.shared.parseVoicingNotation(originalChordName).fingerprint
    }

    private var voicings: [ChordData] {
        ChordLibrary.shared.findAllVoicings(for: baseName)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Change \(baseName) voicing")
                    .font(.headline)

                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(Array(voicings.enumerated()), id: \.offset) { index, voicing in
                            let fp = ChordLibrary.shared.fingersToFingerprint(voicing.fingers)
                            let isCurrent = fp == currentFingerprint || (currentFingerprint == nil && voicing.isDefault)

                            VStack {
                                ChordDiagramCanvas(
                                    chordData: voicing,
                                    strings: ["E","A","D","G","B","e"]
                                )
                                .frame(height: 140)

                                if voicing.isDefault {
                                    Text("Default")
                                        .font(.caption)
                                        .foregroundColor(.appAccent)
                                }

                                if isCurrent {
                                    Text("Current")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                }
                            }
                            .padding()
                            .background(isCurrent ? Color.green.opacity(0.1) : Color(.systemGray6))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(isCurrent ? Color.green : Color.clear, lineWidth: 2)
                            )
                            .onTapGesture {
                                // Only add fingerprint notation for non-default voicings
                                let newName: String
                                if voicing.isDefault {
                                    newName = baseName
                                } else {
                                    newName = "\(baseName)#\(fp)"
                                }
                                onVoicingSelected(newName)
                                dismiss()
                            }
                        }
                    }
                    .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Edit Chord Sheet

struct EditChordSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var songStore: SongStore
    let chordName: String

    @State private var selectedFingers: [Int] = [0, 0, 0, 0, 0, 0]
    @State private var customName = ""
    @State private var showingSaveConfirmation = false
    @State private var savedChordName = ""

    private let strings = ["E", "A", "D", "G", "B", "e"]

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

                    // Save section
                    VStack(spacing: 12) {
                        TextField("Chord name (e.g., G (Sweet Home))", text: $customName)
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
                    .disabled(customName.trimmingCharacters(in: .whitespaces).isEmpty || !hasFingers)
                    .padding(.horizontal)

                    if !hasFingers {
                        Text("Place at least one finger on the fretboard")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                }
                .padding()
            }
            .navigationTitle("Edit Chord")
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
            Button("OK") { dismiss() }
        } message: {
            Text("\"\(savedChordName)\" has been added to your custom chords.")
        }
    }

    private func saveCustomVariation() {
        let trimmedName = customName.trimmingCharacters(in: .whitespaces)

        // Check if a chord with this name already exists
        if let existingChord = CustomChordLibrary.shared.findCustomChord(byDisplayName: trimmedName) {
            // Update the existing chord
            let updatedChord = CustomChordData(
                id: existingChord.id,
                fingers: selectedFingers,
                name: extractBaseChordName(trimmedName),
                displayName: trimmedName,
                barre: detectBarre(selectedFingers),
                dateCreated: existingChord.dateCreated
            )
            CustomChordLibrary.shared.updateCustomChord(updatedChord)
        } else {
            // Create a new chord
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

        // If the name changed from the original, update all songs
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
    VStack(spacing: 20) {
        ChordDiagramView(chordName: "Am")
        ChordDiagramView(chordName: "C")
        ChordDiagramView(chordName: "G")
        ChordDiagramView(chordName: "F")
    }
    .padding()
    .background(Color(.systemGray6))
}
