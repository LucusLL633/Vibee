import SwiftUI

@main
struct VibeApp: App {
    @State private var libraryStore: LibraryStore
    @State private var settingsStore: SettingsStore
    @State private var playerManager: PlayerManager

    init() {
        let library = LibraryStore()
        let settings = SettingsStore()
        _libraryStore = State(initialValue: library)
        _settingsStore = State(initialValue: settings)
        _playerManager = State(initialValue: PlayerManager(libraryStore: library))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(libraryStore)
                .environment(settingsStore)
                .environment(playerManager)
                .preferredColorScheme(settingsStore.colorScheme)
                .tint(AppTheme.accent)
        }
    }
}
