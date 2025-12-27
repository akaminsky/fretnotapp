//
//  CommunityDataService.swift
//  GuitarSongbook
//
//  Service for anonymous song data collection (v1.3)
//  Silently submits song contributions to build community database
//

import Foundation

@MainActor
class CommunityDataService: ObservableObject {
    private let netlifyBaseURL = "https://fretnot.netlify.app"

    /// Submit an anonymous contribution silently (v1.3 data collection)
    /// Fails silently - does not block user flow or show errors
    func submitAnonymousContribution(
        spotifyTrackId: String,
        songTitle: String,
        artist: String,
        chords: [String],
        capo: Int,
        tuning: String
    ) async {
        // Check if user has opted out
        let shareAnonymously = UserDefaults.standard.bool(forKey: "shareAnonymouslyEnabled")

        // Default is true (opt-in), so if key doesn't exist, it should be true
        let shouldShare = UserDefaults.standard.object(forKey: "shareAnonymouslyEnabled") == nil ? true : shareAnonymously

        guard shouldShare else {
            print("📊 Anonymous sharing disabled by user")
            return
        }

        // Don't submit if no chords
        guard !chords.isEmpty else {
            print("📊 Skipping contribution: no chords")
            return
        }

        // Build contribution payload
        let contribution: [String: Any] = [
            "spotifyTrackId": spotifyTrackId,
            "songTitle": songTitle,
            "artist": artist,
            "chords": chords,
            "capo": capo,
            "tuning": tuning
        ]

        guard let url = URL(string: "\(netlifyBaseURL)/.netlify/functions/community-contribute") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: contribution)

            // Submit asynchronously without awaiting response
            let (_, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print("📊 Anonymous contribution submitted successfully")
                } else {
                    print("📊 Contribution failed with status: \(httpResponse.statusCode)")
                }
            }
        } catch {
            // Fail silently - don't block user flow
            print("📊 Anonymous contribution error: \(error.localizedDescription)")
        }
    }

    /// Extract Spotify track ID from URL
    func extractSpotifyTrackId(from url: String) -> String? {
        // Handle both URL formats:
        // https://open.spotify.com/track/2CT3r93YuSHtm57mjxvjhH
        // spotify:track:2CT3r93YuSHtm57mjxvjhH

        if url.starts(with: "spotify:track:") {
            return String(url.dropFirst("spotify:track:".count))
        }

        if let range = url.range(of: "/track/") {
            let afterTrack = url[range.upperBound...]
            let trackId = afterTrack.components(separatedBy: "?").first ?? String(afterTrack)
            return trackId.isEmpty ? nil : String(trackId)
        }

        return nil
    }
}
