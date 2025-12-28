//
//  AnalyticsService.swift
//  GuitarSongbook
//
//  Anonymous usage analytics service
//  Tracks feature usage to understand how users interact with the app
//

import Foundation
import FirebaseAnalytics

struct AnalyticsService {
    private static let netlifyBaseURL = "https://fretnot.netlify.app"

    /// Track an analytics event (fails silently)
    static func track(event: AnalyticsEvent) async {
        // Track to Firebase Analytics
        trackToFirebase(event: event)

        // Track to Supabase (existing analytics)
        await trackToSupabase(event: event)
    }

    /// Track event to Firebase Analytics
    private static func trackToFirebase(event: AnalyticsEvent) {
        // Convert metadata to Firebase-compatible format
        var parameters: [String: Any] = [:]

        for (key, value) in event.metadata {
            // Firebase Analytics parameters must be String, Int, or Double
            if let stringValue = value as? String {
                parameters[key] = stringValue
            } else if let intValue = value as? Int {
                parameters[key] = intValue
            } else if let doubleValue = value as? Double {
                parameters[key] = doubleValue
            } else {
                parameters[key] = String(describing: value)
            }
        }

        // Log event to Firebase
        Analytics.logEvent(event.type.rawValue, parameters: parameters)
    }

    /// Track event to Supabase (existing analytics backend)
    private static func trackToSupabase(event: AnalyticsEvent) async {
        guard let url = URL(string: "\(netlifyBaseURL)/.netlify/functions/analytics-track") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "eventType": event.type.rawValue,
            "eventMetadata": event.metadata
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
            let _ = try await URLSession.shared.data(for: request)
        } catch {
            // Fail silently - don't block user flow
        }
    }
}

// MARK: - Analytics Event Types

struct AnalyticsEvent {
    let type: EventType
    let metadata: [String: Any]

    enum EventType: String {
        case songAdded = "song_added"
        case customChordCreated = "custom_chord_created"
        case chordSuggestionApplied = "chord_suggestion_applied"
        case songTransposed = "song_transposed"
        case tunerOpened = "tuner_opened"
        case strummingPatternAdded = "strumming_pattern_added"
        case notesAdded = "notes_added"
    }

    // Convenience initializers
    static func songAdded(source: String) -> AnalyticsEvent {
        AnalyticsEvent(type: .songAdded, metadata: ["source": source])
    }

    static func customChordCreated(chordName: String) -> AnalyticsEvent {
        AnalyticsEvent(type: .customChordCreated, metadata: ["chord_name": chordName])
    }

    static func chordSuggestionApplied(count: Int) -> AnalyticsEvent {
        AnalyticsEvent(type: .chordSuggestionApplied, metadata: ["chord_count": count])
    }

    static func songTransposed(fromKey: String, toKey: String) -> AnalyticsEvent {
        AnalyticsEvent(type: .songTransposed, metadata: ["from_key": fromKey, "to_key": toKey])
    }

    static func tunerOpened() -> AnalyticsEvent {
        AnalyticsEvent(type: .tunerOpened, metadata: [:])
    }

    static func strummingPatternAdded(patternName: String) -> AnalyticsEvent {
        AnalyticsEvent(type: .strummingPatternAdded, metadata: ["pattern_name": patternName])
    }

    static func notesAdded() -> AnalyticsEvent {
        AnalyticsEvent(type: .notesAdded, metadata: [:])
    }
}
