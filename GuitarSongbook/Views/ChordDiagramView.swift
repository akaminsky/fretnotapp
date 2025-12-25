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

    var body: some View {
        VStack(spacing: 6) {
            Text(chordName)
                .font(.title3)
                .fontWeight(.bold)
                .lineLimit(1)

            if let chordData = chordLibrary.findChord(chordName) {
                Text(chordData.name)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                ChordDiagramCanvas(chordData: chordData, strings: strings)
                    .frame(width: 90, height: 110)

                // Custom chord indicator
                if chordLibrary.isCustomChord(chordName) {
                    Text("CUSTOM")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.appAccent)
                        .cornerRadius(4)
                }
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
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
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
    
    private let stringSpacing: CGFloat = 14
    private let fretSpacing: CGFloat = 18
    private let startX: CGFloat = 15
    private let startY: CGFloat = 20
    
    var body: some View {
        Canvas { context, size in
            // Draw strings (vertical lines)
            for i in 0..<6 {
                let x = startX + CGFloat(i) * stringSpacing
                var path = Path()
                path.move(to: CGPoint(x: x, y: startY))
                path.addLine(to: CGPoint(x: x, y: startY + 5 * fretSpacing))
                context.stroke(path, with: .color(.primary), lineWidth: 1)
            }
            
            // Draw frets (horizontal lines) - 6 frets now
            for i in 0..<6 {
                let y = startY + CGFloat(i) * fretSpacing
                var path = Path()
                path.move(to: CGPoint(x: startX, y: y))
                path.addLine(to: CGPoint(x: startX + 5 * stringSpacing, y: y))
                context.stroke(path, with: .color(.primary), lineWidth: i == 0 ? 3 : 1)
            }
            
            // Draw barre if present
            if let barre = chordData.barre {
                // Position barre in the space between frets (e.g., fret 1 is between line 0 and line 1)
                let y = startY + (CGFloat(barre) - 1) * fretSpacing + fretSpacing/2
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
                    // Finger position - place in the space between frets
                    // Fret 1 is between line 0 and line 1, fret 2 is between line 1 and line 2, etc.
                    let y = startY + (CGFloat(fret) - 1) * fretSpacing + fretSpacing/2
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
    @ObservedObject private var customChordLibrary = CustomChordLibrary.shared
    @EnvironmentObject var songStore: SongStore

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.adaptive(minimum: 100), spacing: 12)
        ], spacing: 12) {
            ForEach(chords, id: \.self) { chord in
                ChordDiagramView(chordName: chord, onEditRequest: {
                    chordToEdit = EditableChord(name: chord)
                })
                .background(Color(.systemBackground))
                .cornerRadius(8)
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
