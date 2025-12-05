//
//  Song.swift
//  GuitarSongbook
//
//  Song model for the guitar songbook
//

import Foundation

struct Song: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var artist: String
    var chords: [String]
    var capoPosition: Int
    var dateAdded: Date
    var spotifyUrl: String?
    var tabUrl: String?
    var albumCoverUrl: String?
    var notes: String?
    var createdAt: Date
    var isFavorite: Bool
    var categories: [String]
    
    init(
        id: UUID = UUID(),
        title: String,
        artist: String,
        chords: [String] = [],
        capoPosition: Int = 0,
        dateAdded: Date = Date(),
        spotifyUrl: String? = nil,
        tabUrl: String? = nil,
        albumCoverUrl: String? = nil,
        notes: String? = nil,
        createdAt: Date = Date(),
        isFavorite: Bool = false,
        categories: [String] = []
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.chords = chords
        self.capoPosition = capoPosition
        self.dateAdded = dateAdded
        self.spotifyUrl = spotifyUrl
        self.tabUrl = tabUrl
        self.albumCoverUrl = albumCoverUrl
        self.notes = notes
        self.createdAt = createdAt
        self.isFavorite = isFavorite
        self.categories = categories
    }
    
    var capoDisplayText: String {
        if capoPosition == 0 {
            return "No Capo"
        } else {
            let suffix: String
            switch capoPosition {
            case 1: suffix = "st"
            case 2: suffix = "nd"
            case 3: suffix = "rd"
            default: suffix = "th"
            }
            return "\(capoPosition)\(suffix) Fret"
        }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: dateAdded)
    }
}
