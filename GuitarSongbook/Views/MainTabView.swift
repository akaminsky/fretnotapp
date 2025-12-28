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

    init() {
        // Force bottom tab bar style on iPad
        UITabBar.appearance().isHidden = false
    }

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
        .tabViewStyle(.automatic)
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @EnvironmentObject var songStore: SongStore
    @EnvironmentObject var spotifyService: SpotifyService
    @State private var showingCategoryManager = false
    @State private var showingBulkImport = false
    @State private var showingCustomChordManager = false
    @AppStorage("shareAnonymouslyEnabled") private var shareAnonymouslyEnabled = true

    // Practice Reminders
    @AppStorage("practiceRemindersEnabled") private var practiceRemindersEnabled = true
    @State private var practiceReminderTime: Date = Calendar.current.date(from: DateComponents(hour: 19, minute: 0)) ?? Date()
    @State private var practiceReminderFrequency: ReminderFrequency = .everyOtherDay

    // Add Song Reminders
    @AppStorage("addSongRemindersEnabled") private var addSongRemindersEnabled = true
    @State private var addSongReminderTime: Date = Calendar.current.date(from: DateComponents(hour: 19, minute: 0)) ?? Date()
    @State private var addSongReminderFrequency: ReminderFrequency = .weekly
    
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

                    Button {
                        showingCustomChordManager = true
                    } label: {
                        HStack {
                            Image(systemName: "star.circle")
                                .foregroundColor(.appAccent)
                                .frame(width: 28)

                            Text("Custom Chords")
                                .foregroundColor(.primary)

                            Spacer()

                            Text("\(CustomChordLibrary.shared.customChords.count)")
                                .foregroundColor(.secondary)

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

                // Community Section
                Section {
                    Toggle(isOn: $shareAnonymouslyEnabled) {
                        HStack {
                            Image(systemName: "person.3.fill")
                                .foregroundColor(.appAccent)
                                .frame(width: 28)

                            Text("Share Songs Anonymously")
                                .foregroundColor(.primary)
                        }
                    }
                } header: {
                    Text("Community")
                } footer: {
                    Text("Help other guitarists by anonymously sharing your chord data when you add Spotify songs. No personal information is shared - only chords, capo position, and tuning. Your notes stay private. You can opt out anytime.")
                }

                // Practice Reminders Section
                Section {
                    Toggle(isOn: $practiceRemindersEnabled) {
                        HStack {
                            Image(systemName: "guitars")
                                .foregroundColor(.appAccent)
                                .frame(width: 28)

                            Text("Remind me to practice")
                                .foregroundColor(.primary)
                        }
                    }
                    .onChange(of: practiceRemindersEnabled) { _, newValue in
                        if newValue {
                            NotificationManager.shared.rescheduleIfNeeded()
                        } else {
                            NotificationManager.shared.cancelPracticeReminders()
                        }
                    }

                    if practiceRemindersEnabled {
                        Picker("Frequency", selection: $practiceReminderFrequency) {
                            ForEach(ReminderFrequency.allCases, id: \.self) { frequency in
                                Text(frequency.rawValue).tag(frequency)
                            }
                        }
                        .onChange(of: practiceReminderFrequency) { _, newValue in
                            UserDefaults.standard.set(newValue.rawValue, forKey: "practiceReminderFrequency")
                            NotificationManager.shared.rescheduleIfNeeded()
                        }

                        DatePicker("Time", selection: $practiceReminderTime, displayedComponents: .hourAndMinute)
                            .onChange(of: practiceReminderTime) { _, newValue in
                                UserDefaults.standard.set(newValue.timeIntervalSince1970, forKey: "practiceReminderTime")
                                NotificationManager.shared.rescheduleIfNeeded()
                            }
                    }
                } header: {
                    Text("Practice Reminders")
                } footer: {
                    Text("Get reminded to practice your songs regularly.")
                }

                // Add Song Reminders Section
                Section {
                    Toggle(isOn: $addSongRemindersEnabled) {
                        HStack {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.appAccent)
                                .frame(width: 28)

                            Text("Remind me to add songs")
                                .foregroundColor(.primary)
                        }
                    }
                    .onChange(of: addSongRemindersEnabled) { _, newValue in
                        if newValue {
                            NotificationManager.shared.rescheduleIfNeeded()
                        } else {
                            NotificationManager.shared.cancelAddSongReminders()
                        }
                    }

                    if addSongRemindersEnabled {
                        Picker("Frequency", selection: $addSongReminderFrequency) {
                            ForEach(ReminderFrequency.allCases, id: \.self) { frequency in
                                Text(frequency.rawValue).tag(frequency)
                            }
                        }
                        .onChange(of: addSongReminderFrequency) { _, newValue in
                            UserDefaults.standard.set(newValue.rawValue, forKey: "addSongReminderFrequency")
                            NotificationManager.shared.rescheduleIfNeeded()
                        }

                        DatePicker("Time", selection: $addSongReminderTime, displayedComponents: .hourAndMinute)
                            .onChange(of: addSongReminderTime) { _, newValue in
                                UserDefaults.standard.set(newValue.timeIntervalSince1970, forKey: "addSongReminderTime")
                                NotificationManager.shared.rescheduleIfNeeded()
                            }
                    }
                } header: {
                    Text("Add Song Reminders")
                } footer: {
                    Text("Get reminded to keep growing your songbook.")
                }

                // Feedback Section
                Section {
                    Link(destination: URL(string: "mailto:fretnotapp@gmail.com")!) {
                        HStack {
                            Image(systemName: "bubble.left.and.bubble.right")
                                .foregroundColor(.appAccent)
                                .frame(width: 28)

                            Text("Send Feedback")
                                .foregroundColor(.primary)

                            Spacer()

                            Image(systemName: "envelope")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .tint(.appAccent)
                } header: {
                    Text("Feedback")
                } footer: {
                        Text("Help us make Fret Not better!")
                }
                
                // About Section
                Section {
                    Link(destination: URL(string: "http://fretnot.app")!) {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(.appAccent)
                                .frame(width: 28)

                            Text("Website")
                                .foregroundColor(.primary)

                            Spacer()

                            Text("fretnot.app")
                                .foregroundColor(.secondary)

                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .tint(.appAccent)
                    
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.appAccent)
                            .frame(width: 28)

                        Text("Version")

                        Spacer()

                        Text("1.3.1")
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
                    .tint(.appAccent)
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                loadNotificationSettings()
            }
            .sheet(isPresented: $showingCategoryManager) {
                CategoryManagerView()
                    .environmentObject(songStore)
            }
            .sheet(isPresented: $showingBulkImport) {
                BulkImportView()
                    .environmentObject(songStore)
                    .environmentObject(spotifyService)
            }
            .sheet(isPresented: $showingCustomChordManager) {
                NavigationStack {
                    CustomChordManagerView()
                        .environmentObject(songStore)
                }
            }
        }
    }

    private func loadNotificationSettings() {
        // Load practice reminder settings
        if let practiceTimeInterval = UserDefaults.standard.object(forKey: "practiceReminderTime") as? TimeInterval {
            practiceReminderTime = Date(timeIntervalSince1970: practiceTimeInterval)
        }
        if let practiceFreqRaw = UserDefaults.standard.string(forKey: "practiceReminderFrequency"),
           let practiceFreq = ReminderFrequency(rawValue: practiceFreqRaw) {
            practiceReminderFrequency = practiceFreq
        }

        // Load add song reminder settings
        if let addSongTimeInterval = UserDefaults.standard.object(forKey: "addSongReminderTime") as? TimeInterval {
            addSongReminderTime = Date(timeIntervalSince1970: addSongTimeInterval)
        }
        if let addSongFreqRaw = UserDefaults.standard.string(forKey: "addSongReminderFrequency"),
           let addSongFreq = ReminderFrequency(rawValue: addSongFreqRaw) {
            addSongReminderFrequency = addSongFreq
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(SongStore())
        .environmentObject(SpotifyService())
        .environmentObject(TabURLDetector())
}

