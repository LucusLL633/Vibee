import Foundation
import SwiftUI
import Combine

/// Manages playback state, queue, shuffle, repeat, and coordinates
/// with the YouTube IFrame player view.
@Observable
final class PlayerManager {

    // MARK: - Playback State

    private(set) var currentTrack: Track?
    private(set) var queue: [Track] = []
    private(set) var queueIndex: Int = 0
    private(set) var isPlaying: Bool = false
    private(set) var currentTime: Double = 0
    private(set) var duration: Double = 0
    private(set) var isReady: Bool = false
    private(set) var isBuffering: Bool = false

    // MARK: - Player Config

    var isShuffling: Bool = false
    var repeatMode: RepeatMode = .off

    // MARK: - Mini Player / Full Player

    var showFullPlayer: Bool = false

    // MARK: - Dependencies

    private let libraryStore: LibraryStore

    // MARK: - Init

    init(libraryStore: LibraryStore) {
        self.libraryStore = libraryStore
    }

    // MARK: - Queue Management

    /// Play a single track, setting the queue to just that track.
    func playTrack(_ track: Track) {
        play(track: track, inQueue: [track], atIndex: 0)
    }

    /// Play a track from a queue (e.g. playlist or library).
    func play(track: Track, inQueue tracks: [Track], atIndex index: Int) {
        var newQueue = tracks
        if isShuffling, newQueue.count > 1 {
            let current = newQueue.remove(at: index)
            newQueue.shuffle()
            newQueue.insert(current, at: 0)
        }
        queue = newQueue
        queueIndex = isShuffling ? 0 : index
        loadCurrentTrack(autoplay: true)
    }

    /// Play a list of tracks starting from the first.
    func playQueue(_ tracks: [Track], shuffle: Bool = false) {
        guard !tracks.isEmpty else { return }
        if shuffle {
            var shuffled = tracks
            shuffled.shuffle()
            queue = shuffled
            queueIndex = 0
        } else {
            queue = tracks
            queueIndex = 0
        }
        loadCurrentTrack(autoplay: true)
    }

    private func loadCurrentTrack(autoplay: Bool) {
        guard queueIndex >= 0, queueIndex < queue.count else { return }
        let track = queue[queueIndex]
        currentTrack = track
        isReady = false
        currentTime = 0
        duration = 0
        isBuffering = true
        if autoplay {
            isPlaying = true
        }
        libraryStore.addToHistory(track)
    }

    // MARK: - Transport Controls

    func togglePlayPause() {
        guard currentTrack != nil else { return }
        if isPlaying {
            sendCommand("pauseVideo")
            isPlaying = false
        } else {
            sendCommand("playVideo")
            isPlaying = true
        }
    }

    func play() {
        guard currentTrack != nil else { return }
        sendCommand("playVideo")
        isPlaying = true
    }

    func pause() {
        sendCommand("pauseVideo")
        isPlaying = false
    }

    func next() {
        guard !queue.isEmpty else { return }
        if repeatMode == .one {
            seek(to: 0)
            play()
            return
        }
        if queueIndex < queue.count - 1 {
            queueIndex += 1
            loadCurrentTrack(autoplay: true)
        } else if repeatMode == .all {
            queueIndex = 0
            loadCurrentTrack(autoplay: true)
        } else {
            // End of queue
            isPlaying = false
        }
    }

    func previous() {
        guard !queue.isEmpty else { return }
        if currentTime > 3 {
            seek(to: 0)
            return
        }
        if queueIndex > 0 {
            queueIndex -= 1
            loadCurrentTrack(autoplay: true)
        } else if repeatMode == .all {
            queueIndex = queue.count - 1
            loadCurrentTrack(autoplay: true)
        } else {
            seek(to: 0)
        }
    }

    func seek(to time: Double) {
        sendCommand("seekTo:\(time)")
        currentTime = time
    }

    // MARK: - Shuffle & Repeat

    func toggleShuffle() {
        isShuffling.toggle()
    }

    func cycleRepeatMode() {
        switch repeatMode {
        case .off: repeatMode = .all
        case .all: repeatMode = .one
        case .one: repeatMode = .off
        }
    }

    // MARK: - JS Bridge (called by WebView)

    /// Called when the YouTube IFrame player reports state changes.
    func handlePlayerState(_ state: Int) {
        // -1: unstarted, 0: ended, 1: playing, 2: paused, 3: buffering, 5: cued
        switch state {
        case 0: // ended
            isPlaying = false
            next()
        case 1: // playing
            isPlaying = true
            isBuffering = false
        case 2: // paused
            isPlaying = false
        case 3: // buffering
            isBuffering = true
        case 5: // cued
            isBuffering = false
        default:
            break
        }
    }

    func handleTimeUpdate(_ time: Double) {
        currentTime = time
    }

    func handleDurationUpdate(_ dur: Double) {
        duration = dur
    }

    func handleReady() {
        isReady = true
        isBuffering = false
    }

    // MARK: - Private

    private func sendCommand(_ command: String) {
        NotificationCenter.default.post(name: .vibePlayerCommand, object: command)
    }

    // MARK: - Favorites

    func toggleFavoriteCurrentTrack() {
        guard let track = currentTrack else { return }
        libraryStore.toggleFavorite(track)
    }

    var isCurrentTrackFavorite: Bool {
        guard let track = currentTrack else { return false }
        return libraryStore.isFavorite(track)
    }

    // MARK: - Progress

    var progress: Double {
        guard duration > 0 else { return 0 }
        return min(currentTime / duration, 1.0)
    }

    var hasTrack: Bool {
        currentTrack != nil
    }
}
