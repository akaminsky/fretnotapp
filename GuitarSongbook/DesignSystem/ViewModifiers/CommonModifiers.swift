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

// MARK: - Max Width Container Modifier

struct MaxWidthContainerModifier: ViewModifier {
    let maxWidth: CGFloat

    func body(content: Content) -> some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            content
                .frame(maxWidth: maxWidth)
                .frame(maxWidth: .infinity) // Center content
        } else {
            content
        }
    }
}

extension View {
    /// Apply max width constraint on iPad to prevent edge-to-edge stretching
    ///
    /// Usage:
    /// ```swift
    /// VStack {
    ///     // Content
    /// }
    /// .maxWidthContainer(700)
    /// ```
    ///
    /// On iPad: Constrains content to maxWidth and centers it
    /// On iPhone: No constraint applied (full width)
    ///
    /// - Parameter maxWidth: Maximum width in points (default: 700)
    func maxWidthContainer(_ maxWidth: CGFloat = 700) -> some View {
        modifier(MaxWidthContainerModifier(maxWidth: maxWidth))
    }
}
