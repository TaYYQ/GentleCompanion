//
//  ProfileView.swift
//  GentleCompanion
//
//  个人中心 — Gentle Liquid Glass 风格
//

import SwiftUI

struct ProfileView: View {
    @State private var currentUser: UserProfile?

    var body: some View {
        ZStack {
            // 深度渐变背景
            LinearGradient(
                colors: [
                    Color(hex: "#1E1633"),
                    Color(hex: "#2D2447"),
                    Color(hex: "#1A0F2E")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            GlassBackground()

            ScrollView {
                VStack(spacing: 28) {
                    avatarSection
                    statsSection
                    quickActions
                    footerSection
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 36)
            }
        }
        .onAppear { loadUser() }
    }

    // MARK: - 头像 & 问候

    private var avatarSection: some View {
        VStack(spacing: 14) {
            ZStack {
                // 外圈光晕
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Gentle.Primary.lavender.opacity(0.35), Color.clear],
                            center: .center,
                            startRadius: 30,
                            endRadius: 52
                        )
                    )
                    .frame(width: 104, height: 104)

                // 头像底
                Circle()
                    .fill(Gentle.Gradient.primaryButton)
                    .frame(width: 80, height: 80)

                // 头像文字
                Text(userInitial)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
            }
            .shadow(color: Gentle.Primary.purple.opacity(0.4), radius: 16, y: 6)

            if let user = currentUser {
                VStack(spacing: 4) {
                    Text("你好，\(user.username)")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)

                    Text(user.email)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.45))
                }
            } else {
                VStack(spacing: 4) {
                    Text("未登录")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white.opacity(0.5))

                    Text("登录后查看你的专注数据")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.35))
                }
            }
        }
    }

    // MARK: - 统计卡片

    private var statsSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                StatCard(
                    icon: "flame.fill",
                    iconColor: Gentle.Primary.orange,
                    value: currentUser.map { "\($0.streakDays)" } ?? "—",
                    label: "连续天数"
                )

                StatCard(
                    icon: "clock.fill",
                    iconColor: Gentle.Primary.indigo,
                    value: currentUser.map { "\($0.totalPomodoros)" } ?? "—",
                    label: "专注次数"
                )

                StatCard(
                    icon: "hourglass",
                    iconColor: Gentle.Primary.lavender,
                    value: currentUser.map { formatMinutes($0.totalMinutes) } ?? "—",
                    label: "累计时长"
                )
            }
        }
    }

    // MARK: - 快捷操作

    private var quickActions: some View {
        VStack(spacing: 0) {
            actionRow(icon: "gearshape.fill", iconColor: Gentle.State.info, title: "设置") {
                // TODO: 打开设置
            }
            divider
            actionRow(icon: "bell.fill", iconColor: Gentle.Primary.yellow, title: "提醒管理") {
                // TODO
            }
            divider
            actionRow(icon: "chart.bar.fill", iconColor: Gentle.Primary.pink, title: "数据统计") {
                // TODO
            }
            divider
            actionRow(icon: "questionmark.circle.fill", iconColor: .white.opacity(0.6), title: "帮助与反馈") {
                // TODO
            }
            divider
            actionRow(icon: "info.circle.fill", iconColor: .white.opacity(0.5), title: "关于 Gentle") {
                // TODO
            }

            // 退出登录（仅登录状态）
            if currentUser != nil {
                divider
                actionRow(icon: "rectangle.portrait.and.arrow.right", iconColor: Gentle.State.error, title: "退出登录", isDestructive: true) {
                    logout()
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: GentleRadius.lg)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: GentleRadius.lg)
                        .stroke(.white.opacity(0.1), lineWidth: 0.8)
                )
        )
    }

    // MARK: - 底部

    private var footerSection: some View {
        VStack(spacing: 4) {
            Text("Gentle Companion")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.25))
            Text("Version 1.0.0")
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.18))
        }
        .padding(.top, 8)
    }

    // MARK: - Helpers

    private var divider: some View {
        Rectangle().fill(.white.opacity(0.08)).frame(height: 0.8)
    }

    private func actionRow(icon: String, iconColor: Color, title: String, isDestructive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundColor(iconColor)
                    .frame(width: 24)

                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(isDestructive ? Gentle.State.error : .white.opacity(0.8))

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.25))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var userInitial: String {
        if let name = currentUser?.username, !name.isEmpty {
            return String(name.prefix(1)).uppercased()
        }
        return "?"
    }

    private func formatMinutes(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes)m"
        }
        let hours = minutes / 60
        let mins = minutes % 60
        return mins > 0 ? "\(hours)h\(mins)m" : "\(hours)h"
    }

    // MARK: - 数据

    private func loadUser() {
        if let data = UserDefaults.standard.data(forKey: "current_user"),
           let user = try? JSONDecoder().decode(UserProfile.self, from: data) {
            currentUser = user
        }
    }

    private func logout() {
        UserDefaults.standard.removeObject(forKey: "current_user")
        UserDefaults.standard.removeObject(forKey: "auth_token")
        currentUser = nil
    }
}

// MARK: - StatCard

struct StatCard: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(iconColor)

            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)

            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: GentleRadius.md)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: GentleRadius.md)
                        .stroke(.white.opacity(0.1), lineWidth: 0.8)
                )
        )
    }
}
