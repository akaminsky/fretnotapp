//
//  CommonModifiers.swift
//  GuitarSongbook
//
//  Common utility modifiers used throughout the app
//

import SwiftUI

// MARK: - Warm Background Modifier

struct WarmBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.warmBackground)
    }
}

extension View {
    /// Apply warm cream background color
    ///
    /// Usage:
    /// ```swift
    /// ZStack {
    ///     // Content
    /// }
    /// .warmBackground()
    /// ```
    ///
    /// Replaces:
    /// ```swift
    /// .background(Color.warmBackground)
    /// ```
    func warmBackground() -> some View {
        modifier(WarmBackgroundModifier())
    }
}
