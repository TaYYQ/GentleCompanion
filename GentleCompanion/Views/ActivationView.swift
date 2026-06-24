//
//  ActivationView.swift
//  GentleCompanion
//
//  首次启动激活页：注册/登录/跳过 → 主页面
//

import SwiftUI

struct ActivationView: View {
    @ObservedObject private var theme = GentleThemeManager.shared
    @StateObject private var manager = AccountManager.shared
    
    @State private var showAccountView = false
    @State private var accountMode: AccountView.AccountMode = .login
    
    var body: some View {
        ZStack {
            // 渐变背景
            themeBackground
            
            // 粒子
            ActivationParticles()
            
            // 内容
            VStack(spacing: 0) {
                Spacer()
                
                // Logo + 欢迎文字
                VStack(spacing: 20) {
                    logoSection
                    welcomeSection
                }
                
                Spacer()
                
                // 操作按钮
                actionButtons
                
                Spacer()
            }
            .padding(.horizontal, 60)
            
            // 帐号页覆盖层
            if showAccountView {
                AccountView(
                    initialMode: accountMode,
                    onLoginSuccess: {
                        showAccountView = false
                        NotificationCenter.default.post(name: .activationComplete, object: nil)
                    },
                    onRegisterSuccess: {
                        showAccountView = false
                        NotificationCenter.default.post(name: .activationComplete, object: nil)
                    }
                )
                .id("\(accountMode)-\(Date().timeIntervalSince1970)")
                .transition(.opacity.combined(with: .scale(scale: 0.97)))
            }
        }
        .frame(width: 998, height: 687)
        .animation(.easeInOut(duration: 0.35), value: showAccountView)
        .onAppear {
            // 如果已登录，直接通知完成
            if manager.isLoggedIn {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    NotificationCenter.default.post(name: .activationComplete, object: nil)
                }
            }
        }
    }
    
    // MARK: - 背景
    
    private var themeBackground: some View {
        ZStack {
            Color(hex: "#0D0D1A")
            LinearGradient(
                colors: [Color(hex: "#A855F7").opacity(0.15), Color(hex: "#EC4899").opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Logo
    
    private var logoSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#A855F7").opacity(0.3), Color(hex: "#EC4899").opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Text("🌸")
                    .font(.system(size: 56))
            }
            .shadow(color: Color(hex: "#A855F7").opacity(0.4), radius: 30, x: 0, y: 0)
        }
    }
    
    // MARK: - 欢迎文字
    
    private var welcomeSection: some View {
        VStack(spacing: 8) {
            Text("欢迎来到温柔点")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "#A855F7"), Color(hex: "#EC4899")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text("开启你的情感陪伴之旅")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - 操作按钮
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            // 注册按钮
            activationButton(
                title: "开始注册",
                subtitle: "创建账户，开启专属体验",
                icon: "person.badge.plus",
                gradient: [Color(hex: "#A855F7"), Color(hex: "#9333EA")]
            ) {
                accountMode = .register
                showAccountView = true
            }
            
            // 登录按钮
            activationButton(
                title: "已有账户",
                subtitle: "登录继续你的旅程",
                icon: "person.fill",
                gradient: [Color(hex: "#6366F1"), Color(hex: "#8B5CF6")]
            ) {
                accountMode = .login
                showAccountView = true
            }
            
            // 跳过按钮
            Button {
                NotificationCenter.default.post(name: .activationComplete, object: nil)
            } label: {
                Text("先看看，随便逛逛 →")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.plain)
        }
        .padding(.bottom, 60)
    }
    
    private func activationButton(
        title: String,
        subtitle: String,
        icon: String,
        gradient: [Color],
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(colors: gradient, startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(nsColor: .controlBackgroundColor).opacity(0.7))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
            )
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
        }
        .buttonStyle(.plain)
        .frame(width: 380)
    }
}

// MARK: - 粒子动画

struct ActivationParticles: View {
    @State private var particles: [AParticle] = (0..<20).map { _ in AParticle() }
    
    struct AParticle: Identifiable {
        let id = UUID()
        var x: CGFloat = .random(in: 0...1)
        var y: CGFloat = .random(in: 0...1)
        var size: CGFloat = .random(in: 2...6)
        var opacity: Double = .random(in: 0.1...0.35)
        var duration: Double = .random(in: 8...18)
        var offset: Double = .random(in: 0...(2 * .pi))
        var symbol: String = ["🌸", "✨", "💜", "🌸", "✨"].randomElement()!
    }
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                for p in particles {
                    let y = (p.y + sin(t / p.duration + p.offset) * 0.05).truncatingRemainder(dividingBy: 1.0)
                    let x = p.x + sin(t / (p.duration * 1.3) + p.offset) * 0.03
                    let pos = CGPoint(x: x * size.width, y: y * size.height)
                    context.opacity = p.opacity
                    context.draw(
                        Text(p.symbol).font(.system(size: p.size)),
                        at: pos
                    )
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - 通知

extension Notification.Name {
    static let activationComplete = Notification.Name("activationComplete")
}
