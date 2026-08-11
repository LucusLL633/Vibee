import SwiftUI

/// Settings screen — appearance, playback, data management, about
struct SettingsScreen: View {
    @Environment(LibraryStore.self) private var libraryStore
    @Environment(SettingsStore.self) private var settingsStore

    @State private var showClearHistoryConfirm = false
    @State private var showClearLibraryConfirm = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spacingLarge) {
                    // Appearance
                    settingsSection("Apparence", icon: "paintbrush.fill") {
                        ForEach(AppearanceMode.allCases) { mode in
                            settingsRow(
                                icon: mode.icon,
                                title: mode.rawValue,
                                isSelected: settingsStore.appearance == mode
                            ) {
                                settingsStore.appearance = mode
                            }
                        }
                    }

                    // Playback
                    settingsSection("Lecture", icon: "play.circle.fill") {
                        Toggle(isOn: Bindable(settingsStore).autoplay) {
                            settingsRowLabel(icon: "play.fill", title: "Lecture automatique")
                        }
                        .tint(AppTheme.accent)

                        Toggle(isOn: Bindable(settingsStore).defaultShuffle) {
                            settingsRowLabel(icon: "shuffle", title: "Lecture aléatoire par défaut")
                        }
                        .tint(AppTheme.accent)

                        Toggle(isOn: Bindable(settingsStore).highQualityThumbnails) {
                            settingsRowLabel(icon: "photo", title: "Miniatures haute qualité")
                        }
                        .tint(AppTheme.accent)
                    }

                    // Data Management
                    settingsSection("Données locales", icon: "internaldrive.fill") {
                        statsRow

                        Button {
                            showClearHistoryConfirm = true
                        } label: {
                            settingsRowLabel(icon: "clock.arrow.circlepath", title: "Effacer l'historique", color: AppTheme.textPrimary)
                        }

                        Button {
                            showClearLibraryConfirm = true
                        } label: {
                            settingsRowLabel(icon: "trash", title: "Vider la bibliothèque", color: .red)
                        }
                    }

                    // About
                    settingsSection("À propos", icon: "info.circle.fill") {
                        settingsRowLabel(icon: "music.note", title: "Vibe", subtitle: "Version 1.0.0")
                        settingsRowLabel(icon: "checkmark.shield.fill", title: "Conformité YouTube",
                                         subtitle: "Lecture via l'API officielle YouTube IFrame. Aucun téléchargement, conversion ou contournement.")
                        settingsRowLabel(icon: "heart.text.square.fill", title: "Méthode",
                                         subtitle: "Métadonnées via YouTube oEmbed. Lecture via lecteur intégré officiel.")
                    }

                    // Legal note
                    VStack(spacing: 6) {
                        Text("Vibe respecte les conditions d'utilisation de YouTube.")
                            .font(.system(size: 12))
                            .foregroundStyle(AppTheme.textTertiary)
                        Text("L'application ne télécharge, ne convertit et ne stocke aucun fichier audio ou vidéo YouTube.")
                            .font(.system(size: 12))
                            .foregroundStyle(AppTheme.textTertiary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, AppTheme.spacingMedium)
                    .padding(.top, AppTheme.spacingSmall)
                }
                .padding(.vertical, AppTheme.spacingLarge)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Paramètres")
            .navigationBarTitleDisplayMode(.large)
            .alert("Effacer l'historique ?", isPresented: $showClearHistoryConfirm) {
                Button("Annuler", role: .cancel) {}
                Button("Effacer", role: .destructive) {
                    libraryStore.clearHistory()
                }
            } message: {
                Text("Tout l'historique d'écoute sera supprimé. Cette action est irréversible.")
            }
            .alert("Vider la bibliothèque ?", isPresented: $showClearLibraryConfirm) {
                Button("Annuler", role: .cancel) {}
                Button("Tout supprimer", role: .destructive) {
                    libraryStore.clearAllData()
                }
            } message: {
                Text("Toutes les musiques, playlists, favoris et historique seront supprimés. Cette action est irréversible.")
            }
        }
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: AppTheme.spacingMedium) {
            statItem("\(libraryStore.tracks.count)", "Musiques")
            Divider().frame(height: 28)
            statItem("\(libraryStore.playlists.count)", "Playlists")
            Divider().frame(height: 28)
            statItem("\(libraryStore.favoriteIds.count)", "Favoris")
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.spacingSmall)
    }

    private func statItem(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(AppTheme.accent)
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(AppTheme.textSecondary)
        }
    }

    // MARK: - Settings Components

    private func settingsSection<Content: View>(_ title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.accent)
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .padding(.horizontal, AppTheme.spacingMedium)

            VStack(spacing: 0) {
                content()
            }
            .background(AppTheme.cardBackground)
            .clipShape(.rect(cornerRadius: AppTheme.cornerRadiusMedium))
            .padding(.horizontal, AppTheme.spacingMedium)
        }
    }

    private func settingsRow(icon: String, title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: AppTheme.spacingMedium) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(AppTheme.textSecondary)
                    .frame(width: 24)

                Text(title)
                    .font(.system(size: 16))
                    .foregroundStyle(AppTheme.textPrimary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(AppTheme.accent)
                }
            }
            .padding(.horizontal, AppTheme.spacingMedium)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(alignment: .bottom) {
            if title != AppearanceMode.allCases.last?.rawValue {
                Rectangle()
                    .fill(AppTheme.elevatedBackground)
                    .frame(height: 0.5)
                    .padding(.leading, 52)
            }
        }
    }

    private func settingsRowLabel(icon: String, title: String, subtitle: String? = nil, color: Color = AppTheme.textPrimary) -> some View {
        HStack(spacing: AppTheme.spacingMedium) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color.opacity(0.8))
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16))
                    .foregroundStyle(color)

                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(AppTheme.textTertiary)
                        .lineLimit(3)
                }
            }

            Spacer()
        }
        .padding(.horizontal, AppTheme.spacingMedium)
        .padding(.vertical, 14)
    }
}
