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
- **Custom Chords** - Create and save your own chord variations
  - Add custom diagrams for any chord name
  - Interactive fretboard to place finger positions
  - Real-time matching shows known chords that match your fingering
  - Edit and update existing custom chords
  - Rename chords across all songs
  - iCloud sync keeps custom chords across devices
- **Chord Validation** - Real-time validation as you type
- **Smart Input** - Auto-capitalize chord names, pill-based UI with drag-to-reorder
- **Chord Autocomplete** - Suggestions as you type
- **Chord Identifier** - Interactive fretboard to identify unknown chords, add directly to songs
- **Chord Log** - View all unique chords you've learned across songs
- **Chord Details** - Tap any chord to see all songs using it and create variations

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

### Version 1.3.0 (December 2024)

#### Chord Diagram Rendering Improvements
- **Dynamic Diagram Sizing** - Chord diagrams now automatically adjust height based on fret range
  - Displays exactly 5 frets for optimal readability
  - Starts at the first fretted note for compact display
  - Low-position chords (frets 1-4) display from the nut
- **Fret Number Labels** - Added fret numbers on the left side of diagrams for easy reference
  - Clear labeling of each fret space
  - Helps identify chord positions at a glance
- **Chord Transposition Support** - Use @ notation to transpose chords (e.g., `Bm@7` for Bm at fret 7)
  - Automatically transposes finger positions
  - Validation prevents transposing chords with open strings
  - Smart error messages guide correct usage
  - Works seamlessly with existing chord library
- **Slash Chord Support** - Added 14 common slash chords (C/G, D/F#, Am/G, etc.)
- **Chord Diagram Bug Fixes**
  - Fixed off-by-one error causing chords at fret 9+ to appear blank
  - Corrected finger position alignment in all fret ranges
  - Fixed barre line positioning for accurate chord display
  - Resolved positioning issues for chords with open strings

#### UI/UX Polish
- **Consistent Card Styling** - Unified visual design across the app
  - All cards (songs, chords) now have consistent corner radius (8pt)
  - Matching subtle drop shadows for depth
  - Improved spacing between cards for better readability
- **Optimized Chord Spacing** - Adjusted padding and diagram width for better grid layout
  - More white space between chord cards
  - Cleaner visual hierarchy in chord overview
- **Removed Redundant Elements**
  - Removed "CUSTOM" badge from chord diagrams (visible via edit menu)
  - Removed position markers (e.g., "5fr") since fret labels provide context

#### Custom Chord System
- **Create Custom Chord Diagrams** - Add diagrams for any chord, even those not in the standard library
  - Click "Add Diagram" on any chord without a diagram
  - Interactive fretboard to place finger positions
  - Real-time matching shows if your fingering matches known chords
  - Supports chords with spaces in names
- **Edit Custom Chords** - Update finger positions and chord names
  - Long-press any custom chord diagram to edit
  - Edit from chord detail page
  - Automatic barre detection
- **Smart Chord Renaming** - Rename chords and update all songs automatically
  - Edit chord name when creating or updating
  - All songs using the chord update to the new name
  - Returns to chord list after renaming for easy navigation
- **Chord Detail Pages** - New dedicated page for each chord
  - View large chord diagram
  - See all songs using the chord
  - Create variations from detail page
  - Edit or delete custom chords
- **Custom Chord Management** - Manage all custom chords from Settings
  - View all custom chords with creation dates
  - Delete custom chords (with usage warnings)
  - See chord usage across songs
- **iCloud Sync** - Custom chords sync automatically across all your devices

#### UI/UX Improvements
- **Song Detail Page Reorganization**
  - Added Tuning tab (positioned between Chords and Strumming) for cleaner guitar info organization
  - Moved guitar information (Chords/Tuning/Strumming) above metadata for better prioritization
  - Removed redundant chord, capo, and tuning displays from properties section
  - Moved Spotify play button to top toolbar for easier access
  - Added always-visible favorite toggle next to song title for quick access
  - Favorite star shows filled (orange) when favorited, outline (gray) when not

- **Song List Enhancements**
  - Replaced ellipsis menu button with dedicated "View Details" button using chevron icon
  - Streamlined card actions for clearer navigation
  - Context menu still accessible via long-press for Edit, Play on Spotify, and Delete actions

- **Add/Edit Song Flow**
  - Smart focus management: title field auto-focuses for manual entry, chords field for Spotify imports
  - Song Details section now hidden when adding from Spotify (cleaner interface)
  - When editing Spotify-linked songs: Song Details and album art hidden until unlinked
  - Album art automatically removed when unlinking from Spotify
  - Removed independent album art deletion (tied to Spotify link status)

- **Visual Consistency**
  - Unified all text links and clickable elements to use primary orange accent color
  - Updated all SwiftUI Link components to use brand color instead of system blue
  - Consistent color scheme throughout app for better brand identity

#### Strumming Patterns
- Added "Classic Acoustic" pattern (D-DU-UDU)
- Added "Simple Strum" pattern (D-DU)
- Expanded preset library for more versatile song coverage

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
- `ChordLibrary` - Standard chord library with 200+ chords and fingering positions
- `CustomChordLibrary` - User-created custom chord management with iCloud sync
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

### CustomChordData
```swift
struct CustomChordData {
    let id: UUID
    let fingers: [Int]      // Fret positions: -1 = muted, 0 = open, 1-15 = fret
    let name: String        // Base chord name (e.g., "G")
    let displayName: String // Full name shown to users (e.g., "G (Sweet Home)")
    let barre: Int?         // Barre fret if applicable
    let dateCreated: Date
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
1.3.0 (Build 4)

## Author
Built by Alexa Kaminsky
[alexakaminsky.com](https://alexakaminsky.com)

---

*Fret Not - The songs you'll never forget*
