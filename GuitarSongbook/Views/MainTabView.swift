//
//  MainTabView.swift
//  GuitarSongbook
//
//  Main tab bar navigation
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var songStore: SongStore
    @EnvironmentObject var spotifyService: SpotifyService
    @EnvironmentObject var tabURLDetector: TabURLDetector
    
    var body: some View {
        TabView {
            // Songs Tab
            ContentView()
                .tabItem {
                    Label("Songs", systemImage: "music.note.list")
                }
            
            // Chords Tab
            ChordLogView()
                .tabItem {
                    Label("Chords", systemImage: "hand.raised.fingers.spread")
                }
            
            // Tuner Tab
            TunerView()
                .tabItem {
                    Label("Tuner", systemImage: "tuningfork")
                }
            
            // Settings Tab
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .tint(.appAccent)
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @EnvironmentObject var songStore: SongStore
    @EnvironmentObject var spotifyService: SpotifyService
    @State private var showingCategoryManager = false
    @State private var showingBulkImport = false
    
    var body: some View {
        NavigationStack {
            List {
                // Library Section
                Section {
                    Button {
                        showingCategoryManager = true
                    } label: {
                        HStack {
                            Image(systemName: "folder")
                                .foregroundColor(.appAccent)
                                .frame(width: 28)
                            
                            Text("Manage Lists")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("\(songStore.categories.count)")
                                .foregroundColor(.secondary)
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(Color(.tertiaryLabel))
                        }
                    }
                    
                    Button {
                        showingBulkImport = true
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                                .foregroundColor(.appAccent)
                                .frame(width: 28)
                            
                            Text("Import Playlist")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(Color(.tertiaryLabel))
                        }
                    }
                } header: {
                    Text("Library")
                }
                
                // Stats Section
                Section {
                    HStack {
                        Image(systemName: "music.note")
                            .foregroundColor(.appAccent)
                            .frame(width: 28)
                        
                        Text("Total Songs")
                        
                        Spacer()
                        
                        Text("\(songStore.songs.count)")
                            .foregroundColor(.secondary)
                            .padding(.trailing, 3)
                    }
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.appAccent)
                            .frame(width: 28)
                        
                        Text("Favorites")
                        
                        Spacer()
                        
                        Text("\(songStore.favoritesCount)")
                            .foregroundColor(.secondary)
                            .padding(.trailing, 3)
                    }
                    
                    HStack {
                        Image(systemName: "guitars")
                            .foregroundColor(.appAccent)
                            .frame(width: 28)
                        
                        Text("Unique Chords")
                        
                        Spacer()
                        
                        Text("\(songStore.allUniqueChords.count)")
                            .foregroundColor(.secondary)
                            .padding(.trailing, 3)
                    }
                } header: {
                    Text("Stats")
                }
                
                // Sync Section
                Section {
                    HStack {
                        Image(systemName: songStore.iCloudEnabled ? "checkmark.icloud" : "xmark.icloud")
                            .foregroundColor(songStore.iCloudEnabled ? .green : .secondary)
                            .frame(width: 28)
                        
                        Text("iCloud Sync")
                        
                        Spacer()
                        
                        Text(songStore.iCloudEnabled ? "Enabled" : "Disabled")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Sync")
                } footer: {
                    if songStore.iCloudEnabled {
                        Text("Your songs sync automatically across all your devices.")
                    } else {
                        Text("Sign in to iCloud in Settings to sync your songs across devices.")
                    }
                }
                
                // Feedback Section
                Section {
                    Link(destination: URL(string: "https://forms.gle/eYaCmNPsNSFG7KLw6")!) {
                        HStack {
                            Image(systemName: "bubble.left.and.bubble.right")
                                .foregroundColor(.appAccent)
                                .frame(width: 28)
                            
                            Text("Send Feedback")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Feedback")
                } footer: {
                    Text("Help us make Never Fret better!")
                }
                
                // About Section
                Section {
                    Link(destination: URL(string: "https://neverfret.app")!) {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(.appAccent)
                                .frame(width: 28)
                            
                            Text("Website")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("neverfret.app")
                                .foregroundColor(.secondary)
                            
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.appAccent)
                            .frame(width: 28)
                        
                        Text("Version")
                        
                        Spacer()
                        
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://alexakaminsky.com")!) {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.appAccent)
                                .frame(width: 28)
                            
                            Text("Built by Alexa Kaminsky")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingCategoryManager) {
                CategoryManagerView()
                    .environmentObject(songStore)
            }
            .sheet(isPresented: $showingBulkImport) {
                BulkImportView()
                    .environmentObject(songStore)
                    .environmentObject(spotifyService)
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(SongStore())
        .environmentObject(SpotifyService())
        .environmentObject(TabURLDetector())
}

