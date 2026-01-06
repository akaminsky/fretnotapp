//
//  Typography.swift
//  GuitarSongbook
//
//  Typography styles and text modifiers for consistent text styling throughout the app
//

import SwiftUI

extension Font {
    // MARK: - Form Labels

    /// Uppercase form label style (.caption, semibold weight)
    /// Usage: section headers, form field labels
    static let formLabel = Font.caption.weight(.semibold)

    /// Standard form label style (.caption, medium weight)
    /// Usage: secondary form labels, subtle headers
    static let formLabelMedium = Font.caption.weight(.medium)
}

extension Text {
    /// Apply form label styling with uppercase and secondary color
    /// Usage: Apply to Text views for consistent form label appearance
    /// Example: Text("Song Title").formLabelStyle()
    func formLabelStyle() -> some View {
        self
            .font(.formLabel)
            .foregroundColor(.secondary)
            .textCase(.uppercase)
    }
}
