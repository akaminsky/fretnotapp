//
//  NotesTextField.swift
//  GuitarSongbook
//
//  A multi-line text field for notes with warm styling
//

import SwiftUI

/// A multi-line text field for notes with warm styling
///
/// Usage:
/// ```swift
/// NotesTextField(text: $notes)
/// ```
struct NotesTextField: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool

    var body: some View {
        TextField("Add notes on chord order, technique, or playing tips...", text: $text, axis: .vertical)
            .focused($isFocused)
            .lineLimit(3...6)
            .warmTextField(focused: isFocused)
    }
}

#Preview {
    @Previewable @State var notes = ""

    NotesTextField(text: $notes)
        .padding()
        .warmBackground()
}
