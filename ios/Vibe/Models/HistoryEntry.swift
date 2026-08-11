import Foundation

struct HistoryEntry: Identifiable, Codable, Hashable {
    let id: String
    let trackId: String
    let playedAt: Date

    init(
        id: String = UUID().uuidString,
        trackId: String,
        playedAt: Date = Date()
    ) {
        self.id = id
        self.trackId = trackId
        self.playedAt = playedAt
    }
}
