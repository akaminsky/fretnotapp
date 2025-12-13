//
//  TestChordView.swift
//  GuitarSongbook
//
//  Standalone test for chord identifier

import SwiftUI

struct TestChordView: View {
    @State private var tapCount = 0
    @State private var selectedFret = 0

    var body: some View {
        NavigationStack {
            List {
                Section("Basic Test") {
                    Text("If you can read this and tap buttons, the view works!")
                        .font(.subheadline)

                    Button("Test Button (Taps: \(tapCount))") {
                        tapCount += 1
                    }
                    .buttonStyle(.borderedProminent)
                }

                Section("Fret Selector Test") {
                    Text("Selected: Fret \(selectedFret)")
                        .font(.headline)

                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(0...12, id: \.self) { fret in
                                Button("\(fret)") {
                                    selectedFret = fret
                                }
                                .buttonStyle(.bordered)
                                .tint(selectedFret == fret ? .blue : .gray)
                            }
                        }
                    }
                }

                Section("Chord Identifier") {
                    SimpleChordIdentifier()
                }
            }
            .navigationTitle("Test View")
        }
    }
}

struct SimpleChordIdentifier: View {
    @State private var selectedFingers: [Int] = [-1, -1, -1, -1, -1, -1]
    private let strings = ["E", "A", "D", "G", "B", "e"]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tap to select fret for each string:")
                .font(.caption)
                .foregroundColor(.secondary)

            ForEach(0..<6, id: \.self) { index in
                HStack {
                    Text(strings[index])
                        .font(.headline)
                        .frame(width: 30)

                    ForEach([-1, 0, 1, 2, 3, 4, 5], id: \.self) { fret in
                        Button(action: {
                            selectedFingers[index] = fret
                        }) {
                            Text(fret == -1 ? "×" : fret == 0 ? "O" : "\(fret)")
                                .font(.caption)
                                .frame(width: 32, height: 32)
                                .background(selectedFingers[index] == fret ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(selectedFingers[index] == fret ? .white : .primary)
                                .cornerRadius(6)
                        }
                    }
                }
            }

            Text("Selected: \(selectedFingers.description)")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 8)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    TestChordView()
}
