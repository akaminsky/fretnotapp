//
//  CornerRadius.swift
//  GuitarSongbook
//
//  Border radius values for consistent rounded corners throughout the app
//

import SwiftUI

enum CornerRadius {
    /// Small radius - 4pt
    /// Usage: compact elements, tight corners
    static let sm: CGFloat = 4

    /// Medium radius - 6pt
    /// Usage: buttons, small cards, compact components
    static let md: CGFloat = 6

    /// Input radius - 8pt
    /// Usage: text fields, text editors, search inputs
    static let input: CGFloat = 8

    /// Pill radius - 10pt
    /// Usage: pills, medium rounded components
    static let pill: CGFloat = 10

    /// Card radius - 12pt
    /// Usage: cards, sections, large containers
    static let card: CGFloat = 12

    /// Large pill radius - 16pt
    /// Usage: large pill buttons, prominent rounded elements
    static let largePill: CGFloat = 16

    /// Category pill radius - 20pt
    /// Usage: category filter pills, extra rounded buttons
    static let categoryPill: CGFloat = 20
}
