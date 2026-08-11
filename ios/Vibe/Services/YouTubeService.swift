import Foundation

/// Error types for YouTube metadata fetching
enum YouTubeError: LocalizedError {
    case invalidURL
    case unsupportedURL
    case notFound
    case privateVideo
    case network
    case noMetadata
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Le lien n'est pas valide."
        case .unsupportedURL:
            return "Ce type de lien YouTube n'est pas supporté. Utilise un lien de vidéo YouTube."
        case .notFound:
            return "Cette vidéo n'existe pas ou a été supprimée."
        case .privateVideo:
            return "Cette vidéo est privée et n'est pas accessible."
        case .network:
            return "Erreur réseau. Vérifie ta connexion Internet et réessaie."
        case .noMetadata:
            return "Impossible de récupérer les informations de cette vidéo."
        case .unknown:
            return "Une erreur inattendue s'est produite."
        }
    }

    var icon: String {
        switch self {
        case .invalidURL, .unsupportedURL: return "exclamationmark.link"
        case .notFound: return "questionmark.video"
        case .privateVideo: return "lock.fill"
        case .network: return "wifi.slash"
        case .noMetadata, .unknown: return "exclamationmark.triangle"
        }
    }
}

/// Metadata fetched from YouTube's oEmbed API (free, no API key needed)
struct YouTubeMetadata: Codable {
    let title: String
    let authorName: String
    let thumbnailURL: String
    let thumbnailWidth: Int
    let thumbnailHeight: Int

    enum CodingKeys: String, CodingKey {
        case title
        case authorName = "author_name"
        case thumbnailURL = "thumbnail_url"
        case thumbnailWidth = "thumbnail_width"
        case thumbnailHeight = "thumbnail_height"
    }
}

/// YouTubeService handles all YouTube-related operations using official, compliant APIs.
///
/// Metadata is fetched via the YouTube oEmbed endpoint (https://www.youtube.com/oembed),
/// which is a free, public, official API that requires no API key.
/// Playback uses the official YouTube IFrame Player API via WKWebView.
/// No downloading, converting, or storing of YouTube audio/video files occurs.
struct YouTubeService {

    /// Extracts the 11-character video ID from various YouTube URL formats.
    static func extractVideoId(from url: String) -> String? {
        let trimmed = url.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let parsed = URL(string: trimmed) else {
            if trimmed.count == 11 && !trimmed.contains("/") { return trimmed }
            return nil
        }

        let host = parsed.host?.replacingOccurrences(of: "www.", with: "") ?? ""

        if host == "youtu.be" {
            let id = parsed.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            return id.count == 11 ? id : nil
        }

        if host.hasSuffix("youtube.com") || host.hasSuffix("youtube-nocookie.com") {
            let components = URLComponents(url: parsed, resolvingAgainstBaseURL: false)
            if parsed.path == "/watch" {
                if let v = components?.queryItems?.first(where: { $0.name == "v" })?.value {
                    return v.count == 11 ? v : nil
                }
            }
            if parsed.path.hasPrefix("/embed/") {
                let id = String(parsed.path.dropFirst("/embed/".count))
                return id.count == 11 ? id : nil
            }
            if parsed.path.hasPrefix("/shorts/") {
                let id = String(parsed.path.dropFirst("/shorts/".count))
                    .components(separatedBy: "/").first ?? ""
                return id.count == 11 ? id : nil
            }
            if let v = components?.queryItems?.first(where: { $0.name == "v" })?.value {
                return v.count == 11 ? v : nil
            }
        }

        if trimmed.count == 11 && !trimmed.contains(" ") { return trimmed }
        return nil
    }

    /// Fetches video metadata via the official YouTube oEmbed API.
    /// This is a free public endpoint that returns title, author, and thumbnail.
    static func fetchMetadata(forVideoId videoId: String) async -> Result<YouTubeMetadata, YouTubeError> {
        let urlString = "https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=\(videoId)&format=json"

        guard let url = URL(string: urlString) else {
            return .failure(.invalidURL)
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 15

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let http = response as? HTTPURLResponse {
                if http.statusCode == 403 {
                    return .failure(.privateVideo)
                }
                if http.statusCode == 404 {
                    return .failure(.notFound)
                }
                if http.statusCode != 200 {
                    return .failure(.noMetadata)
                }
            }

            let metadata = try JSONDecoder().decode(YouTubeMetadata.self, from: data)
            return .success(metadata)
        } catch let error as DecodingError {
            _ = error
            return .failure(.noMetadata)
        } catch {
            if let urlError = error as? URLError {
                switch urlError.code {
                case .notConnectedToInternet, .networkConnectionLost,
                     .timedOut, .cannotFindHost, .cannotConnectToHost:
                    return .failure(.network)
                default:
                    return .failure(.network)
                }
            }
            return .failure(.unknown)
        }
    }

    /// Builds a Track from YouTube oEmbed metadata.
    static func buildTrack(from metadata: YouTubeMetadata, videoId: String) -> Track {
        let betterThumb = "https://img.youtube.com/vi/\(videoId)/hqdefault.jpg"
        return Track(
            youtubeId: videoId,
            title: metadata.title,
            artist: metadata.authorName,
            thumbnailURL: betterThumb
        )
    }

    /// Returns the YouTube embed URL for playback via the official IFrame API.
    static func embedURL(forVideoId videoId: String, autoplay: Bool = true) -> URL? {
        var components = URLComponents(string: "https://www.youtube.com/embed/\(videoId)")
        components?.queryItems = [
            URLQueryItem(name: "enablejsapi", value: "1"),
            URLQueryItem(name: "playsinline", value: "1"),
            URLQueryItem(name: "autoplay", value: autoplay ? "1" : "0"),
            URLQueryItem(name: "controls", value: "0"),
            URLQueryItem(name: "modestbranding", value: "1"),
            URLQueryItem(name: "rel", value: "0"),
            URLQueryItem(name: "iv_load_policy", value: "3"),
        ]
        return components?.url
    }
}
