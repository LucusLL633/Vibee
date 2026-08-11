import Foundation

enum RepeatMode: String, Codable, CaseIterable {
    case off, all, one

    var icon: String {
        switch self {
        case .off: return "repeat"
        case .all: return "repeat"
        case .one: return "repeat.1"
        }
    }

    var isActive: Bool { self != .off }
}

enum LibraryFilter: String, CaseIterable, Identifiable {
    case all = "Tout"
    case favorites = "Favoris"
    case recentlyAdded = "Récents"
    case recentlyPlayed = "Écoutées"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .all: return "music.note"
        case .favorites: return "heart.fill"
        case .recentlyAdded: return "clock.badge.plus"
        case .recentlyPlayed: return "clock"
        }
    }
}

enum AppearanceMode: String, Codable, CaseIterable, Identifiable {
    case dark = "Sombre"
    case light = "Clair"
    case automatic = "Automatique"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .dark: return "moon.fill"
        case .light: return "sun.max.fill"
        case .automatic: return "circle.lefthalf.filled"
        }
    }
}

enum TrackSheetType: Identifiable {
    case playlistPicker(Track)
    case info(Track)
    case createPlaylist(trackId: String?)
    case editPlaylist(Playlist)

    var id: String {
        switch self {
        case .playlistPicker(let t): return "playlist-picker-\(t.id)"
        case .info(let t): return "info-\(t.id)"
        case .createPlaylist: return "create-playlist"
        case .editPlaylist(let p): return "edit-playlist-\(p.id)"
        }
    }
}
