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
    
    init(fingers: [Int], name: String, barre: Int? = nil) {
        self.fingers = fingers
        self.name = name
        self.barre = barre
    }
}

class ChordLibrary {
    static let shared = ChordLibrary()
    
    private let chords: [String: ChordData] = [
        // Major Chords
        "C": ChordData(fingers: [-1, 3, 2, 0, 1, 0], name: "C Major"),
        "C#": ChordData(fingers: [-1, 4, 6, 6, 6, 4], name: "C# Major", barre: 4),
        "Db": ChordData(fingers: [-1, 4, 6, 6, 6, 4], name: "Db Major", barre: 4),
        "D": ChordData(fingers: [-1, -1, 0, 2, 3, 2], name: "D Major"),
        "D#": ChordData(fingers: [-1, -1, 1, 3, 4, 3], name: "D# Major"),
        "Eb": ChordData(fingers: [-1, -1, 1, 3, 4, 3], name: "Eb Major"),
        "E": ChordData(fingers: [0, 2, 2, 1, 0, 0], name: "E Major"),
        "F": ChordData(fingers: [1, 3, 3, 2, 1, 1], name: "F Major", barre: 1),
        "F#": ChordData(fingers: [2, 4, 4, 3, 2, 2], name: "F# Major", barre: 2),
        "Gb": ChordData(fingers: [2, 4, 4, 3, 2, 2], name: "Gb Major", barre: 2),
        "G": ChordData(fingers: [3, 2, 0, 0, 0, 3], name: "G Major"),
        "G#": ChordData(fingers: [4, 6, 6, 5, 4, 4], name: "G# Major", barre: 4),
        "Ab": ChordData(fingers: [4, 6, 6, 5, 4, 4], name: "Ab Major", barre: 4),
        "A": ChordData(fingers: [-1, 0, 2, 2, 2, 0], name: "A Major"),
        "A#": ChordData(fingers: [-1, 1, 3, 3, 3, 1], name: "A# Major", barre: 1),
        "Bb": ChordData(fingers: [-1, 1, 3, 3, 3, 1], name: "Bb Major", barre: 1),
        "B": ChordData(fingers: [-1, 2, 4, 4, 4, 2], name: "B Major", barre: 2),

        // Minor Chords
        "Am": ChordData(fingers: [-1, 0, 2, 2, 1, 0], name: "A Minor"),
        "A#m": ChordData(fingers: [-1, 1, 3, 3, 2, 1], name: "A# Minor", barre: 1),
        "Bbm": ChordData(fingers: [-1, 1, 3, 3, 2, 1], name: "Bb Minor", barre: 1),
        "Bm": ChordData(fingers: [-1, 2, 4, 4, 3, 2], name: "B Minor", barre: 2),
        "Cm": ChordData(fingers: [-1, 3, 5, 5, 4, 3], name: "C Minor", barre: 3),
        "C#m": ChordData(fingers: [-1, 4, 6, 6, 5, 4], name: "C# Minor", barre: 4),
        "Dbm": ChordData(fingers: [-1, 4, 6, 6, 5, 4], name: "Db Minor", barre: 4),
        "Dm": ChordData(fingers: [-1, -1, 0, 2, 3, 1], name: "D Minor"),
        "D#m": ChordData(fingers: [-1, -1, 1, 3, 4, 2], name: "D# Minor"),
        "Ebm": ChordData(fingers: [-1, -1, 1, 3, 4, 2], name: "Eb Minor"),
        "Em": ChordData(fingers: [0, 2, 2, 0, 0, 0], name: "E Minor"),
        "Fm": ChordData(fingers: [1, 3, 3, 1, 1, 1], name: "F Minor", barre: 1),
        "F#m": ChordData(fingers: [2, 4, 4, 2, 2, 2], name: "F# Minor", barre: 2),
        "Gbm": ChordData(fingers: [2, 4, 4, 2, 2, 2], name: "Gb Minor", barre: 2),
        "Gm": ChordData(fingers: [3, 5, 5, 3, 3, 3], name: "G Minor", barre: 3),
        "G#m": ChordData(fingers: [4, 6, 6, 4, 4, 4], name: "G# Minor", barre: 4),
        "Abm": ChordData(fingers: [4, 6, 6, 4, 4, 4], name: "Ab Minor", barre: 4),

        // Seventh Chords
        "A7": ChordData(fingers: [-1, 0, 2, 0, 2, 0], name: "A Seventh"),
        "Bb7": ChordData(fingers: [-1, 1, 3, 1, 3, 1], name: "Bb Seventh", barre: 1),
        "B7": ChordData(fingers: [-1, 2, 1, 2, 0, 2], name: "B Seventh"),
        "C7": ChordData(fingers: [-1, 3, 2, 3, 1, 0], name: "C Seventh"),
        "C#7": ChordData(fingers: [-1, 4, 6, 4, 6, 4], name: "C# Seventh", barre: 4),
        "Db7": ChordData(fingers: [-1, 4, 6, 4, 6, 4], name: "Db Seventh", barre: 4),
        "D7": ChordData(fingers: [-1, -1, 0, 2, 1, 2], name: "D Seventh"),
        "Eb7": ChordData(fingers: [-1, -1, 1, 3, 2, 3], name: "Eb Seventh"),
        "E7": ChordData(fingers: [0, 2, 0, 1, 0, 0], name: "E Seventh"),
        "F7": ChordData(fingers: [1, 3, 1, 2, 1, 1], name: "F Seventh", barre: 1),
        "F#7": ChordData(fingers: [2, 4, 2, 3, 2, 2], name: "F# Seventh", barre: 2),
        "Gb7": ChordData(fingers: [2, 4, 2, 3, 2, 2], name: "Gb Seventh", barre: 2),
        "G7": ChordData(fingers: [3, 2, 0, 0, 0, 1], name: "G Seventh"),
        "Ab7": ChordData(fingers: [4, 6, 4, 5, 4, 4], name: "Ab Seventh", barre: 4),

        // Major Seventh
        "Amaj7": ChordData(fingers: [-1, 0, 2, 1, 2, 0], name: "A Major 7"),
        "Bbmaj7": ChordData(fingers: [-1, 1, 3, 2, 3, 1], name: "Bb Major 7", barre: 1),
        "Bmaj7": ChordData(fingers: [-1, 2, 4, 3, 4, 2], name: "B Major 7", barre: 2),
        "Cmaj7": ChordData(fingers: [-1, 3, 2, 0, 0, 0], name: "C Major 7"),
        "C#maj7": ChordData(fingers: [-1, 4, 6, 5, 6, 4], name: "C# Major 7", barre: 4),
        "Dbmaj7": ChordData(fingers: [-1, 4, 6, 5, 6, 4], name: "Db Major 7", barre: 4),
        "Dmaj7": ChordData(fingers: [-1, -1, 0, 2, 2, 2], name: "D Major 7"),
        "Ebmaj7": ChordData(fingers: [-1, -1, 1, 3, 3, 3], name: "Eb Major 7"),
        "Emaj7": ChordData(fingers: [0, 2, 1, 1, 0, 0], name: "E Major 7"),
        "Fmaj7": ChordData(fingers: [1, 3, 2, 2, 1, 1], name: "F Major 7", barre: 1),
        "F#maj7": ChordData(fingers: [2, 4, 3, 3, 2, 2], name: "F# Major 7", barre: 2),
        "Gbmaj7": ChordData(fingers: [2, 4, 3, 3, 2, 2], name: "Gb Major 7", barre: 2),
        "Gmaj7": ChordData(fingers: [3, 2, 0, 0, 0, 2], name: "G Major 7"),
        "Abmaj7": ChordData(fingers: [4, 6, 5, 5, 4, 4], name: "Ab Major 7", barre: 4),

        // Minor Seventh
        "Am7": ChordData(fingers: [-1, 0, 2, 0, 1, 0], name: "A Minor 7"),
        "Bbm7": ChordData(fingers: [-1, 1, 3, 1, 2, 1], name: "Bb Minor 7", barre: 1),
        "Bm7": ChordData(fingers: [-1, 2, 4, 2, 3, 2], name: "B Minor 7", barre: 2),
        "Cm7": ChordData(fingers: [-1, 3, 5, 3, 4, 3], name: "C Minor 7", barre: 3),
        "C#m7": ChordData(fingers: [-1, 4, 6, 4, 5, 4], name: "C# Minor 7", barre: 4),
        "Dbm7": ChordData(fingers: [-1, 4, 6, 4, 5, 4], name: "Db Minor 7", barre: 4),
        "Dm7": ChordData(fingers: [-1, -1, 0, 2, 1, 1], name: "D Minor 7"),
        "Ebm7": ChordData(fingers: [-1, -1, 1, 3, 2, 2], name: "Eb Minor 7"),
        "Em7": ChordData(fingers: [0, 2, 0, 0, 0, 0], name: "E Minor 7"),
        "Fm7": ChordData(fingers: [1, 3, 1, 1, 1, 1], name: "F Minor 7", barre: 1),
        "F#m7": ChordData(fingers: [2, 4, 2, 2, 2, 2], name: "F# Minor 7", barre: 2),
        "Gbm7": ChordData(fingers: [2, 4, 2, 2, 2, 2], name: "Gb Minor 7", barre: 2),
        "Gm7": ChordData(fingers: [3, 5, 3, 3, 3, 3], name: "G Minor 7", barre: 3),
        "Abm7": ChordData(fingers: [4, 6, 4, 4, 4, 4], name: "Ab Minor 7", barre: 4),

        // Suspended Chords
        "Asus4": ChordData(fingers: [-1, 0, 2, 2, 3, 0], name: "A Suspended 4"),
        "Bsus4": ChordData(fingers: [-1, 2, 4, 4, 5, 2], name: "B Suspended 4", barre: 2),
        "Csus4": ChordData(fingers: [-1, 3, 3, 0, 1, 1], name: "C Suspended 4"),
        "Dsus4": ChordData(fingers: [-1, -1, 0, 2, 3, 3], name: "D Suspended 4"),
        "Esus4": ChordData(fingers: [0, 2, 2, 2, 0, 0], name: "E Suspended 4"),
        "Fsus4": ChordData(fingers: [1, 3, 3, 3, 1, 1], name: "F Suspended 4", barre: 1),
        "Gsus4": ChordData(fingers: [3, 3, 0, 0, 1, 3], name: "G Suspended 4"),

        "Asus2": ChordData(fingers: [-1, 0, 2, 2, 0, 0], name: "A Suspended 2"),
        "Bsus2": ChordData(fingers: [-1, 2, 4, 4, 2, 2], name: "B Suspended 2", barre: 2),
        "Csus2": ChordData(fingers: [-1, 3, 0, 0, 3, 3], name: "C Suspended 2"),
        "Dsus2": ChordData(fingers: [-1, -1, 0, 2, 3, 0], name: "D Suspended 2"),
        "Esus2": ChordData(fingers: [0, 2, 2, 4, 0, 0], name: "E Suspended 2"),
        "Fsus2": ChordData(fingers: [1, 3, 3, 0, 1, 1], name: "F Suspended 2", barre: 1),
        "Gsus2": ChordData(fingers: [3, 0, 0, 0, 3, 3], name: "G Suspended 2"),

        // Power Chords
        "A5": ChordData(fingers: [-1, 0, 2, 2, -1, -1], name: "A Power Chord"),
        "B5": ChordData(fingers: [-1, 2, 4, 4, -1, -1], name: "B Power Chord"),
        "C5": ChordData(fingers: [-1, 3, 5, 5, -1, -1], name: "C Power Chord"),
        "D5": ChordData(fingers: [-1, -1, 0, 2, 3, -1], name: "D Power Chord"),
        "E5": ChordData(fingers: [0, 2, 2, -1, -1, -1], name: "E Power Chord"),
        "F5": ChordData(fingers: [1, 3, 3, -1, -1, -1], name: "F Power Chord"),
        "G5": ChordData(fingers: [3, 5, 5, -1, -1, -1], name: "G Power Chord"),

        // 6th Chords
        "A6": ChordData(fingers: [-1, 0, 2, 2, 2, 2], name: "A Sixth"),
        "C6": ChordData(fingers: [-1, 3, 2, 2, 1, 0], name: "C Sixth"),
        "D6": ChordData(fingers: [-1, -1, 0, 2, 0, 2], name: "D Sixth"),
        "E6": ChordData(fingers: [0, 2, 2, 1, 2, 0], name: "E Sixth"),
        "F6": ChordData(fingers: [1, 3, 3, 2, 3, 1], name: "F Sixth", barre: 1),
        "G6": ChordData(fingers: [3, 2, 0, 0, 0, 0], name: "G Sixth"),

        "Am6": ChordData(fingers: [-1, 0, 2, 2, 1, 2], name: "A Minor 6"),
        "Dm6": ChordData(fingers: [-1, -1, 0, 2, 0, 1], name: "D Minor 6"),
        "Em6": ChordData(fingers: [0, 2, 2, 0, 2, 0], name: "E Minor 6"),

        // Add9 Chords
        "Cadd9": ChordData(fingers: [-1, 3, 2, 0, 3, 0], name: "C Add 9"),
        "Dadd9": ChordData(fingers: [-1, -1, 0, 2, 3, 0], name: "D Add 9"),
        "Eadd9": ChordData(fingers: [0, 2, 2, 1, 0, 2], name: "E Add 9"),
        "Gadd9": ChordData(fingers: [3, 0, 0, 0, 0, 3], name: "G Add 9"),
        "Aadd9": ChordData(fingers: [-1, 0, 2, 4, 2, 0], name: "A Add 9"),

        // Dominant 9th Chords
        "A9": ChordData(fingers: [-1, 0, 2, 4, 2, 3], name: "A Ninth"),
        "C9": ChordData(fingers: [-1, 3, 2, 3, 3, 3], name: "C Ninth"),
        "D9": ChordData(fingers: [-1, -1, 0, 2, 1, 0], name: "D Ninth"),
        "E9": ChordData(fingers: [0, 2, 0, 1, 0, 2], name: "E Ninth"),
        "G9": ChordData(fingers: [3, 2, 0, 2, 0, 1], name: "G Ninth"),

        // Major 9th Chords
        "Amaj9": ChordData(fingers: [-1, 0, 2, 1, 0, 0], name: "A Major 9"),
        "Cmaj9": ChordData(fingers: [-1, 3, 2, 4, 3, 0], name: "C Major 9"),
        "Dmaj9": ChordData(fingers: [-1, -1, 0, 2, 2, 0], name: "D Major 9"),
        "Emaj9": ChordData(fingers: [0, 2, 1, 1, 0, 2], name: "E Major 9"),
        "Gmaj9": ChordData(fingers: [3, 0, 0, 2, 0, 2], name: "G Major 9"),

        // Minor 9th Chords
        "Am9": ChordData(fingers: [-1, 0, 2, 4, 1, 3], name: "A Minor 9"),
        "Dm9": ChordData(fingers: [-1, -1, 0, 2, 1, 0], name: "D Minor 9"),
        "Em9": ChordData(fingers: [0, 2, 0, 0, 0, 2], name: "E Minor 9"),

        // Diminished
        "Adim": ChordData(fingers: [-1, 0, 1, 2, 1, 2], name: "A Diminished"),
        "Bdim": ChordData(fingers: [-1, 2, 3, 4, 3, -1], name: "B Diminished"),
        "Cdim": ChordData(fingers: [-1, 3, 4, 2, 4, 2], name: "C Diminished"),
        "Ddim": ChordData(fingers: [-1, -1, 0, 1, 0, 1], name: "D Diminished"),
        "Edim": ChordData(fingers: [-1, -1, 2, 3, 2, 3], name: "E Diminished"),
        "Fdim": ChordData(fingers: [-1, -1, 3, 4, 3, 4], name: "F Diminished"),
        "Gdim": ChordData(fingers: [-1, -1, 5, 6, 5, 6], name: "G Diminished"),

        // Diminished 7th
        "Adim7": ChordData(fingers: [-1, 0, 1, 2, 1, 2], name: "A Diminished 7"),
        "Bdim7": ChordData(fingers: [-1, 2, 3, 1, 3, 1], name: "B Diminished 7"),
        "Cdim7": ChordData(fingers: [-1, 3, 4, 2, 4, 2], name: "C Diminished 7"),
        "Ddim7": ChordData(fingers: [-1, -1, 0, 1, 0, 1], name: "D Diminished 7"),
        "Edim7": ChordData(fingers: [-1, -1, 2, 3, 2, 3], name: "E Diminished 7"),

        // Half-Diminished (m7b5)
        "Am7b5": ChordData(fingers: [-1, 0, 1, 0, 1, 0], name: "A Half-Diminished"),
        "Bm7b5": ChordData(fingers: [-1, 2, 3, 2, 3, 2], name: "B Half-Diminished"),
        "Cm7b5": ChordData(fingers: [-1, 3, 4, 3, 4, 3], name: "C Half-Diminished"),
        "Dm7b5": ChordData(fingers: [-1, -1, 0, 1, 1, 1], name: "D Half-Diminished"),
        "Em7b5": ChordData(fingers: [0, 1, 0, 0, 0, 0], name: "E Half-Diminished"),

        // Augmented
        "Aaug": ChordData(fingers: [-1, 0, 3, 2, 2, 1], name: "A Augmented"),
        "Baug": ChordData(fingers: [-1, 2, 1, 0, 0, 3], name: "B Augmented"),
        "Caug": ChordData(fingers: [-1, 3, 2, 1, 1, 0], name: "C Augmented"),
        "Daug": ChordData(fingers: [-1, -1, 0, 3, 3, 2], name: "D Augmented"),
        "Eaug": ChordData(fingers: [0, 3, 2, 1, 1, 0], name: "E Augmented"),
        "Faug": ChordData(fingers: [-1, -1, 4, 3, 3, 2], name: "F Augmented"),
        "Gaug": ChordData(fingers: [3, 2, 1, 0, 0, 3], name: "G Augmented"),

        // Altered Dominants
        "A7#5": ChordData(fingers: [-1, 0, 3, 0, 2, 1], name: "A7 Sharp 5"),
        "C7#5": ChordData(fingers: [-1, 3, 2, 3, 1, 4], name: "C7 Sharp 5"),
        "E7#5": ChordData(fingers: [0, 3, 0, 1, 1, 0], name: "E7 Sharp 5"),

        "A7b5": ChordData(fingers: [-1, 0, 1, 0, 2, 0], name: "A7 Flat 5"),
        "C7b5": ChordData(fingers: [-1, 3, 4, 3, 5, 0], name: "C7 Flat 5"),
        "E7b5": ChordData(fingers: [0, 1, 0, 1, 3, 0], name: "E7 Flat 5"),

        "A7#9": ChordData(fingers: [-1, 0, 2, 0, 2, 3], name: "A7 Sharp 9"),
        "E7#9": ChordData(fingers: [0, 2, 0, 1, 3, 2], name: "E7 Sharp 9"),

        "A7b9": ChordData(fingers: [-1, 0, 2, 0, 2, 1], name: "A7 Flat 9"),
        "E7b9": ChordData(fingers: [0, 2, 0, 1, 3, 1], name: "E7 Flat 9"),

        // Slash Chords (chord with alternate bass note)
        "C/G": ChordData(fingers: [3, 3, 2, 0, 1, 0], name: "C/G"),
        "C/B": ChordData(fingers: [-1, 2, 2, 0, 1, 0], name: "C/B"),
        "C/E": ChordData(fingers: [0, 3, 2, 0, 1, 0], name: "C/E"),
        "D/F#": ChordData(fingers: [2, -1, 0, 2, 3, 2], name: "D/F#"),
        "D/A": ChordData(fingers: [-1, 0, 0, 2, 3, 2], name: "D/A"),
        "G/B": ChordData(fingers: [-1, 2, 0, 0, 0, 3], name: "G/B"),
        "G/D": ChordData(fingers: [-1, -1, 0, 0, 0, 3], name: "G/D"),
        "Am/G": ChordData(fingers: [3, 0, 2, 2, 1, 0], name: "Am/G"),
        "Am/F#": ChordData(fingers: [2, 0, 2, 2, 1, 0], name: "Am/F#"),
        "Am/E": ChordData(fingers: [0, 0, 2, 2, 1, 0], name: "Am/E"),
        "Em/D": ChordData(fingers: [-1, -1, 0, 0, 0, 0], name: "Em/D"),
        "Em/B": ChordData(fingers: [-1, 2, 2, 0, 0, 0], name: "Em/B"),
        "F/C": ChordData(fingers: [-1, 3, 3, 2, 1, 1], name: "F/C"),
        "F/G": ChordData(fingers: [3, 3, 3, 2, 1, 1], name: "F/G", barre: 1),
    ]
    
    func findChord(_ name: String) -> ChordData? {
        let normalized = name.trimmingCharacters(in: .whitespaces)

        // Parse for transposition notation (e.g., "Am@7")
        let (baseChordName, transposition) = parseChordNotation(normalized)

        // 1. Check custom chords first with full name (literal @ names have priority)
        // This allows custom chords like "Bm@7" to override transposition
        if let customChord = CustomChordLibrary.shared.findCustomChord(byDisplayName: normalized) {
            return customChord.asChordData
        }

        // 2. Find base chord
        guard let baseChord = findBaseChord(baseChordName) else {
            return nil
        }

        // 3. Apply transposition if specified
        if let targetFret = transposition {
            return transposeChord(baseChord, toFret: targetFret)
        }

        return baseChord
    }
    
    var allChordNames: [String] {
        Array(chords.keys).sorted()
    }

    // Check if a chord name is custom
    func isCustomChord(_ name: String) -> Bool {
        CustomChordLibrary.shared.isCustomChordName(name)
    }

    // Get all chord names (library + custom)
    var allChordNamesIncludingCustom: [String] {
        let libraryChords = Array(chords.keys)
        let customChordNames = CustomChordLibrary.shared.customChords.map { $0.displayName }
        return (libraryChords + customChordNames).sorted()
    }
    
    // Find chords that match given finger positions
    func findChordsMatching(fingers: [Int], barre: Int? = nil) -> [(String, ChordData)] {
        var matches: [(String, ChordData)] = []
        
        for (name, chordData) in chords {
            if matchesFingerPositions(userFingers: fingers, userBarre: barre, chordData: chordData) {
                matches.append((name, chordData))
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

    /// Find base chord without transposition
    private func findBaseChord(_ name: String) -> ChordData? {
        // Check custom
        if let custom = CustomChordLibrary.shared.findCustomChord(byDisplayName: name) {
            return custom.asChordData
        }

        // Check standard
        if let standard = chords[name] {
            return standard
        }

        // Try variations
        let variations = [
            name.replacingOccurrences(of: "min", with: "m"),
            name.replacingOccurrences(of: "maj", with: ""),
            name.replacingOccurrences(of: "M", with: ""),
            name.replacingOccurrences(of: "minor", with: "m"),
            name.replacingOccurrences(of: "major", with: "")
        ]

        for variation in variations {
            if let chord = chords[variation] {
                return chord
            }
        }

        return nil
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
