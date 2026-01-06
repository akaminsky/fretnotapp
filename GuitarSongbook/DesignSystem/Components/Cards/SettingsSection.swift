//
//  SettingsSection.swift
//  GuitarSongbook
//
//  A settings-style section with title, optional footer, and card styling
//

import SwiftUI

/// A settings-style section with title, optional footer, and card styling
///
/// Usage:
/// ```swift
/// SettingsSection(title: "General", footer: "App settings") {
///     SettingsRow { Toggle("Dark Mode", isOn: $darkMode) }
///     SettingsRow { Text("Version 1.0") }
/// }
/// ```
struct SettingsSection<Content: View>: View {
    let title: String
    let footer: String?
    @ViewBuilder let content: Content

    init(title: String, footer: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.footer = footer
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(title)
                .formLabelStyle()
                .padding(.horizontal, Spacing.lg)

            VStack(spacing: 0) {
                content
            }
            .settingsCard()

            if let footer = footer {
                Text(footer)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.xs)
            }
        }
    }
}

#Preview {
    SettingsSection(title: "Example", footer: "This is a footer") {
        SettingsRow {
            Text("Row 1")
        }
        Divider()
        SettingsRow {
            Text("Row 2")
        }
    }
    .padding()
    .warmBackground()
}
