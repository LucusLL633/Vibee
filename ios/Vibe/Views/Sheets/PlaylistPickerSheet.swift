import SwiftUI

/// Sheet for picking a playlist to add a track to, or creating a new one
struct PlaylistPickerSheet: View {
    @Environment(LibraryStore.self) private var libraryStore
    @Environment(\.dismiss) private var dismiss

    let track: Track

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spacingSmall) {
                    // Create new playlist
                    Button {
                        dismiss()
                        // Trigger create playlist sheet with this track
                        NotificationCenter.default.post(name: .vibeCreatePlaylistWithTrack, object: track.id)
                    } label: {
                        HStack(spacing: AppTheme.spacingMedium) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(AppTheme.accent)

                            Text("Créer une nouvelle playlist")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(AppTheme.textPrimary)

                            Spacer()
                        }
                        .padding(AppTheme.spacingMedium)
                        .background(AppTheme.cardBackground)
                        .clipShape(.rect(cornerRadius: AppTheme.cornerRadiusMedium))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, AppTheme.spacingMedium)
                    .padding(.bottom, AppTheme.spacingSmall)

                    // Existing playlists
                    if libraryStore.playlists.isEmpty {
                        Text("Aucune playlist existante.")
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.textTertiary)
                            .padding(.top, AppTheme.spacingLarge)
                    } else {
                        VStack(spacing: 2) {
                            ForEach(libraryStore.playlists) { playlist in
                                Button {
                                    libraryStore.addTrack(track.id, toPlaylist: playlist.id)
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                    dismiss()
                                } label: {
                                    HStack(spacing: AppTheme.spacingMedium) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color(hexString: playlist.coverColorHex) ?? AppTheme.accent)
                                                .frame(width: 48, height: 48)

                                            Image(systemName: "music.note.list")
                                                .font(.system(size: 18))
                                                .foregroundStyle(.black.opacity(0.8))
                                        }

                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(playlist.name)
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundStyle(AppTheme.textPrimary)
                                            Text("\(playlist.trackCount) titre\(playlist.trackCount > 1 ? "s" : "")")
                                                .font(.system(size: 13))
                                                .foregroundStyle(AppTheme.textSecondary)
                                        }

                                        Spacer()

                                        if playlist.trackIds.contains(track.id) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 20))
                                                .foregroundStyle(AppTheme.accent)
                                        }
                                    }
                                    .padding(.horizontal, AppTheme.spacingMedium)
                                    .padding(.vertical, 8)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.vertical, AppTheme.spacingMedium)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Ajouter à une playlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annuler") { dismiss() }
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
        }
    }
}

extension Notification.Name {
    static let vibeCreatePlaylistWithTrack = Notification.Name("vibeCreatePlaylistWithTrack")
}
