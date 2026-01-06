//
//  Shadows.swift
//  GuitarSongbook
//
//  Shadow presets for consistent depth and elevation throughout the app
//

import SwiftUI

enum ShadowStyle {
    /// Standard card shadow for subtle elevation
    /// Color: black at 5% opacity, Radius: 8pt, Offset: (0, 2)
    /// Usage: cards, sections, form containers
    static let card = (
        color: Color.cardShadow,
        radius: CGFloat(8),
        x: CGFloat(0),
        y: CGFloat(2)
    )

    /// Floating button shadow for prominent elevation
    /// Color: black at 20% opacity, Radius: 8pt, Offset: (0, 4)
    /// Usage: floating action buttons, prominent CTAs
    static let floatingButton = (
        color: Color.floatingButtonShadow,
        radius: CGFloat(8),
        x: CGFloat(0),
        y: CGFloat(4)
    )

    /// Subtle shadow for minimal elevation
    /// Color: black at 5% opacity, Radius: 4pt, Offset: (0, 1)
    /// Usage: small cards, pills, subtle depth
    static let subtle = (
        color: Color.cardShadow,
        radius: CGFloat(4),
        x: CGFloat(0),
        y: CGFloat(1)
    )
}
