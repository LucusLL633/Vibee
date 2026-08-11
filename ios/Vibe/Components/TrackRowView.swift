import SwiftUI

/// A single track row with thumbnail, title, artist, and optional menu
struct TrackRowView: View {
    let track: Track
    var showMenu: Bool = true
    var onPlay: (() -> Void)? = nil
    var onToggleFavorite: (() -> Void)? = nil
    var onAddToPlaylist: (() -> Void)? = nil
    var onRemove: (() -> Void)? = nil
    var onShowInfo: (() -> Void)? = nil
    var isFavorite: Bool = false

    var body: some View {
        HStack(spacing: AppTheme.spacingMedium) {
            TrackThumbnail(thumbnailURL: track.thumbnailURL, videoId: track.youtubeId, size: 48)

            VStack(alignment: .leading, spacing: 3) {
                Text(track.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(1)

                Text(track.artist)
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            if showMenu {
                Menu {
                    Button {
                        onToggleFavorite?()
                    } label: {
                        Label(isFavorite ? "Retirer des favoris" : "Ajouter aux favoris",
                              systemImage: isFavorite ? "heart.slash" : "heart")
                    }

                    Button {
                        onAddToPlaylist?()
                    } label: {
                        Label("Ajouter à une playlist", systemImage: "text.badge.plus")
                    }

                    Button {
                        onShowInfo?()
                    } label: {
                        Label("Informations", systemImage: "info.circle")
                    }

                    Divider()

                    Button(role: .destructive) {
                        onRemove?()
                    } label: {
                        Label("Retirer de la bibliothèque", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18))
                        .foregroundStyle(AppTheme.textSecondary)
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onPlay?()
        }
    }
}
