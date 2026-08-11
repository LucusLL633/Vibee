import Foundation
import SwiftUI

@Observable
final class SettingsStore {

    var appearance: AppearanceMode {
        didSet { save() }
    }

    var autoplay: Bool {
        didSet { save() }
    }

    var defaultShuffle: Bool {
        didSet { save() }
    }

    var highQualityThumbnails: Bool {
        didSet { save() }
    }

    private let appearanceKey = "vibe.settings.appearance"
    private let autoplayKey = "vibe.settings.autoplay"
    private let shuffleKey = "vibe.settings.shuffle"
    private let qualityKey = "vibe.settings.quality"

    init() {
        let storedAppearance = UserDefaults.standard.string(forKey: appearanceKey)
            .flatMap { AppearanceMode(rawValue: $0) } ?? .dark
        self.appearance = storedAppearance

        self.autoplay = UserDefaults.standard.object(forKey: autoplayKey) as? Bool ?? true
        self.defaultShuffle = UserDefaults.standard.object(forKey: shuffleKey) as? Bool ?? false
        self.highQualityThumbnails = UserDefaults.standard.object(forKey: qualityKey) as? Bool ?? true
    }

    var colorScheme: ColorScheme? {
        switch appearance {
        case .dark: return .dark
        case .light: return .light
        case .automatic: return nil
        }
    }

    private func save() {
        UserDefaults.standard.set(appearance.rawValue, forKey: appearanceKey)
        UserDefaults.standard.set(autoplay, forKey: autoplayKey)
        UserDefaults.standard.set(defaultShuffle, forKey: shuffleKey)
        UserDefaults.standard.set(highQualityThumbnails, forKey: qualityKey)
    }
}
