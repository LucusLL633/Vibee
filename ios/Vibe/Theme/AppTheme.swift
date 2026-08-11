import SwiftUI

enum AppTheme {
    static let background = Color(hex: 0x0A0A0A)
    static let cardBackground = Color(hex: 0x181818)
    static let elevatedBackground = Color(hex: 0x242424)
    static let accent = Color(hex: 0x00FA82)
    static let accentDim = Color(hex: 0x00FA82).opacity(0.18)
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: 0xA8A8A8)
    static let textTertiary = Color(hex: 0x707070)

    static let accentGradient = LinearGradient(
        colors: [Color(hex: 0x00FA82), Color(hex: 0x00C668)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let playerGradient = LinearGradient(
        colors: [Color(hex: 0x1A1A1A), Color(hex: 0x050505)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let accentGlow = RadialGradient(
        colors: [Color(hex: 0x00FA82).opacity(0.3), Color.clear],
        center: .center,
        startRadius: 1,
        endRadius: 120
    )

    static let cornerRadiusSmall: CGFloat = 8
    static let cornerRadiusMedium: CGFloat = 12
    static let cornerRadiusLarge: CGFloat = 16
    static let cornerRadiusXL: CGFloat = 22

    static let spacingXS: CGFloat = 6
    static let spacingSmall: CGFloat = 10
    static let spacingMedium: CGFloat = 16
    static let spacingLarge: CGFloat = 24
    static let spacingXL: CGFloat = 32
}

extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }

    init?(hexString: String) {
        let cleaned = hexString.replacingOccurrences(of: "#", with: "")
        guard let value = UInt32(cleaned, radix: 16) else { return nil }
        self.init(hex: value)
    }
}
