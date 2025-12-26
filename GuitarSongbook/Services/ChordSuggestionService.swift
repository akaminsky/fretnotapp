//
//  ChordSuggestionService.swift
//  GuitarSongbook
//
//  Service for suggesting chords based on Spotify audio features
//

import Foundation

@MainActor
class ChordSuggestionService: ObservableObject {
    @Published var isSuggesting = false
    @Published var suggestedChords: [String] = []
    @Published var suggestionSource: SuggestionSource = .none
    @Published var error: String?
    @Published var audioFeaturesKey: Int?
    @Published var audioFeaturesMode: Int?
    @Published var audioFeaturesTempo: Double?

    private let spotifyService: SpotifyService
    private let chordLibrary = ChordLibrary.shared

    enum SuggestionSource {
        case none
        case spotify           // Tier 1: Audio analysis
        case ultimateGuitar    // Tier 2: External database (future)
        case fallback          // Tier 3: ChordLibrary defaults

        var description: String {
            switch self {
            case .none: return ""
            case .spotify: return "Spotify audio analysis"
            case .ultimateGuitar: return "Ultimate Guitar"
            case .fallback: return "default chords"
            }
        }
    }

    init(spotifyService: SpotifyService) {
        self.spotifyService = spotifyService
    }

    // MARK: - Main Suggestion Method

    func suggestChords(for track: SpotifyTrack, capoPosition: Int = 0) async {
        let startTime = Date()
        isSuggesting = true

        // For MVP: Only Tier 1 (Spotify audio analysis)
        if let analysisChords = await generateChordsFromAudioAnalysis(trackId: track.id, capoPosition: capoPosition) {
            suggestedChords = analysisChords
            suggestionSource = .spotify
        } else {
            // Tier 3: Default suggestions based on common progressions
            suggestedChords = getDefaultChords()
            suggestionSource = .fallback
        }

        // Ensure loading state is visible for at least 250ms
        let elapsed = Date().timeIntervalSince(startTime)
        let minimumDisplayTime: TimeInterval = 0.25
        if elapsed < minimumDisplayTime {
            try? await Task.sleep(nanoseconds: UInt64((minimumDisplayTime - elapsed) * 1_000_000_000))
        }

        isSuggesting = false
    }

    // MARK: - Tier 1: Spotify Audio Analysis

    private func generateChordsFromAudioAnalysis(trackId: String, capoPosition: Int) async -> [String]? {
        do {
            let features = try await spotifyService.fetchAudioFeatures(trackId: trackId)

            // Store original audio features (not transposed)
            audioFeaturesKey = features.key
            audioFeaturesMode = features.mode
            audioFeaturesTempo = features.tempo

            // Transpose key DOWN by capo position to get easier chords
            // Example: Song in F# (key=6) with Capo 2 → E (key=4)
            let adjustedKey = (features.key - capoPosition + 12) % 12

            return generateChordsFromKey(key: adjustedKey, mode: features.mode)
        } catch {
            self.error = "Failed to fetch audio features: \(error.localizedDescription)"
            return nil
        }
    }

    private func generateChordsFromKey(key: Int, mode: Int) -> [String] {
        // Map key integer to note name
        let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        guard key >= 0 && key < notes.count else {
            return getDefaultChords()
        }
        let rootNote = notes[key]

        if mode == 1 { // Major key
            return generateMajorProgression(root: rootNote)
        } else { // Minor key
            return generateMinorProgression(root: rootNote)
        }
    }

    private func generateMajorProgression(root: String) -> [String] {
        // Common major progression: I-V-vi-IV
        // Example: C major = C, G, Am, F
        let intervals = getMajorScaleChords(root: root)
        let progression = [
            intervals[0],  // I
            intervals[4],  // V
            intervals[5],  // vi
            intervals[3],  // IV
            intervals[1],  // ii
            intervals[2]   // iii
        ]

        // Validate against library and return only chords that exist
        return progression.filter { chordLibrary.findChord($0) != nil }
    }

    private func generateMinorProgression(root: String) -> [String] {
        // Common minor progression: i-VI-III-VII
        // Example: A minor = Am, F, C, G
        let intervals = getMinorScaleChords(root: root)
        let progression = [
            intervals[0],  // i
            intervals[5],  // VI
            intervals[2],  // III
            intervals[6],  // VII
            intervals[3],  // iv
            intervals[4]   // v
        ]

        // Validate against library
        return progression.filter { chordLibrary.findChord($0) != nil }
    }

    // MARK: - Tier 3: Fallback

    private func getDefaultChords() -> [String] {
        // Return most common guitar chords
        return ["C", "G", "Am", "F", "D", "Em"]
    }

    // MARK: - Helper Methods

    private func getMajorScaleChords(root: String) -> [String] {
        // Generate I-ii-iii-IV-V-vi-viidim for given root
        // Major scale intervals (in semitones from root): 0, 2, 4, 5, 7, 9, 11
        // Chord qualities: Maj, min, min, Maj, Maj, min, dim

        let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        guard let rootIndex = notes.firstIndex(of: root) else {
            return []
        }

        // Major scale intervals: [0, 2, 4, 5, 7, 9, 11]
        return [
            root,                              // I (major)
            "\(getNote(notes, rootIndex, 2))m",  // ii (minor)
            "\(getNote(notes, rootIndex, 4))m",  // iii (minor)
            getNote(notes, rootIndex, 5),      // IV (major)
            getNote(notes, rootIndex, 7),      // V (major)
            "\(getNote(notes, rootIndex, 9))m",  // vi (minor)
            "\(getNote(notes, rootIndex, 11))dim" // viidim (diminished)
        ]
    }

    private func getMinorScaleChords(root: String) -> [String] {
        // Natural minor scale chords
        // Minor scale intervals: [0, 2, 3, 5, 7, 8, 10]
        // i-iidim-III-iv-v-VI-VII

        let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]

        // For minor chords, root should already have 'm' suffix
        // Extract base note if it has 'm' suffix
        let baseRoot = root.hasSuffix("m") ? String(root.dropLast()) : root

        guard let rootIndex = notes.firstIndex(of: baseRoot) else {
            return []
        }

        return [
            "\(baseRoot)m",                       // i (minor)
            "\(getNote(notes, rootIndex, 2))dim", // iidim (diminished)
            getNote(notes, rootIndex, 3),         // III (major)
            "\(getNote(notes, rootIndex, 5))m",   // iv (minor)
            "\(getNote(notes, rootIndex, 7))m",   // v (minor)
            getNote(notes, rootIndex, 8),         // VI (major)
            getNote(notes, rootIndex, 10),        // VII (major)
        ]
    }

    private func getNote(_ notes: [String], _ baseIndex: Int, _ semitones: Int) -> String {
        let index = (baseIndex + semitones) % notes.count
        return notes[index]
    }
}
