import SwiftUI

/// Hidden container that hosts the YouTube IFrame WebView player.
/// This view stays in the hierarchy whenever a track is loaded,
/// keeping the WKWebView alive for continuous playback.
struct HiddenPlayerView: View {
    @Environment(PlayerManager.self) private var playerManager

    var body: some View {
        if let track = playerManager.currentTrack {
            YouTubePlayerWebView(
                videoId: track.youtubeId,
                onStateChange: { state in
                    playerManager.handlePlayerState(state)
                },
                onTimeUpdate: { time in
                    playerManager.handleTimeUpdate(time)
                },
                onDurationUpdate: { dur in
                    playerManager.handleDurationUpdate(dur)
                },
                onReady: {
                    playerManager.handleReady()
                }
            )
            .frame(width: 1, height: 1)
            .opacity(0.01)
            .allowsHitTesting(false)
        }
    }
}
