import SwiftUI

/// Playlist detail — shows tracks in a playlist with play/shuffle/reorder
struct PlaylistDetailView: View {
    @Environment(LibraryStore.self) private var libraryStore
    @Environment(PlayerManager.self) private var playerManager

    let playlist: Playlist
    @Binding var sheetType: TrackSheetType?

    @State private var showEditSheet = false

    private var tracks: [Track] {
        libraryStore.tracksInPlaylist(playlist)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.spacingLarge) {
                // Header
                headerSection

                // Actions
                actionButtons

                // Track list
                if tracks.isEmpty {
                    VStack(spacing: AppTheme.spacingMedium) {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 40))
                            .foregroundStyle(AppTheme.textTertiary)

                        Text("Playlist vide")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)

                        Text("Ajoute des musiques depuis ta bibliothèque.")
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.textTertiary)
                    }
                    .padding(.top, AppTheme.spacingXL)
                } else {
                    VStack(spacing: 2) {
                        ForEach(tracks) { track in
                            HStack(spacing: AppTheme.spacingSmall) {
                                Image(systemName: "line.3.horizontal")
                                    .font(.system(size: 14))
                                    .foregroundStyle(AppTheme.textTertiary)

                                TrackRowView(
                                    track: track,
                                    onPlay: {
                                        playerManager.play(track: track, inQueue: tracks,
                                                          atIndex: tracks.firstIndex(of: track) ?? 0)
                                    },
                                    onToggleFavorite: { libraryStore.toggleFavorite(track) },
                                    onAddToPlaylist: { sheetType = .playlistPicker(track) },
                                    onRemove: { libraryStore.removeTrack(track.id, fromPlaylist: playlist.id) },
                                    onShowInfo: { sheetType = .info(track) },
                                    isFavorite: libraryStore.isFavorite(track)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.spacingMedium)
                }
            }
            .padding(.vertical, AppTheme.spacingLarge)
            .padding(.bottom, playerManager.hasTrack ? 80 : 20)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
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
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 20))
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: AppTheme.spacingMedium) {
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                    .fill(Color(hexString: playlist.coverColorHex) ?? AppTheme.accent)
                    .frame(width: 180, height: 180)
                    .shadow(color: .black.opacity(0.4), radius: 15, y: 8)

                Image(systemName: "music.note.list")
                    .font(.system(size: 56))
                    .foregroundStyle(.black.opacity(0.8))
            }

            VStack(spacing: 6) {
                Text(playlist.name)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)

                if !playlist.description.isEmpty {
                    Text(playlist.description)
                        .font(.system(size: 15))
                        .foregroundStyle(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }

                Text("Playlist • \(tracks.count) titre\(tracks.count > 1 ? "s" : "")")
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.textTertiary)
            }
        }
    }

    // MARK: - Actions

    private var actionButtons: some View {
        HStack(spacing: AppTheme.spacingMedium) {
            Button {
                playerManager.playQueue(tracks, shuffle: false)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                    Text("Lecture")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.black)
                .padding(.horizontal, AppTheme.spacingLarge)
                .padding(.vertical, 12)
                .background(AppTheme.accent)
                .clipShape(.rect(cornerRadius: 22))
            }
            .buttonStyle(.plain)
            .disabled(tracks.isEmpty)

            Button {
                playerManager.isShuffling = true
                playerManager.playQueue(tracks, shuffle: true)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "shuffle")
                    Text("Aléatoire")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)
                .padding(.horizontal, AppTheme.spacingLarge)
                .padding(.vertical, 12)
                .background(AppTheme.cardBackground)
                .clipShape(.rect(cornerRadius: 22))
            }
            .buttonStyle(.plain)
            .disabled(tracks.isEmpty)

            Spacer()
        }
        .padding(.horizontal, AppTheme.spacingMedium)
    }
}
