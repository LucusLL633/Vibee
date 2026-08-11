import SwiftUI

/// Full screen player with large artwork, controls, and progress
struct FullPlayerView: View {
    @Environment(PlayerManager.self) private var playerManager
    @Environment(LibraryStore.self) private var libraryStore
    @Environment(\.dismiss) private var dismiss

    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false

    var body: some View {
        ZStack(alignment: .top) {
            AppTheme.playerGradient.ignoresSafeArea()

            // Blurred background thumbnail
            if let track = playerManager.currentTrack {
                AsyncImage(url: URL(string: track.thumbnailMaxResURL)) { phase in
                    if case .success(let image) = phase {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .blur(radius: 60)
                            .opacity(0.15)
                            .ignoresSafeArea()
                    }
                }
            }

            VStack(spacing: 0) {
                // Drag handle + close
                topBar

                if let track = playerManager.currentTrack {
                    artworkSection(track)

                    trackInfoSection(track)

                    progressSection

                    controlsSection

                    bottomActions(track)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, AppTheme.spacingLarge)
            .padding(.top, AppTheme.spacingSmall)
        }
        .offset(y: dragOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if value.translation.height > 0 {
                        dragOffset = value.translation.height
                        isDragging = true
                    }
                }
                .onEnded { value in
                    isDragging = false
                    if value.translation.height > 120 {
                        playerManager.showFullPlayer = false
                    }
                    withAnimation(.spring(duration: 0.3)) {
                        dragOffset = 0
                    }
                }
        )
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button {
                playerManager.showFullPlayer = false
            } label: {
                Image(systemName: "chevron.down")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(AppTheme.textSecondary)
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)

            Spacer()

            Text("LECTURE EN COURS")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(AppTheme.textTertiary)
                .tracking(1.5)

            Spacer()

            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.bottom, AppTheme.spacingMedium)
    }

    // MARK: - Artwork

    private func artworkSection(_ track: Track) -> some View {
        TrackThumbnail(
            thumbnailURL: track.thumbnailMaxResURL,
            videoId: track.youtubeId,
            size: UIScreen.main.bounds.width - AppTheme.spacingLarge * 2,
            cornerRadius: AppTheme.cornerRadiusXL
        )
        .shadow(color: .black.opacity(0.5), radius: 20, y: 10)
        .padding(.bottom, AppTheme.spacingLarge)
    }

    // MARK: - Track Info

    private func trackInfoSection(_ track: Track) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text(track.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(track.artist)
                    .font(.system(size: 18))
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            Button {
                playerManager.toggleFavoriteCurrentTrack()
            } label: {
                Image(systemName: playerManager.isCurrentTrackFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 22))
                    .foregroundStyle(playerManager.isCurrentTrackFavorite ? AppTheme.accent : AppTheme.textSecondary)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
        }
        .padding(.bottom, AppTheme.spacingLarge)
    }

    // MARK: - Progress

    private var progressSection: some View {
        VStack(spacing: 6) {
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppTheme.elevatedBackground)
                        .frame(height: 4)

                    Capsule()
                        .fill(AppTheme.accent)
                        .frame(width: geo.size.width * playerManager.progress, height: 4)
                }
                .frame(maxHeight: 4)
            }
            .frame(height: 4)

            HStack {
                Text(FormatUtil.time(playerManager.currentTime))
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(AppTheme.textTertiary)

                Spacer()

                if playerManager.isBuffering {
                    Text("Chargement…")
                        .font(.system(size: 12))
                        .foregroundStyle(AppTheme.textTertiary)
                } else if let dur = playerManager.currentTrack?.duration, dur > 0 {
                    Text(FormatUtil.time(Double(dur)))
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(AppTheme.textTertiary)
                } else {
                    Text(FormatUtil.time(playerManager.duration))
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(AppTheme.textTertiary)
                }
            }
        }
        .padding(.bottom, AppTheme.spacingLarge)
    }

    // MARK: - Controls

    private var controlsSection: some View {
        HStack(spacing: 0) {
            // Shuffle
            Button {
                playerManager.toggleShuffle()
            } label: {
                Image(systemName: "shuffle")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(playerManager.isShuffling ? AppTheme.accent : AppTheme.textSecondary)
                    .frame(width: 50, height: 50)
            }
            .buttonStyle(.plain)

            Spacer()

            // Previous
            PlayerControlButton(icon: "backward.fill") {
                playerManager.previous()
            }

            Spacer()

            // Play/Pause
            PlayPauseButton(isPlaying: playerManager.isPlaying) {
                playerManager.togglePlayPause()
            }

            Spacer()

            // Next
            PlayerControlButton(icon: "forward.fill") {
                playerManager.next()
            }

            Spacer()

            // Repeat
            Button {
                playerManager.cycleRepeatMode()
            } label: {
                Image(systemName: playerManager.repeatMode.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(playerManager.repeatMode.isActive ? AppTheme.accent : AppTheme.textSecondary)
                    .frame(width: 50, height: 50)
            }
            .buttonStyle(.plain)
        }
        .padding(.bottom, AppTheme.spacingLarge)
    }

    // MARK: - Bottom Actions

    private func bottomActions(_ track: Track) -> some View {
        HStack(spacing: AppTheme.spacingLarge) {
            Spacer()

            // YouTube link
            Link(destination: URL(string: track.youtubeURL) ?? URL(string: "https://youtube.com")!) {
                VStack(spacing: 4) {
                    Image(systemName: "arrow.up.right.square")
                        .font(.system(size: 20))
                    Text("YouTube")
                        .font(.system(size: 11))
                }
                .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()
        }
        .padding(.bottom, AppTheme.spacingSmall)
    }
}
