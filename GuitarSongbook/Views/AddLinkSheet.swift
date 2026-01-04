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

    var isValid: Bool {
        guard let url = URL(string: urlText) else { return false }
        return url.scheme != nil && url.host != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Paste URL here", text: $urlText)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .onChange(of: urlText) { _, newValue in
                            siteName = SongLink.detectSiteName(from: newValue)
                        }
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
