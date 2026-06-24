//
//  MainView.swift
//  GentleCompanion
//
//  Gentle design system — main interface
//

import SwiftUI

// MARK: - Activation Phase

enum ActivationPhase: Equatable {
    case welcome
    case select
    case main
}

// MARK: - Main View

struct MainView: View {
    @State private var phase: ActivationPhase = .welcome
    @State private var selectedEmotion: Emotion?
    @State private var currentMessage: String = ""
    @State private var showTimeMode = false
    @State private var showGentleWall = false
    @State private var showSocialFeed = false
    @State private var showSettings = false
    @State private var showBreathing = false
    @State private var showAccount = false

    @StateObject private var theme = GentleThemeManager.shared
    @StateObject private var accountManager = AccountManager.shared

    var body: some View {
        ZStack {
            if phase == .main {
                mainInterface
                    .transition(.opacity)
            }

            if phase != .main {
                activationOverlay
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.8), value: phase)
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Gentle")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Gentle.Text.primary)

                if let account = accountManager.currentAccount {
                    Text(account.username)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Gentle.Text.secondary)
                }
            }

            Spacer()

            Button { showAccount = true } label: {
                HStack(spacing: 7) {
                    if let account = accountManager.currentAccount {
                        Circle()
                            .fill(Gentle.Gradient.primaryButton)
                            .frame(width: 28, height: 28)
                            .overlay {
                                Text(String(account.username.prefix(1)).uppercased())
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            }
                    } else {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 28, height: 28)
                            .overlay {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(Gentle.Text.secondary)
                            }
                    }

                    Text(accountManager.currentAccount?.username ?? "登录账号")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(accountManager.currentAccount != nil ? Gentle.Text.primary : Gentle.Primary.lavender)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.08))
                        .overlay(
                            Capsule()
                                .stroke(
                                    accountManager.currentAccount != nil
                                        ? Gentle.Primary.lavender.opacity(0.3)
                                        : Gentle.Primary.lavender,
                                    lineWidth: 1
                                )
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    // MARK: - Main Interface

    private var mainInterface: some View {
        VStack(spacing: 0) {
            topBar
                .padding(.horizontal, 32)
                .padding(.top, 16)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: GentleSpacing.xxl) {
                    Spacer().frame(height: GentleSpacing.xl)
                    emotionHeroCard
                    moduleGrid
                    Spacer().frame(height: GentleSpacing.xxl)
                }
                .padding(.horizontal, 60)
            }
        }
        .background(theme.current.background)
        .sheet(isPresented: $showTimeMode) {
            TimeModeView(isPresented: $showTimeMode)
                .frame(width: 998, height: 686)
                .fixedSize()
        }
        .sheet(isPresented: $showGentleWall) {
            GentleWallView(isPresented: $showGentleWall)
                .frame(width: 998, height: 686)
                .fixedSize()
        }
        .sheet(isPresented: $showSocialFeed) {
            SocialFeedView(isPresented: $showSocialFeed)
                .frame(width: 998, height: 686)
                .fixedSize()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(isPresented: $showSettings)
                .frame(width: 998, height: 686)
                .fixedSize()
        }
        .sheet(isPresented: $showBreathing) {
            BreathingView(isPresented: $showBreathing)
                .frame(width: 998, height: 686)
                .fixedSize()
        }
        .sheet(isPresented: $showAccount) {
            AccountView()
        }
    }

    // MARK: - Emotion Hero Card

    private var emotionHeroCard: some View {
        VStack(spacing: GentleSpacing.lg) {
            if let emotion = selectedEmotion {
                Text(emotion.emoji)
                    .font(.system(size: 80))
                    .shadow(color: Color(hex: emotion.color).opacity(0.3), radius: 20, x: 0, y: 10)

                HStack(spacing: GentleSpacing.xs) {
                    Circle()
                        .fill(Color(hex: emotion.color))
                        .frame(width: 8, height: 8)
                    Text(emotion.rawValue)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(hex: emotion.color))
                }
                .padding(.horizontal, GentleSpacing.md)
                .padding(.vertical, GentleSpacing.xs)
                .background(Capsule().fill(Color(hex: emotion.color).opacity(0.12)))

                Text(currentMessage)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(Gentle.Text.primary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .frame(maxWidth: 480)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text("🌸")
                    .font(.system(size: 72))
                    .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)

                Text("今天感觉怎么样？")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(Gentle.Text.secondary)
            }

            emotionGrid

            if selectedEmotion != nil {
                Button {
                    pickRandomMessage()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "arrow.clockwise").font(.system(size: 11, weight: .medium))
                        Text("换一句").font(.system(size: 12, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(Gentle.Text.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(GentleSpacing.xxl)
        .frame(maxWidth: 600)
        .background(RoundedRectangle(cornerRadius: 32, style: .continuous).fill(.ultraThinMaterial))
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 32, style: .continuous).stroke(Gentle.Border.focus, lineWidth: 1))
    }

    // MARK: - Emotion Grid

    private var emotionGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 7), spacing: 10) {
            ForEach(Emotion.allCases) { emotion in
                emotionChip(for: emotion)
            }
        }
        .padding(.horizontal, 12)
    }

    private func emotionChip(for emotion: Emotion) -> some View {
        let isSelected = selectedEmotion == emotion

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedEmotion = emotion
            }
            pickRandomMessage()
        } label: {
            VStack(spacing: 4) {
                Text(emotion.emoji).font(.system(size: 24))
                Text(emotion.rawValue)
                    .font(.system(size: 9, weight: isSelected ? .bold : .regular, design: .rounded))
                    .foregroundColor(isSelected ? Color(hex: emotion.color) : Gentle.Text.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(width: 52, height: 56)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? Color(hex: emotion.color).opacity(0.14) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? Color(hex: emotion.color).opacity(0.5) : Color.clear, lineWidth: 1.5)
            )
            .scaleEffect(isSelected ? 1.1 : 1.0)
            .shadow(color: isSelected ? Color(hex: emotion.color).opacity(0.2) : .clear, radius: 6, x: 0, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Module Grid

    private var moduleGrid: some View {
        let spacing: CGFloat = 20
        let columns = [
            GridItem(.flexible(), spacing: spacing),
            GridItem(.flexible(), spacing: spacing)
        ]

        return LazyVGrid(columns: columns, spacing: spacing) {
            moduleCard(title: "时间模式", icon: "clock", subtitle: "专注 · 25 分钟") { showTimeMode = true }
            moduleCard(title: "温柔墙", icon: "heart.text.square", subtitle: "每日善意") { showGentleWall = true }
            moduleCard(title: "呼吸练习", icon: "wind", subtitle: "4-4-6-2 放松") { showBreathing = true }
            moduleCard(title: "社交动态", icon: "person.2", subtitle: "分享心情") { showSocialFeed = true }
            moduleCard(title: "设置", icon: "gear", subtitle: "个性化") { showSettings = true }
        }
        .frame(maxWidth: 720)
    }

    private func moduleCard(title: String, icon: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: GentleSpacing.lg) {
                ZStack {
                    Circle()
                        .fill(Gentle.Gradient.primaryButton)
                        .frame(width: 52, height: 52)
                        .shadow(color: Color(hex: "#7C3AED").opacity(0.25), radius: 8, x: 0, y: 4)

                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Gentle.Text.primary)

                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Gentle.Text.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Gentle.Text.secondary.opacity(0.5))
            }
            .padding(GentleSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Gentle.Background.secondary)
                    .shadow(color: GentleShadow.md.color, radius: GentleShadow.md.radius, x: GentleShadow.md.x, y: GentleShadow.md.y)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Activation Overlay

    private var activationOverlay: some View {
        ZStack {
            RadialGradient(
                colors: [theme.current.background, theme.current.secondary.opacity(0.15), Gentle.Background.primary],
                center: .center,
                startRadius: 0,
                endRadius: 600
            ).ignoresSafeArea()

            if phase == .welcome {
                welcomeView
                    .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.95)), removal: .opacity.combined(with: .scale(scale: 1.05))))
            } else if phase == .select {
                emotionSelectView
                    .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 1.05)), removal: .opacity.combined(with: .scale(scale: 0.95))))
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Welcome View

    private var welcomeView: some View {
        VStack(spacing: GentleSpacing.xl) {
            Spacer()

            VStack(spacing: GentleSpacing.lg) {
                Text("🌸")
                    .font(.system(size: 80))
                    .shadow(color: .black.opacity(0.1), radius: 16, x: 0, y: 8)

                Text("欢迎回来")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundColor(Gentle.Text.primary)
                    .multilineTextAlignment(.center)

                Text("今天，你感觉怎么样？")
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundColor(Gentle.Text.secondary)
            }

            Spacer()

            Text("点击任意处继续")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(Gentle.Text.secondary.opacity(0.6))
                .padding(.bottom, GentleSpacing.xxl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.7)) {
                phase = .select
            }
        }
    }

    // MARK: - Emotion Select View

    private var emotionSelectView: some View {
        VStack(spacing: GentleSpacing.xl) {
            Spacer()

            Text("今天，你感觉怎么样？")
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundColor(Gentle.Text.primary)

            Text("选择一个最接近你此刻心情的词")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(Gentle.Text.secondary)

            if let emotion = selectedEmotion {
                emotionQuoteCard(for: emotion)
                    .transition(.asymmetric(insertion: .opacity.combined(with: .move(edge: .bottom)), removal: .opacity))
            }

            emotionGrid

            if selectedEmotion != nil {
                enterButton
                    .transition(.asymmetric(insertion: .opacity.combined(with: .move(edge: .bottom)), removal: .opacity))
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 80)
    }

    private func emotionQuoteCard(for emotion: Emotion) -> some View {
        VStack(spacing: GentleSpacing.md) {
            HStack(spacing: GentleSpacing.xs) {
                Text(emotion.emoji).font(.system(size: 24))
                Text(emotion.rawValue)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: emotion.color))
            }

            ScrollView(.vertical, showsIndicators: false) {
                Text(currentMessage)
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(Gentle.Text.primary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxHeight: 140)

            Button {
                pickRandomMessage()
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "arrow.clockwise").font(.system(size: 11, weight: .medium))
                    Text("换一句").font(.system(size: 12, weight: .medium, design: .rounded))
                }
                .foregroundColor(Gentle.Text.secondary.opacity(0.7))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(GentleSpacing.xl)
        .frame(maxWidth: 560)
        .background(RoundedRectangle(cornerRadius: 28, style: .continuous).fill(.ultraThinMaterial))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(Gentle.Border.focus, lineWidth: 1))
    }

    private var enterButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.8)) {
                phase = .main
            }
        } label: {
            HStack(spacing: 10) {
                Text("进入温柔").font(.system(size: 18, weight: .semibold, design: .rounded))
                Image(systemName: "arrow.right").font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 40)
            .padding(.vertical, 16)
            .background(
                Capsule().fill(LinearGradient(colors: [Color(hex: "#A78BFA"), Color(hex: "#7C3AED")], startPoint: .leading, endPoint: .trailing))
            )
            .shadow(color: Color(hex: "#7C3AED").opacity(0.4), radius: 16, x: 0, y: 8)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Helpers

    private func pickRandomMessage() {
        guard let emotion = selectedEmotion else { return }
        let messages = GentleMessage.messages(for: emotion)
        currentMessage = messages.randomElement() ?? messages[0]
    }
}

// MARK: - Scale Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
