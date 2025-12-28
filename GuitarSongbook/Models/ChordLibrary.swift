//
//  ChordLibrary.swift
//  GuitarSongbook
//
//  Guitar chord fingering library
//

import Foundation

struct ChordData {
    let fingers: [Int]  // [E, A, D, G, B, e] - -1 = don't play, 0 = open, 1-15 = fret
    let name: String
    let barre: Int?
    let isDefault: Bool

    init(fingers: [Int], name: String, barre: Int? = nil, isDefault: Bool = false) {
        self.fingers = fingers
        self.name = name
        self.barre = barre
        self.isDefault = isDefault
    }
}

class ChordLibrary {
    static let shared = ChordLibrary()

    private let chords: [ChordData] = [
        // Major Chords
        ChordData(fingers: [-1, 3, 2, 0, 1, 0], name: "C", isDefault: true),
        ChordData(fingers: [-1, 3, 2, 0, 1, 3], name: "C"),  // C with high G (x32013)
        ChordData(fingers: [-1, 4, 6, 6, 6, 4], name: "C#", barre: 4),
        ChordData(fingers: [-1, 4, 6, 6, 6, 4], name: "Db", barre: 4),
        ChordData(fingers: [-1, -1, 0, 2, 3, 2], name: "D", isDefault: true),
        ChordData(fingers: [-1, -1, 0, 2, 3, 5], name: "D"),  // D with high A (xx0235)
        ChordData(fingers: [-1, -1, 1, 3, 4, 3], name: "D#"),
        ChordData(fingers: [-1, -1, 1, 3, 4, 3], name: "Eb"),
        ChordData(fingers: [0, 2, 2, 1, 0, 0], name: "E", isDefault: true),
        ChordData(fingers: [1, 3, 3, 2, 1, 1], name: "F", barre: 1, isDefault: true),
        ChordData(fingers: [2, 4, 4, 3, 2, 2], name: "F#", barre: 2),
        ChordData(fingers: [2, 4, 4, 3, 2, 2], name: "Gb", barre: 2),
        ChordData(fingers: [3, 2, 0, 0, 0, 3], name: "G", isDefault: true),
        ChordData(fingers: [3, 2, 0, 0, 3, 3], name: "G"),  // Bluegrass G / Rock G (320033)
        ChordData(fingers: [4, 6, 6, 5, 4, 4], name: "G#", barre: 4),
        ChordData(fingers: [4, 6, 6, 5, 4, 4], name: "Ab", barre: 4),
        ChordData(fingers: [-1, 0, 2, 2, 2, 0], name: "A", isDefault: true),
        ChordData(fingers: [-1, 1, 3, 3, 3, 1], name: "A#", barre: 1),
        ChordData(fingers: [-1, 1, 3, 3, 3, 1], name: "Bb", barre: 1),
        ChordData(fingers: [-1, 2, 4, 4, 4, 2], name: "B", barre: 2, isDefault: true),

        // Minor Chords
        ChordData(fingers: [-1, 0, 2, 2, 1, 0], name: "Am", isDefault: true),
        ChordData(fingers: [-1, 1, 3, 3, 2, 1], name: "A#m", barre: 1),
        ChordData(fingers: [-1, 1, 3, 3, 2, 1], name: "Bbm", barre: 1),
        ChordData(fingers: [-1, 2, 4, 4, 3, 2], name: "Bm", barre: 2, isDefault: true),
        ChordData(fingers: [-1, 3, 5, 5, 4, 3], name: "Cm", barre: 3, isDefault: true),
        ChordData(fingers: [-1, 4, 6, 6, 5, 4], name: "C#m", barre: 4),
        ChordData(fingers: [-1, 4, 6, 6, 5, 4], name: "Dbm", barre: 4),
        ChordData(fingers: [-1, -1, 0, 2, 3, 1], name: "Dm", isDefault: true),
        ChordData(fingers: [-1, -1, 1, 3, 4, 2], name: "D#m"),
        ChordData(fingers: [-1, -1, 1, 3, 4, 2], name: "Ebm"),
        ChordData(fingers: [0, 2, 2, 0, 0, 0], name: "Em", isDefault: true),
        ChordData(fingers: [1, 3, 3, 1, 1, 1], name: "Fm", barre: 1, isDefault: true),
        ChordData(fingers: [2, 4, 4, 2, 2, 2], name: "F#m", barre: 2),
        ChordData(fingers: [2, 4, 4, 2, 2, 2], name: "Gbm", barre: 2),
        ChordData(fingers: [3, 5, 5, 3, 3, 3], name: "Gm", barre: 3, isDefault: true),
        ChordData(fingers: [4, 6, 6, 4, 4, 4], name: "G#m", barre: 4),
        ChordData(fingers: [4, 6, 6, 4, 4, 4], name: "Abm", barre: 4),

        // Seventh Chords
        ChordData(fingers: [-1, 0, 2, 0, 2, 0], name: "A7", isDefault: true),
        ChordData(fingers: [-1, 1, 3, 1, 3, 1], name: "Bb7", barre: 1),
        ChordData(fingers: [-1, 2, 1, 2, 0, 2], name: "B7", isDefault: true),
        ChordData(fingers: [-1, 3, 2, 3, 1, 0], name: "C7", isDefault: true),
        ChordData(fingers: [-1, 4, 6, 4, 6, 4], name: "C#7", barre: 4),
        ChordData(fingers: [-1, 4, 6, 4, 6, 4], name: "Db7", barre: 4),
        ChordData(fingers: [-1, -1, 0, 2, 1, 2], name: "D7", isDefault: true),
        ChordData(fingers: [-1, -1, 1, 3, 2, 3], name: "Eb7"),
        ChordData(fingers: [0, 2, 0, 1, 0, 0], name: "E7", isDefault: true),
        ChordData(fingers: [1, 3, 1, 2, 1, 1], name: "F7", barre: 1, isDefault: true),
        ChordData(fingers: [2, 4, 2, 3, 2, 2], name: "F#7", barre: 2),
        ChordData(fingers: [2, 4, 2, 3, 2, 2], name: "Gb7", barre: 2),
        ChordData(fingers: [3, 2, 0, 0, 0, 1], name: "G7", isDefault: true),
        ChordData(fingers: [4, 6, 4, 5, 4, 4], name: "Ab7", barre: 4),

        // Major Seventh
        ChordData(fingers: [-1, 0, 2, 1, 2, 0], name: "Amaj7"),
        ChordData(fingers: [-1, 1, 3, 2, 3, 1], name: "Bbmaj7", barre: 1),
        ChordData(fingers: [-1, 2, 4, 3, 4, 2], name: "Bmaj7", barre: 2),
        ChordData(fingers: [-1, 3, 2, 0, 0, 0], name: "Cmaj7"),
        ChordData(fingers: [-1, 4, 6, 5, 6, 4], name: "C#maj7", barre: 4),
        ChordData(fingers: [-1, 4, 6, 5, 6, 4], name: "Dbmaj7", barre: 4),
        ChordData(fingers: [-1, -1, 0, 2, 2, 2], name: "Dmaj7"),
        ChordData(fingers: [-1, -1, 1, 3, 3, 3], name: "Ebmaj7"),
        ChordData(fingers: [0, 2, 1, 1, 0, 0], name: "Emaj7"),
        ChordData(fingers: [1, 3, 2, 2, 1, 1], name: "Fmaj7", barre: 1),
        ChordData(fingers: [2, 4, 3, 3, 2, 2], name: "F#maj7", barre: 2),
        ChordData(fingers: [2, 4, 3, 3, 2, 2], name: "Gbmaj7", barre: 2),
        ChordData(fingers: [3, 2, 0, 0, 0, 2], name: "Gmaj7"),
        ChordData(fingers: [4, 6, 5, 5, 4, 4], name: "Abmaj7", barre: 4),

        // Minor Seventh
        ChordData(fingers: [-1, 0, 2, 0, 1, 0], name: "Am7", isDefault: true),
        ChordData(fingers: [-1, 1, 3, 1, 2, 1], name: "Bbm7", barre: 1),
        ChordData(fingers: [-1, 2, 4, 2, 3, 2], name: "Bm7", barre: 2, isDefault: true),
        ChordData(fingers: [-1, 3, 5, 3, 4, 3], name: "Cm7", barre: 3, isDefault: true),
        ChordData(fingers: [-1, 4, 6, 4, 5, 4], name: "C#m7", barre: 4),
        ChordData(fingers: [-1, 4, 6, 4, 5, 4], name: "Dbm7", barre: 4),
        ChordData(fingers: [-1, -1, 0, 2, 1, 1], name: "Dm7", isDefault: true),
        ChordData(fingers: [-1, -1, 1, 3, 2, 2], name: "Ebm7"),
        ChordData(fingers: [0, 2, 0, 0, 0, 0], name: "Em7", isDefault: true),
        ChordData(fingers: [1, 3, 1, 1, 1, 1], name: "Fm7", barre: 1, isDefault: true),
        ChordData(fingers: [2, 4, 2, 2, 2, 2], name: "F#m7", barre: 2),
        ChordData(fingers: [2, 4, 2, 2, 2, 2], name: "Gbm7", barre: 2),
        ChordData(fingers: [3, 5, 3, 3, 3, 3], name: "Gm7", barre: 3, isDefault: true),
        ChordData(fingers: [4, 6, 4, 4, 4, 4], name: "Abm7", barre: 4),

        // Suspended Chords
        ChordData(fingers: [-1, 0, 2, 2, 3, 0], name: "A Suspended 4"),
        ChordData(fingers: [-1, 2, 4, 4, 5, 2], name: "B Suspended 4", barre: 2),
        ChordData(fingers: [-1, 3, 3, 0, 1, 1], name: "C Suspended 4"),
        ChordData(fingers: [-1, -1, 0, 2, 3, 3], name: "D Suspended 4"),
        ChordData(fingers: [0, 2, 2, 2, 0, 0], name: "E Suspended 4"),
        ChordData(fingers: [1, 3, 3, 3, 1, 1], name: "F Suspended 4", barre: 1),
        ChordData(fingers: [3, 3, 0, 0, 1, 3], name: "G Suspended 4"),

        ChordData(fingers: [-1, 0, 2, 2, 0, 0], name: "A Suspended 2"),
        ChordData(fingers: [-1, 2, 4, 4, 2, 2], name: "B Suspended 2", barre: 2),
        ChordData(fingers: [-1, 3, 0, 0, 3, 3], name: "C Suspended 2"),
        ChordData(fingers: [-1, -1, 0, 2, 3, 0], name: "D Suspended 2"),
        ChordData(fingers: [0, 2, 2, 4, 0, 0], name: "E Suspended 2"),
        ChordData(fingers: [1, 3, 3, 0, 1, 1], name: "F Suspended 2", barre: 1),
        ChordData(fingers: [3, 0, 0, 0, 3, 3], name: "G Suspended 2"),

        // Power Chords
        ChordData(fingers: [-1, 0, 2, 2, -1, -1], name: "A Power Chord"),
        ChordData(fingers: [-1, 2, 4, 4, -1, -1], name: "B Power Chord"),
        ChordData(fingers: [-1, 3, 5, 5, -1, -1], name: "C Power Chord"),
        ChordData(fingers: [-1, -1, 0, 2, 3, -1], name: "D Power Chord"),
        ChordData(fingers: [0, 2, 2, -1, -1, -1], name: "E Power Chord"),
        ChordData(fingers: [1, 3, 3, -1, -1, -1], name: "F Power Chord"),
        ChordData(fingers: [3, 5, 5, -1, -1, -1], name: "G Power Chord"),

        // 6th Chords
        ChordData(fingers: [-1, 0, 2, 2, 2, 2], name: "A Sixth"),
        ChordData(fingers: [-1, 3, 2, 2, 1, 0], name: "C Sixth"),
        ChordData(fingers: [-1, -1, 0, 2, 0, 2], name: "D Sixth"),
        ChordData(fingers: [0, 2, 2, 1, 2, 0], name: "E Sixth"),
        ChordData(fingers: [1, 3, 3, 2, 3, 1], name: "F Sixth", barre: 1),
        ChordData(fingers: [3, 2, 0, 0, 0, 0], name: "G Sixth"),

        ChordData(fingers: [-1, 0, 2, 2, 1, 2], name: "A Minor 6"),
        ChordData(fingers: [-1, -1, 0, 2, 0, 1], name: "D Minor 6"),
        ChordData(fingers: [0, 2, 2, 0, 2, 0], name: "E Minor 6"),

        // Add9 Chords
        ChordData(fingers: [-1, 3, 2, 0, 3, 0], name: "C Add 9"),
        ChordData(fingers: [-1, -1, 0, 2, 3, 0], name: "D Add 9"),
        ChordData(fingers: [0, 2, 2, 1, 0, 2], name: "E Add 9"),
        ChordData(fingers: [3, 0, 0, 0, 0, 3], name: "G Add 9"),
        ChordData(fingers: [-1, 0, 2, 4, 2, 0], name: "A Add 9"),

        // Dominant 9th Chords
        ChordData(fingers: [-1, 0, 2, 4, 2, 3], name: "A Ninth"),
        ChordData(fingers: [-1, 3, 2, 3, 3, 3], name: "C Ninth"),
        ChordData(fingers: [-1, -1, 0, 2, 1, 0], name: "D Ninth"),
        ChordData(fingers: [0, 2, 0, 1, 0, 2], name: "E Ninth"),
        ChordData(fingers: [3, 2, 0, 2, 0, 1], name: "G Ninth"),

        // Major 9th Chords
        ChordData(fingers: [-1, 0, 2, 1, 0, 0], name: "A Major 9"),
        ChordData(fingers: [-1, 3, 2, 4, 3, 0], name: "C Major 9"),
        ChordData(fingers: [-1, -1, 0, 2, 2, 0], name: "D Major 9"),
        ChordData(fingers: [0, 2, 1, 1, 0, 2], name: "E Major 9"),
        ChordData(fingers: [3, 0, 0, 2, 0, 2], name: "G Major 9"),

        // Minor 9th Chords
        ChordData(fingers: [-1, 0, 2, 4, 1, 3], name: "A Minor 9"),
        ChordData(fingers: [-1, -1, 0, 2, 1, 0], name: "D Minor 9"),
        ChordData(fingers: [0, 2, 0, 0, 0, 2], name: "E Minor 9"),

        // Diminished
        ChordData(fingers: [-1, 0, 1, 2, 1, 2], name: "A Diminished"),
        ChordData(fingers: [-1, 2, 3, 4, 3, -1], name: "B Diminished"),
        ChordData(fingers: [-1, 3, 4, 2, 4, 2], name: "C Diminished"),
        ChordData(fingers: [-1, -1, 0, 1, 0, 1], name: "D Diminished"),
        ChordData(fingers: [-1, -1, 2, 3, 2, 3], name: "E Diminished"),
        ChordData(fingers: [-1, -1, 3, 4, 3, 4], name: "F Diminished"),
        ChordData(fingers: [-1, -1, 5, 6, 5, 6], name: "G Diminished"),

        // Diminished 7th
        ChordData(fingers: [-1, 0, 1, 2, 1, 2], name: "A Diminished 7"),
        ChordData(fingers: [-1, 2, 3, 1, 3, 1], name: "B Diminished 7"),
        ChordData(fingers: [-1, 3, 4, 2, 4, 2], name: "C Diminished 7"),
        ChordData(fingers: [-1, -1, 0, 1, 0, 1], name: "D Diminished 7"),
        ChordData(fingers: [-1, -1, 2, 3, 2, 3], name: "E Diminished 7"),

        // Half-Diminished (m7b5)
        ChordData(fingers: [-1, 0, 1, 0, 1, 0], name: "A Half-Diminished"),
        ChordData(fingers: [-1, 2, 3, 2, 3, 2], name: "B Half-Diminished"),
        ChordData(fingers: [-1, 3, 4, 3, 4, 3], name: "C Half-Diminished"),
        ChordData(fingers: [-1, -1, 0, 1, 1, 1], name: "D Half-Diminished"),
        ChordData(fingers: [0, 1, 0, 0, 0, 0], name: "E Half-Diminished"),

        // Augmented
        ChordData(fingers: [-1, 0, 3, 2, 2, 1], name: "A Augmented"),
        ChordData(fingers: [-1, 2, 1, 0, 0, 3], name: "B Augmented"),
        ChordData(fingers: [-1, 3, 2, 1, 1, 0], name: "C Augmented"),
        ChordData(fingers: [-1, -1, 0, 3, 3, 2], name: "D Augmented"),
        ChordData(fingers: [0, 3, 2, 1, 1, 0], name: "E Augmented"),
        ChordData(fingers: [-1, -1, 4, 3, 3, 2], name: "F Augmented"),
        ChordData(fingers: [3, 2, 1, 0, 0, 3], name: "G Augmented"),

        // Altered Dominants
        ChordData(fingers: [-1, 0, 3, 0, 2, 1], name: "A7 Sharp 5"),
        ChordData(fingers: [-1, 3, 2, 3, 1, 4], name: "C7 Sharp 5"),
        ChordData(fingers: [0, 3, 0, 1, 1, 0], name: "E7 Sharp 5"),

        ChordData(fingers: [-1, 0, 1, 0, 2, 0], name: "A7 Flat 5"),
        ChordData(fingers: [-1, 3, 4, 3, 5, 0], name: "C7 Flat 5"),
        ChordData(fingers: [0, 1, 0, 1, 3, 0], name: "E7 Flat 5"),

        ChordData(fingers: [-1, 0, 2, 0, 2, 3], name: "A7 Sharp 9"),
        ChordData(fingers: [0, 2, 0, 1, 3, 2], name: "E7 Sharp 9"),

        ChordData(fingers: [-1, 0, 2, 0, 2, 1], name: "A7 Flat 9"),
        ChordData(fingers: [0, 2, 0, 1, 3, 1], name: "E7 Flat 9"),

        // Slash Chords (chord with alternate bass note)
        ChordData(fingers: [3, 3, 2, 0, 1, 0], name: "C/G"),
        ChordData(fingers: [-1, 2, 2, 0, 1, 0], name: "C/B"),
        ChordData(fingers: [0, 3, 2, 0, 1, 0], name: "C/E"),
        ChordData(fingers: [2, -1, 0, 2, 3, 2], name: "D/F#"),
        ChordData(fingers: [-1, 0, 0, 2, 3, 2], name: "D/A"),
        ChordData(fingers: [-1, 2, 0, 0, 0, 3], name: "G/B"),
        ChordData(fingers: [-1, -1, 0, 0, 0, 3], name: "G/D"),
        ChordData(fingers: [3, 0, 2, 2, 1, 0], name: "Am/G"),
        ChordData(fingers: [2, 0, 2, 2, 1, 0], name: "Am/F#"),
        ChordData(fingers: [0, 0, 2, 2, 1, 0], name: "Am/E"),
        ChordData(fingers: [-1, -1, 0, 0, 0, 0], name: "Em/D"),
        ChordData(fingers: [-1, 2, 2, 0, 0, 0], name: "Em/B"),
        ChordData(fingers: [-1, 3, 3, 2, 1, 1], name: "F/C"),
        ChordData(fingers: [3, 3, 3, 2, 1, 1], name: "F/G", barre: 1),

        // Common Chord Variations & Alternative Voicings

        // G Voicings (descriptive names for special cases)
        ChordData(fingers: [3, 2, 0, 0, 0, -1], name: "G (no high e)"),
        ChordData(fingers: [3, 2, 0, 0, 0, 0], name: "G (open high e)"),
        ChordData(fingers: [-1, 2, 0, 0, 0, 3], name: "G (no low E)"),

        // Other alternate voicings with descriptive names
        ChordData(fingers: [-1, 3, 2, 0, 3, 3], name: "Cadd9"),  // Cadd9 fuller voicing (x32033)
        ChordData(fingers: [-1, -1, 0, 2, 3, 5], name: "Dm"),  // Dm with high F (xx0235)
        ChordData(fingers: [-1, 0, 2, 2, 1, 3], name: "Am"),  // Am with high C (x02213)
        ChordData(fingers: [0, 2, 2, 0, 0, 3], name: "Em"),  // Em with high G (022003)
        ChordData(fingers: [0, 2, 2, 1, 0, 4], name: "E"),  // E with high E (022104)
        ChordData(fingers: [-1, 0, 2, 2, 2, 5], name: "A"),  // A with high E (x02225)
        ChordData(fingers: [-1, 0, 2, 0, 2, 3], name: "A7"),  // A7 with high C# (x02023)
        ChordData(fingers: [3, 2, 0, 0, 0, 1], name: "G7"),  // G7 alternate voicing (320001)
        ChordData(fingers: [-1, 3, 3, 2, 1, 0], name: "F"),  // Easier F without barre (x33210)
        ChordData(fingers: [-1, -1, 3, 2, 1, 1], name: "F", barre: 1),  // Simplified F without low E (xx3211)
        ChordData(fingers: [-1, -1, 0, 4, 3, 2], name: "Bm"),  // Easier Bm without full barre (xx0432)

        // C Barre Variations (E-shape)
        ChordData(fingers: [-1, 3, 5, 5, 5, 3], name: "C (barre 3)", barre: 3),
        ChordData(fingers: [-1, 3, 5, 5, 5, -1], name: "C (barre alt)", barre: 3),

        // D Barre Variations (E-shape)
        ChordData(fingers: [-1, 5, 7, 7, 7, 5], name: "D (barre 5)", barre: 5),
        ChordData(fingers: [-1, 5, 7, 7, 7, -1], name: "D (barre alt)", barre: 5),

        // A Barre Variations (E-shape)
        ChordData(fingers: [5, 7, 7, 6, 5, 5], name: "A (barre 5)", barre: 5),

        // E Variations
        ChordData(fingers: [-1, 2, 2, 1, 0, 0], name: "E (no low E)"),

        // A Variations
        ChordData(fingers: [-1, 0, 2, 2, 2, -1], name: "A (no high e)"),

        // Minor Barre Variations
        ChordData(fingers: [5, 7, 7, 5, 5, 5], name: "Am (barre 5)", barre: 5),
        ChordData(fingers: [-1, 5, 7, 7, 6, 5], name: "Dm (barre 5)", barre: 5),
        ChordData(fingers: [7, 9, 9, 7, 7, 7], name: "Em (barre 7)", barre: 7),

        // 7th Chord Variations
        ChordData(fingers: [-1, 3, 5, 3, 5, 3], name: "C7 (barre 3)", barre: 3),
        ChordData(fingers: [-1, -1, 0, 2, 1, 3], name: "D7 (alt)"),
        ChordData(fingers: [0, 2, 2, 1, 3, 0], name: "E7 (alt)"),
        ChordData(fingers: [5, 7, 5, 6, 5, 5], name: "A7 (barre 5)", barre: 5),
        ChordData(fingers: [-1, 2, 4, 2, 4, 2], name: "B7 (alt)", barre: 2),

        // 9th Chord Variations
        ChordData(fingers: [-1, 3, 2, 3, 3, -1], name: "C9 (alt)"),
        ChordData(fingers: [-1, 5, 4, 5, 5, 0], name: "D9 (alt)"),
        ChordData(fingers: [-1, 2, 1, 2, 2, 2], name: "B9", barre: 2),
        ChordData(fingers: [1, 3, 1, 2, 1, 3], name: "F9", barre: 1),
        ChordData(fingers: [3, -1, 0, 0, 0, 1], name: "G9 (alt)"),

        // Major 7th Variations
        ChordData(fingers: [-1, 3, 5, 4, 5, 3], name: "Cmaj7 (alt)", barre: 3),
        ChordData(fingers: [-1, -1, 0, 6, 7, 5], name: "Dmaj7 (alt)"),
        ChordData(fingers: [0, 2, 1, 1, 0, -1], name: "Emaj7 (alt)"),
        ChordData(fingers: [3, 5, 4, 4, 3, 3], name: "Gmaj7 (alt)", barre: 3),
        ChordData(fingers: [-1, 0, 2, 1, 2, -1], name: "Amaj7 (alt)"),

        // Minor 7th Variations
        ChordData(fingers: [-1, 0, 2, 0, 1, 3], name: "Am7 (alt)"),
        ChordData(fingers: [-1, -1, 0, 2, 1, 1], name: "Dm7 (alt)", barre: 1),
        ChordData(fingers: [0, 2, 2, 0, 3, 0], name: "Em7 (alt)"),

        // Power Chord Variations (5th chords at different positions)
        ChordData(fingers: [-1, 3, 5, 5, -1, -1], name: "C5 (3rd fret)"),
        ChordData(fingers: [-1, 5, 7, 7, -1, -1], name: "D5 (5th fret)"),
        ChordData(fingers: [-1, 7, 9, 9, -1, -1], name: "E5 (7th fret)"),
        ChordData(fingers: [-1, 8, 10, 10, -1, -1], name: "F5 (8th fret)"),
        ChordData(fingers: [-1, 10, 12, 12, -1, -1], name: "G5 (10th fret)"),
        ChordData(fingers: [-1, 12, 14, 14, -1, -1], name: "A5 (12th fret)"),
    ]

    // MARK: - Fingerprint Parsing Functions

    /// Parse voicing notation like "G#320033" into base name and fingerprint
    /// - Parameter name: Chord name with optional fingerprint (e.g., "G#320033" or "G")
    /// - Returns: Tuple of (baseName, fingerprint) where fingerprint is nil if not present
    func parseVoicingNotation(_ name: String) -> (baseName: String, fingerprint: String?) {
        let components = name.split(separator: "#", maxSplits: 1)
        if components.count == 2 {
            return (String(components[0]), String(components[1]))
        }
        return (name, nil)
    }

    /// Convert fingerprint string to finger positions array
    /// - Parameter fp: Fingerprint string (e.g., "320033" or "X20033")
    /// - Returns: Array of finger positions, or nil if invalid
    func fingerprintToFingers(_ fp: String) -> [Int]? {
        var result: [Int] = []
        for char in fp {
            if char == "X" || char == "x" {
                result.append(-1)
            } else if let digit = Int(String(char)) {
                result.append(digit)
            } else {
                return nil // Invalid character
            }
        }
        return result.count == 6 ? result : nil
    }

    /// Convert finger positions array to fingerprint string
    /// - Parameter fingers: Array of 6 finger positions
    /// - Returns: Fingerprint string (e.g., "320033" or "X20033")
    func fingersToFingerprint(_ fingers: [Int]) -> String {
        return fingers.map { $0 == -1 ? "X" : "\($0)" }.joined()
    }

    // MARK: - Chord Lookup

    func findChord(_ name: String) -> ChordData? {
        let normalized = name.trimmingCharacters(in: .whitespaces)

        // 1. Parse voicing notation (e.g., "G#320033")
        let (baseName, fingerprint) = parseVoicingNotation(normalized)

        // 2. Check custom chords first with full name
        if let customChord = CustomChordLibrary.shared.findCustomChord(byDisplayName: normalized) {
            return customChord.asChordData
        }

        // 3. If fingerprint specified, find exact match
        if let fp = fingerprint, let fingers = fingerprintToFingers(fp) {
            return chords.first(where: { $0.name == baseName && $0.fingers == fingers })
        }

        // 4. Parse for transposition notation (e.g., "Am@7")
        let (baseChordName, transposition) = parseChordNotation(baseName)

        // 5. Check custom chords with base name (for transposition)
        if let customChord = CustomChordLibrary.shared.findCustomChord(byDisplayName: baseChordName) {
            if let targetFret = transposition {
                return transposeChord(customChord.asChordData, toFret: targetFret)
            }
            return customChord.asChordData
        }

        // 6. Find base chord (prefer default)
        guard let baseChord = findBaseChord(baseChordName) else {
            return nil
        }

        // 7. Apply transposition if specified
        if let targetFret = transposition {
            return transposeChord(baseChord, toFret: targetFret)
        }

        return baseChord
    }
    
    var allChordNames: [String] {
        // Get unique chord names from array
        let uniqueNames = Set(chords.map { $0.name })
        return Array(uniqueNames).sorted()
    }

    // Check if a chord name is custom
    func isCustomChord(_ name: String) -> Bool {
        CustomChordLibrary.shared.isCustomChordName(name)
    }

    // Get all chord names (library + custom)
    var allChordNamesIncludingCustom: [String] {
        let libraryChords = Set(chords.map { $0.name })
        let customChordNames = CustomChordLibrary.shared.customChords.map { $0.displayName }
        return (Array(libraryChords) + customChordNames).sorted()
    }
    
    // Find chords that match given finger positions
    func findChordsMatching(fingers: [Int], barre: Int? = nil) -> [(String, ChordData)] {
        var matches: [(String, ChordData)] = []

        for chordData in chords {
            if matchesFingerPositions(userFingers: fingers, userBarre: barre, chordData: chordData) {
                matches.append((chordData.name, chordData))
            }
        }

        // Sort by exact matches first (same barre), then by name
        return matches.sorted { first, second in
            let firstExactBarre = first.1.barre == barre
            let secondExactBarre = second.1.barre == barre

            if firstExactBarre != secondExactBarre {
                return firstExactBarre
            }
            return first.0 < second.0
        }
    }
    
    private func matchesFingerPositions(userFingers: [Int], userBarre: Int?, chordData: ChordData) -> Bool {
        // Check if finger positions match exactly
        guard userFingers.count == 6 && chordData.fingers.count == 6 else { return false }
        
        // Compare finger positions element by element
        for i in 0..<6 {
            if userFingers[i] != chordData.fingers[i] {
                return false
            }
        }
        
        // Barre matching logic:
        // - If user specified barre, chord must have matching barre OR no barre (user might not have indicated barre)
        // - If user didn't specify barre, match chords with or without barre
        if let userBarre = userBarre {
            // User specified a barre - prefer exact matches but also allow chords without barre
            // (in case user didn't indicate barre but finger positions match)
            if let chordBarre = chordData.barre {
                return userBarre == chordBarre
            }
            // Chord has no barre - still match if finger positions are exact
            return true
        } else {
            // User didn't specify barre - match regardless of barre
            return true
        }
    }

    // MARK: - Chord Transposition

    /// Parse chord name with optional transposition notation (e.g., "Am@7")
    /// Returns (baseChordName, transpositionFret) or (chordName, nil) if no transposition
    func parseChordNotation(_ name: String) -> (baseChord: String, transposition: Int?) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)

        // Check for @ notation
        let components = trimmed.split(separator: "@", maxSplits: 1)

        if components.count == 2 {
            let baseChord = String(components[0]).trimmingCharacters(in: .whitespaces)
            let transpositionStr = String(components[1]).trimmingCharacters(in: .whitespaces)

            if let transposition = Int(transpositionStr) {
                return (baseChord, transposition)
            }
        }

        // No transposition notation
        return (trimmed, nil)
    }

    /// Transpose a chord to a specific fret position
    /// Returns nil if transposition is invalid (open strings, out of range, etc.)
    func transposeChord(_ chordData: ChordData, toFret targetFret: Int) -> ChordData? {
        // Validate target fret
        guard targetFret >= 1 && targetFret <= 15 else {
            return nil
        }

        // Cannot transpose chords with open strings
        if chordData.fingers.contains(0) {
            return nil
        }

        // Find the minimum fretted position (for relative transposition)
        let frettedPositions = chordData.fingers.filter { $0 > 0 }
        guard let minFret = frettedPositions.min() else {
            return nil  // No fretted notes
        }

        // Calculate transposition amount
        let transposition = targetFret - minFret

        // Apply transposition
        let transposedFingers = chordData.fingers.map { fret in
            if fret == -1 {
                return -1  // Muted strings stay muted
            } else if fret > 0 {
                let newFret = fret + transposition
                if newFret < 1 || newFret > 15 {
                    return -2  // Invalid marker
                }
                return newFret
            } else {
                return -2  // Open strings cannot be transposed
            }
        }

        // Check validity
        if transposedFingers.contains(-2) {
            return nil
        }

        // Transpose barre if present
        let transposedBarre = chordData.barre.map { $0 + transposition }
        if let barre = transposedBarre, (barre < 1 || barre > 15) {
            return nil
        }

        return ChordData(
            fingers: transposedFingers,
            name: chordData.name,
            barre: transposedBarre
        )
    }

    /// Check if a chord can be transposed (no open strings)
    func canTranspose(_ chordData: ChordData) -> Bool {
        return !chordData.fingers.contains(0)
    }

    /// Validate chord name with helpful error messages
    func validateChordName(_ name: String) -> (isValid: Bool, errorMessage: String?) {
        let (baseChordName, transposition) = parseChordNotation(name)

        // Find base chord
        guard let baseChord = findBaseChord(baseChordName) else {
            return (false, "Chord '\(baseChordName)' not found")
        }

        // If no transposition, it's valid
        guard let targetFret = transposition else {
            return (true, nil)
        }

        // Validate transposition
        if targetFret < 1 || targetFret > 15 {
            return (false, "Fret position must be between 1 and 15")
        }

        if baseChord.fingers.contains(0) {
            return (false, "Cannot transpose '\(baseChordName)' - it has open strings. Try a barre chord version.")
        }

        if transposeChord(baseChord, toFret: targetFret) == nil {
            return (false, "Transposition to fret \(targetFret) is out of range")
        }

        return (true, nil)
    }

    /// Find base chord without transposition, preferring default voicings
    private func findBaseChord(_ name: String) -> ChordData? {
        // Check custom
        if let custom = CustomChordLibrary.shared.findCustomChord(byDisplayName: name) {
            return custom.asChordData
        }

        // Find all matches
        let matches = chords.filter { $0.name == name }

        if !matches.isEmpty {
            // Prefer default if exists
            if let defaultMatch = matches.first(where: { $0.isDefault }) {
                return defaultMatch
            }
            // Fall back to first match
            return matches.first
        }

        // Try variations - both removing and adding suffixes
        let variations = [
            // Remove suffixes
            name.replacingOccurrences(of: "min", with: "m"),
            name.replacingOccurrences(of: "maj", with: ""),
            name.replacingOccurrences(of: "M", with: ""),
            name.replacingOccurrences(of: "minor", with: "m"),
            name.replacingOccurrences(of: "major", with: ""),
            // Add suffixes
            name + " Major",
            name + " Minor",
            name + "m",
            name.replacingOccurrences(of: "m", with: " Minor"),
            name.replacingOccurrences(of: "maj", with: " Major")
        ]

        for variation in variations {
            let variationMatches = chords.filter { $0.name == variation }
            if !variationMatches.isEmpty {
                // Prefer default if exists
                if let defaultMatch = variationMatches.first(where: { $0.isDefault }) {
                    return defaultMatch
                }
                // Fall back to first match
                return variationMatches.first
            }
        }

        return nil
    }

    /// Find all voicings for a chord name, sorted with defaults first
    /// - Parameter baseName: The base chord name (e.g., "G Major" or "Am7" or just "G")
    /// - Returns: Array of all voicings sorted by preference (defaults first, then by complexity)
    func findAllVoicings(for baseName: String) -> [ChordData] {
        // First, resolve the base name to the actual chord name in the library
        // This handles cases where user types "G" but library has "G Major"
        guard let resolvedChord = findBaseChord(baseName) else {
            return []
        }

        // Now find all chords with the same name as the resolved chord
        let matches = chords.filter { $0.name == resolvedChord.name }

        return matches.sorted { a, b in
            // Defaults first
            if a.isDefault != b.isDefault {
                return a.isDefault
            }
            // Then by complexity (fewer frets = simpler)
            let aComplexity = a.fingers.filter { $0 > 0 }.reduce(0, +)
            let bComplexity = b.fingers.filter { $0 > 0 }.reduce(0, +)
            return aComplexity < bComplexity
        }
    }
}

// MARK: - ChordData Extensions

extension ChordData {
    /// Calculate optimal fret range for displaying this chord
    var fretRange: (startFret: Int, numFrets: Int) {
        let playedFrets = fingers.filter { $0 > 0 && $0 <= 15 }

        guard !playedFrets.isEmpty else {
            return (startFret: 0, numFrets: 5)
        }

        let minFret = playedFrets.min()!
        let maxFret = playedFrets.max()!

        // For chords with open strings and low frets, or very low frets in general,
        // always show from the nut
        let hasOpenStrings = fingers.contains(0)
        let shouldStartFromNut = minFret <= 3 || (hasOpenStrings && minFret <= 4)

        let startFret = shouldStartFromNut ? 0 : minFret

        // Calculate how many frets we need to show to include all fretted positions
        let span = maxFret - startFret + 1

        // Always show exactly 5 frets (or more if needed to show all positions)
        let numFrets = max(5, span)

        return (startFret: startFret, numFrets: numFrets)
    }

    /// Position marker text (e.g., "7fr" or nil if starting at fret 0)
    var positionMarker: String? {
        let range = fretRange
        return range.startFret > 0 ? "\(range.startFret)fr" : nil
    }
}
