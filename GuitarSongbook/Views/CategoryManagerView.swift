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
    @State private var categoryToDelete: String? = nil
    
    var body: some View {
        NavigationStack {
            List {
                // Add new category section
                Section {
                    HStack {
                        TextField("New category name...", text: $newCategoryName)
                        
                        Button {
                            addCategory()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(newCategoryName.isEmpty ? .secondary : .appAccent)
                        }
                        .disabled(newCategoryName.isEmpty)
                    }
                } header: {
                    Text("Create Category")
                }
                
                // Favorites (built-in, can't delete)
                Section {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.appGold)
                            .frame(width: 24)
                        
                        Text("Favorites")
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text("\(songStore.favoritesCount) songs")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Built-in")
                } footer: {
                    Text("Favorites cannot be deleted or renamed")
                }
                
                // Custom categories
                Section {
                    if songStore.categories.isEmpty {
                        HStack {
                            Spacer()
                            VStack(spacing: 8) {
                                Image(systemName: "folder")
                                    .font(.title)
                                    .foregroundColor(.secondary)
                                Text("No custom categories yet")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 20)
                            Spacer()
                        }
                    } else {
                        ForEach(songStore.categories, id: \.self) { category in
                            if editingCategory == category {
                                // Editing mode
                                HStack {
                                    Image(systemName: "folder.fill")
                                        .foregroundColor(.blue)
                                        .frame(width: 24)
                                    
                                    TextField("Category name", text: $editedName)
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
                                        .foregroundColor(.blue)
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
                                    }
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        categoryToDelete = category
                                        showingDeleteAlert = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    
                                    Button {
                                        editingCategory = category
                                        editedName = category
                                    } label: {
                                        Label("Rename", systemImage: "pencil")
                                    }
                                    .tint(.orange)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Custom Categories")
                } footer: {
                    if !songStore.categories.isEmpty {
                        Text("Swipe left to edit or delete. Long press for more options.")
                    }
                }
            }
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Delete Category", isPresented: $showingDeleteAlert) {
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
                    Text("Are you sure you want to delete \"\(category)\"? Songs will not be deleted, but they will be removed from this category.")
                }
            }
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

