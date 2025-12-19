//
//  SongStore.swift
//  GuitarSongbook
//
//  Manages song data persistence and state with iCloud sync
//

import Foundation
import SwiftUI

enum SortColumn: String, CaseIterable {
    case title, artist, chords, capo, dateAdded
    
    var displayName: String {
        switch self {
        case .title: return "Title"
        case .artist: return "Artist"
        case .chords: return "Chords"
        case .capo: return "Capo"
        case .dateAdded: return "Date Added"
        }
    }
}

enum SortDirection {
    case ascending, descending
    
    mutating func toggle() {
        self = self == .ascending ? .descending : .ascending
    }
}

class SongStore: ObservableObject {
    @Published var songs: [Song] = []
    @Published var categories: [String] = []
    @Published var filterChord: String = ""
    @Published var filterCapo: String = ""
    @Published var filterCategory: String = "" // Empty = All, "favorites" = Favorites, or category name
    @Published var searchText: String = ""
    @Published var sortColumn: SortColumn = .dateAdded
    @Published var sortDirection: SortDirection = .descending
    @Published var iCloudEnabled: Bool = false
    
    private let songsKey = "guitarSongs"
    private let categoriesKey = "guitarCategories"
    
    // iCloud key-value store
    private let iCloudStore = NSUbiquitousKeyValueStore.default
    
    init() {
        setupiCloudSync()
        loadSongs()
        loadCategories()
    }
    
    // MARK: - iCloud Setup
    
    private func setupiCloudSync() {
        // Check if iCloud is available
        if FileManager.default.ubiquityIdentityToken != nil {
            iCloudEnabled = true
            
            // Listen for changes from other devices
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(iCloudDataDidChange),
                name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                object: iCloudStore
            )
            
            // Start syncing
            iCloudStore.synchronize()
        } else {
            iCloudEnabled = false
            print("iCloud not available - using local storage only")
        }
    }
    
    @objc private func iCloudDataDidChange(_ notification: Notification) {
        // Reload data when changes come from another device
        DispatchQueue.main.async { [weak self] in
            self?.loadSongs()
            self?.loadCategories()
        }
    }
    
    // MARK: - Computed Properties
    
    var filteredAndSortedSongs: [Song] {
        var result = songs
        
        // Apply favorite/category filter
        if filterCategory == "favorites" {
            result = result.filter { $0.isFavorite }
        } else if !filterCategory.isEmpty {
            result = result.filter { $0.categories.contains(filterCategory) }
        }
        
        // Apply chord filter
        if !filterChord.isEmpty {
            if filterChord == "__NO_CHORDS__" {
                // Filter for songs with no chords
                result = result.filter { $0.chords.isEmpty }
            } else if filterChord == "__HAS_CHORDS__" {
                // Filter for songs that have at least one chord
                result = result.filter { !$0.chords.isEmpty }
            } else {
                // Filter for songs containing the selected chord
                result = result.filter { $0.chords.contains(filterChord) }
            }
        }
        
        // Apply capo filter
        if let capoInt = Int(filterCapo) {
            result = result.filter { $0.capoPosition == capoInt }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            let search = searchText.lowercased()
            result = result.filter {
                $0.title.lowercased().contains(search) ||
                $0.artist.lowercased().contains(search)
            }
        }
        
        // Apply sorting
        result.sort { song1, song2 in
            let comparison: Bool
            switch sortColumn {
            case .title:
                comparison = song1.title.lowercased() < song2.title.lowercased()
            case .artist:
                comparison = song1.artist.lowercased() < song2.artist.lowercased()
            case .chords:
                comparison = song1.chords.count < song2.chords.count
            case .capo:
                comparison = song1.capoPosition < song2.capoPosition
            case .dateAdded:
                comparison = song1.dateAdded < song2.dateAdded
            }
            return sortDirection == .ascending ? comparison : !comparison
        }
        
        return result
    }
    
    var allUniqueChords: [String] {
        var chordSet = Set<String>()
        for song in songs {
            for chord in song.chords {
                chordSet.insert(chord)
            }
        }
        return Array(chordSet).sorted()
    }
    
    var songCountText: String {
        let total = songs.count
        let filtered = filteredAndSortedSongs.count
        
        if hasActiveFilters {
            return "\(filtered) of \(total) songs"
        }
        return "\(total) song\(total == 1 ? "" : "s")"
    }
    
    var favoritesCount: Int {
        songs.filter { $0.isFavorite }.count
    }
    
    // MARK: - CRUD Operations
    
    func addSong(_ song: Song) {
        songs.insert(song, at: 0)
        saveSongs()
    }
    
    func updateSong(_ song: Song) {
        if let index = songs.firstIndex(where: { $0.id == song.id }) {
            songs[index] = song
            saveSongs()
        }
    }
    
    func deleteSong(_ song: Song) {
        songs.removeAll { $0.id == song.id }
        HapticManager.shared.medium()
        saveSongs()
    }

    func toggleFavorite(_ song: Song) {
        if let index = songs.firstIndex(where: { $0.id == song.id }) {
            songs[index].isFavorite.toggle()
            HapticManager.shared.light()
            saveSongs()
        }
    }
    
    func addCategory(_ song: Song, category: String) {
        if let index = songs.firstIndex(where: { $0.id == song.id }) {
            if !songs[index].categories.contains(category) {
                songs[index].categories.append(category)
                saveSongs()
            }
        }
    }
    
    func removeCategory(_ song: Song, category: String) {
        if let index = songs.firstIndex(where: { $0.id == song.id }) {
            songs[index].categories.removeAll { $0 == category }
            saveSongs()
        }
    }
    
    // MARK: - Category Management
    
    func createCategory(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty && !categories.contains(trimmed) {
            categories.append(trimmed)
            saveCategories()
        }
    }
    
    func deleteCategory(_ name: String) {
        categories.removeAll { $0 == name }
        // Remove category from all songs
        for i in songs.indices {
            songs[i].categories.removeAll { $0 == name }
        }
        saveCategories()
        saveSongs()
    }
    
    func renameCategory(from oldName: String, to newName: String) {
        let trimmed = newName.trimmingCharacters(in: .whitespaces)
        if let index = categories.firstIndex(of: oldName) {
            categories[index] = trimmed
            // Update all songs with this category
            for i in songs.indices {
                if let catIndex = songs[i].categories.firstIndex(of: oldName) {
                    songs[i].categories[catIndex] = trimmed
                }
            }
            saveCategories()
            saveSongs()
        }
    }
    
    func songsInCategory(_ category: String) -> Int {
        songs.filter { $0.categories.contains(category) }.count
    }
    
    // MARK: - Sorting
    
    func sortBy(_ column: SortColumn) {
        if sortColumn == column {
            sortDirection.toggle()
        } else {
            sortColumn = column
            sortDirection = .ascending
        }
    }
    
    // MARK: - Filtering
    
    func clearFilters() {
        filterChord = ""
        filterCapo = ""
        filterCategory = ""
        searchText = ""
    }
    
    var hasActiveFilters: Bool {
        !filterChord.isEmpty || !filterCapo.isEmpty || !filterCategory.isEmpty || !searchText.isEmpty
    }
    
    // MARK: - Persistence (Local + iCloud)
    
    private func saveSongs() {
        guard let encoded = try? JSONEncoder().encode(songs) else { return }
        
        // Save to local UserDefaults (always)
        UserDefaults.standard.set(encoded, forKey: songsKey)
        
        // Save to iCloud if available
        if iCloudEnabled {
            iCloudStore.set(encoded, forKey: songsKey)
            iCloudStore.synchronize()
        }
    }
    
    private func loadSongs() {
        var data: Data?
        
        // Try iCloud first if available
        if iCloudEnabled {
            data = iCloudStore.data(forKey: songsKey)
        }
        
        // Fall back to local storage
        if data == nil {
            data = UserDefaults.standard.data(forKey: songsKey)
        }
        
        // Decode and set
        if let data = data,
           let decoded = try? JSONDecoder().decode([Song].self, from: data) {
            songs = decoded
            
            // If we loaded from local but iCloud is enabled, push to iCloud
            if iCloudEnabled && iCloudStore.data(forKey: songsKey) == nil {
                saveSongs()
            }
        }
    }
    
    private func saveCategories() {
        // Save to local UserDefaults
        UserDefaults.standard.set(categories, forKey: categoriesKey)
        
        // Save to iCloud if available
        if iCloudEnabled {
            iCloudStore.set(categories, forKey: categoriesKey)
            iCloudStore.synchronize()
        }
    }
    
    private func loadCategories() {
        var loaded: [String]?
        
        // Try iCloud first
        if iCloudEnabled {
            loaded = iCloudStore.array(forKey: categoriesKey) as? [String]
        }
        
        // Fall back to local
        if loaded == nil {
            loaded = UserDefaults.standard.stringArray(forKey: categoriesKey)
        }
        
        if let loaded = loaded {
            categories = loaded
        }
    }
    
    // MARK: - Manual Sync
    
    func forceSync() {
        if iCloudEnabled {
            iCloudStore.synchronize()
            loadSongs()
            loadCategories()
        }
    }
}
