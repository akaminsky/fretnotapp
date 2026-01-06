//
//  InputModifiers.swift
//  GuitarSongbook
//
//  Input field styling modifiers with focus state support
//

import SwiftUI

// MARK: - Warm Text Field Modifier

struct WarmTextFieldModifier: ViewModifier {
    let focused: Bool

    func body(content: Content) -> some View {
        content
            .padding(Spacing.md)
            .background(Color.warmInputBackground)
            .cornerRadius(CornerRadius.input)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.input)
                    .stroke(
                        focused ? Color.appAccent.opacity(0.4) : Color.inputBorder,
                        lineWidth: 1
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: focused)
    }
}

extension View {
    /// Apply warm text field styling with focus state
    ///
    /// Usage:
    /// ```swift
    /// @FocusState private var isFocused: Bool
    ///
    /// TextField("Search...", text: $query)
    ///     .focused($isFocused)
    ///     .warmTextField(focused: isFocused)
    /// ```
    ///
    /// Replaces the pattern:
    /// ```swift
    /// .padding(12)
    /// .background(Color.warmInputBackground)
    /// .cornerRadius(8)
    /// .overlay(
    ///     RoundedRectangle(cornerRadius: 8)
    ///         .stroke(isFocused ? Color.appAccent.opacity(0.4) : Color.inputBorder, lineWidth: 1)
    /// )
    /// .animation(.easeInOut(duration: 0.2), value: isFocused)
    /// ```
    func warmTextField(focused: Bool) -> some View {
        modifier(WarmTextFieldModifier(focused: focused))
    }
}

// MARK: - Warm Text Editor Modifier

struct WarmTextEditorModifier: ViewModifier {
    let focused: Bool

    func body(content: Content) -> some View {
        content
            .padding(Spacing.md)
            .background(Color.warmInputBackground)
            .cornerRadius(CornerRadius.input)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.input)
                    .stroke(
                        focused ? Color.appAccent.opacity(0.4) : Color.inputBorder,
                        lineWidth: 1
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: focused)
    }
}

extension View {
    /// Apply warm text editor styling with focus state
    ///
    /// Usage:
    /// ```swift
    /// @FocusState private var isFocused: Bool
    ///
    /// TextEditor(text: $notes)
    ///     .focused($isFocused)
    ///     .frame(minHeight: 120)
    ///     .warmTextEditor(focused: isFocused)
    /// ```
    func warmTextEditor(focused: Bool) -> some View {
        modifier(WarmTextEditorModifier(focused: focused))
    }
}
