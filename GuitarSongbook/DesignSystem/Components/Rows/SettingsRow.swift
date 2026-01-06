//
//  SettingsRow.swift
//  GuitarSongbook
//
//  A row container for settings content with standard padding
//

import SwiftUI

/// A row container for settings content with standard padding
///
/// Usage:
/// ```swift
/// SettingsRow {
///     HStack {
///         Image(systemName: "gear")
///         Text("Settings")
///     }
/// }
/// ```
struct SettingsRow<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            content
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.md)
        }
    }
}

#Preview {
    SettingsRow {
        HStack {
            Image(systemName: "star.fill")
            Text("Example Row")
            Spacer()
            Text("Value")
                .foregroundColor(.secondary)
        }
    }
    .warmCard()
    .padding()
}
