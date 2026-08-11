import SwiftUI

/// Home screen — personalized greeting, recently added, recently played, favorites, playlists
struct HomeScreen: View {
    @Environment(LibraryStore.self) private var libraryStore
    @Environment(PlayerManager.self) private var playerManager

    @Binding var showAddMusic: Bool
    @Binding var sheetType: TrackSheetType?

    @State private var showSettings = false

    private var recentlyAdded: [Track] { libraryStore.recentlyAddedTracks }
    private var recentlyPlayed: [Track] { libraryStore.recentlyPlayedTracks }
    private var favorites: [Track] { libraryStore.favoriteTracks }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spacingLarge) {
                    // Greeting
                    greetingSection

                    // Add music button
                    addButton

                    // Recently added
                    if !recentlyAdded.isEmpty {
                        VStack(spacing: AppTheme.spacingMedium) {
                            SectionHeader(title: "Récemment ajoutées")
                            TrackCarousel(tracks: recentlyAdded) { track, queue in
                                playerManager.play(track: track, inQueue: queue, atIndex: queue.firstIndex(of: track) ?? 0)
                            }
                        }
                    }

                    // Recently played
                    if !recentlyPlayed.isEmpty {
                        VStack(spacing: AppTheme.spacingMedium) {
                            SectionHeader(title: "Écoutées récemment")
                            TrackCarousel(tracks: Array(recentlyPlayed.prefix(10))) { track, queue in
                                playerManager.play(track: track, inQueue: queue, atIndex: queue.firstIndex(of: track) ?? 0)
                            }
                        }
                    }

                    // Favorites
                    if !favorites.isEmpty {
                        VStack(spacing: AppTheme.spacingMedium) {
                            SectionHeader(title: "Favoris", subtitle: "\(favorites.count) titre\(favorites.count > 1 ? "s" : "")")
                            TrackCarousel(tracks: Array(favorites.prefix(10))) { track, queue in
                                playerManager.play(track: track, inQueue: queue, atIndex: queue.firstIndex(of: track) ?? 0)
                            }
                        }
                    }

                    // Playlists
                    if !libraryStore.playlists.isEmpty {
                        VStack(spacing: AppTheme.spacingMedium) {
                            SectionHeader(title: "Playlists")
                            playlistCards
                        }
                    }

                    // Empty state
                    if libraryStore.tracks.isEmpty {
                        EmptyStateView(
                            icon: "music.note.house",
                            title: "Bienvenue sur Vibe",
                            message: "Ajoute ta première musique en collant un lien YouTube pour commencer ta bibliothèque.",
                            actionTitle: "+ Ajouter une musique",
                            action: { showAddMusic = true }
                        )
                        .padding(.top, AppTheme.spacingXL)
                    }
                }
                .padding(.vertical, AppTheme.spacingLarge)
                .padding(.bottom, playerManager.hasTrack ? 80 : 20)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationBarHidden(true)
            .sheet(isPresented: $showSettings) {
                SettingsScreen()
            }
        }
    }

    // MARK: - Greeting

    private var greetingSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greetingText)
                    .font(.system(size: 15))
                    .foregroundStyle(AppTheme.textSecondary)

                Text("Bonjour \u{1F44B}")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)
            }
            Spacer()

            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(AppTheme.textSecondary)
                    .frame(width: 40, height: 40)
                    .background(AppTheme.cardBackground)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, AppTheme.spacingMedium)
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Bonjour"
        case 12..<18: return "Bon après-midi"
        case 18..<22: return "Bonsoir"
        default: return "Bonne nuit"
        }
    }

    // MARK: - Add Button

    private var addButton: some View {
        Button {
            showAddMusic = true
        } label: {
            HStack(spacing: AppTheme.spacingMedium) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.black)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Ajouter une musique")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.black)

                    Text("Colle un lien YouTube")
                        .font(.system(size: 13))
                        .foregroundStyle(.black.opacity(0.7))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.black.opacity(0.6))
            }
            .padding(AppTheme.spacingLarge)
            .background(AppTheme.accentGradient)
            .clipShape(.rect(cornerRadius: AppTheme.cornerRadiusLarge))
            .shadow(color: AppTheme.accent.opacity(0.3), radius: 10, y: 5)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, AppTheme.spacingMedium)
    }

    // MARK: - Playlist Cards

    private var playlistCards: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.spacingMedium) {
                ForEach(libraryStore.playlists) { playlist in
                    PlaylistCard(playlist: playlist)
                }
            }
            .padding(.horizontal, AppTheme.spacingMedium)
        }
    }
}

/// Playlist card for horizontal carousels
struct PlaylistCard: View {
    @Environment(LibraryStore.self) private var libraryStore
    @Environment(PlayerManager.self) private var playerManager

    let playlist: Playlist

    var body: some View {
        let tracks = libraryStore.tracksInPlaylist(playlist)
        Button {
            playerManager.playQueue(tracks, shuffle: false)
        } label: {
            VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
                ZStack {
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                        .fill(Color(hexString: playlist.coverColorHex) ?? AppTheme.accent)
                        .frame(width: 140, height: 140)

                    Image(systemName: "music.note.list")
                        .font(.system(size: 40))
                        .foregroundStyle(.black.opacity(0.8))
                }

                Text(playlist.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(1)
                    .frame(width: 140, alignment: .leading)

                Text("\(playlist.trackCount) titre\(playlist.trackCount > 1 ? "s" : "")")
                    .font(.system(size: 12))
                    .foregroundStyle(AppTheme.textSecondary)
                    .frame(width: 140, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
    }
}
