//
//  ButtonModifiers.swift
//  GuitarSongbook
//
//  Button styling modifiers for consistent button appearance
//

import SwiftUI

// MARK: - Primary Button Modifier

struct PrimaryButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .buttonStyle(.borderedProminent)
            .tint(.appAccent)
    }
}

extension View {
    /// Apply primary button styling (bordered prominent with app accent color)
    ///
    /// Usage:
    /// ```swift
    /// Button("Save") { save() }
    ///     .primaryButton()
    /// ```
    func primaryButton() -> some View {
        modifier(PrimaryButtonModifier())
    }
}

// MARK: - Floating Action Button Modifier

struct FloatingActionButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title2.weight(.semibold))
            .foregroundColor(.white)
            .frame(width: 56, height: 56)
            .background(Color.appAccent)
            .cornerRadius(28)
            .shadow(
                color: ShadowStyle.floatingButton.color,
                radius: ShadowStyle.floatingButton.radius,
                x: ShadowStyle.floatingButton.x,
                y: ShadowStyle.floatingButton.y
            )
    }
}

extension View {
    /// Apply floating action button styling (circular, 56x56, orange background, prominent shadow)
    ///
    /// Usage:
    /// ```swift
    /// Button {
    ///     addSong()
    /// } label: {
    ///     Image(systemName: "plus")
    /// }
    /// .floatingActionButton()
    /// ```
    func floatingActionButton() -> some View {
        modifier(FloatingActionButtonModifier())
    }
}

// MARK: - Icon Button Modifier

struct IconButtonModifier: ViewModifier {
    let size: CGFloat
    let backgroundColor: Color
    let foregroundColor: Color

    init(
        size: CGFloat = 32,
        backgroundColor: Color = Color.appAccent.opacity(0.1),
        foregroundColor: Color = .appAccent
    ) {
        self.size = size
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }

    func body(content: Content) -> some View {
        content
            .foregroundColor(foregroundColor)
            .frame(width: size, height: size)
            .background(backgroundColor)
            .cornerRadius(size / 2)
    }
}

extension View {
    /// Apply icon button styling (circular background for icon buttons)
    ///
    /// Usage:
    /// ```swift
    /// Button {
    ///     clearFilters()
    /// } label: {
    ///     Image(systemName: "xmark")
    /// }
    /// .iconButton()
    /// ```
    ///
    /// Custom styling:
    /// ```swift
    /// .iconButton(size: 40, backgroundColor: .red.opacity(0.1), foregroundColor: .red)
    /// ```
    func iconButton(
        size: CGFloat = 32,
        backgroundColor: Color = Color.appAccent.opacity(0.1),
        foregroundColor: Color = .appAccent
    ) -> some View {
        modifier(IconButtonModifier(
            size: size,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor
        ))
    }
}
