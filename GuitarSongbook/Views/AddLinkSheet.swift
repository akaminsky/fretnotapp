//
//  AddLinkSheet.swift
//  GuitarSongbook
//
//  Sheet for adding individual resource links to songs
//

import SwiftUI

struct AddLinkSheet: View {
    @Environment(\.dismiss) var dismiss
    let onAdd: (String) -> Void

    @State private var urlText = ""
    @State private var siteName = ""
    @FocusState private var isURLFocused: Bool

    var isValid: Bool {
        guard let url = URL(string: urlText) else { return false }
        return url.scheme != nil && url.host != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Paste URL here", text: $urlText)
                        .focused($isURLFocused)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(Spacing.md)
                        .background(Color.warmInputBackground)
                        .cornerRadius(CornerRadius.input)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isURLFocused ? Color.appAccent.opacity(0.4) : Color.inputBorder, lineWidth: 1)
                        )
                        .animation(.easeInOut(duration: 0.2), value: isURLFocused)
                        .onChange(of: urlText) { _, newValue in
                            siteName = SongLink.detectSiteName(from: newValue)
                        }
                        .listRowBackground(Color.clear)
                } header: {
                    Text("URL")
                } footer: {
                    Text("Paste a link to tabs, lyrics, videos, or any music resource")
                }

                if isValid {
                    Section {
                        HStack {
                            Image(systemName: "link.circle.fill")
                                .foregroundColor(.green)
                            Text("Will save as: \(siteName)")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
            .background(Color.warmBackground)
            .navigationTitle("Add Link")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onAdd(urlText)
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
}

#Preview {
    AddLinkSheet { url in
        print("Added URL: \(url)")
    }
}
