//
//  GentiOSHomeView.swift
//  GentleCompanion iOS
//
//  陪伴页 — 心情记录 + 温柔语录 + Liquid Glass 卡片
//

import SwiftUI

struct GentiOSHomeView: View {
    @ObservedObject private var theme = GentleThemeManager.shared
    @StateObject private var account = AccountManager.shared
    @StateObject private var community = CommunityManager.shared
    @State private var selectedEmotion: Emotion? = nil
    @State private var appear = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                moodSection
                quoteSection
                featureSection
                socialFeedSection
                Spacer().frame(height: 8)
            }
            .padding(.horizontal, 20)
        }
        .scrollIndicators(.hidden)
        .background {
            ZStack {
                Gentle.Glass.darkBase
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [GentleThemeManager.shared.current.primary.opacity(0.1), .clear],
                            center: .top,
                            startRadius: 0,
                            endRadius: 300
                        )
                    )
                    .frame(width: 420, height: 420)
                    .offset(y: -160)
                    .blur(radius: 10)
            }
            .ignoresSafeArea()
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { appear = true }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(greeting())
                    .font(.system(size: 30, weight: .thin, design: .serif))
                    .foregroundColor(Gentle.Glass.textPrimary)

                if let name = account.currentAccount?.username, !name.isEmpty {
                    Text(name)
                        .font(.system(size: 30, weight: .thin, design: .serif))
                        .foregroundColor(Gentle.Glass.textPrimary)
                }

                Text(formattedDate())
                    .font(.system(size: 13, weight: .light))
                    .foregroundColor(Gentle.Glass.textTertiary)
                    .padding(.top, 2)
            }

            Spacer()

            NavigationLink(destination: GentiOSProfileView()) {
                    ZStack {
                        Circle()
                        .fill(
                            LinearGradient(
                                colors: [Gentle.Primary.lavender.opacity(0.3), Gentle.Primary.pink.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 46, height: 46)
                        .overlay {
                            Circle()
                                .stroke(Gentle.Glass.borderWhite, lineWidth: 0.5)
                        }

                        avatarDisplayView(
                            account.isLoggedIn ? (account.currentAccount?.avatar ?? "🌸") : "🌸",
                            size: 20
                        )
                    }
                }
                .buttonStyle(.plain)
        }
        .padding(.top, 8)
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 20)
    }

    // MARK: - Mood Grid

    private var moodSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("此刻心情")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Gentle.Glass.textSecondary)
                    .padding(.leading, 4)
                Spacer()
                if selectedEmotion != nil {
                    Label("已记录", systemImage: "checkmark")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#34D399"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color(hex: "#34D399").opacity(0.1))
                                .overlay(Capsule().stroke(Color(hex: "#34D399").opacity(0.2), lineWidth: 0.5))
                        )
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
                ForEach(Emotion.allCases) { emotion in
                    moodCell(emotion)
                }
            }
        }
        .padding(20)
        .liquidGlassCard(cornerRadius: GentleRadius.xxxl, opacity: 0.5)
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 20)
    }

    private func moodCell(_ emotion: Emotion) -> some View {
        let isSelected = selectedEmotion == emotion
        return Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                selectedEmotion = isSelected ? nil : emotion
                if !isSelected { SettingsManager.shared.appendEmotionEntry(emotion) }
            }
        } label: {
            VStack(spacing: 6) {
                Text(emotion.emoji)
                    .font(.system(size: 28))
                    .scaleEffect(isSelected ? 1.12 : 1.0)
                Text(emotion.displayName)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? Gentle.Glass.textPrimary : Gentle.Glass.textTertiary)
            }
            .frame(height: 72)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color(hex: emotion.color).opacity(0.15) : Gentle.Glass.borderWhite)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? Color(hex: emotion.color).opacity(0.25) : Gentle.Glass.borderWhite,
                        lineWidth: 0.5
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedEmotion)
    }

    // MARK: - Quote

    @ViewBuilder
    private var quoteSection: some View {
        if let emotion = selectedEmotion {
            VStack(spacing: 16) {
                Text(emotion.emoji).font(.system(size: 44))
                    .shadow(color: Color(hex: emotion.color).opacity(0.3), radius: 16)
                Text(emotion.gentleMessage)
                    .font(.system(size: 18, weight: .medium, design: .serif))
                    .foregroundColor(Gentle.Glass.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                Text("— 温柔点 · 说给你听")
                    .font(.system(size: 11, weight: .light))
                    .foregroundColor(Gentle.Glass.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(24)
            .liquidGlassCard(cornerRadius: GentleRadius.xxxl, opacity: 0.45)
            .overlay {
                RoundedRectangle(cornerRadius: GentleRadius.xxxl, style: .continuous)
                    .stroke(Color(hex: emotion.color).opacity(0.12), lineWidth: 0.5)
            }
            .transition(.scale(scale: 0.92).combined(with: .opacity))
        } else {
            VStack(spacing: 12) {
                Text("🌸").font(.system(size: 36)).opacity(0.4)
                Text("点击一个心情\n我为你准备了一段温柔的话")
                    .font(.system(size: 14, weight: .light, design: .rounded))
                    .foregroundColor(Gentle.Glass.textTertiary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(28)
            .liquidGlassCard(cornerRadius: GentleRadius.xxxl, opacity: 0.3)
        }
    }

    // MARK: - Features

    private var featureSection: some View {
        VStack(spacing: 14) {
            Text("放松工具")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Gentle.Glass.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 4)
                .padding(.top, 2)

            NavigationLink(destination: BreathingiOSView()) {
                featureCard(
                    icon: "wind", title: "深呼吸", subtitle: "4-7-8 呼吸法",
                    c1: "#A78BFA", c2: "#7C3AED"
                )
            }
            .buttonStyle(.plain)
        }
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 20)
    }

    private func featureCard(icon: String, title: String, subtitle: String, c1: String, c2: String) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: c1).opacity(0.25), Color(hex: c2).opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 42, height: 42)
                    .overlay {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(hex: c1).opacity(0.2), lineWidth: 0.5)
                    }
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(hex: c1))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Gentle.Glass.textPrimary)
                Text(subtitle)
                    .font(.system(size: 11, weight: .light))
                    .foregroundColor(Gentle.Glass.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .liquidGlassCard(cornerRadius: GentleRadius.xl, opacity: 0.5)
    }

    // MARK: - Social Feed

    private var socialFeedSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("社交动态")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Gentle.Glass.textSecondary)
                    .padding(.leading, 4)
                Spacer()
                NavigationLink(destination: GentiOSSocialView()) {
                    HStack(spacing: 3) {
                        Text("更多")
                            .font(.system(size: 12, weight: .light))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .light))
                    }
                    .foregroundColor(Gentle.Glass.textTertiary)
                }
            }
            .padding(.top, 8)

            ForEach(Array(community.posts.prefix(3))) { post in
                socialPostRow(post)
            }
        }
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 20)
    }

    private func socialPostRow(_ post: CommunityPost) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#A78BFA").opacity(0.35), Color(hex: "#EC4899").opacity(0.18)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 28, height: 28)
                    Text(String(post.authorName.prefix(1)))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Gentle.Glass.textPrimary)
                }
                Text(post.authorName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Gentle.Glass.textPrimary)
                Text("· \(post.timeAgo)")
                    .font(.system(size: 11))
                    .foregroundColor(Gentle.Glass.textTertiary)
                Spacer()
                Text(post.emotion)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(Color(hex: "#A78BFA"))
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color(hex: "#A78BFA").opacity(0.1))
                            .overlay(Capsule().stroke(Color(hex: "#A78BFA").opacity(0.15), lineWidth: 0.5))
                    )
            }

            Text(post.content)
                .font(.system(size: 13, weight: .light))
                .foregroundColor(Gentle.Glass.textSecondary)
                .lineLimit(2)
                .lineSpacing(4)

            HStack(spacing: 4) {
                Image(systemName: post.isLiked ? "heart.fill" : "heart")
                    .font(.system(size: 10))
                    .foregroundColor(post.isLiked ? Color(hex: "#F472B6") : Gentle.Glass.textTertiary)
                Text("\(post.likes)")
                    .font(.system(size: 10))
                    .foregroundColor(Gentle.Glass.textTertiary)
            }
        }
        .padding(14)
        .liquidGlassCard(cornerRadius: GentleRadius.lg, opacity: 0.45)
    }

    // MARK: - Helpers

    private func greeting() -> String {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 6..<12: return "早上好"
        case 12..<18: return "下午好"
        case 18..<23: return "晚上好"
        default: return "夜深了"
        }
    }

    private func formattedDate() -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_CN")
        f.dateFormat = "M月d日 EEEE"
        return f.string(from: Date())
    }
}
