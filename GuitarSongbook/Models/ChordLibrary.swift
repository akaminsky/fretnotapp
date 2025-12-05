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
        "D": ChordData(fingers: [-1, -1, 0, 2, 3, 2], name: "D Major"),
        "E": ChordData(fingers: [0, 2, 2, 1, 0, 0], name: "E Major"),
        "F": ChordData(fingers: [1, 3, 3, 2, 1, 1], name: "F Major", barre: 1),
        "G": ChordData(fingers: [3, 2, 0, 0, 0, 3], name: "G Major"),
        "A": ChordData(fingers: [-1, 0, 2, 2, 2, 0], name: "A Major"),
        "B": ChordData(fingers: [-1, 2, 4, 4, 4, 2], name: "B Major", barre: 2),
        
        // Minor Chords
        "Am": ChordData(fingers: [-1, 0, 2, 2, 1, 0], name: "A Minor"),
        "Bm": ChordData(fingers: [-1, 2, 4, 4, 3, 2], name: "B Minor", barre: 2),
        "Cm": ChordData(fingers: [-1, 3, 5, 5, 4, 3], name: "C Minor", barre: 3),
        "Dm": ChordData(fingers: [-1, -1, 0, 2, 3, 1], name: "D Minor"),
        "Em": ChordData(fingers: [0, 2, 2, 0, 0, 0], name: "E Minor"),
        "Fm": ChordData(fingers: [1, 3, 3, 1, 1, 1], name: "F Minor", barre: 1),
        "Gm": ChordData(fingers: [3, 5, 5, 3, 3, 3], name: "G Minor", barre: 3),
        
        // Seventh Chords
        "A7": ChordData(fingers: [-1, 0, 2, 0, 2, 0], name: "A Seventh"),
        "B7": ChordData(fingers: [-1, 2, 1, 2, 0, 2], name: "B Seventh"),
        "C7": ChordData(fingers: [-1, 3, 2, 3, 1, 0], name: "C Seventh"),
        "D7": ChordData(fingers: [-1, -1, 0, 2, 1, 2], name: "D Seventh"),
        "E7": ChordData(fingers: [0, 2, 0, 1, 0, 0], name: "E Seventh"),
        "F7": ChordData(fingers: [1, 3, 1, 2, 1, 1], name: "F Seventh", barre: 1),
        "G7": ChordData(fingers: [3, 2, 0, 0, 0, 1], name: "G Seventh"),
        
        // Major Seventh
        "Amaj7": ChordData(fingers: [-1, 0, 2, 1, 2, 0], name: "A Major 7"),
        "Cmaj7": ChordData(fingers: [-1, 3, 2, 0, 0, 0], name: "C Major 7"),
        "Dmaj7": ChordData(fingers: [-1, -1, 0, 2, 2, 2], name: "D Major 7"),
        "Emaj7": ChordData(fingers: [0, 2, 1, 1, 0, 0], name: "E Major 7"),
        "Fmaj7": ChordData(fingers: [1, 3, 2, 2, 1, 1], name: "F Major 7", barre: 1),
        "Gmaj7": ChordData(fingers: [3, 2, 0, 0, 0, 2], name: "G Major 7"),
        
        // Minor Seventh
        "Am7": ChordData(fingers: [-1, 0, 2, 0, 1, 0], name: "A Minor 7"),
        "Bm7": ChordData(fingers: [-1, 2, 4, 2, 3, 2], name: "B Minor 7", barre: 2),
        "Cm7": ChordData(fingers: [-1, 3, 5, 3, 4, 3], name: "C Minor 7", barre: 3),
        "Dm7": ChordData(fingers: [-1, -1, 0, 2, 1, 1], name: "D Minor 7"),
        "Em7": ChordData(fingers: [0, 2, 0, 0, 0, 0], name: "E Minor 7"),
        "Fm7": ChordData(fingers: [1, 3, 1, 1, 1, 1], name: "F Minor 7", barre: 1),
        "Gm7": ChordData(fingers: [3, 5, 3, 3, 3, 3], name: "G Minor 7", barre: 3),
        
        // Suspended Chords
        "Asus4": ChordData(fingers: [-1, 0, 2, 2, 3, 0], name: "A Suspended 4"),
        "Dsus4": ChordData(fingers: [-1, -1, 0, 2, 3, 3], name: "D Suspended 4"),
        "Esus4": ChordData(fingers: [0, 2, 2, 2, 0, 0], name: "E Suspended 4"),
        "Gsus4": ChordData(fingers: [3, 3, 0, 0, 1, 3], name: "G Suspended 4"),
        
        "Asus2": ChordData(fingers: [-1, 0, 2, 2, 0, 0], name: "A Suspended 2"),
        "Dsus2": ChordData(fingers: [-1, -1, 0, 2, 3, 0], name: "D Suspended 2"),
        "Esus2": ChordData(fingers: [0, 2, 2, 4, 0, 0], name: "E Suspended 2"),
        
        // Power Chords
        "A5": ChordData(fingers: [-1, 0, 2, 2, -1, -1], name: "A Power Chord"),
        "D5": ChordData(fingers: [-1, -1, 0, 2, 3, -1], name: "D Power Chord"),
        "E5": ChordData(fingers: [0, 2, 2, -1, -1, -1], name: "E Power Chord"),
        "G5": ChordData(fingers: [3, 5, 5, -1, -1, -1], name: "G Power Chord"),
        
        // Diminished
        "Adim": ChordData(fingers: [-1, 0, 1, 2, 1, 2], name: "A Diminished"),
        "Bdim": ChordData(fingers: [-1, 2, 3, 4, 3, -1], name: "B Diminished"),
        "Cdim": ChordData(fingers: [-1, 3, 4, 2, 4, 2], name: "C Diminished"),
        "Ddim": ChordData(fingers: [-1, -1, 0, 1, 0, 1], name: "D Diminished"),
        "Edim": ChordData(fingers: [-1, -1, 2, 3, 2, 3], name: "E Diminished"),
        
        // Augmented
        "Aaug": ChordData(fingers: [-1, 0, 3, 2, 2, 1], name: "A Augmented"),
        "Caug": ChordData(fingers: [-1, 3, 2, 1, 1, 0], name: "C Augmented"),
        "Daug": ChordData(fingers: [-1, -1, 0, 3, 3, 2], name: "D Augmented"),
        "Eaug": ChordData(fingers: [0, 3, 2, 1, 1, 0], name: "E Augmented"),
    ]
    
    func findChord(_ name: String) -> ChordData? {
        let normalized = name.trimmingCharacters(in: .whitespaces)
        
        // Direct match
        if let chord = chords[normalized] {
            return chord
        }
        
        // Try common variations
        let variations = [
            normalized,
            normalized.replacingOccurrences(of: "min", with: "m"),
            normalized.replacingOccurrences(of: "maj", with: ""),
            normalized.replacingOccurrences(of: "M", with: ""),
            normalized.replacingOccurrences(of: "minor", with: "m"),
            normalized.replacingOccurrences(of: "major", with: "")
        ]
        
        for variation in variations {
            if let chord = chords[variation] {
                return chord
            }
        }
        
        return nil
    }
    
    var allChordNames: [String] {
        Array(chords.keys).sorted()
    }
}

