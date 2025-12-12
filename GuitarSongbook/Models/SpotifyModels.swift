//
//  SpotifyModels.swift
//  GuitarSongbook
//
//  Spotify API response models
//

import Foundation

struct SpotifySearchResponse: Codable {
    let tracks: SpotifyTracks?
}

struct SpotifyTracks: Codable {
    let items: [SpotifyTrack]
}

struct SpotifyTrack: Codable, Identifiable {
    let id: String
    let name: String
    let artists: [SpotifyArtist]
    let album: SpotifyAlbum
    let externalUrls: SpotifyExternalUrls
    
    enum CodingKeys: String, CodingKey {
        case id, name, artists, album
        case externalUrls = "external_urls"
    }
    
    var artistNames: String {
        artists.map { $0.name }.joined(separator: ", ")
    }
    
    var albumCoverUrl: String? {
        album.images.first?.url
    }
    
    var mediumAlbumCoverUrl: String? {
        album.images.count > 1 ? album.images[1].url : album.images.first?.url
    }
    
    var smallAlbumCoverUrl: String? {
        album.images.last?.url
    }
}

struct SpotifyArtist: Codable {
    let name: String
}

struct SpotifyAlbum: Codable {
    let name: String
    let images: [SpotifyImage]
}

struct SpotifyImage: Codable {
    let url: String
    let height: Int?
    let width: Int?
}

struct SpotifyExternalUrls: Codable {
    let spotify: String
}

struct SpotifyTokenResponse: Codable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
    }
}

// MARK: - Playlist Models

struct SpotifyPlaylistResponse: Codable {
    let items: [SpotifyPlaylistItem]
    let next: String?
    let total: Int
}

struct SpotifyPlaylistItem: Codable {
    let track: SpotifyTrack?
}

struct SpotifyPlaylistInfo: Codable {
    let name: String
    let description: String?
}

