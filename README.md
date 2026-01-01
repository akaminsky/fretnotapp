# Fret Not - Guitar Songbook

A comprehensive iOS app for guitarists to track songs, learn chords, and stay in tune.

## Features

### 🎵 Song Management
- **Add Songs Manually** - Quick entry with title (required), artist, chords, capo position, tuning, and notes
- **Spotify Integration** - Search and import songs directly from Spotify
- **Intelligent Chord Suggestions** - Automatic chord recommendations based on song analysis
  - Analyzes song key and mode using Spotify audio features
  - Generates chord progressions based on music theory
  - Capo-aware transposition for easier chord shapes
  - Interactive tap-to-add interface
- **Bulk Import** - Import entire Spotify playlists at once
- **Auto-fill** - Automatically populate song details from Spotify (editable)
- **Song Metadata** - Automatically capture key signature and tempo from Spotify
- **Tuning Support** - Track tuning for each song (Standard, Drop D, Drop C, Half Step Down, Open D, Open G, or custom)
- **Custom Lists** - Organize songs into custom categories
- **Favorites** - Mark songs as favorites for quick access
- **Search & Filter** - Find songs by title, artist, chord, capo, or list

### 🎸 Chord Features
- **Chord Library** - 250+ guitar chords with diagrams and alternative voicings
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

### 🎼 Strumming Patterns
- **Strumming Pattern Library** - Preset patterns for different playing styles
- **Multiple Patterns Per Song** - Attach multiple strumming patterns to each song
- **Visual Pattern Display** - Clear notation showing down/up strums (D-DU-UDU)
- **Common Presets** - Classic Acoustic, Simple Strum, and more

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

### Version 1.4 (January 2025)

#### Share Extension - Import Chord Charts
- **Import from Any App** - Share chord charts directly into Fret Not from any app
  - Works with Ultimate Guitar, Safari, Notes, Messages, Mail, Files, and more
  - Native iOS share sheet integration
  - Quick import workflow with confirmation preview
- **Smart Text Parsing** - Automatically extracts chord information
  - Detects capo position (e.g., "Capo 2" → sets capo to 2)
  - Identifies all unique chords in the chart (Am, E7, G, D, etc.)
  - Preserves full chord chart text in notes for reference
  - Filters out tablature, instructions, and false positives
- **Pre-filled Song Entry** - Opens AddSongView with extracted data
  - Chords field pre-populated with comma-separated chord list
  - Capo position automatically set
  - Notes field contains full chord chart for reference
  - User adds song title/artist manually or links to Spotify
- **Background Processing** - Data shared via App Group for seamless handoff
  - Share Extension processes text and saves to shared storage
  - Main app opens with pre-filled data ready to save
  - Clean UX with no data loss

#### Chord Library Search
- **Full Library Lookup** - Search and view any chord from the 200+ chord library
  - Progressive disclosure: default view shows only your learned chords
  - Search activates full library (user's chords + all library chords)
  - No need to add a chord to a song to see how to play it
- **Smart Search Results** - Partitioned display for better organization
  - User's chords appear first (chords you've used in songs)
  - Visual divider separates the two groups
  - Library chords appear below (chords you haven't used yet)
  - Alphabetical sorting within each group
- **Usage Indicators** - Clear feedback about chord usage
  - Header shows breakdown: "12 chords (4 used in your songs)"
  - Default view: "5 chords in your songs"
  - Helps distinguish learned vs. new chords
- **Enhanced Search** - Improved placeholder text
  - "Search your chords and library" makes feature discoverable
  - Works with chord name search (partial matching)

#### Bug Fixes & Improvements
- **Fixed Chord Pill Drag Crash** - Resolved crash when reordering chord pills via drag-and-drop
  - Moved binding update from drag event to drop completion
  - Smooth drag-and-drop experience without crashes
- **Fixed Notification Scheduling** - Practice and add song reminders now fire reliably
  - Corrected "Every Other Day" frequency (now schedules 30 notifications over 60 days)
  - Fixed default settings (reminders now default to enabled as intended)
  - All frequencies work correctly: Daily, Every Other Day, Weekly
- **Standardized Chord Names** - Simplified chord library to use standard guitar notation
  - Changed verbose names to standard: "D Suspended 4" → "Dsus4"
  - Removed 80+ lines of variation matching code
  - All 210+ chords now use clean, consistent names
  - Improved chord matching and search accuracy

### Version 1.3.1 (December 2024)

#### Chord Voicing Management System
- **Default Voicing Selection** - Smart chord library now picks default (textbook) voicings automatically
  - Each chord marked as default or alternative voicing
  - Typing "G" automatically uses standard 320003 fingering
  - Over 25 chords marked as default (C, D, E, F, G, A, B and their minor/seventh variants)
- **Alternate Voicing Picker** - Tap any chord pill to see and select different fingerings
  - View all available voicings side-by-side
  - Visual comparison with fingerprint notation
  - "Default" badge highlights standard fingerings
  - "Create Voicing" button to add custom alternatives
- **Voicing Notation** - Internal fingerprint system (e.g., "G#320033") keeps voicings separate
  - Clean display shows only chord name (not notation)
  - Each unique fingering tracked separately
  - Backward compatible with existing songs
- **Custom Chord Integration** - Create custom chords directly from chord input
  - Type unknown chord → see "Create custom chord" option
  - Chord name pre-filled for quick creation
  - Custom chords appear in autocomplete suggestions
  - Auto-replaces pill when creating from voicing picker
- **Enhanced Chord Input** - Improved pill-based chord entry
  - Tap pill to change voicing after adding
  - Supports chords with spaces (e.g., "C (barre alt)")
  - Helper text: "Tap for alternate fingerings"
  - Works in both add and edit song modes
- **Chord Name Aliases** - Added short names for common chords
  - E7, Am7, D7, A7, G7, C7, B7, Dm7, Em7, etc.
  - Duplicates with easier-to-type names
  - Preserves backward compatibility with full names

#### Tuner Improvements
- **Corrected String Display** - Tuner now displays strings in correct EADGBE order (low to high)
  - Standard tuning: E A D G B E (left to right)
  - All tunings now follow natural guitar layout
  - String numbers still show correctly (6 5 4 3 2 1)
- **Improved Pitch Detection** - Enhanced sensitivity and accuracy
  - More sensitive to quieter guitar strings
  - Better noise filtering (60-1200 Hz range)
  - More stable readings with increased smoothing (8 samples)
  - Lower detection thresholds for picking up softer notes
  - Works better with acoustic guitars and lighter picking

#### Expanded Chord Library
- **50+ New Chord Variations** - Added commonly used alternative voicings
  - G variations (no high e, open high e, no low E)
  - Barre chord shapes for C, D, A at different positions
  - Alternative 7th chord voicings (C7, D7, E7, A7, B7)
  - More 9th chords (E9, A9, B9, F9, G9 variations)
  - Major 7th alternatives (Cmaj7, Dmaj7, Emaj7, Gmaj7, Amaj7)
  - Minor 7th variations (Am7, Dm7, Em7)
  - Power chords at higher fret positions (3rd, 5th, 7th, 8th, 10th, 12th frets)
  - Minor barre chords (Am, Dm, Em at different positions)
- **Improved Chord Recognition** - Chord identifier now recognizes common fingering variations
  - G with or without high E string
  - Barre chord shapes (e.g., C at 3rd fret, D at 5th fret)
  - Alternative voicings for 7th and 9th chords

#### Local Notification Reminders
- **Practice Reminders** - Get reminded to practice your songs regularly
  - Toggle on/off in Settings
  - Frequency options: Daily, Every Other Day, or Weekly
  - Customizable time (default: 7:00 PM)
  - Enabled by default (Every Other Day)
  - Random motivational messages
- **Add Song Reminders** - Get reminded to grow your songbook
  - Separate toggle and settings from practice reminders
  - Frequency options: Daily, Every Other Day, or Weekly
  - Customizable time (default: 7:00 PM)
  - Enabled by default (Weekly)
  - Encourages continuous learning
- **Device-Only Notifications** - All notifications scheduled locally on your device
  - No server required
  - Complete privacy
  - Works offline
- **Independent Controls** - Each reminder type can be enabled/disabled separately
  - Practice without being reminded to add songs
  - Vice versa, or both at once

#### Firebase Analytics Integration
- **Google Analytics 4** - Integrated Firebase Analytics for comprehensive usage insights
  - Anonymous event tracking for feature usage
  - Dual tracking to both Firebase (for Google Analytics dashboard) and Supabase (for custom queries)
  - Tracks song additions, custom chord creation, chord suggestions, transpositions, tuner usage
  - No personal information collected - only feature usage patterns
  - Helps prioritize future features based on actual usage data

### Version 1.3.0 (December 2024)

#### Intelligent Chord Suggestions
- **Automatic Chord Suggestions** - Suggest chords when importing from Spotify
  - Analyzes song key, mode, and tempo using Spotify audio features
  - Generates chord progressions based on music theory
  - Capo-aware: suggestions transpose automatically based on capo position
  - Works in both add and edit modes
- **Interactive Suggestions** - Tap suggested chord pills to add them to your song
  - Visual feedback shows which chords are already added
  - "Add All" button to quickly add entire progression
  - Suggestions update when you change capo position
- **Loading States** - Clear feedback while fetching suggestions
  - Animated loading indicator with message
  - Minimum 250ms display time for smooth UX
  - Save button disabled until suggestions load
- **Song Metadata** - Automatically captures and displays song information
  - Key signature (e.g., "C♯ Major", "A Minor")
  - Tempo in BPM (e.g., "120 BPM")
  - Displayed in properties section on song detail page
  - Syncs across devices with iCloud

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
  - 3-column chord diagram layout for better use of screen space
  - Notes section now appears above metadata for better hierarchy
  - Key and Tempo integrated into properties section (no separate section)
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
- **New Strumming Pattern System** - Track and practice strumming patterns for each song
  - Preset library with common patterns (Classic Acoustic, Simple Strum, and more)
  - Visual strumming pattern display in song details
  - Attach multiple patterns to songs for versatile coverage
  - "Classic Acoustic" pattern (D-DU-UDU)
  - "Simple Strum" pattern (D-DU)

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

### Data & Analytics (December 2024)
- **Anonymous Community Contributions** - Optionally share chord data to help other guitarists
  - Anonymous chord progressions, capo positions, and tuning information
  - No personal information collected - only musical data
  - Can be disabled in Settings → "Share my songs anonymously"
  - Building dataset for future community chord suggestion features
- **Anonymous Usage Analytics** - Help improve the app through anonymous feature usage tracking
  - Tracks how songs are added (manual vs Spotify)
  - Tracks custom chord creation
  - Tracks chord suggestion usage
  - Tracks strumming pattern and notes usage
  - No personal information, song titles, or identifying details collected

### Filter Improvements (December 2024)
- **Smooth Filter Animations** - Replaced janky Menu animations with instant confirmationDialog updates
  - Filter pills now update instantly with no animation
  - Chord and Capo filters use native iOS bottom sheet selection
  - Improved readability with white backgrounds and black text
- **Enhanced Filter UI**
  - Clear button replaced with easy-to-tap orange circular icon
  - White filter pill backgrounds with orange borders when active
  - Fixed "Capo Capo 3" display bug (now shows "Capo: 3")
  - Better contrast for filter text visibility

## Technical Details

### Architecture
- **SwiftUI** - Modern declarative UI framework
- **CloudKit** - iCloud sync using CloudKit containers
- **AVFoundation** - Real-time pitch detection for tuner
- **Combine** - Reactive state management
- **Firebase Analytics** - Google Analytics 4 for usage tracking
- **UserNotifications** - Local notification scheduling

### Key Components
- `SongStore` - Central state management for songs
- `ChordLibrary` - Standard chord library with 250+ chords and fingering positions
- `CustomChordLibrary` - User-created custom chord management with iCloud sync
- `AudioPitchDetector` - Real-time tuner functionality
- `SpotifyService` - Spotify API integration
- `ChordSuggestionService` - Intelligent chord suggestions based on audio analysis
- `HapticManager` - Centralized haptic feedback
- `CommunityDataService` - Anonymous data contribution and analytics
- `AnalyticsService` - Firebase Analytics and Supabase tracking
- `NotificationManager` - Local practice and add song reminder notifications
- `ShareExtensionHandler` - Share Extension data handling and main app integration
- `ChordChartParser` - Text parsing for chord chart imports

### Services
- **HapticManager** - Provides light, medium, heavy, success, and error haptics
- **SpotifyService** - Handles authentication and API calls
- **ChordSuggestionService** - Generates chord suggestions using audio analysis and music theory
- **CommunityDataService** - Manages anonymous community contributions (optional)
- **AnalyticsService** - Tracks anonymous feature usage to Firebase Analytics and Supabase
- **NotificationManager** - Manages local practice and add song reminder notifications
- **TabURLDetector** - Detects Ultimate Guitar tab URLs

### Backend Services
- **Netlify Functions** - Serverless functions for Spotify integration and data collection
  - `spotify-search.js` - Search Spotify catalog
  - `spotify-playlist.js` - Import Spotify playlists
  - `community-contribute.js` - Store anonymous community contributions
  - `analytics-track.js` - Store anonymous usage analytics
- **Supabase** - Secure cloud database for anonymous community data and analytics
  - PostgreSQL database with Row-Level Security (RLS)
  - Encrypted data storage and transmission

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
    var key: Int?           // 0-11 (C, C#, D, ..., B)
    var mode: Int?          // 0 = minor, 1 = major
    var tempo: Double?      // BPM
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

### What Stays on Your Device
- **Your Personal Song Library** - All songs, notes, and practice data stay private on your device
- **Custom Chords** - Your custom chord diagrams (synced via your personal iCloud)
- **Settings and Preferences** - Your app configuration

### Optional Anonymous Data Collection
- **Community Contributions** - Anonymous chord data to help other guitarists (opt-out available)
  - Chord progressions, capo positions, tuning information
  - No personal information, song titles, or identifying details
  - Can be disabled in Settings → "Share my songs anonymously"
- **Usage Analytics** - Anonymous feature usage to improve the app
  - Tracks which features are used (no personal data or song titles)
  - Helps prioritize development and improvements

### Permissions
- **Microphone** - Required for tuner functionality only (audio never recorded or transmitted)
- **Notifications** - Optional, for practice and songbook growth reminders (scheduled locally on device)
- **iCloud** - Optional, for syncing your personal data across devices

### GDPR Compliance
- Right to access anonymous data
- Right to delete anonymous contributions
- Right to opt-out at any time
- Full privacy policy: [https://fretnot.app/privacy.html](https://fretnot.app/privacy.html)

## App Store
Available on the [App Store](https://apps.apple.com/us/app/fret-not/id6756530936)

## Feedback
Email: fretnotapp@gmail.com

## Version
1.4 (Build 6)

## Author
Built by Alexa Kaminsky
[alexakaminsky.com](https://alexakaminsky.com)

---

*Fret Not - The songs you'll never forget*
