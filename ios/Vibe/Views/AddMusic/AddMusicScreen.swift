import SwiftUI

/// Add Music screen — paste YouTube link, fetch metadata, add to library
struct AddMusicScreen: View {
    @Environment(LibraryStore.self) private var libraryStore
    @Environment(\.dismiss) private var dismiss

    @State private var urlText: String = ""
    @State private var isLoading: Bool = false
    @State private var error: YouTubeError? = nil
    @State private var previewTrack: Track? = nil
    @State private var selectedPlaylistId: String? = nil
    @State private var addToFavorites: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spacingLarge) {
                    // URL input
                    urlInputSection

                    // Loading
                    if isLoading {
                        LoadingMetadataCard()
                            .padding(.horizontal, AppTheme.spacingMedium)
                    }

                    // Error
                    if let error {
                        errorView(error)
                    }

                    // Preview
                    if let track = previewTrack {
                        previewSection(track)
                    }

                    // Paste from clipboard
                    if previewTrack == nil && !isLoading {
                        pasteButton
                    }
                }
                .padding(.vertical, AppTheme.spacingLarge)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Ajouter une musique")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annuler") { dismiss() }
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
        }
    }

    // MARK: - URL Input

    private var urlInputSection: some View {
        VStack(spacing: AppTheme.spacingMedium) {
            HStack(spacing: AppTheme.spacingSmall) {
                Image(systemName: "link")
                    .font(.system(size: 18))
                    .foregroundStyle(AppTheme.textTertiary)

                TextField("Colle un lien YouTube…", text: $urlText)
                    .font(.system(size: 16))
                    .foregroundStyle(AppTheme.textPrimary)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.done)
                    .onSubmit { fetchMetadata() }
            }
            .padding(AppTheme.spacingMedium)
            .background(AppTheme.cardBackground)
            .clipShape(.rect(cornerRadius: AppTheme.cornerRadiusMedium))

            Button {
                fetchMetadata()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                    Text("Rechercher")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(urlText.isEmpty ? AppTheme.textSecondary : .black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(urlText.isEmpty ? AppTheme.elevatedBackground : AppTheme.accent)
                .clipShape(.rect(cornerRadius: AppTheme.cornerRadiusMedium))
            }
            .buttonStyle(.plain)
            .disabled(urlText.isEmpty || isLoading)
        }
        .padding(.horizontal, AppTheme.spacingMedium)
    }

    // MARK: - Paste Button

    private var pasteButton: some View {
        Button {
            if let text = UIPasteboard.general.string {
                urlText = text
                fetchMetadata()
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "doc.on.clipboard")
                Text("Coller depuis le presse-papiers")
            }
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(AppTheme.accent)
        }
        .buttonStyle(.plain)
        .padding(.top, AppTheme.spacingSmall)
    }

    // MARK: - Error View

    private func errorView(_ error: YouTubeError) -> some View {
        VStack(spacing: AppTheme.spacingMedium) {
            Image(systemName: error.icon)
                .font(.system(size: 36))
                .foregroundStyle(AppTheme.textTertiary)

            Text(error.errorDescription ?? "Une erreur s'est produite.")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)

            Button {
                self.error = nil
                self.urlText = ""
            } label: {
                Text("Réessayer")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppTheme.accent)
                    .padding(.horizontal, AppTheme.spacingLarge)
                    .padding(.vertical, 10)
                    .background(AppTheme.accentDim)
                    .clipShape(.rect(cornerRadius: 20))
            }
            .buttonStyle(.plain)
        }
        .padding(AppTheme.spacingXL)
        .padding(.horizontal, AppTheme.spacingMedium)
    }

    // MARK: - Preview

    private func previewSection(_ track: Track) -> some View {
        VStack(spacing: AppTheme.spacingLarge) {
            // Thumbnail preview
            VStack(spacing: AppTheme.spacingMedium) {
                TrackThumbnail(
                    thumbnailURL: track.thumbnailMaxResURL,
                    videoId: track.youtubeId,
                    size: UIScreen.main.bounds.width - AppTheme.spacingMedium * 2,
                    cornerRadius: AppTheme.cornerRadiusLarge
                )

                VStack(spacing: 4) {
                    Text(track.title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppTheme.spacingMedium)

                    Text(track.artist)
                        .font(.system(size: 16))
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }

            // Options
            VStack(spacing: AppTheme.spacingMedium) {
                // Add to favorites
                Toggle(isOn: $addToFavorites) {
                    Label("Ajouter aux favoris", systemImage: "heart")
                }
                .tint(AppTheme.accent)

                // Playlist picker
                if !libraryStore.playlists.isEmpty {
                    Menu {
                        Button("Aucune playlist") { selectedPlaylistId = nil }
                        Divider()
                        ForEach(libraryStore.playlists) { pl in
                            Button(pl.name) { selectedPlaylistId = pl.id }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "music.note.list")
                            Text(selectedPlaylistId.flatMap { libraryStore.playlist(byId: $0)?.name } ?? "Ajouter à une playlist")
                            Spacer()
                            Image(systemName: "chevron.down")
                        }
                        .font(.system(size: 15))
                        .foregroundStyle(AppTheme.textSecondary)
                        .padding(AppTheme.spacingMedium)
                        .background(AppTheme.cardBackground)
                        .clipShape(.rect(cornerRadius: AppTheme.cornerRadiusSmall))
                    }
                }
            }
            .padding(.horizontal, AppTheme.spacingMedium)

            // Add button
            Button {
                addTrackToLibrary(track)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("Ajouter à ma bibliothèque")
                }
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppTheme.accentGradient)
                .clipShape(.rect(cornerRadius: AppTheme.cornerRadiusLarge))
                .shadow(color: AppTheme.accent.opacity(0.3), radius: 10, y: 5)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, AppTheme.spacingMedium)
        }
    }

    // MARK: - Actions

    private func fetchMetadata() {
        guard let videoId = YouTubeService.extractVideoId(from: urlText) else {
            error = .invalidURL
            previewTrack = nil
            return
        }

        // Check if already in library
        if libraryStore.exists(youtubeId: videoId) {
            if let existing = libraryStore.track(byYouTubeId: videoId) {
                previewTrack = existing
                error = nil
                return
            }
        }

        isLoading = true
        error = nil
        previewTrack = nil

        Task {
            let result = await YouTubeService.fetchMetadata(forVideoId: videoId)
            await MainActor.run {
                isLoading = false
                switch result {
                case .success(let metadata):
                    previewTrack = YouTubeService.buildTrack(from: metadata, videoId: videoId)
                case .failure(let err):
                    error = err
                }
            }
        }
    }

    private func addTrackToLibrary(_ track: Track) {
        libraryStore.addTrack(track)

        if addToFavorites {
            libraryStore.toggleFavorite(track)
        }

        if let playlistId = selectedPlaylistId {
            libraryStore.addTrack(track.id, toPlaylist: playlistId)
        }

        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        dismiss()
    }
}
