//
//  FormTextField.swift
//  GuitarSongbook
//
//  A labeled text field with warm styling and focus states
//

import SwiftUI

/// A labeled text field with warm styling and focus states
///
/// Usage:
/// ```swift
/// FormTextField(label: "Title", text: $title, placeholder: "Enter title")
/// ```
struct FormTextField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .formLabelStyle()

            TextField(placeholder, text: $text)
                .focused($isFocused)
                .warmTextField(focused: isFocused)
        }
    }
}

#Preview {
    @Previewable @State var text = ""

    FormTextField(label: "Song Title", text: $text, placeholder: "Enter song title")
        .padding()
        .warmBackground()
}
