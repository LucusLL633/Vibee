import SwiftUI

/// Mini player shown above the tab bar when a track is loaded
struct MiniPlayerView: View {
    @Environment(PlayerManager.self) private var playerManager

    var body: some View {
        if let track = playerManager.currentTrack {
            HStack(spacing: AppTheme.spacingMedium) {
                TrackThumbnail(thumbnailURL: track.thumbnailURL, videoId: track.youtubeId, size: 44, cornerRadius: 6)

                VStack(alignment: .leading, spacing: 2) {
                    Text(track.title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineLimit(1)

                    Text(track.artist)
                        .font(.system(size: 12))
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineLimit(1)
                }

                Spacer()

                // Play/pause
                Button {
                    playerManager.togglePlayPause()
                } label: {
                    Image(systemName: playerManager.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(.plain)

                // Next
                Button {
                    playerManager.next()
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, AppTheme.spacingSmall)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: AppTheme.cornerRadiusMedium))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                    .stroke(AppTheme.accent.opacity(0.15), lineWidth: 0.5)
            )
            .onTapGesture {
                playerManager.showFullPlayer = true
            }
            .shadow(color: .black.opacity(0.3), radius: 10, y: 4)
        }
    }
}
