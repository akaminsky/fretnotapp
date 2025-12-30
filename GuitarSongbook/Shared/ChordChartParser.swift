//
//  ChordChartParser.swift
//  GuitarSongbook
//
//  Parses chord chart text to extract capo position and chord names
//  Shared between main app and Share Extension
//

import Foundation

struct ParsedChordChart {
    let capoPosition: Int
    let chords: [String]
    let fullText: String
}

class ChordChartParser {

    // MARK: - Public API

    static func parse(_ text: String) -> ParsedChordChart {
        let capo = extractCapo(from: text)
        let chords = extractChords(from: text)

        return ParsedChordChart(
            capoPosition: capo,
            chords: chords,
            fullText: text
        )
    }

    // Original method for backward compatibility
    private static func extractChords(from text: String) -> [String] {
        let (chords, _) = extractChordsWithDebug(from: text)
        return chords
    }

    // MARK: - Capo Extraction

    private static func extractCapo(from text: String) -> Int {
        // Regex pattern: "Capo X" or "Capo: Xth fret" where X is a number
        // (?i) makes it case-insensitive
        // :?\s* matches optional colon and whitespace
        // (\d+) captures one or more digits
        let capoPattern = #"(?i)capo:?\s*(\d+)"#

        guard let regex = try? NSRegularExpression(pattern: capoPattern),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              let capoRange = Range(match.range(at: 1), in: text),
              let capo = Int(text[capoRange]) else {
            return 0  // Default to no capo
        }

        // Validate capo is in reasonable range (0-7)
        guard capo >= 0 && capo <= 7 else {
            return 0
        }

        return capo
    }

    // MARK: - Chord Extraction

    private static func extractChordsWithDebug(from text: String) -> ([String], String) {
        // Filter out tablature and instruction lines before processing
        let lines = text.components(separatedBy: .newlines)
        var filteredText = ""

        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)

            // Skip empty lines
            if trimmedLine.isEmpty {
                continue
            }

            // Skip lines that look like guitar tablature
            // Tablature lines contain patterns like: e|---3---|  or  B|-3h5-5-|
            let isTablature = line.contains("|") && (
                line.contains("---") ||  // Dashes indicating strings
                line.contains("e|") ||   // String markers
                line.contains("B|") ||
                line.contains("G|") ||
                line.contains("D|") ||
                line.contains("A|") ||
                line.contains("E|")
            )

            // Skip chord diagram lines (contain x-x-x-x patterns or E-A-D-G-B-e)
            let isChordDiagram = line.contains("E-A-D-G-B-e") ||
                                 line.contains("x-x-") ||
                                 line.contains("-x-x-") ||
                                 (line.contains("x") && line.contains("-") && line.filter { $0.isNumber }.count > 3)

            // Skip instruction lines (Play:, Key:, Capo:, etc.)
            let isInstruction = trimmedLine.hasPrefix("Play:") ||
                               trimmedLine.hasPrefix("Key:") ||
                               trimmedLine.hasPrefix("For ") ||
                               trimmedLine.hasPrefix("or use") ||
                               trimmedLine.hasPrefix("The ") ||
                               trimmedLine.hasPrefix("Capo:") ||
                               trimmedLine.contains("transpose") ||
                               trimmedLine.contains("Real Book") ||
                               trimmedLine.contains("fret") ||
                               trimmedLine.contains("---") // Divider lines

            // Skip lines with explanatory text in parentheses that define chords
            // Also skip lines that are chord fingering diagrams (e.g., "G     3-x-0-0-3(3)")
            let isExplanation = line.contains("(=") ||
                               line.contains("as the root") ||
                               line.contains("\"")  // Skip lines with quoted text

            // Skip chord fingering lines (e.g., "G     3-x-0-0-3(3)") by looking for pattern of spaces followed by numbers and x
            let hasFingering = line.contains("-") && line.contains("(") && (line.filter { $0.isNumber }.count > 4)

            if !isTablature && !isChordDiagram && !isInstruction && !isExplanation && !hasFingering {
                filteredText += line + "\n"
            }
        }

        // Comprehensive chord pattern matching:
        // [A-G] - Root note (C, D, E, F, G, A, B) - MUST be uppercase
        // [#♯b♭]? - Optional sharp or flat (supports both # and ♯, b and ♭)
        // (?:m|maj|min|dim|aug)? - Optional quality (minor, major, diminished, augmented)
        // (?:\d+)? - Optional number for extensions (7, 9, 11, 13)
        // (?:sus\d?)? - Optional suspended chord (sus2, sus4)
        // (?:add\d+)? - Optional added note (add9, add11)
        // (?:/[A-G][#♯b♭]?)? - Optional slash chord bass note
        // (?![#♯b♭\w]) - Not followed by sharp/flat/word character (replaces \b to allow # before space)
        let chordPattern = #"\b([A-G][#♯b♭]?(?:m|maj|min|dim|aug)?(?:\d+)?(?:sus\d?)?(?:add\d+)?(?:/[A-G][#♯b♭]?)?)(?![#♯b♭\w])"#

        guard let regex = try? NSRegularExpression(pattern: chordPattern) else {
            return ([], filteredText)
        }

        let nsRange = NSRange(filteredText.startIndex..<filteredText.endIndex, in: filteredText)
        let matches = regex.matches(in: filteredText, range: nsRange)

        // Extract and deduplicate chords, preserving order of first appearance
        var seenChords = Set<String>()
        var uniqueChords: [String] = []

        // Blacklist of common false positives (words that look like chords)
        let blacklist = Set(["I", "Oh", "All"])

        for match in matches {
            guard let range = Range(match.range, in: filteredText) else { continue }
            let chord = String(filteredText[range])

            // Filter out common words that match the pattern
            if blacklist.contains(chord) {
                continue
            }

            // Add to unique list if not seen before
            if !seenChords.contains(chord) {
                seenChords.insert(chord)
                uniqueChords.append(chord)
            }
        }

        return (uniqueChords, filteredText)
    }
}
