import SwiftUI

/// Animated loading shimmer view
struct ShimmerView: View {
    @State private var animate = false

    var body: some View {
        Rectangle()
            .fill(AppTheme.elevatedBackground)
            .overlay(
                LinearGradient(
                    colors: [
                        .clear,
                        Color.white.opacity(0.06),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: animate ? 200 : -200)
            )
            .clipped()
            .onAppear {
                withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                    animate = true
                }
            }
    }
}

/// Loading card for metadata fetching
struct LoadingMetadataCard: View {
    var body: some View {
        VStack(spacing: AppTheme.spacingMedium) {
            ShimmerView()
                .frame(height: 180)
                .clipShape(.rect(cornerRadius: AppTheme.cornerRadiusMedium))

            ShimmerView()
                .frame(height: 20)
                .clipShape(.rect(cornerRadius: 6))

            ShimmerView()
                .frame(width: 120, height: 16)
                .clipShape(.rect(cornerRadius: 6))
        }
    }
}
