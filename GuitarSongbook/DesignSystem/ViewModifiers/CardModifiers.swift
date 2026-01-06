//
//  CardModifiers.swift
//  GuitarSongbook
//
//  Card styling modifiers for consistent card appearance throughout the app
//

import SwiftUI

// MARK: - Warm Card Modifier

struct WarmCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color(.systemBackground))
            .cornerRadius(CornerRadius.card)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.card)
                    .stroke(Color.cardBorder, lineWidth: 0.5)
            )
            .shadow(
                color: ShadowStyle.card.color,
                radius: ShadowStyle.card.radius,
                x: ShadowStyle.card.x,
                y: ShadowStyle.card.y
            )
    }
}

extension View {
    /// Apply warm card styling (white background, rounded corners, border, shadow)
    ///
    /// Usage:
    /// ```swift
    /// VStack {
    ///     Text("Card content")
    /// }
    /// .warmCard()
    /// ```
    ///
    /// Replaces the pattern:
    /// ```swift
    /// .background(Color(.systemBackground))
    /// .cornerRadius(12)
    /// .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.08), lineWidth: 0.5))
    /// .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
    /// ```
    func warmCard() -> some View {
        modifier(WarmCardModifier())
    }
}

// MARK: - Settings Card Modifier

struct SettingsCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color(.systemBackground))
            .cornerRadius(CornerRadius.card)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.card)
                    .stroke(Color.cardBorder, lineWidth: 0.5)
            )
            .shadow(
                color: ShadowStyle.card.color,
                radius: ShadowStyle.card.radius,
                x: ShadowStyle.card.x,
                y: ShadowStyle.card.y
            )
    }
}

extension View {
    /// Apply settings card styling (identical to warmCard but semantically named for settings)
    ///
    /// Usage:
    /// ```swift
    /// VStack {
    ///     Text("Settings content")
    /// }
    /// .settingsCard()
    /// ```
    func settingsCard() -> some View {
        modifier(SettingsCardModifier())
    }
}
