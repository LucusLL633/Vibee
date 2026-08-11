import SwiftUI

/// Reusable async thumbnail image view with placeholder
struct TrackThumbnail: View {
    let thumbnailURL: String
    let videoId: String
    var size: CGFloat = 48
    var cornerRadius: CGFloat = 8

    var body: some View {
        AsyncImage(url: URL(string: thumbnailURL)) { phase in
            switch phase {
            case .empty:
                Rectangle()
                    .fill(AppTheme.elevatedBackground)
                    .overlay {
                        Image(systemName: "music.note")
                            .foregroundStyle(AppTheme.textTertiary)
                            .font(.system(size: size * 0.35))
                    }
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure:
                Rectangle()
                    .fill(AppTheme.elevatedBackground)
                    .overlay {
                        Image(systemName: "music.note")
                            .foregroundStyle(AppTheme.textTertiary)
                            .font(.system(size: size * 0.35))
                    }
            @unknown default:
                Rectangle()
                    .fill(AppTheme.elevatedBackground)
                    .overlay {
                        Image(systemName: "music.note")
                            .foregroundStyle(AppTheme.textTertiary)
                            .font(.system(size: size * 0.35))
                    }
            }
        }
        .frame(width: size, height: size)
        .clipShape(.rect(cornerRadius: cornerRadius))
    }
}
