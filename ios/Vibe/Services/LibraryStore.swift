import Foundation
import SwiftUI

@Observable
final class LibraryStore {

    // MARK: - Data

    private(set) var tracks: [Track] = []
    private(set) var playlists: [Playlist] = []
    private(set) var history: [HistoryEntry] = []
    private(set) var favoriteIds: Set<String> = []

    // MARK: - Storage Keys

    private let tracksKey = "vibe.tracks"
    private let playlistsKey = "vibe.playlists"
    private let historyKey = "vibe.history"
    private let favoritesKey = "vibe.favorites"

    private let maxHistorySize = 200

    // MARK: - Init

    init() {
        loadAll()
    }

    // MARK: - Loading

    private func loadAll() {
        loadTracks()
        loadPlaylists()
        loadHistory()
        loadFavorites()
    }

    private func loadTracks() {
        if let data = UserDefaults.standard.data(forKey: tracksKey) {
            if let decoded = try? JSONDecoder().decode([Track].self, from: data) {
                tracks = decoded
            }
        }
    }

    private func loadPlaylists() {
        if let data = UserDefaults.standard.data(forKey: playlistsKey) {
            if let decoded = try? JSONDecoder().decode([Playlist].self, from: data) {
                playlists = decoded
            }
        }
    }

    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: historyKey) {
            if let decoded = try? JSONDecoder().decode([HistoryEntry].self, from: data) {
                history = decoded
            }
        }
    }

    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey) {
            if let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) {
                favoriteIds = decoded
            }
        }
    }

    // MARK: - Saving

    private func saveTracks() {
        if let data = try? JSONEncoder().encode(tracks) {
            UserDefaults.standard.set(data, forKey: tracksKey)
        }
    }

    private func savePlaylists() {
        if let data = try? JSONEncoder().encode(playlists) {
            UserDefaults.standard.set(data, forKey: playlistsKey)
        }
    }

    private func saveHistory() {
        if let data = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(data, forKey: historyKey)
        }
    }

    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favoriteIds) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
    }

    // MARK: - Track Management

    func addTrack(_ track: Track) {
        if let idx = tracks.firstIndex(where: { $0.youtubeId == track.youtubeId }) {
            tracks[idx] = track
        } else {
            tracks.insert(track, at: 0)
        }
        saveTracks()
    }

    func removeTrack(_ track: Track) {
        tracks.removeAll { $0.id == track.id }
        favoriteIds.remove(track.id)
        playlists = playlists.map { pl in
            var updated = pl
            updated.trackIds.removeAll { $0 == track.id }
            return updated
        }
        history.removeAll { $0.trackId == track.id }
        saveTracks()
        savePlaylists()
        saveHistory()
        saveFavorites()
    }

    func track(byId id: String) -> Track? {
        tracks.first { $0.id == id }
    }

    func track(byYouTubeId yid: String) -> Track? {
        tracks.first { $0.youtubeId == yid }
    }

    func exists(youtubeId: String) -> Bool {
        tracks.contains { $0.youtubeId == youtubeId }
    }

    func updateTrack(_ track: Track) {
        if let idx = tracks.firstIndex(where: { $0.id == track.id }) {
            tracks[idx] = track
            saveTracks()
        }
    }

    // MARK: - Favorites

    func toggleFavorite(_ track: Track) {
        if favoriteIds.contains(track.id) {
            favoriteIds.remove(track.id)
        } else {
            favoriteIds.insert(track.id)
        }
        saveFavorites()
    }

    func isFavorite(_ track: Track) -> Bool {
        favoriteIds.contains(track.id)
    }

    var favoriteTracks: [Track] {
        tracks.filter { favoriteIds.contains($0.id) }
    }

    // MARK: - History

    func addToHistory(_ track: Track) {
        history.insert(HistoryEntry(trackId: track.id), at: 0)
        if history.count > maxHistorySize {
            history = Array(history.prefix(maxHistorySize))
        }
        if let idx = tracks.firstIndex(where: { $0.id == track.id }) {
            tracks[idx].lastPlayedAt = Date()
            tracks[idx].playCount += 1
            saveTracks()
        }
        saveHistory()
    }

    func clearHistory() {
        history.removeAll()
        saveHistory()
    }

    var recentlyPlayedTracks: [Track] {
        let recent = history.prefix(30)
        return recent.compactMap { entry in
            tracks.first { $0.id == entry.trackId }
        }
    }

    var recentlyAddedTracks: [Track] {
        tracks
            .sorted { $0.addedAt > $1.addedAt }
            .prefix(30)
            .map { $0 }
    }

    // MARK: - Playlist Management

    func createPlaylist(name: String, description: String = "") -> Playlist {
        let playlist = Playlist(name: name, description: description)
        playlists.insert(playlist, at: 0)
        savePlaylists()
        return playlist
    }

    func deletePlaylist(_ playlist: Playlist) {
        playlists.removeAll { $0.id == playlist.id }
        savePlaylists()
    }

    func updatePlaylist(_ playlist: Playlist) {
        if let idx = playlists.firstIndex(where: { $0.id == playlist.id }) {
            playlists[idx] = playlist
            savePlaylists()
        }
    }

    func playlist(byId id: String) -> Playlist? {
        playlists.first { $0.id == id }
    }

    func addTrack(_ trackId: String, toPlaylist playlistId: String) {
        guard let idx = playlists.firstIndex(where: { $0.id == playlistId }) else { return }
        if !playlists[idx].trackIds.contains(trackId) {
            playlists[idx].trackIds.append(trackId)
            savePlaylists()
        }
    }

    func removeTrack(_ trackId: String, fromPlaylist playlistId: String) {
        guard let idx = playlists.firstIndex(where: { $0.id == playlistId }) else { return }
        playlists[idx].trackIds.removeAll { $0 == trackId }
        savePlaylists()
    }

    func moveTrack(in playlistId: String, from: Int, to: Int) {
        guard let idx = playlists.firstIndex(where: { $0.id == playlistId }) else { return }
        guard from < playlists[idx].trackIds.count, to < playlists[idx].trackIds.count else { return }
        playlists[idx].trackIds.move(fromOffsets: IndexSet(integer: from), toOffset: to)
        savePlaylists()
    }

    func tracksInPlaylist(_ playlist: Playlist) -> [Track] {
        playlist.trackIds.compactMap { trackId in
            tracks.first { $0.id == trackId }
        }
    }

    // MARK: - Data Management

    func clearAllData() {
        tracks.removeAll()
        playlists.removeAll()
        history.removeAll()
        favoriteIds.removeAll()
        saveTracks()
        savePlaylists()
        saveHistory()
        saveFavorites()
    }
}
