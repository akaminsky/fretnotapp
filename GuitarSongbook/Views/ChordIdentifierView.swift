//
//  ChordIdentifierView.swift
//  GuitarSongbook
//
//  Interactive chord identifier - tap to place fingers and identify the chord
//

import SwiftUI

struct ChordIdentifierView: View {
    @State private var selectedFingers: [Int] = [-1, -1, -1, -1, -1, -1] // [E, A, D, G, B, e]

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

                    Text("Tap string names at top to toggle open (O) or muted (×)")
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
                    selectedFingers = [-1, -1, -1, -1, -1, -1]
                } label: {
                    Label("Clear All", systemImage: "arrow.counterclockwise")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .buttonStyle(.bordered)

                // Results
                ChordResultsView(selectedFingers: selectedFingers, chordLibrary: chordLibrary)
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
            selectedFingers[stringIndex] = -1
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

struct ChordResultsView: View {
    let selectedFingers: [Int]
    let chordLibrary: ChordLibrary

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
    }

    private var emptyResultView: some View {
        VStack(spacing: 12) {
            Image(systemName: "questionmark.circle")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text("No matching chord found")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Try adjusting finger positions")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private var matchedChordsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Matching Chords (\(matchedChords.count))")
                .font(.headline)
                .padding(.horizontal)

            ForEach(Array(matchedChords.prefix(10).enumerated()), id: \.offset) { index, match in
                let (name, chordData) = match
                VStack(spacing: 12) {
                    // Chord diagram (includes chord name)
                    ChordDiagramView(chordName: name)
                        .frame(height: 140)
                        .padding(.vertical, 8)

                    if let barre = chordData.barre {
                        Text("Barre at fret \(barre)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
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

#Preview {
    NavigationStack {
        ChordIdentifierView()
            .navigationTitle("Identify Chord")
    }
}
