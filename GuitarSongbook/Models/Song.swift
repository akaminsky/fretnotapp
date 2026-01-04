//
//  Song.swift
//  GuitarSongbook
//
//  Song model for the guitar songbook
//

import Foundation

// MARK: - Song Link

struct SongLink: Codable, Identifiable, Equatable {
    let id: UUID
    var url: String
    var siteName: String
    var addedAt: Date

    init(id: UUID = UUID(), url: String, siteName: String? = nil, addedAt: Date = Date()) {
        self.id = id
        self.url = url
        self.siteName = siteName ?? SongLink.detectSiteName(from: url)
        self.addedAt = addedAt
    }

    // Auto-detect site name from URL
    static func detectSiteName(from urlString: String) -> String {
        guard let url = URL(string: urlString),
              let host = url.host else {
            return "Link"
        }

        // Remove www. and extract domain
        let domain = host.replacingOccurrences(of: "www.", with: "")

        // Known site mappings
        let siteMap: [String: String] = [
            "ultimate-guitar.com": "Ultimate Guitar",
            "tabs.ultimate-guitar.com": "Ultimate Guitar",
            "songsterr.com": "Songsterr",
            "chordify.net": "Chordify",
            "guitartabs.cc": "Guitar Tabs",
            "azchords.com": "AZ Chords",
            "e-chords.com": "E-Chords",
            "chordie.com": "Chordie",
            "youtube.com": "YouTube",
            "youtu.be": "YouTube",
            "genius.com": "Genius",
            "azlyrics.com": "AZ Lyrics",
            "lyrics.com": "Lyrics.com",
            "metrolyrics.com": "MetroLyrics",
            "vimeo.com": "Vimeo",
            "guitartabsexplorer.com": "Guitar Tabs Explorer",
            "bigbasstabs.com": "Big Bass Tabs",
            "911tabs.com": "911 Tabs"
        ]

        // Check for known sites
        for (pattern, name) in siteMap {
            if domain.contains(pattern) {
                return name
            }
        }

        // Fallback: capitalize domain name
        let mainDomain = domain.components(separatedBy: ".").first ?? "Link"
        return mainDomain.prefix(1).uppercased() + mainDomain.dropFirst()
    }
}

// MARK: - Song

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
    var tabUrl: String?     // Deprecated - kept for backward compatibility
    var links: [SongLink]   // New field replacing tabUrl
    var albumCoverUrl: String?
    var notes: String?
    var createdAt: Date
    var isFavorite: Bool
    var categories: [String]
    var key: Int?           // 0-11 (C, C#, D, ..., B)
    var mode: Int?          // 0 = minor, 1 = major
    var tempo: Double?      // BPM

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
        links: [SongLink] = [],
        albumCoverUrl: String? = nil,
        notes: String? = nil,
        createdAt: Date = Date(),
        isFavorite: Bool = false,
        categories: [String] = [],
        key: Int? = nil,
        mode: Int? = nil,
        tempo: Double? = nil
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
        self.links = links
        self.albumCoverUrl = albumCoverUrl
        self.notes = notes
        self.createdAt = createdAt
        self.isFavorite = isFavorite
        self.categories = categories
        self.key = key
        self.mode = mode
        self.tempo = tempo
    }
    
    // MARK: - Custom Decoding for Data Migration
    // Handles old data that might be missing newer fields
    
    enum CodingKeys: String, CodingKey {
        case id, title, artist, chords, capoPosition, tuning, strumPatterns, dateAdded
        case spotifyUrl, tabUrl, links, albumCoverUrl, notes, createdAt
        case isFavorite, categories
        case key, mode, tempo
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

        // Decode new links array
        links = try container.decodeIfPresent([SongLink].self, forKey: .links) ?? []

        // Data migration: Convert old tabUrl to links array if needed
        if let oldTabUrl = tabUrl, !oldTabUrl.isEmpty, links.isEmpty {
            links = [SongLink(url: oldTabUrl)]
        }

        // Newer fields - provide defaults if missing
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? dateAdded
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
        categories = try container.decodeIfPresent([String].self, forKey: .categories) ?? []

        // Audio features
        key = try container.decodeIfPresent(Int.self, forKey: .key)
        mode = try container.decodeIfPresent(Int.self, forKey: .mode)
        tempo = try container.decodeIfPresent(Double.self, forKey: .tempo)
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
        try container.encodeIfPresent(tabUrl, forKey: .tabUrl)  // Keep for backward compatibility
        try container.encode(links, forKey: .links)  // New primary field
        try container.encodeIfPresent(albumCoverUrl, forKey: .albumCoverUrl)
        try container.encodeIfPresent(notes, forKey: .notes)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encode(categories, forKey: .categories)
        try container.encodeIfPresent(key, forKey: .key)
        try container.encodeIfPresent(mode, forKey: .mode)
        try container.encodeIfPresent(tempo, forKey: .tempo)
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

    var keyDisplayText: String? {
        guard let key = key, let mode = mode else { return nil }
        let notes = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]
        guard key >= 0 && key < notes.count else { return nil }
        let modeText = mode == 1 ? "Major" : "Minor"
        return "\(notes[key]) \(modeText)"
    }

    var tempoDisplayText: String? {
        guard let tempo = tempo else { return nil }
        return "\(Int(tempo)) BPM"
    }
}
