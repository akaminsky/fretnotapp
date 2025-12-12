//
//  SpotifyService.swift
//  GuitarSongbook
//
//  Handles Spotify API integration
//

import Foundation

@MainActor
class SpotifyService: ObservableObject {
    @Published var isConnected = false
    @Published var isSearching = false
    @Published var searchResults: [SpotifyTrack] = []
    @Published var errorMessage: String?
    
    private var accessToken: String?
    
    // Your Netlify site URL (use .netlify.app domain or your custom domain)
    // If you set up a custom domain in Netlify, you can use that instead
    private let netlifyBaseURL = "https://fretnot.netlify.app"
    
    private var useNetlify: Bool {
        // Use Netlify if URL is set and looks valid
        return !netlifyBaseURL.isEmpty && netlifyBaseURL.hasPrefix("https://")
    }
    
    init() {
        Task {
            await authenticate()
        }
    }
    
    // MARK: - Authentication
    
    func authenticate() async {
        if useNetlify {
            // Use Netlify function for authentication
            guard let url = URL(string: "\(netlifyBaseURL)/.netlify/functions/spotify-token") else {
                print("❌ Spotify: Invalid Netlify URL")
                isConnected = false
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ Spotify: Invalid response")
                    isConnected = false
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    let tokenResponse = try JSONDecoder().decode(SpotifyTokenResponse.self, from: data)
                    accessToken = tokenResponse.accessToken
                    isConnected = true
                    print("✅ Spotify: Authentication successful via Netlify")
                } else {
                    if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let errorMessage = errorData["error"] as? String {
                        print("❌ Spotify Auth Error (\(httpResponse.statusCode)): \(errorMessage)")
                    } else {
                        print("❌ Spotify Auth Error: Status code \(httpResponse.statusCode)")
                    }
                    isConnected = false
                }
            } catch {
                isConnected = false
                print("❌ Spotify auth error: \(error.localizedDescription)")
            }
        } else {
            // Fallback: Not using Netlify (for development)
            print("⚠️ Spotify: Netlify URL not configured, using demo mode")
            isConnected = false
        }
    }
    
    // MARK: - Search
    
    func search(query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        errorMessage = nil
        
        if useNetlify {
            // Use Netlify function for search
            guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let url = URL(string: "\(netlifyBaseURL)/.netlify/functions/spotify-search?q=\(encodedQuery)") else {
                searchWithDemoData(query: query)
                isSearching = false
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    print("⚠️ Spotify: Search failed, using demo data")
                    searchWithDemoData(query: query)
                    isSearching = false
                    return
                }
                
                let searchResponse = try JSONDecoder().decode(SpotifySearchResponse.self, from: data)
                searchResults = searchResponse.tracks?.items ?? []
                isConnected = true
            } catch {
                print("Spotify search error: \(error)")
                searchWithDemoData(query: query)
            }
        } else {
            // Fallback to demo data if Netlify not configured
            print("⚠️ Spotify: Using demo data (Netlify not configured)")
            errorMessage = "Spotify search unavailable. Showing sample results."
            searchWithDemoData(query: query)
        }
        
        isSearching = false
    }
    
    private func searchWithDemoData(query: String) {
        let demoTracks = Self.demoTracks
        let lowercasedQuery = query.lowercased()
        
        let filtered = demoTracks.filter { track in
            track.name.lowercased().contains(lowercasedQuery) ||
            track.artistNames.lowercased().contains(lowercasedQuery) ||
            track.album.name.lowercased().contains(lowercasedQuery)
        }
        
        if filtered.isEmpty {
            // Return a generic result for any search
            searchResults = [SpotifyTrack(
                id: UUID().uuidString,
                name: query,
                artists: [SpotifyArtist(name: "Unknown Artist")],
                album: SpotifyAlbum(name: "Unknown Album", images: []),
                externalUrls: SpotifyExternalUrls(spotify: "https://open.spotify.com/search/\(query)")
            )]
        } else {
            searchResults = filtered
        }
    }
    
    func clearResults() {
        searchResults = []
    }
    
    // MARK: - Playlist Import
    
    func fetchPlaylistTracks(playlistURL: String) async -> [SpotifyTrack] {
        // Extract playlist ID from URL
        guard let playlistId = extractPlaylistId(from: playlistURL) else {
            print("❌ Spotify: Could not extract playlist ID from URL")
            return []
        }
        
        if useNetlify {
            // Use Netlify function for playlist fetching
            guard let url = URL(string: "\(netlifyBaseURL)/.netlify/functions/spotify-playlist?id=\(playlistId)") else {
                print("❌ Spotify: Invalid Netlify URL for playlist")
                return []
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    print("❌ Spotify: Failed to fetch playlist")
                    return []
                }
                
                let playlistResponse = try JSONDecoder().decode(SpotifyPlaylistResponse.self, from: data)
                
                // Extract valid tracks
                let validTracks = playlistResponse.items.compactMap { $0.track }
                return validTracks
            } catch {
                print("Error fetching playlist: \(error)")
                return []
            }
        } else {
            print("❌ Spotify: Cannot fetch playlist (Netlify not configured)")
            return []
        }
    }
    
    private func extractPlaylistId(from urlString: String) -> String? {
        // Handle spotify:playlist: format
        if urlString.hasPrefix("spotify:playlist:") {
            return String(urlString.dropFirst(17))
        }
        
        // Handle https://open.spotify.com/playlist/{id}
        if let url = URL(string: urlString),
           url.host?.contains("spotify.com") == true {
            let pathComponents = url.pathComponents
            if let playlistIndex = pathComponents.firstIndex(of: "playlist"),
               playlistIndex + 1 < pathComponents.count {
                // Get the ID and remove query parameters
                let idWithParams = pathComponents[playlistIndex + 1]
                return idWithParams.components(separatedBy: "?").first
            }
        }
        
        // If it's just an ID
        if !urlString.contains("/") && !urlString.contains(":") {
            return urlString
        }
        
        return nil
    }
    
    // MARK: - Demo Data
    
    static let demoTracks: [SpotifyTrack] = [
        SpotifyTrack(
            id: "demo1",
            name: "Wonderwall",
            artists: [SpotifyArtist(name: "Oasis")],
            album: SpotifyAlbum(name: "(What's the Story) Morning Glory?", images: [SpotifyImage(url: "https://via.placeholder.com/300", height: 300, width: 300)]),
            externalUrls: SpotifyExternalUrls(spotify: "https://open.spotify.com/track/2CT3r93YuSHtm57mjxvjhH")
        ),
        SpotifyTrack(
            id: "demo2",
            name: "Hotel California",
            artists: [SpotifyArtist(name: "Eagles")],
            album: SpotifyAlbum(name: "Hotel California", images: [SpotifyImage(url: "https://via.placeholder.com/300", height: 300, width: 300)]),
            externalUrls: SpotifyExternalUrls(spotify: "https://open.spotify.com/track/40riOy7x9W7GXGyjoSdS8j")
        ),
        SpotifyTrack(
            id: "demo3",
            name: "Black",
            artists: [SpotifyArtist(name: "Pearl Jam")],
            album: SpotifyAlbum(name: "Ten", images: [SpotifyImage(url: "https://via.placeholder.com/300", height: 300, width: 300)]),
            externalUrls: SpotifyExternalUrls(spotify: "https://open.spotify.com/track/5Xak5fmy089t0FYmh3VJiY")
        ),
        SpotifyTrack(
            id: "demo4",
            name: "Sweet Child O' Mine",
            artists: [SpotifyArtist(name: "Guns N' Roses")],
            album: SpotifyAlbum(name: "Appetite for Destruction", images: [SpotifyImage(url: "https://via.placeholder.com/300", height: 300, width: 300)]),
            externalUrls: SpotifyExternalUrls(spotify: "https://open.spotify.com/track/7snQQk1zcKl8gZ92AnueZW")
        ),
        SpotifyTrack(
            id: "demo5",
            name: "Stairway to Heaven",
            artists: [SpotifyArtist(name: "Led Zeppelin")],
            album: SpotifyAlbum(name: "Led Zeppelin IV", images: [SpotifyImage(url: "https://via.placeholder.com/300", height: 300, width: 300)]),
            externalUrls: SpotifyExternalUrls(spotify: "https://open.spotify.com/track/5CQ30WqJwcep0pYcV4AMNc")
        ),
        SpotifyTrack(
            id: "demo6",
            name: "Free Bird",
            artists: [SpotifyArtist(name: "Lynyrd Skynyrd")],
            album: SpotifyAlbum(name: "(Pronounced 'Lĕh-'nérd 'Skin-'nérd)", images: [SpotifyImage(url: "https://via.placeholder.com/300", height: 300, width: 300)]),
            externalUrls: SpotifyExternalUrls(spotify: "https://open.spotify.com/track/5qTZ38X8xqW5HQ33Lq5PzR")
        ),
        SpotifyTrack(
            id: "demo7",
            name: "Tears in Heaven",
            artists: [SpotifyArtist(name: "Eric Clapton")],
            album: SpotifyAlbum(name: "Unplugged", images: [SpotifyImage(url: "https://via.placeholder.com/300", height: 300, width: 300)]),
            externalUrls: SpotifyExternalUrls(spotify: "https://open.spotify.com/track/1kgwJ2y7p6V7Kk9FIF4YV5")
        ),
        SpotifyTrack(
            id: "demo8",
            name: "Wish You Were Here",
            artists: [SpotifyArtist(name: "Pink Floyd")],
            album: SpotifyAlbum(name: "Wish You Were Here", images: [SpotifyImage(url: "https://via.placeholder.com/300", height: 300, width: 300)]),
            externalUrls: SpotifyExternalUrls(spotify: "https://open.spotify.com/track/6mFkJmJqdDVQ1REhVfGgd1")
        ),
        SpotifyTrack(
            id: "demo9",
            name: "Yesterday",
            artists: [SpotifyArtist(name: "The Beatles")],
            album: SpotifyAlbum(name: "Yesterday and Today", images: [SpotifyImage(url: "https://via.placeholder.com/300", height: 300, width: 300)]),
            externalUrls: SpotifyExternalUrls(spotify: "https://open.spotify.com/track/3BQHpFgAp4l80e1XslIjNI")
        ),
        SpotifyTrack(
            id: "demo10",
            name: "Hallelujah",
            artists: [SpotifyArtist(name: "Jeff Buckley")],
            album: SpotifyAlbum(name: "Grace", images: [SpotifyImage(url: "https://via.placeholder.com/300", height: 300, width: 300)]),
            externalUrls: SpotifyExternalUrls(spotify: "https://open.spotify.com/track/3pRaLNL3b8x5uBOcsgvdqM")
        )
    ]
}

