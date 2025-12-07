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
    private let clientId = "b43e82c8141440d3b47fd8f5456a2015"
    private let clientSecret = "59ca8582f8c2434494e1f41efee70166"
    
    init() {
        Task {
            await authenticate()
        }
    }
    
    // MARK: - Authentication
    
    func authenticate() async {
        guard let url = URL(string: "https://accounts.spotify.com/api/token") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let body = "grant_type=client_credentials&client_id=\(clientId)&client_secret=\(clientSecret)"
        request.httpBody = body.data(using: .utf8)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                isConnected = false
                return
            }
            
            let tokenResponse = try JSONDecoder().decode(SpotifyTokenResponse.self, from: data)
            accessToken = tokenResponse.accessToken
            isConnected = true
        } catch {
            isConnected = false
            print("Spotify auth error: \(error)")
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
        
        // If connected to Spotify, use real API
        if let token = accessToken {
            await searchSpotify(query: query, token: token)
        } else {
            // Fallback to demo data
            searchWithDemoData(query: query)
        }
        
        isSearching = false
    }
    
    private func searchSpotify(query: String, token: String) async {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.spotify.com/v1/search?q=\(encodedQuery)&type=track&limit=10") else {
            searchWithDemoData(query: query)
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                searchWithDemoData(query: query)
                return
            }
            
            let searchResponse = try JSONDecoder().decode(SpotifySearchResponse.self, from: data)
            searchResults = searchResponse.tracks?.items ?? []
        } catch {
            print("Spotify search error: \(error)")
            searchWithDemoData(query: query)
        }
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

