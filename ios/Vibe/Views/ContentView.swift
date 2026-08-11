import SwiftUI

/// Root tab bar view with mini player overlay
struct ContentView: View {
    @Environment(LibraryStore.self) private var libraryStore
    @Environment(PlayerManager.self) private var playerManager
    @Environment(SettingsStore.self) private var settingsStore

    @State private var selectedTab: AppTab = .home
    @State private var showAddMusic = false
    @State private var sheetType: TrackSheetType?

    var body: some View {
        ZStack(alignment: .bottom) {
            AppTheme.background.ignoresSafeArea()

            TabView(selection: $selectedTab) {
                HomeScreen(showAddMusic: $showAddMusic, sheetType: $sheetType)
                    .tabItem {
                        Label("Accueil", systemImage: "house.fill")
                    }
                    .tag(AppTab.home)

                SearchScreen(showAddMusic: $showAddMusic, sheetType: $sheetType)
                    .tabItem {
                        Label("Recherche", systemImage: "magnifyingglass")
                    }
                    .tag(AppTab.search)

                LibraryScreen(sheetType: $sheetType)
                    .tabItem {
                        Label("Bibliothèque", systemImage: "books.vertical.fill")
                    }
                    .tag(AppTab.library)

                PlaylistsScreen(sheetType: $sheetType)
                    .tabItem {
                        Label("Playlists", systemImage: "music.note.list")
                    }
                    .tag(AppTab.playlists)
            }
            .tint(AppTheme.accent)

            // Hidden YouTube IFrame player — stays alive for continuous playback
            HiddenPlayerView()
                .frame(width: 1, height: 1)
                .opacity(0.01)
                .allowsHitTesting(false)
                .position(x: -100, y: -100)

            // Mini player + tab bar overlay
            VStack(spacing: 0) {
                if playerManager.hasTrack {
                    MiniPlayerView()
                        .padding(.horizontal, AppTheme.spacingSmall)
                        .padding(.bottom, 4)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.spring(duration: 0.4), value: playerManager.hasTrack)
        }
        .sheet(isPresented: $showAddMusic) {
            AddMusicScreen()
        }
        .sheet(item: $sheetType) { type in
            sheetView(for: type)
        }
        .fullScreenCover(isPresented: Bindable(playerManager).showFullPlayer) {
            FullPlayerView()
        }
        .preferredColorScheme(settingsStore.colorScheme)
    }

    @ViewBuilder
    private func sheetView(for type: TrackSheetType) -> some View {
        switch type {
        case .playlistPicker(let track):
            PlaylistPickerSheet(track: track)
        case .info(let track):
            TrackInfoSheet(track: track)
        case .createPlaylist(let trackId):
            CreatePlaylistSheet(initialTrackId: trackId)
        case .editPlaylist(let playlist):
            EditPlaylistSheet(playlist: playlist)
        }
    }
}

enum AppTab: Hashable {
    case home, search, library, playlists
}
