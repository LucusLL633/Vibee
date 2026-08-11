import SwiftUI

/// Circular play button with accent gradient
struct PlayButton: View {
    let action: () -> Void
    var size: CGFloat = 52

    var body: some View {
        Button(action: action) {
            Image(systemName: "play.fill")
                .font(.system(size: size * 0.38))
                .foregroundStyle(.black)
                .frame(width: size, height: size)
                .background(AppTheme.accentGradient)
                .clipShape(Circle())
                .shadow(color: AppTheme.accent.opacity(0.3), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
}

/// Shuffle button
struct ShuffleButton: View {
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "shuffle")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(isActive ? AppTheme.accent : AppTheme.textSecondary)
                .frame(width: 44, height: 44)
                .background(isActive ? AppTheme.accentDim : Color.clear)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

/// Player control button (prev, play/pause, next)
struct PlayerControlButton: View {
    let icon: String
    var size: CGFloat = 30
    var color: Color = AppTheme.textPrimary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 56, height: 56)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// Large circular play/pause button for full player
struct PlayPauseButton: View {
    let isPlaying: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(.black)
                .frame(width: 72, height: 72)
                .background(AppTheme.accent)
                .clipShape(Circle())
                .shadow(color: AppTheme.accent.opacity(0.4), radius: 12, y: 6)
        }
        .buttonStyle(.plain)
    }
}
