//
//  ResourceLinkDetector.swift
//  GuitarSongbook
//
//  Detects music resource URLs (tabs, lyrics, videos) from clipboard when user returns to app
//

import Foundation
import UIKit

class ResourceLinkDetector: ObservableObject {
    @Published var detectedURL: String?
    @Published var detectedSiteName: String?
    @Published var showingSavePrompt = false

    // The song the user was viewing when they left to search for resources
    var pendingSongId: UUID?

    // Known music resource websites (tabs, lyrics, videos)
    private let recognizedSites: [(domain: String, name: String)] = [
        // Tab sites
        ("ultimate-guitar.com", "Ultimate Guitar"),
        ("tabs.ultimate-guitar.com", "Ultimate Guitar"),
        ("songsterr.com", "Songsterr"),
        ("chordify.net", "Chordify"),
        ("guitartabs.cc", "Guitar Tabs"),
        ("azchords.com", "AZ Chords"),
        ("e-chords.com", "E-Chords"),
        ("chordie.com", "Chordie"),
        ("guitartabsexplorer.com", "Guitar Tabs Explorer"),
        ("bigbasstabs.com", "Big Bass Tabs"),
        ("911tabs.com", "911 Tabs"),

        // Lyrics sites
        ("genius.com", "Genius"),
        ("azlyrics.com", "AZ Lyrics"),
        ("lyrics.com", "Lyrics.com"),
        ("metrolyrics.com", "MetroLyrics"),

        // Video sites
        ("youtube.com", "YouTube"),
        ("youtu.be", "YouTube"),
        ("vimeo.com", "Vimeo")
    ]
    
    // Last checked URL to avoid repeat prompts
    private var lastCheckedURL: String?
    
    init() {
        // Listen for app becoming active
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func appDidBecomeActive() {
        // Only check if we have a pending song (user was searching for resources)
        guard pendingSongId != nil else { return }

        checkClipboardForResourceURL()
    }

    func checkClipboardForResourceURL() {
        // Check if clipboard has a URL
        guard UIPasteboard.general.hasURLs || UIPasteboard.general.hasStrings else {
            return
        }

        var urlString: String?

        // Try to get URL directly
        if let url = UIPasteboard.general.url {
            urlString = url.absoluteString
        }
        // Or try to parse from string
        else if let string = UIPasteboard.general.string,
                let url = URL(string: string),
                url.scheme == "http" || url.scheme == "https" {
            urlString = string
        }

        guard let urlString = urlString else { return }

        // Don't prompt for the same URL twice
        guard urlString != lastCheckedURL else { return }
        lastCheckedURL = urlString

        // Check if it's from a recognized site
        for site in recognizedSites {
            if urlString.lowercased().contains(site.domain) {
                DispatchQueue.main.async {
                    self.detectedURL = urlString
                    self.detectedSiteName = site.name
                    self.showingSavePrompt = true
                }
                return
            }
        }
    }
    
    func startWatchingForSong(_ songId: UUID) {
        pendingSongId = songId
        lastCheckedURL = nil // Reset so we can detect new URLs
    }
    
    @MainActor
    func stopWatching() {
        pendingSongId = nil
        detectedURL = nil
        detectedSiteName = nil
        showingSavePrompt = false
    }
    
    @MainActor
    func clearDetection() {
        detectedURL = nil
        detectedSiteName = nil
        showingSavePrompt = false
    }
}

