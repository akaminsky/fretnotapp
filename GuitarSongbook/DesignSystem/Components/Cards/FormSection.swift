//
//  FormSection.swift
//  GuitarSongbook
//
//  A card-style section for form content with an uppercase title
//

import SwiftUI

/// A card-style section for form content with an uppercase title
///
/// Usage:
/// ```swift
/// FormSection(title: "Song Details") {
///     FormTextField(label: "Title", text: $title)
///     FormTextField(label: "Artist", text: $artist)
/// }
/// ```
struct FormSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(title)
                .formLabelStyle()

            content
        }
        .padding(Spacing.lg)
        .warmCard()
    }
}

#Preview {
    FormSection(title: "Example Section") {
        Text("Content goes here")
            .padding()
    }
    .padding()
    .warmBackground()
}
