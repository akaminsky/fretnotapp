//
//  StrumPattern.swift
//  GuitarSongbook
//
//  Model for strum patterns with labels
//

import Foundation

struct StrumPattern: Identifiable, Codable, Equatable {
    let id: UUID
    var label: String
    var pattern: String

    init(id: UUID = UUID(), label: String, pattern: String) {
        self.id = id
        self.label = label
        self.pattern = pattern
    }

    // Common strum pattern presets
    static let commonPatterns: [(name: String, pattern: String)] = [
        ("Basic Folk / Pop", "D-D-D-D"),
        ("Straight Eighths", "DU-DU-DU-DU"),
        ("Pop / Singer-Songwriter Classic", "D-DU-U-DU"),
        ("Folk Rock / Indie", "D-DU-DU-U"),
        ("Laid-Back Groove", "D-U-D-U"),
        ("Country / Train Feel", "D-DU-DU-DU"),
        ("Syncopated Pop", "D-DU-U-U"),
        ("Classic Acoustic", "D-DU-UDU"),
        ("Simple Strum", "D-DU"),
        ("Reggae-Inspired", "U-U-U-U"),
        ("Driving Anthem", "D-DU-DU-DU"),
        ("Simple 3/4 (Waltz Feel)", "D-DU-DU"),
    ]

    // Common song part labels
    static let commonLabels = [
        "Verse",
        "Chorus",
        "Bridge",
        "Intro",
        "Outro",
        "Solo",
        "Pre-Chorus",
    ]
}
