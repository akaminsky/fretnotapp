# Fret Not - Release Notes

## Version 1.4.1 - Design System & iPad Optimization

### iPad Optimization
- **Unified 800pt layout** across all constrained pages for consistent reading width
- **Adaptive spacing system** - 32pt margins on iPad, 16pt on iPhone for better use of screen space
- **Full-screen modals** on iPad provide immersive editing experience while maintaining focused content width
- **Smart navigation titles** positioned within content area on iPad for perfect alignment
- **Enhanced chord identifier** and variation editor with 800pt constrained width in full-screen presentation

### Design System Implementation
- **Complete visual refresh** with warm color palette throughout the app
- Warm cream background (rgb(250,247,245)) creates a cohesive, inviting feel
- **Consistent card styling** with subtle shadows (5% opacity, 8pt radius) on all white sections
- **Enhanced focus states** with orange accent color and smooth animations on all text inputs
- Updated all bottom sheets with warm backgrounds and improved grouping

### User Experience Enhancements
- **Tappable matched chord badges**: When creating custom chords, you can now tap suggested chord names to instantly add them to your song
- **Custom variation from voicing picker**: Tap any chord diagram, then "Create Custom Variation" to add personalized fingerings directly to your song
- **Improved Spotify search results**: Search result cards now have proper shadows and borders for better visibility

### Technical Improvements
- Centralized design tokens (colors, spacing, shadows, corner radius)
- Adaptive spacing tokens that adjust based on device type
- Reusable view modifiers (`.warmCard()`, `.warmTextField()`, `.maxWidthContainer()`)
- Extracted reusable UI components for consistency
- Backend infrastructure improvements

### Views Updated
- ContentView: 800pt constraint + custom title on iPad
- AddSongView: 800pt constraint + full-screen presentation
- SongDetailView: Full-screen edit modal
- ChordLogView: Full-screen identifier + 4-column grid on iPad
- ChordDetailPageView: Full-screen variation editor with 800pt content
- ChordIdentifierView: 800pt constrained content
- MainTabView: 800pt settings + full-screen modals
- CategoryManagerView: 800pt constraint + focus states + warm background
- CustomChordManagerView: Warm background + grouped style + proper dismiss
- SongSelectorSheet: Warm background + grouped style
- SaveCustomChordSheet: Warm background + grouped form style
- AddLinkSheet: Focus states + warm background + grouped form style
- SpotifySearchResults: Consistent card styling with shadows

---

## Previous Versions

### Version 1.4 - Chord Management & UX Polish
- Multiple resource links support (migrated from single Tab URL)
- First launch onboarding
- Standardized chord creation UX
- Enlarged chord diagram view
- Chord library search functionality
- Bug fixes for drag-and-drop reordering

### Version 1.3.1 - Analytics & Reminders
- Firebase Analytics integration
- Local notification reminders
- Anonymous usage tracking
- Improved tuner sensitivity

### Version 1.3.0 - Community Features
- Share Extension for importing chord charts
- Comprehensive chord voicing management
- Expanded chord library (50+ variations)
- Community data collection

---

*Built with ❤️ by Alexa Kaminsky*
