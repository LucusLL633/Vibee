import SwiftUI

/// Playlists tab — list of all playlists + create new
struct PlaylistsScreen: View {
    @Environment(LibraryStore.self) private var libraryStore
    @Environment(PlayerManager.self) private var playerManager

    @Binding var sheetType: TrackSheetType?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spacingMedium) {
                    // Create playlist button
                    Button {
                        sheetType = .createPlaylist(trackId: nil)
                    } label: {
                        HStack(spacing: AppTheme.spacingMedium) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(AppTheme.accent)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Créer une playlist")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(AppTheme.textPrimary)

                                Text("Organise tes musiques")
                                    .font(.system(size: 13))
                                    .foregroundStyle(AppTheme.textSecondary)
                            }

                            Spacer()
                        }
                        .padding(AppTheme.spacingMedium)
                        .background(AppTheme.cardBackground)
                        .clipShape(.rect(cornerRadius: AppTheme.cornerRadiusMedium))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, AppTheme.spacingMedium)

                    if libraryStore.playlists.isEmpty {
                        EmptyStateView(
                            icon: "music.note.list",
                            title: "Aucune playlist",
                            message: "Crée ta première playlist pour organiser tes musiques par thème, humeur ou genre."
                        )
                        .padding(.top, AppTheme.spacingLarge)
                    } else {
                        VStack(spacing: 2) {
                            ForEach(libraryStore.playlists) { playlist in
                                NavigationLink(value: playlist) {
                                    PlaylistRowView(playlist: playlist)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button {
                                        sheetType = .editPlaylist(playlist)
                                    } label: {
                                        Label("Modifier", systemImage: "pencil")
                                    }
                                    Button(role: .destructive) {
                                        libraryStore.deletePlaylist(playlist)
                                    } label: {
                                        Label("Supprimer", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, AppTheme.spacingMedium)
                    }
                }
                .padding(.vertical, AppTheme.spacingMedium)
                .padding(.bottom, playerManager.hasTrack ? 80 : 20)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Playlists")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: Playlist.self) { playlist in
                PlaylistDetailView(playlist: playlist, sheetType: $sheetType)
            }
        }
    }
}

/// Row view for a playlist
struct PlaylistRowView: View {
    @Environment(LibraryStore.self) private var libraryStore

    let playlist: Playlist

    var body: some View {
        HStack(spacing: AppTheme.spacingMedium) {
            // Cover
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                    .fill(Color(hexString: playlist.coverColorHex) ?? AppTheme.accent)
                    .frame(width: 56, height: 56)

                Image(systemName: "music.note.list")
                    .font(.system(size: 22))
                    .foregroundStyle(.black.opacity(0.8))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(playlist.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(1)

                Text("Playlist • \(playlist.trackCount) titre\(playlist.trackCount > 1 ? "s" : "")")
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppTheme.textTertiary)
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }
}
