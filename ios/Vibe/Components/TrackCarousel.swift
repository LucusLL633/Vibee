import SwiftUI

/// Horizontal scrolling track card carousel
struct TrackCarousel: View {
    let tracks: [Track]
    let onPlay: (Track, [Track]) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.spacingMedium) {
                ForEach(tracks) { track in
                    TrackCard(track: track) {
                        onPlay(track, tracks)
                    }
                }
            }
            .padding(.horizontal, AppTheme.spacingMedium)
        }
    }
}

/// Individual track card for carousels
struct TrackCard: View {
    let track: Track
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
                TrackThumbnail(
                    thumbnailURL: track.thumbnailURL,
                    videoId: track.youtubeId,
                    size: 140,
                    cornerRadius: AppTheme.cornerRadiusMedium
                )

                Text(track.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(width: 140, alignment: .leading)

                Text(track.artist)
                    .font(.system(size: 12))
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(1)
                    .frame(width: 140, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
    }
}
