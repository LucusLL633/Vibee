import SwiftUI

/// Sheet showing detailed track information
struct TrackInfoSheet: View {
    @Environment(LibraryStore.self) private var libraryStore
    @Environment(\.dismiss) private var dismiss

    let track: Track

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spacingLarge) {
                    // Thumbnail
                    TrackThumbnail(
                        thumbnailURL: track.thumbnailMaxResURL,
                        videoId: track.youtubeId,
                        size: 200,
                        cornerRadius: AppTheme.cornerRadiusLarge
                    )

                    // Title & artist
                    VStack(spacing: 6) {
                        Text(track.title)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(AppTheme.textPrimary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppTheme.spacingMedium)

                        Text(track.artist)
                            .font(.system(size: 16))
                            .foregroundStyle(AppTheme.textSecondary)
                    }

                    // Info rows
                    VStack(spacing: 0) {
                        infoRow(icon: "calendar", title: "Ajoutée le", value: FormatUtil.fullDate(track.addedAt))
                        infoRow(icon: "play.circle", title: "Lectures", value: "\(track.playCount)")
                        infoRow(icon: "heart.fill", title: "Favori", value: libraryStore.isFavorite(track) ? "Oui" : "Non")
                        if let lastPlayed = track.lastPlayedAt {
                            infoRow(icon: "clock", title: "Dernière écoute", value: FormatUtil.relativeDate(lastPlayed))
                        }
                    }
                    .background(AppTheme.cardBackground)
                    .clipShape(.rect(cornerRadius: AppTheme.cornerRadiusMedium))
                    .padding(.horizontal, AppTheme.spacingMedium)

                    // YouTube link
                    Link(destination: URL(string: track.youtubeURL) ?? URL(string: "https://youtube.com")!) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.up.right.square")
                            Text("Ouvrir sur YouTube")
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppTheme.accent)
                        .padding(.horizontal, AppTheme.spacingLarge)
                        .padding(.vertical, 12)
                        .background(AppTheme.accentDim)
                        .clipShape(.rect(cornerRadius: 20))
                    }
                    .padding(.top, AppTheme.spacingSmall)
                }
                .padding(.vertical, AppTheme.spacingLarge)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Informations")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") { dismiss() }
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
        }
    }

    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: AppTheme.spacingMedium) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(AppTheme.textSecondary)
                .frame(width: 24)

            Text(title)
                .font(.system(size: 15))
                .foregroundStyle(AppTheme.textSecondary)

            Spacer()

            Text(value)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(AppTheme.textPrimary)
        }
        .padding(.horizontal, AppTheme.spacingMedium)
        .padding(.vertical, 14)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(AppTheme.elevatedBackground)
                .frame(height: 0.5)
                .padding(.leading, 52)
        }
    }
}
