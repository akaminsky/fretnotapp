//
//  Spacing.swift
//  GuitarSongbook
//
//  Spacing scale for consistent padding and margins throughout the app
//

import SwiftUI

enum Spacing {
    /// Extra small spacing - 4pt
    /// Usage: tight gaps between related items
    static let xs: CGFloat = 4

    /// Small spacing - 8pt
    /// Usage: standard gap between related items, section internal spacing
    static let sm: CGFloat = 8

    /// Medium spacing - 12pt
    /// Usage: input padding, card internal spacing, compact sections
    static let md: CGFloat = 12

    /// Large spacing - 16pt
    /// Usage: section padding, horizontal page padding, comfortable gaps
    static let lg: CGFloat = 16

    /// Extra large spacing - 20pt
    /// Usage: page padding, larger section gaps
    static let xl: CGFloat = 20

    /// Extra extra large spacing - 24pt
    /// Usage: major section separators, page-level spacing
    static let xxl: CGFloat = 24
}
