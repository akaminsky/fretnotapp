# iPad Experience Audit - Fret Not

## Critical Design Issue: Inconsistent Navigation Patterns

### The Problem
**SongDetailView** is presented as a **sheet** from ContentView, but **ChordDetailPageView** uses **push navigation** (NavigationLink). This creates inconsistent UX and is the root cause of many iPad issues.

**Current Behavior:**
- Tap song → Sheet appears (cramped on iPad)
- Tap chord → Push navigation (full screen, works great)

**Why This Matters:**
- Sheets with `.presentationDetents([.medium, .large])` are designed for iPhone and look tiny/awkward on iPad
- SongDetailView is a full-featured detail page (not a quick action) - it should be push navigation
- Push navigation on iPad enables split-view/master-detail patterns

### Your Observation is Spot On
> "It makes me wonder, why is it a bottom sheet for the iPhone and not just its own page like we do for the chord details"

**Answer:** There's no good reason! SongDetailView should use the same navigation pattern as ChordDetailPageView.

---

## iPad-Specific Issues Found

### 1. Sheet Presentations That Are Too Small
These views use `.presentationDetents([.medium, .large])` which looks cramped on iPad:

**SongDetailView.swift:**
- Line 976: SpotifyLinkSheet
- Line 1128: CategoryPickerView

**AddSongView.swift:**
- Line 1588: SpotifyLinkSheetForEdit
- Line 1907: Voicing picker

**ChordDiagramView.swift:**
- Line 372: ChangeVoicingSheet

**Issue:** These sheets are sized for iPhone and appear as small floating windows on iPad. Users expect full-screen or larger presentations.

---

### 2. Missing iPad-Specific Layouts

**Chord Grids:**
- Currently shows 3 chords per row (hardcoded)
- iPad has space for 4-6 chords per row
- Located in: ChordDiagramView.swift (line 194), ContentView.swift

**Song List:**
- Single column list on iPad (wasted space)
- Should use 2-column grid or master-detail pattern
- Located in: ContentView.swift

**Forms and Inputs:**
- AddSongView stretches edge-to-edge on iPad (overwhelming)
- Should have max width constraint (like 600-700pt)
- Located in: AddSongView.swift

---

### 3. Onboarding Images

**Current Implementation:**
- Hardcoded image names: "onboarding-1" through "onboarding-7"
- Same images for iPhone and iPad
- Located in: OnboardingView.swift (lines 17-25)

**iPad Issues:**
- iPhone screenshots in onboarding look tiny on iPad
- iPhone aspect ratios don't fill iPad screen properly
- No iPad-specific screenshots showing iPad layouts

**Solution Needed:**
- Conditional loading: "onboarding-ipad-1" vs "onboarding-iphone-1"
- iPad screenshots should show iPad-optimized layouts
- Or use vector graphics/SF Symbols that scale better

---

### 4. Navigation Structure Issues

**ContentView** (Songs tab):
- Has NavigationStack ✅
- Uses sheet for SongDetailView ❌ (should be NavigationLink)
- Line 76: `.sheet(item: $selectedSong)`

**ChordLogView** (Chords tab):
- Has NavigationStack ✅
- Uses NavigationLink for ChordDetailPageView ✅
- Lines 229, 250, 276

**Inconsistency:** Same type of content (detail views) uses different navigation patterns.

---

### 5. Specific UI Elements That Need iPad Adaptation

**Spacing & Padding:**
- Many views use fixed `Spacing.md` (12pt) which feels cramped on iPad
- Should scale: 12pt → 16-20pt on iPad
- Examples: AddSongView padding, ContentView list spacing

**Card Widths:**
- Cards stretch edge-to-edge on iPad
- Should have max width constraints (600-700pt) and center
- Examples: AddSongView form sections, FilterControlsView

**Font Sizes:**
- Currently same across all devices
- Could benefit from `.dynamicTypeSize()` scaling on iPad
- Especially: SongDetailView title, AddSongView inputs

**Bottom Sheets:**
- 31 sheet presentations found across the app
- Many would benefit from full-screen on iPad
- Or at least `.presentationDetents([.large])` instead of `.medium`

---

## Recommended Fix Priority

### High Priority (User-Facing Issues)
1. **Convert SongDetailView to push navigation** - Solves the main inconsistency and iPad sizing issue
2. **Increase chord grid columns on iPad** - Makes better use of space
3. **Add iPad-specific onboarding images** - First impression matters

### Medium Priority (Polish)
4. **Constrain AddSongView width on iPad** - Improves form usability
5. **Update sheet detents for iPad** - Use `.large` or full-screen
6. **Add 2-column song list on iPad** - Better space utilization

### Low Priority (Nice-to-Have)
7. **Adaptive spacing/padding** - Fine-tune layout density
8. **Master-detail layout** (Advanced) - Split view on iPad landscape

---

## Technical Approach

### For Navigation Pattern Fix:
- Change ContentView line 76 from `.sheet(item: $selectedSong)` to use NavigationLink
- Remove dismiss button from SongDetailView toolbar (or make it Back button)
- Update SongRowView to wrap in NavigationLink instead of using `onTap`

### For Onboarding Images:
```swift
let isIPad = UIDevice.current.userInterfaceIdiom == .pad
let imagePrefix = isIPad ? "onboarding-ipad" : "onboarding-iphone"
let imageName = "\(imagePrefix)-\(index + 1)"
```

### For Chord Grid Columns:
```swift
let columns = UIDevice.current.userInterfaceIdiom == .pad ? 5 : 3
LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: columns))
```

### For Sheet Detents on iPad:
```swift
.presentationDetents(UIDevice.current.userInterfaceIdiom == .pad ? [.large] : [.medium, .large])
```

---

## Asset Considerations

**New Assets Needed:**
- 7 iPad onboarding screenshots (1024×1366 for 11" iPad, or 2048×2732 for 12.9")
- Or create universal designs that work at any size

**Image Format:**
- PNG with @2x and @3x variants
- Or use PDF vectors that scale automatically

---

## Summary

The biggest issue is the **inconsistent navigation pattern** between SongDetailView (sheet) and ChordDetailPageView (push). This is:
1. Confusing for users
2. Makes iPad experience feel broken
3. Easy to fix with high impact

The other issues (grid columns, onboarding images, sheet sizes) are polish items that would significantly improve the iPad experience but aren't fundamental UX problems.

**Your instinct was correct** - SongDetailView should be push navigation, just like ChordDetailPageView.
