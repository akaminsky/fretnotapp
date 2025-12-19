# Fret Not - Guitar Songbook

A comprehensive iOS app for guitarists to track songs, learn chords, and stay in tune.

## Features

### 🎵 Song Management
- **Add Songs Manually** - Quick entry with title (required), artist, chords, capo position, tuning, and notes
- **Spotify Integration** - Search and import songs directly from Spotify
- **Bulk Import** - Import entire Spotify playlists at once
- **Auto-fill** - Automatically populate song details from Spotify (editable)
- **Tuning Support** - Track tuning for each song (Standard, Drop D, Drop C, Half Step Down, Open D, Open G, or custom)
- **Custom Lists** - Organize songs into custom categories
- **Favorites** - Mark songs as favorites for quick access
- **Search & Filter** - Find songs by title, artist, chord, capo, or list

### 🎸 Chord Features
- **Chord Library** - 200+ guitar chords with diagrams
- **Chord Validation** - Real-time validation as you type
- **Smart Input** - Auto-capitalize chord names, pill-based UI with drag-to-reorder
- **Chord Autocomplete** - Suggestions as you type
- **Chord Identifier** - Interactive fretboard to identify unknown chords, add directly to songs
- **Chord Log** - View all unique chords you've learned across songs

### 🎚️ Tuner
- **Built-in Tuner** - Real-time pitch detection with auto-detection
- **Multiple Tunings** - Support for Standard, Drop D, Drop C, Half Step Down, Open D, and Open G tunings
- **Manual & Auto String Selection** - Select specific strings or let auto-detection find them

### ☁️ Sync & Storage
- **iCloud Sync** - Automatic sync across iPhone, iPad, and Mac
- **Local Storage** - Works offline, syncs when connected

### ✨ UX Enhancements
- **Haptic Feedback** - Tactile response for all interactions
  - Adding/removing chords
  - Playing chord sounds
  - Favoriting songs
  - Deleting items
- **Loading States** - Clear feedback during async operations
- **Smart Focus** - Auto-focus on chord input when adding songs
- **Visual Feedback** - Animations and state indicators throughout

## Recent Updates

### Tuning Features (December 2024)
- Added tuning field to song details (Standard, Drop D, Drop C, Half Step Down, Open D, Open G, or custom)
- Enhanced tuner with multiple tuning support
- Tuner now adapts to show correct target notes for selected tuning
- Improved tuner layout with tighter spacing

### Chord Management (December 2024)
- Drag-and-drop reordering for chord pills in edit mode
- Visual drag handle indicator
- Add identified chords directly to songs from Chord Identifier
- Improved Chord Identifier UX with better button placement

### Song Entry (December 2024)
- Made song title the only required field when adding songs manually
- Artist and other fields now optional for faster entry

### UX Improvements (December 2024)
- Added haptic feedback throughout the app
- Loading indicators for save operations
- Smart keyboard handling and focus management
- Enhanced chord input with validation pills
- Consistent link colors throughout the app

### Chord Input Enhancement (December 2024)
- Pill-based UI with removable chips
- Real-time validation against chord library
- Visual distinction between valid (blue) and invalid (red) chords
- Autocomplete suggestions as you type
- Focus retention for quick multi-chord entry

### Layout Improvements (December 2024)
- Reorganized add/edit song form (Guitar Info before Song Details)
- Fixed chord card spacing in grid view
- Added "Identify a Chord" button to empty state

## Technical Details

### Architecture
- **SwiftUI** - Modern declarative UI framework
- **CloudKit** - iCloud sync using CloudKit containers
- **AVFoundation** - Real-time pitch detection for tuner
- **Combine** - Reactive state management

### Key Components
- `SongStore` - Central state management for songs
- `ChordLibrary` - Chord data and fingering positions
- `AudioPitchDetector` - Real-time tuner functionality
- `SpotifyService` - Spotify API integration
- `HapticManager` - Centralized haptic feedback

### Services
- **HapticManager** - Provides light, medium, heavy, success, and error haptics
- **SpotifyService** - Handles authentication and API calls
- **TabURLDetector** - Detects Ultimate Guitar tab URLs

## Data Model

### Song
```swift
struct Song {
    let id: UUID
    var title: String
    var artist: String
    var chords: [String]
    var capoPosition: Int
    var tuning: String
    var dateAdded: Date
    var spotifyUrl: String?
    var tabUrl: String?
    var albumCoverUrl: String?
    var notes: String?
    var isFavorite: Bool
    var categories: [String]
}
```

### ChordData
```swift
struct ChordData {
    let fingers: [Int]  // Fret positions for each string
    let name: String
    let barre: Int?     // Barre fret if applicable
}
```

## Requirements
- iOS 17.0+
- iPhone and iPad support
- iCloud account (optional, for sync)

## Privacy
- **No data collection** - All data stays on your device or in your iCloud
- **Microphone permission** - Required for tuner functionality only
- **iCloud permission** - Optional, for syncing across devices

## App Store
Available on the [App Store](https://apps.apple.com/us/app/fret-not/id6756530936)

## Feedback
Email: fretnotapp@gmail.com

## Version
1.1.0 (Build 2)

## Author
Built by Alexa Kaminsky
[alexakaminsky.com](https://alexakaminsky.com)

---

*Fret Not - The songs you'll never forget*
