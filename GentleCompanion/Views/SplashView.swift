//
//  SplashView.swift
//  GentleCompanion
//
//  启动检测页 — Liquid Glass 设计
//

import SwiftUI

enum SplashPhase: Equatable {
    case detecting
    case detected
    case done
}

struct SplashView: View {
    @ObservedObject private var theme = GentleThemeManager.shared
    @Binding var isPresented: Bool

    @State private var phase: SplashPhase = .detecting
    @State private var progress: CGFloat = 0
    @State private var progressText: String = "初始化..."
    @State private var iconScale: CGFloat = 0.5
    @State private var iconOpacity: CGFloat = 0
    @State private var checkmarkOpacity: CGFloat = 0
    @State private var subtitleOpacity: CGFloat = 0

    private let steps: [(String, Double)] = [
        ("检测系统平台...", 0.20),
        ("读取界面配置...", 0.45),
        ("加载品牌资源...", 0.65),
        ("应用主题皮肤...", 0.85),
        ("准备完成",       1.00),
    ]

    var body: some View {
        ZStack {
            themeBackground

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(theme.current.primaryGradient)
                            .frame(width: 96, height: 96)
                            .shadow(color: theme.current.primary.opacity(0.3), radius: 24, x: 0, y: 12)
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [.white.opacity(0.3), .clear],
                                    center: .topLeading,
                                    startRadius: 0, endRadius: 40
                                )
                            )
                            .frame(width: 96, height: 96)
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 42, weight: .ultraLight))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(iconScale)
                    .opacity(iconOpacity)

                    VStack(spacing: 6) {
                        Text("温柔点")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(theme.current.textPrimary)
                            .opacity(iconOpacity)
                        Text("GentleCompanion")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(theme.current.textSecondary)
                            .opacity(iconOpacity)
                    }

                    if phase == .detected || phase == .done {
                        Image(systemName: theme.current.icon)
                            .font(.system(size: 24))
                            .foregroundColor(theme.current.primary)
                            .opacity(checkmarkOpacity)
                            .transition(.scale.combined(with: .opacity))
                    }
                }

                Spacer().frame(height: 60)

                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(theme.current.border.opacity(0.5))
                                    .frame(height: 6)
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(theme.current.primaryGradient)
                                    .frame(width: geometry.size.width * progress, height: 6)
                                    .shadow(color: theme.current.primary.opacity(0.4), radius: 4, x: 0, y: 2)
                            }
                        }
                        .frame(height: 6)

                        Text(progressText)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(theme.current.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 40)
                    .opacity(iconOpacity)

                    if phase == .detected || phase == .done {
                        detectionResultCard
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .bottom)),
                                removal: .opacity
                            ))
                    }
                }

                Spacer().frame(height: 80)
            }
        }
        .ignoresSafeArea()
        .onAppear { runDetection() }
    }

    // MARK: - Theme Background

    private var themeBackground: some View {
        ZStack {
            Rectangle().fill(theme.current.background)
            RadialGradient(
                colors: [
                    theme.current.primary.opacity(0.12),
                    theme.current.background,
                    theme.current.background,
                ],
                center: .center, startRadius: 0, endRadius: 500
            )
        }
    }

    // MARK: - Detection Result Card

    private var detectionResultCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "#34D399"))
                Text(theme.current.tagline)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(theme.current.textPrimary)
                Spacer()
            }

            HStack(spacing: 12) {
                Text("主题色")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(theme.current.textSecondary)
                Circle()
                    .fill(theme.current.primaryGradient)
                    .frame(width: 24, height: 24)
                    .overlay(Circle().stroke(theme.current.border, lineWidth: 1.5))
                Spacer()
            }

            if phase == .detected {
                Text("正在进入...")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(theme.current.textSecondary.opacity(0.6))
                    .padding(.top, 4)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(.white.opacity(0.15), lineWidth: 0.5)
                )
        )
        .overlay(alignment: .top) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white.opacity(0.08))
                .frame(height: 1)
                .padding(.horizontal, 1)
        }
        .shadow(color: theme.current.primary.opacity(0.1), radius: 12, x: 0, y: 6)
        .padding(.horizontal, 40)
        .opacity(checkmarkOpacity)
    }

    // MARK: - Detection Logic

    private func runDetection() {
        withAnimation(.easeOut(duration: 0.6)) {
            iconOpacity = 1
            iconScale = 1
        }

        for (index, (text, targetProgress)) in steps.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(index) * 0.4) {
                withAnimation(.easeInOut(duration: 0.35)) {
                    progressText = text
                    progress = targetProgress
                }

                if index == steps.count - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                            phase = .detected
                            checkmarkOpacity = 1
                            subtitleOpacity = 1
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            withAnimation(.easeInOut(duration: 0.6)) { phase = .done }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                isPresented = false
                            }
                        }
                    }
                }
            }
        }
    }
}
