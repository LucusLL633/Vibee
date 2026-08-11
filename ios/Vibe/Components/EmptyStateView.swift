import SwiftUI

/// Empty state view with icon and message
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: AppTheme.spacingMedium) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(AppTheme.textTertiary)
                .padding(.bottom, AppTheme.spacingSmall)

            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)

            Text(message)
                .font(.system(size: 15))
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.spacingXL)

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.black)
                        .padding(.horizontal, AppTheme.spacingLarge)
                        .padding(.vertical, AppTheme.spacingMedium)
                        .background(AppTheme.accent)
                        .clipShape(.rect(cornerRadius: AppTheme.cornerRadiusMedium))
                }
                .padding(.top, AppTheme.spacingSmall)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(AppTheme.spacingXL)
    }
}
