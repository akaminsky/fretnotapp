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
    var tuning: String
    var strumPatterns: [StrumPattern]
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
        tuning: String = "EADGBE",
        strumPatterns: [StrumPattern] = [],
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
        self.tuning = tuning
        self.strumPatterns = strumPatterns
        self.dateAdded = dateAdded
        self.spotifyUrl = spotifyUrl
        self.tabUrl = tabUrl
        self.albumCoverUrl = albumCoverUrl
        self.notes = notes
        self.createdAt = createdAt
        self.isFavorite = isFavorite
        self.categories = categories
    }
    
    // MARK: - Custom Decoding for Data Migration
    // Handles old data that might be missing newer fields
    
    enum CodingKeys: String, CodingKey {
        case id, title, artist, chords, capoPosition, tuning, strumPatterns, dateAdded
        case spotifyUrl, tabUrl, albumCoverUrl, notes, createdAt
        case isFavorite, categories
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Required fields
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        artist = try container.decode(String.self, forKey: .artist)
        
        // Fields with defaults for backwards compatibility
        chords = try container.decodeIfPresent([String].self, forKey: .chords) ?? []
        capoPosition = try container.decodeIfPresent(Int.self, forKey: .capoPosition) ?? 0
        tuning = try container.decodeIfPresent(String.self, forKey: .tuning) ?? "EADGBE"
        strumPatterns = try container.decodeIfPresent([StrumPattern].self, forKey: .strumPatterns) ?? []
        dateAdded = try container.decodeIfPresent(Date.self, forKey: .dateAdded) ?? Date()
        
        // Optional fields
        spotifyUrl = try container.decodeIfPresent(String.self, forKey: .spotifyUrl)
        tabUrl = try container.decodeIfPresent(String.self, forKey: .tabUrl)
        albumCoverUrl = try container.decodeIfPresent(String.self, forKey: .albumCoverUrl)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        
        // Newer fields - provide defaults if missing
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? dateAdded
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
        categories = try container.decodeIfPresent([String].self, forKey: .categories) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(artist, forKey: .artist)
        try container.encode(chords, forKey: .chords)
        try container.encode(capoPosition, forKey: .capoPosition)
        try container.encode(tuning, forKey: .tuning)
        try container.encode(strumPatterns, forKey: .strumPatterns)
        try container.encode(dateAdded, forKey: .dateAdded)
        try container.encodeIfPresent(spotifyUrl, forKey: .spotifyUrl)
        try container.encodeIfPresent(tabUrl, forKey: .tabUrl)
        try container.encodeIfPresent(albumCoverUrl, forKey: .albumCoverUrl)
        try container.encodeIfPresent(notes, forKey: .notes)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encode(categories, forKey: .categories)
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
