//
//  FilterControlsView.swift
//  GuitarSongbook
//
//  Filter and search controls - Notion inspired
//

import SwiftUI

struct FilterControlsView: View {
    @EnvironmentObject var songStore: SongStore
    @State private var showFilters = false
    
    var body: some View {
        VStack(spacing: 10) {
            // Search Bar with Filter Icon - Notion style
            HStack(spacing: 10) {
                // Search Field
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("Search...", text: $songStore.searchText)
                        .font(.subheadline)
                    
                    if !songStore.searchText.isEmpty {
                        Button {
                            songStore.searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.subheadline)
                                .foregroundColor(Color(.tertiaryLabel))
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                
                // Filter Button - Notion style
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showFilters.toggle()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.subheadline)
                        
                        if songStore.hasActiveFilters {
                            Text("\(activeFilterCount)")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 16, height: 16)
                                .background(Color.appAccent)
                                .clipShape(Circle())
                        }
                    }
                    .foregroundColor(songStore.hasActiveFilters ? .appAccent : .secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(songStore.hasActiveFilters ? Color.appAccent : Color(.systemGray4), lineWidth: 1)
                    )
                }
                
                // Sort Button
                Menu {
                    ForEach(SortColumn.allCases, id: \.self) { column in
                        Button {
                            if songStore.sortColumn == column {
                                songStore.sortDirection.toggle()
                            } else {
                                songStore.sortColumn = column
                                songStore.sortDirection = .ascending
                            }
                        } label: {
                            HStack {
                                Text(column.displayName)
                                if songStore.sortColumn == column {
                                    Image(systemName: songStore.sortDirection == .ascending ? "arrow.up" : "arrow.down")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: songStore.sortDirection == .ascending ? "arrow.up" : "arrow.down")
                            .font(.caption)
                        Text(songStore.sortColumn.displayName)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                }
            }
            
            // Expandable Filter Section
            if showFilters {
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        // Chord Filter
                        Menu {
                            Button("All Chords") {
                                songStore.filterChord = ""
                            }
                            Divider()
                            Button("Has Chords") {
                                songStore.filterChord = "__HAS_CHORDS__"
                            }
                            Button("No Chords") {
                                songStore.filterChord = "__NO_CHORDS__"
                            }
                            if !songStore.allUniqueChords.isEmpty {
                                Divider()
                                ForEach(songStore.allUniqueChords, id: \.self) { chord in
                                    Button(chord) {
                                        songStore.filterChord = chord
                                    }
                                }
                            }
                        } label: {
                            FilterPill(
                                label: "Chord",
                                value: songStore.filterChord.isEmpty ? nil : getChordFilterDisplayValue(songStore.filterChord)
                            )
                        }
                        
                        // Capo Filter
                        Menu {
                            Button("All") {
                                songStore.filterCapo = ""
                            }
                            Divider()
                            Button("No Capo") {
                                songStore.filterCapo = "0"
                            }
                            ForEach(1...7, id: \.self) { fret in
                                Button("\(fret)\(ordinalSuffix(fret)) Fret") {
                                    songStore.filterCapo = String(fret)
                                }
                            }
                        } label: {
                            FilterPill(
                                label: "Capo",
                                value: songStore.filterCapo.isEmpty ? nil : formatCapo(songStore.filterCapo)
                            )
                        }
                        
                        Spacer()
                        
                        if songStore.hasActiveFilters {
                            Button {
                                songStore.clearFilters()
                            } label: {
                                Text("Clear")
                                    .font(.subheadline)
                                    .foregroundColor(.appAccent)
                            }
                        }
                    }
                }
                .padding(.top, 4)
            }
            
            // Active filters chips (when collapsed)
            if !showFilters && songStore.hasActiveFilters {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        if !songStore.filterChord.isEmpty {
                            ActiveFilterChip(
                                icon: "music.note",
                                label: getChordFilterDisplayValue(songStore.filterChord)
                            ) {
                                songStore.filterChord = ""
                            }
                        }
                        
                        if !songStore.filterCapo.isEmpty {
                            ActiveFilterChip(
                                icon: "guitars",
                                label: formatCapo(songStore.filterCapo)
                            ) {
                                songStore.filterCapo = ""
                            }
                        }
                    }
                }
            }
        }
        .padding(.bottom, 4)
    }
    
    private var activeFilterCount: Int {
        var count = 0
        if !songStore.filterChord.isEmpty { count += 1 }
        if !songStore.filterCapo.isEmpty { count += 1 }
        return count
    }
    
    private func formatCapo(_ value: String) -> String {
        if value == "0" { return "No Capo" }
        if let num = Int(value) {
            return "Capo \(num)"
        }
        return value
    }
    
    private func ordinalSuffix(_ number: Int) -> String {
        switch number {
        case 1: return "st"
        case 2: return "nd"
        case 3: return "rd"
        default: return "th"
        }
    }
    
    private func getChordFilterDisplayValue(_ filterValue: String) -> String {
        switch filterValue {
        case "__NO_CHORDS__":
            return "No Chords"
        case "__HAS_CHORDS__":
            return "Has Chords"
        default:
            return filterValue
        }
    }
}

// MARK: - Filter Pill

struct FilterPill: View {
    let label: String
    let value: String?
    
    var body: some View {
        HStack(spacing: 6) {
            Text(label)
                .foregroundColor(.secondary)
            
            if let value = value {
                Text(value)
                    .foregroundColor(.appAccent)
                    .fontWeight(.medium)
            } else {
                Text("All")
                    .foregroundColor(.primary)
            }
            
            Image(systemName: "chevron.down")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .font(.subheadline)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(value != nil ? Color.appAccent.opacity(0.1) : Color(.systemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(value != nil ? Color.appAccent.opacity(0.3) : Color(.systemGray4), lineWidth: 1)
        )
    }
}

// MARK: - Active Filter Chip

struct ActiveFilterChip: View {
    let icon: String
    let label: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
            
            Text(label)
                .font(.subheadline)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption2)
                    .fontWeight(.semibold)
            }
        }
        .foregroundColor(.appAccent)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.appAccent.opacity(0.12))
        .cornerRadius(20)
    }
}

#Preview {
    VStack {
        FilterControlsView()
            .environmentObject(SongStore())
        Spacer()
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
