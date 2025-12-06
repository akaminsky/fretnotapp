//
//  TabURLDetector.swift
//  GuitarSongbook
//
//  Detects guitar tab URLs from clipboard when user returns to app
//

import Foundation
import UIKit

class TabURLDetector: ObservableObject {
    @Published var detectedURL: String?
    @Published var detectedSiteName: String?
    @Published var showingSavePrompt = false
    
    // The song the user was viewing when they left to search for tabs
    var pendingSongId: UUID?
    
    // Known guitar tab websites
    private let tabSites: [(domain: String, name: String)] = [
        ("ultimate-guitar.com", "Ultimate Guitar"),
        ("songsterr.com", "Songsterr"),
        ("chordify.net", "Chordify"),
        ("guitartabs.cc", "Guitar Tabs"),
        ("azchords.com", "AZ Chords"),
        ("e-chords.com", "E-Chords"),
        ("chordie.com", "Chordie"),
        ("tabs.ultimate-guitar.com", "Ultimate Guitar"),
        ("guitartabsexplorer.com", "Guitar Tabs Explorer"),
        ("bigbasstabs.com", "Big Bass Tabs"),
        ("911tabs.com", "911 Tabs"),
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
        // Only check if we have a pending song (user was searching for tabs)
        guard pendingSongId != nil else { return }
        
        checkClipboardForTabURL()
    }
    
    func checkClipboardForTabURL() {
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
        
        // Check if it's from a known tab site
        for site in tabSites {
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
    
    func stopWatching() {
        pendingSongId = nil
        detectedURL = nil
        detectedSiteName = nil
        showingSavePrompt = false
    }
    
    func clearDetection() {
        detectedURL = nil
        detectedSiteName = nil
        showingSavePrompt = false
    }
}

