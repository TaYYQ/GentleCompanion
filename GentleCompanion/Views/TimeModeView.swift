//
//  TimeModeView.swift
//  GentleCompanion
//
//  番茄钟专注模式 — 嵌入 PomodoroView
//

import SwiftUI

// MARK: - Primary Button (local compatibility wrapper)
// Used by GentleWallView and SocialFeedView which call GentleButton(title:icon:action:variant:)

enum GentleButtonVariant {
    case primary, secondary, accent
}

/// Compatibility wrapper — use GentlePrimaryButtonStyle in Design.swift for new code.
struct GentleButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    var variant: GentleButtonVariant = .primary

    var body: some View {
        Button(action: action) {
            HStack(spacing: GentleSpacing.sm) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                }
                Text(title)
                    .font(GentleFont.caption())
            }
            .foregroundColor(variant == .primary ? .white : Gentle.Text.primary)
            .padding(.horizontal, GentleSpacing.lg)
            .padding(.vertical, GentleSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: GentleRadius.sm, style: .continuous)
                    .fill(variant == .primary ? Gentle.Gradient.primaryButton
                              : variant == .secondary ? LinearGradient(colors: [Gentle.Background.tertiary, Gentle.Background.tertiary.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                              : Gentle.Gradient.secondaryButton)
            )
            .shadow(
                color: GentleShadow.sm.color,
                radius: GentleShadow.sm.radius,
                x: GentleShadow.sm.x,
                y: GentleShadow.sm.y
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Time Mode View (番茄钟容器)

struct TimeModeView: View {
    @Binding var isPresented: Bool
    var body: some View {
        ZStack {
            // 柔和渐变背景
            LinearGradient(
                colors: [
                    Gentle.Background.primary,
                    Gentle.Background.tertiary
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // PomodoroView 全屏内容
            PomodoroView(
                currentEmotion: nil,
                onClose: { isPresented = false }
            )

            // 自定义顶部导航栏（覆盖在 PomodoroView 之上）
            VStack {
                customHeader
                Spacer()
            }
            .padding(.top, GentleSpacing.lg)
        }
    }

    // MARK: - 自定义顶部栏

    private var customHeader: some View {
        HStack {
            Button(action: { isPresented = false }) {
                HStack(spacing: GentleSpacing.sm) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                    Text("返回")
                        .font(GentleFont.caption())
                }
                .foregroundColor(Gentle.Text.secondary)
                .padding(.horizontal, GentleSpacing.md)
                .padding(.vertical, GentleSpacing.sm)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                )
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()

            Text("专注模式")
                .font(GentleFont.headline())
                .foregroundColor(Gentle.Text.primary)
                .padding(.horizontal, GentleSpacing.md)
                .padding(.vertical, GentleSpacing.sm)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                )

            Spacer()

            // 占位，保持对称
            Color.clear
                .frame(width: 60, height: 1)
        }
        .padding(.horizontal, GentleSpacing.lg)
    }
}
