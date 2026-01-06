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
            List {
                // Add new category section
                Section {
                    HStack(spacing: 12) {
                        TextField("New list name...", text: $newCategoryName)
                            .focused($isNewCategoryFocused)
                            .padding(12)
                            .background(Color.warmInputBackground)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isNewCategoryFocused ? Color.appAccent.opacity(0.4) : Color.inputBorder, lineWidth: 1)
                            )
                            .animation(.easeInOut(duration: 0.2), value: isNewCategoryFocused)

                        Button {
                            addCategory()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(newCategoryName.isEmpty ? .secondary : .appAccent)
                        }
                        .disabled(newCategoryName.isEmpty)
                    }
                    .listRowBackground(Color.clear)
                } header: {
                    Text("Create List")
                }
                
                // All categories (Favorites + Custom)
                Section {
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
                    .padding(.vertical, 4)
                    .swipeActions(edge: .trailing) {
                        Button {
                            showingFavoritesAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.red)
                        
                        Button {
                            showingFavoritesAlert = true
                        } label: {
                            Label("Rename", systemImage: "pencil")
                        }
                        .tint(.appAccent)
                    }
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
                                .buttonStyle(.borderedProminent)
                                .tint(.appAccent)
                                
                                Button {
                                    editingCategory = nil
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
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
                            .padding(.vertical, 4)
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
                                        .foregroundColor(.red)
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    categoryToDelete = category
                                    showingDeleteAlert = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(.red)
                                
                                Button {
                                    editingCategory = category
                                    editedName = category
                                } label: {
                                    Label("Rename", systemImage: "pencil")
                                }
                                .tint(.appAccent)
                            }
                        }
                    }
                } header: {
                    Text("Lists")
                } footer: {
                    Text("Swipe left to edit or delete lists.")
                }
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
            .listStyle(.insetGrouped)
        }
        .scrollContentBackground(.hidden)
        .background(Color.warmBackground)
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
