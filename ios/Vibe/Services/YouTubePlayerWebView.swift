import SwiftUI
import WebKit
import AVFoundation

/// UIViewRepresentable wrapping a WKWebView that loads the official YouTube IFrame Player.
/// This handles playback via YouTube's official embedded player — no downloading or conversion.
struct YouTubePlayerWebView: UIViewRepresentable {

    let videoId: String
    let onStateChange: (Int) -> Void
    let onTimeUpdate: (Double) -> Void
    let onDurationUpdate: (Double) -> Void
    let onReady: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onStateChange: onStateChange,
                    onTimeUpdate: onTimeUpdate,
                    onDurationUpdate: onDurationUpdate,
                    onReady: onReady)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.allowsPictureInPictureMediaPlayback = true

        if #available(iOS 16.4, *) {
            config.preferences.isElementFullscreenEnabled = false
        }

        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: "stateChange")
        contentController.add(context.coordinator, name: "timeUpdate")
        contentController.add(context.coordinator, name: "durationUpdate")
        contentController.add(context.coordinator, name: "ready")
        config.userContentController = contentController

        // Inject JS error handler
        let script = WKUserScript(source: Self.bridgeJS, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        config.userContentController.addUserScript(script)

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = .black
        webView.isOpaque = false

        configureAudioSession()

        let html = Self.htmlPage(forVideoId: videoId)
        webView.loadHTMLString(html, baseURL: URL(string: "https://www.youtube.com"))
        context.coordinator.webView = webView
        context.coordinator.subscribeToCommands()

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if context.coordinator.currentVideoId != videoId {
            context.coordinator.currentVideoId = videoId
            let html = Self.htmlPage(forVideoId: videoId)
            webView.loadHTMLString(html, baseURL: URL(string: "https://www.youtube.com"))
        }
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            // Non-fatal — playback continues without background audio optimization
        }
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, WKScriptMessageHandler {

        let onStateChange: (Int) -> Void
        let onTimeUpdate: (Double) -> Void
        let onDurationUpdate: (Double) -> Void
        let onReady: () -> Void

        weak var webView: WKWebView?
        var currentVideoId: String?
        private var commandObserver: NSObjectProtocol?
        private var timeObserver: Timer?

        init(onStateChange: @escaping (Int) -> Void,
             onTimeUpdate: @escaping (Double) -> Void,
             onDurationUpdate: @escaping (Double) -> Void,
             onReady: @escaping () -> Void) {
            self.onStateChange = onStateChange
            self.onTimeUpdate = onTimeUpdate
            self.onDurationUpdate = onDurationUpdate
            self.onReady = onReady
            super.init()
        }

        func userContentController(_ userContentController: WKUserContentController,
                                   didReceive message: WKScriptMessage) {
            switch message.name {
            case "stateChange":
                if let state = message.body as? Int {
                    onStateChange(state)
                }
            case "timeUpdate":
                if let time = message.body as? Double {
                    onTimeUpdate(time)
                }
            case "durationUpdate":
                if let dur = message.body as? Double {
                    onDurationUpdate(dur)
                }
            case "ready":
                onReady()
                startPolling()
            default:
                break
            }
        }

        private func startPolling() {
            timeObserver?.invalidate()
            timeObserver = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
                guard let webView = self?.webView else { return }
                webView.evaluateJavaScript("window._vibeGetCurrentTime()") { result, _ in
                    if let time = result as? Double, time > 0 {
                        self?.onTimeUpdate(time)
                    }
                }
                webView.evaluateJavaScript("window._vibeGetDuration()") { result, _ in
                    if let dur = result as? Double, dur > 0 {
                        self?.onDurationUpdate(dur)
                    }
                }
            }
        }

        func subscribeToCommands() {
            commandObserver = NotificationCenter.default.addObserver(
                forName: .vibePlayerCommand, object: nil, queue: .main
            ) { [weak self] notification in
                guard let command = notification.object as? String else { return }
                self?.executeJSCommand(command)
            }
        }

        private func executeJSCommand(_ command: String) {
            guard let webView = webView else { return }
            if command == "playVideo" {
                webView.evaluateJavaScript("window._vibePlay()")
            } else if command == "pauseVideo" {
                webView.evaluateJavaScript("window._vibePause()")
            } else if command.hasPrefix("seekTo:") {
                let timeStr = String(command.dropFirst("seekTo:".count))
                if let time = Double(timeStr) {
                    webView.evaluateJavaScript("window._vibeSeek(\(time))")
                }
            }
        }

        deinit {
            timeObserver?.invalidate()
            if let obs = commandObserver {
                NotificationCenter.default.removeObserver(obs)
            }
        }
    }

    // MARK: - HTML & JS

    static func htmlPage(forVideoId videoId: String) -> String {
        """
        <!DOCTYPE html>
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            html, body { width: 100%; height: 100%; background: #000; overflow: hidden; }
            #player { width: 100%; height: 100%; }
        </style>
        </head>
        <body>
        <div id="player"></div>
        <script src="https://www.youtube.com/iframe_api"></script>
        <script>
        var player;
        var ready = false;

        function onYouTubeIframeAPIReady() {
            player = new YT.Player('player', {
                videoId: '\(videoId)',
                playerVars: {
                    'autoplay': 1,
                    'controls': 0,
                    'disablekb': 1,
                    'fs': 0,
                    'iv_load_policy': 3,
                    'modestbranding': 1,
                    'playsinline': 1,
                    'rel': 0,
                    'enablejsapi': 1
                },
                events: {
                    'onReady': onPlayerReady,
                    'onStateChange': onPlayerStateChange
                }
            });
        }

        function onPlayerReady(event) {
            ready = true;
            event.target.playVideo();
            window.webkit.messageHandlers.ready.postMessage(true);
        }

        function onPlayerStateChange(event) {
            window.webkit.messageHandlers.stateChange.postMessage(event.data);
        }

        window._vibePlay = function() {
            if (ready && player) player.playVideo();
        };
        window._vibePause = function() {
            if (ready && player) player.pauseVideo();
        };
        window._vibeSeek = function(time) {
            if (ready && player) player.seekTo(time, true);
        };
        window._vibeGetCurrentTime = function() {
            if (ready && player) return player.getCurrentTime();
            return 0;
        };
        window._vibeGetDuration = function() {
            if (ready && player) return player.getDuration();
            return 0;
        };
        </script>
        </body>
        </html>
        """
    }

    static let bridgeJS = """
    window.onerror = function(msg, url, line, col, error) {
        console.log('JS Error: ' + msg);
    };
    """
}

// MARK: - Notification Name

extension Notification.Name {
    static let vibePlayerCommand = Notification.Name("vibePlayerCommand")
}
