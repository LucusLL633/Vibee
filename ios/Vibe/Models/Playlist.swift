import Foundation

struct Playlist: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var description: String
    var trackIds: [String]
    var createdAt: Date
    var coverColorHex: String

    init(
        id: String = UUID().uuidString,
        name: String,
        description: String = "",
        trackIds: [String] = [],
        createdAt: Date = Date(),
        coverColorHex: String = Playlist.randomCoverColor()
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.trackIds = trackIds
        self.createdAt = createdAt
        self.coverColorHex = coverColorHex
    }

    var trackCount: Int { trackIds.count }

    static let coverColors: [String] = [
        "#00FA82", "#00C6FF", "#FF6B6B", "#FFD93D",
        "#A855F7", "#FF4081", "#00E5FF", "#FF9100"
    ]

    static func randomCoverColor() -> String {
        coverColors.randomElement() ?? "#00FA82"
    }
}
