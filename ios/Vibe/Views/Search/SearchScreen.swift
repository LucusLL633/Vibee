import SwiftUI

/// Search screen — search within user's library + quick add button
struct SearchScreen: View {
    @Environment(LibraryStore.self) private var libraryStore
    @Environment(PlayerManager.self) private var playerManager

    @Binding var showAddMusic: Bool
    @Binding var sheetType: TrackSheetType?

    @State private var searchText: String = ""

    private var searchResults: [Track] {
        guard !searchText.isEmpty else { return [] }
        let query = searchText.lowercased()
        return libraryStore.tracks.filter {
            $0.title.lowercased().contains(query) || $0.artist.lowercased().contains(query)
        }
    }

    private var playlistResults: [Playlist] {
        guard !searchText.isEmpty else { return [] }
        let query = searchText.lowercased()
        return libraryStore.playlists.filter {
            $0.name.lowercased().contains(query) || $0.description.lowercased().contains(query)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spacingLarge) {
                    // Quick add button
                    quickAddButton

                    if searchText.isEmpty {
                        // Recent searches / suggestions
                        if !libraryStore.tracks.isEmpty {
                            VStack(alignment: .leading, spacing: AppTheme.spacingMedium) {
                                Text("Rechercher dans ta bibliothèque")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(AppTheme.textSecondary)
                                    .padding(.horizontal, AppTheme.spacingMedium)

                                Text("Trouve tes musiques, artistes et playlists.")
                                    .font(.system(size: 14))
                                    .foregroundStyle(AppTheme.textTertiary)
                                    .padding(.horizontal, AppTheme.spacingMedium)
                            }
                            .padding(.top, AppTheme.spacingLarge)
                        } else {
                            EmptyStateView(
                                icon: "magnifyingglass",
                                title: "Bibliothèque vide",
                                message: "Ajoute d'abord des musiques pour pouvoir les rechercher.",
                                actionTitle: "+ Ajouter une musique",
                                action: { showAddMusic = true }
                            )
                        }
                    } else {
                        // Search results
                        searchResultsSection
                    }
                }
                .padding(.vertical, AppTheme.spacingMedium)
                .padding(.bottom, playerManager.hasTrack ? 80 : 20)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .searchable(text: $searchText, prompt: "Rechercher dans ta bibliothèque…")
            .navigationBarHidden(true)
        }
    }

    // MARK: - Quick Add

    private var quickAddButton: some View {
        Button {
            showAddMusic = true
        } label: {
            HStack(spacing: AppTheme.spacingMedium) {
                Image(systemName: "link.badge.plus")
                    .font(.system(size: 22))
                    .foregroundStyle(AppTheme.accent)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Ajouter depuis YouTube")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text("Colle un lien pour ajouter une musique")
                        .font(.system(size: 13))
                        .foregroundStyle(AppTheme.textSecondary)
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppTheme.textTertiary)
            }
            .padding(AppTheme.spacingMedium)
            .background(AppTheme.cardBackground)
            .clipShape(.rect(cornerRadius: AppTheme.cornerRadiusMedium))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, AppTheme.spacingMedium)
        .padding(.top, AppTheme.spacingMedium)
    }

    // MARK: - Results

    private var searchResultsSection: some View {
        VStack(spacing: AppTheme.spacingMedium) {
            // Tracks
            if !searchResults.isEmpty {
                VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
                    Text("Musiques (\(searchResults.count))")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppTheme.textSecondary)
                        .padding(.horizontal, AppTheme.spacingMedium)

                    VStack(spacing: 2) {
                        ForEach(searchResults) { track in
                            TrackRowView(
                                track: track,
                                onPlay: {
                                    playerManager.play(track: track, inQueue: searchResults,
                                                      atIndex: searchResults.firstIndex(of: track) ?? 0)
                                },
                                onToggleFavorite: { libraryStore.toggleFavorite(track) },
                                onAddToPlaylist: { sheetType = .playlistPicker(track) },
                                onRemove: { libraryStore.removeTrack(track) },
                                onShowInfo: { sheetType = .info(track) },
                                isFavorite: libraryStore.isFavorite(track)
                            )
                            .padding(.horizontal, AppTheme.spacingMedium)
                        }
                    }
                }
            }

            // Playlists
            if !playlistResults.isEmpty {
                VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
                    Text("Playlists (\(playlistResults.count))")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppTheme.textSecondary)
                        .padding(.horizontal, AppTheme.spacingMedium)

                    VStack(spacing: 2) {
                        ForEach(playlistResults) { playlist in
                            PlaylistRowView(playlist: playlist)
                                .padding(.horizontal, AppTheme.spacingMedium)
                        }
                    }
                }
            }

            // No results
            if searchResults.isEmpty && playlistResults.isEmpty {
                VStack(spacing: AppTheme.spacingMedium) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 36))
                        .foregroundStyle(AppTheme.textTertiary)

                    Text("Aucun résultat pour « \(searchText) »")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)

                    Text("Essaie avec un autre titre ou artiste.")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.textTertiary)
                }
                .padding(.top, AppTheme.spacingXL)
            }
        }
    }
}

enum SearchScope: String, CaseIterable {
    case all = "Tout"
    case tracks = "Musiques"
    case playlists = "Playlists"
}
