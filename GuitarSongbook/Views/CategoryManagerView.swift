//
//  CategoryManagerView.swift
//  GuitarSongbook
//
//  Manage song categories
//

import SwiftUI

struct CategoryManagerView: View {
    @EnvironmentObject var songStore: SongStore
    @Environment(\.dismiss) var dismiss
    
    @State private var newCategoryName = ""
    @State private var editingCategory: String? = nil
    @State private var editedName = ""
    @State private var showingDeleteAlert = false
    @State private var showingFavoritesAlert = false
    @State private var categoryToDelete: String? = nil
    @FocusState private var isNewCategoryFocused: Bool
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Add new category section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("CREATE LIST")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 20)

                        HStack(spacing: 12) {
                            TextField("New list name...", text: $newCategoryName)
                                .focused($isNewCategoryFocused)
                                .warmTextField(focused: isNewCategoryFocused)

                            Button {
                                addCategory()
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(newCategoryName.isEmpty ? .secondary : .appAccent)
                            }
                            .disabled(newCategoryName.isEmpty)
                        }
                        .padding(.horizontal, 20)
                    }

                    // All categories (Favorites + Custom)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("LISTS")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 20)

                        VStack(spacing: 0) {
                            // Favorites row
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.appAccent)
                                    .frame(width: 24)

                                Text("Favorites")
                                    .fontWeight(.medium)

                                Spacer()

                                Text("\(songStore.favoritesCount) songs")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .contentShape(Rectangle())
                            .contextMenu {
                                Button {
                                    showingFavoritesAlert = true
                                } label: {
                                    Label("Rename", systemImage: "pencil")
                                }

                                Button(role: .destructive) {
                                    showingFavoritesAlert = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }

                            Divider()
                                .padding(.leading, 44)

                            // Custom categories
                            ForEach(songStore.categories, id: \.self) { category in
                                if editingCategory == category {
                                    // Editing mode
                                    HStack {
                                        Image(systemName: "folder.fill")
                                            .foregroundColor(.secondary)
                                            .frame(width: 24)

                                        TextField("List name", text: $editedName)
                                            .textFieldStyle(.roundedBorder)

                                        Button("Save") {
                                            saveEdit(oldName: category)
                                        }
                                        .primaryButton()

                                        Button {
                                            editingCategory = nil
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                } else {
                                    // Display mode
                                    HStack {
                                        Image(systemName: "folder.fill")
                                            .foregroundColor(.secondary)
                                            .frame(width: 24)

                                        Text(category)
                                            .fontWeight(.medium)

                                        Spacer()

                                        Text("\(songStore.songsInCategory(category)) songs")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .contentShape(Rectangle())
                                    .contextMenu {
                                        Button {
                                            editingCategory = category
                                            editedName = category
                                        } label: {
                                            Label("Rename", systemImage: "pencil")
                                        }

                                        Button(role: .destructive) {
                                            categoryToDelete = category
                                            showingDeleteAlert = true
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }

                                if category != songStore.categories.last {
                                    Divider()
                                        .padding(.leading, 44)
                                }
                            }
                        }
                        .warmCard()
                        .padding(.horizontal, 20)

                        Text("Tap and hold to rename or delete lists.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 20)
                    }
                }
                .padding(.vertical, 20)
            }
            .navigationTitle("Lists")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Delete List", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {
                    categoryToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let category = categoryToDelete {
                        songStore.deleteCategory(category)
                        categoryToDelete = nil
                    }
                }
            } message: {
                if let category = categoryToDelete {
                    Text("Are you sure you want to delete \"\(category)\"? Songs will not be deleted, but they will be removed from this list.")
                }
            }
            .alert("Favorites", isPresented: $showingFavoritesAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Favorites cannot be deleted or renamed.")
            }
            .background(Color.warmBackground)
        }
    }

    private func addCategory() {
        songStore.createCategory(newCategoryName)
        newCategoryName = ""
    }
    
    private func saveEdit(oldName: String) {
        if !editedName.isEmpty && editedName != oldName {
            songStore.renameCategory(from: oldName, to: editedName)
        }
        editingCategory = nil
    }
}

#Preview {
    CategoryManagerView()
        .environmentObject(SongStore())
}
