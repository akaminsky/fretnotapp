//
//  Colors.swift
//  GuitarSongbook
//
//  Centralized color palette for the design system
//

import SwiftUI

extension Color {
    // MARK: - Brand Colors

    /// Primary accent color for buttons, icons, interactive elements (#F38C03)
    static let appAccent = Color(red: 0.953, green: 0.549, blue: 0.012)

    /// Darker accent for text on light backgrounds (WCAG AA compliant, #B35A00)
    static let appAccentText = Color(red: 0.702, green: 0.353, blue: 0.0)

    // MARK: - Background Colors
 
    /// Warm cream background for main views (rgb(250, 247, 245))
    static let warmBackground = Color(red: 0.98, green: 0.97, blue: 0.96)

    /// Warm cream for input fields and subtle backgrounds (rgb(254, 252, 251))
    static let warmInputBackground = Color(red: 0.995, green: 0.99, blue: 0.985)

    // MARK: - Border Colors

    /// Warm taupe for subtle card borders (rgb(235, 230, 224))
    static let warmBorder = Color(red: 0.92, green: 0.90, blue: 0.88)

    /// Medium warm taupe for input borders (rgb(210, 200, 190))
    static let inputBorder = Color(red: 0.824, green: 0.784, blue: 0.745)

    // MARK: - Shadow Colors

    /// Standard card shadow color (black at 5% opacity)
    static let cardShadow = Color.black.opacity(0.05)

    /// Border overlay for cards (black at 8% opacity)
    static let cardBorder = Color.black.opacity(0.08)

    /// Floating button shadow (black at 20% opacity)
    static let floatingButtonShadow = Color.black.opacity(0.2)
}
