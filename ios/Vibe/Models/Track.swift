import Foundation

struct Track: Identifiable, Codable, Hashable {
    let id: String
    var youtubeId: String
    var title: String
    var artist: String
    var thumbnailURL: String
    var duration: Int?
    var addedAt: Date
    var lastPlayedAt: Date?
    var playCount: Int

    init(
        id: String = UUID().uuidString,
        youtubeId: String,
        title: String,
        artist: String,
        thumbnailURL: String,
        duration: Int? = nil,
        addedAt: Date = Date(),
        lastPlayedAt: Date? = nil,
        playCount: Int = 0
    ) {
        self.id = id
        self.youtubeId = youtubeId
        self.title = title
        self.artist = artist
        self.thumbnailURL = thumbnailURL
        self.duration = duration
        self.addedAt = addedAt
        self.lastPlayedAt = lastPlayedAt
        self.playCount = playCount
    }

    var thumbnailHQURL: String {
        "https://img.youtube.com/vi/\(youtubeId)/hqdefault.jpg"
    }

    var thumbnailMQURL: String {
        "https://img.youtube.com/vi/\(youtubeId)/mqdefault.jpg"
    }

    var thumbnailMaxResURL: String {
        "https://img.youtube.com/vi/\(youtubeId)/maxresdefault.jpg"
    }

    var youtubeURL: String {
        "https://www.youtube.com/watch?v=\(youtubeId)"
    }

    var durationText: String? {
        guard let d = duration, d > 0 else { return nil }
        return FormatUtil.time(Double(d))
    }
}
