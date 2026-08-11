import SwiftUI

/// Sheet for editing an existing playlist
struct EditPlaylistSheet: View {
    @Environment(LibraryStore.self) private var libraryStore
    @Environment(\.dismiss) private var dismiss

    let playlist: Playlist

    @State private var name: String = ""
    @State private var description: String = ""
    @State private var selectedColor: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spacingLarge) {
                    // Preview
                    ZStack {
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                            .fill(Color(hexString: selectedColor) ?? AppTheme.accent)
                            .frame(width: 140, height: 140)
                            .shadow(color: .black.opacity(0.3), radius: 10, y: 5)

                        Image(systemName: "music.note.list")
                            .font(.system(size: 44))
                            .foregroundStyle(.black.opacity(0.8))
                    }
                    .padding(.top, AppTheme.spacingMedium)

                    // Name
                    VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
                        Text("Nom")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)

                        TextField("Ma playlist", text: $name)
                            .font(.system(size: 16))
                            .foregroundStyle(AppTheme.textPrimary)
                            .padding(AppTheme.spacingMedium)
                            .background(AppTheme.cardBackground)
                            .clipShape(.rect(cornerRadius: AppTheme.cornerRadiusSmall))
                    }

                    // Description
                    VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
                        Text("Description (optionnel)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)

                        TextField("Description…", text: $description, axis: .vertical)
                            .font(.system(size: 16))
                            .foregroundStyle(AppTheme.textPrimary)
                            .lineLimit(3...6)
                            .padding(AppTheme.spacingMedium)
                            .background(AppTheme.cardBackground)
                            .clipShape(.rect(cornerRadius: AppTheme.cornerRadiusSmall))
                    }

                    // Color picker
                    VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
                        Text("Couleur")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: AppTheme.spacingSmall) {
                            ForEach(Playlist.coverColors, id: \.self) { colorHex in
                                Button {
                                    selectedColor = colorHex
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                } label: {
                                    Circle()
                                        .fill(Color(hexString: colorHex) ?? AppTheme.accent)
                                        .frame(width: 44, height: 44)
                                        .overlay {
                                            if selectedColor == colorHex {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 18, weight: .bold))
                                                    .foregroundStyle(.black)
                                            }
                                        }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.horizontal, AppTheme.spacingMedium)
                .padding(.bottom, AppTheme.spacingLarge)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Modifier la playlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annuler") { dismiss() }
                        .foregroundStyle(AppTheme.textSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Enregistrer") {
                        savePlaylist()
                    }
                    .foregroundStyle(AppTheme.accent)
                    .font(.system(size: 16, weight: .semibold))
                    .disabled(name.isEmpty)
                }
            }
            .onAppear {
                name = playlist.name
                description = playlist.description
                selectedColor = playlist.coverColorHex
            }
        }
    }

    private func savePlaylist() {
        var updated = playlist
        updated.name = name
        updated.description = description
        updated.coverColorHex = selectedColor
        libraryStore.updatePlaylist(updated)

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        dismiss()
    }
}
