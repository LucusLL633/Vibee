import SwiftUI

/// Library screen — all tracks with filter tabs
struct LibraryScreen: View {
    @Environment(LibraryStore.self) private var libraryStore
    @Environment(PlayerManager.self) private var playerManager

    @Binding var sheetType: TrackSheetType?

    @State private var filter: LibraryFilter = .all

    private var filteredTracks: [Track] {
        switch filter {
        case .all:
            return libraryStore.tracks.sorted { $0.addedAt > $1.addedAt }
        case .favorites:
            return libraryStore.favoriteTracks
        case .recentlyAdded:
            return libraryStore.recentlyAddedTracks
        case .recentlyPlayed:
            return libraryStore.recentlyPlayedTracks
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spacingMedium) {
                    // Filter pills
                    filterPills

                    if filteredTracks.isEmpty {
                        emptyState
                    } else {
                        // Play all bar
                        playAllBar

                        // Track list
                        VStack(spacing: 2) {
                            ForEach(filteredTracks) { track in
                                TrackRowView(
                                    track: track,
                                    onPlay: {
                                        playerManager.play(track: track, inQueue: filteredTracks,
                                                          atIndex: filteredTracks.firstIndex(of: track) ?? 0)
                                    },
                                    onToggleFavorite: { libraryStore.toggleFavorite(track) },
                                    onAddToPlaylist: { sheetType = .playlistPicker(track) },
                                    onRemove: { libraryStore.removeTrack(track) },
                                    onShowInfo: { sheetType = .info(track) },
                                    isFavorite: libraryStore.isFavorite(track)
                                )
                            }
                        }
                        .padding(.horizontal, AppTheme.spacingMedium)
                    }
                }
                .padding(.vertical, AppTheme.spacingMedium)
                .padding(.bottom, playerManager.hasTrack ? 80 : 20)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Bibliothèque")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Filter Pills

    private var filterPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.spacingSmall) {
                ForEach(LibraryFilter.allCases) { f in
                    Button {
                        withAnimation(.spring(duration: 0.25)) {
                            filter = f
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: f.icon)
                                .font(.system(size: 13))
                            Text(f.rawValue)
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundStyle(filter == f ? .black : AppTheme.textSecondary)
                        .padding(.horizontal, AppTheme.spacingMedium)
                        .padding(.vertical, 8)
                        .background(filter == f ? AppTheme.accent : AppTheme.cardBackground)
                        .clipShape(.rect(cornerRadius: 20))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, AppTheme.spacingMedium)
        }
    }

    // MARK: - Play All

    private var playAllBar: some View {
        HStack(spacing: AppTheme.spacingMedium) {
            Button {
                playerManager.playQueue(filteredTracks, shuffle: false)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                    Text("Tout lire")
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.black)
                .padding(.horizontal, AppTheme.spacingLarge)
                .padding(.vertical, 10)
                .background(AppTheme.accent)
                .clipShape(.rect(cornerRadius: 20))
            }
            .buttonStyle(.plain)

            Button {
                playerManager.isShuffling = true
                playerManager.playQueue(filteredTracks, shuffle: true)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "shuffle")
                    Text("Aléatoire")
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)
                .padding(.horizontal, AppTheme.spacingLarge)
                .padding(.vertical, 10)
                .background(AppTheme.cardBackground)
                .clipShape(.rect(cornerRadius: 20))
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(.horizontal, AppTheme.spacingMedium)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        EmptyStateView(
            icon: filter == .favorites ? "heart" : "music.note",
            title: emptyTitle,
            message: emptyMessage
        )
    }

    private var emptyTitle: String {
        switch filter {
        case .all: return "Bibliothèque vide"
        case .favorites: return "Pas de favoris"
        case .recentlyAdded: return "Rien de nouveau"
        case .recentlyPlayed: return "Rien d'écouté"
        }
    }

    private var emptyMessage: String {
        switch filter {
        case .all: return "Ajoute des musiques en collant des liens YouTube."
        case .favorites: return "Marque tes musiques préférées avec le cœur."
        case .recentlyAdded: return "Les musiques que tu ajoutes apparaîtront ici."
        case .recentlyPlayed: return "Les musiques que tu écoutes apparaîtront ici."
        }
    }
}
