//
//  AuthView.swift
//  GentleCompanion
//
//  登录 & 注册 — iOS 26 Liquid Glass 风格 · 情感化升级版
//

import SwiftUI

// MARK: - AuthView (入口)

struct AuthView: View {
    @State private var isLogin = true
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var confirmPassword = ""
    @State private var rememberMe = true   // 记住我

    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSuccess = false

    // 水波纹动画
    @State private var rippleOrigin: CGPoint = .zero
    @State private var showRipple = false

    var onAuthenticated: (() -> Void)?

    var body: some View {
        ZStack {
            // ─── 情感化背景 ───
            EmotionalBackground()

            // ─── 毛玻璃主卡片 ───
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 28) {
                        headerSection
                        modeToggle
                        formSection
                        rememberMeToggle
                        submitButton
                        socialDivider
                        socialRow
                        bottomHint
                    }
                    .padding(.horizontal, 28)
                    .padding(.vertical, 36)
                }
            }
            .frame(maxWidth: 400)
            .background(
                RoundedRectangle(cornerRadius: GentleRadius.xxl, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: GentleRadius.xxl, style: .continuous)
                            .stroke(.white.opacity(0.18), lineWidth: 0.8)
                    )
            )
            .padding(.horizontal, 24)

            // 右上角关闭
            VStack {
                HStack {
                    Spacer()
                    Button(action: { NSApp.keyWindow?.close() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                            .frame(width: 30, height: 30)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .overlay(Circle().stroke(.white.opacity(0.15), lineWidth: 0.5))
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(16)
                }
                Spacer()
            }
        }
    }

    // MARK: - 情感化背景

    struct EmotionalBackground: View {
        @State private var blob1Offset: CGSize = .zero
        @State private var blob2Offset: CGSize = .zero
        @State private var blob3Offset: CGSize = .zero
        @State private var blob4Offset: CGSize = .zero

        var body: some View {
            ZStack {
                // 深紫 → 深蓝微渐变
                LinearGradient(
                    colors: [
                        Color(hex: "#1A0F2E"),
                        Color(hex: "#1E1633"),
                        Color(hex: "#1A1040"),
                        Color(hex: "#0F1A2E")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // 极光光斑 1 — 左上角，紫色
                BlobView(
                    color: Color(hex: "#7C3AED").opacity(0.12),
                    size: 320,
                    seed: 1
                )
                .offset(x: -120 + blob1Offset.width, y: -80 + blob1Offset.height)
                .blur(radius: 60)

                // 极光光斑 2 — 右上角，粉色
                BlobView(
                    color: Color(hex: "#F472B6").opacity(0.09),
                    size: 260,
                    seed: 2
                )
                .offset(x: 160 + blob2Offset.width, y: 60 + blob2Offset.height)
                .blur(radius: 55)

                // 极光光斑 3 — 右下角，靛蓝
                BlobView(
                    color: Color(hex: "#8B5CF6").opacity(0.11),
                    size: 280,
                    seed: 3
                )
                .offset(x: 80 + blob3Offset.width, y: 200 + blob3Offset.height)
                .blur(radius: 50)

                // 极光光斑 4 — 左下角，薰衣草
                BlobView(
                    color: Color(hex: "#A78BFA").opacity(0.08),
                    size: 220,
                    seed: 4
                )
                .offset(x: -180 + blob4Offset.width, y: 280 + blob4Offset.height)
                .blur(radius: 48)
            }
            .onAppear {
                // 呼吸般缓慢飘动
                withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                    blob1Offset = CGSize(width: 30, height: 20)
                }
                withAnimation(.easeInOut(duration: 14).repeatForever(autoreverses: true)) {
                    blob2Offset = CGSize(width: -25, height: 30)
                }
                withAnimation(.easeInOut(duration: 12).repeatForever(autoreverses: true)) {
                    blob3Offset = CGSize(width: -20, height: -25)
                }
                withAnimation(.easeInOut(duration: 16).repeatForever(autoreverses: true)) {
                    blob4Offset = CGSize(width: 25, height: -20)
                }
            }
        }
    }

    // MARK: - 极光Blob组件

    struct BlobView: View {
        let color: Color
        let size: CGFloat
        let seed: Int

        @State private var phase: CGFloat = 0

        var body: some View {
            Canvas { context, canvasSize in
                var path = Path()

                let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
                let points = 6
                let angleStep = (2 * .pi) / CGFloat(points)

                for i in 0..<points {
                    let angle = angleStep * CGFloat(i) + phase
                    let wave = sin(angle * 3 + phase * 0.5) * 0.3 + 1.0
                    let radius = (size / 2) * wave
                    let x = center.x + cos(angle) * radius
                    let y = center.y + sin(angle) * radius

                    if i == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        let prevAngle = angleStep * CGFloat(i - 1) + phase
                        let cpRadius = radius * 0.6
                        let cpX = center.x + cos(prevAngle + angleStep * 0.5) * cpRadius
                        let cpY = center.y + sin(prevAngle + angleStep * 0.5) * cpRadius
                        path.addQuadCurve(to: CGPoint(x: x, y: y), control: CGPoint(x: cpX, y: cpY))
                    }
                }
                path.closeSubpath()

                context.fill(path, with: .color(color))
            }
            .frame(width: size, height: size)
            .onAppear {
                withAnimation(.linear(duration: 12 + Double(seed) * 2).repeatForever(autoreverses: false)) {
                    phase = .pi * 2
                }
            }
        }
    }

    // MARK: - Header（含呼吸 Logo）

    private var headerSection: some View {
        VStack(spacing: 10) {
            BreathingLogo()

            Text("欢迎回来")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(Gentle.Text.darkPrimary)

            Text(isLogin ? "登录继续你的情绪旅程" : "创建账号，开始记录")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Gentle.Text.darkSecondary)
        }
    }

    // MARK: - 呼吸 Logo

    struct BreathingLogo: View {
        @State private var isBreathing = false
        @State private var glowOpacity: Double = 0.3

        var body: some View {
            ZStack {
                // 辉光
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Gentle.Primary.purple.opacity(0.4),
                                Gentle.Primary.purple.opacity(0.1),
                                .clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 50
                        )
                    )
                    .frame(width: 100, height: 100)
                    .opacity(glowOpacity)

                // Logo 主体
                Circle()
                    .fill(Gentle.Gradient.primaryButton)
                    .frame(width: 64, height: 64)
                    .overlay(
                        Circle()
                            .stroke(.white.opacity(0.3), lineWidth: 1.5)
                    )
                    .shadow(
                        color: Gentle.Primary.purple.opacity(0.5),
                        radius: 16,
                        y: 4
                    )
            }
            .scaleEffect(isBreathing ? 1.08 : 0.96)
            .onAppear {
                // 呼吸动画：3s 完成一次缩放，无限循环
                withAnimation(
                    .easeInOut(duration: 3.0)
                        .repeatForever(autoreverses: true)
                ) {
                    isBreathing = true
                }
                // 辉光脉动
                withAnimation(
                    .easeInOut(duration: 3.0)
                        .repeatForever(autoreverses: true)
                ) {
                    glowOpacity = 0.55
                }
            }
        }
    }

    // MARK: - 模式切换

    private var modeToggle: some View {
        HStack(spacing: 0) {
            modeButton("登录", isSelected: isLogin) {
                withAnimation(.easeInOut(duration: 0.2)) { isLogin = true }
            }
            modeButton("注册", isSelected: !isLogin) {
                withAnimation(.easeInOut(duration: 0.2)) { isLogin = false }
            }
        }
        .padding(3)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.08))
                .overlay(
                    Capsule()
                        .stroke(.white.opacity(0.15), lineWidth: 0.6)
                )
        )
    }

    private func modeButton(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: {
            action()
            errorMessage = nil
        }) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : .white.opacity(0.45))
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.white.opacity(0.15) : Color.clear)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - 表单

    @ViewBuilder
    private var formSection: some View {
        VStack(spacing: 14) {
            if !isLogin {
                GentleTextField(
                    text: $username,
                    placeholder: "你的名字…",
                    icon: "person.fill",
                    error: nil
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            GentleTextField(
                text: $email,
                placeholder: "请留下你的足迹…",
                icon: "envelope.fill",
                error: nil
            )

            GentleSecureField(
                text: $password,
                placeholder: "输入你的秘密钥匙…",
                icon: "lock.fill",
                error: nil
            )

            if !isLogin {
                GentleSecureField(
                    text: $confirmPassword,
                    placeholder: "再确认一次…",
                    icon: "lock.fill",
                    error: nil
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            // 错误提示
            if let err = errorMessage {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 13))
                    Text(err)
                        .font(.system(size: 13))
                }
                .foregroundColor(Gentle.State.error)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: GentleRadius.sm)
                        .fill(Gentle.State.error.opacity(0.12))
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    // MARK: - 记住我

    private var rememberMeToggle: some View {
        HStack(spacing: 8) {
            Button(action: { rememberMe.toggle() }) {
                HStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(
                                rememberMe ? Gentle.Primary.lavender : Color.white.opacity(0.3),
                                lineWidth: 1.2
                            )
                            .frame(width: 18, height: 18)

                        if rememberMe {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Gentle.Gradient.primaryButton)
                                .frame(width: 18, height: 18)
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white)
                                )
                        }
                    }
                    Text("记住我")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.5))
                }
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()
        }
        .padding(.horizontal, 4)
    }

    // MARK: - 提交按钮

    private var submitButton: some View {
        Button(action: submit) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else {
                    HStack(spacing: 8) {
                        Text(isLogin ? "回到这里" : "开启旅程")
                            .font(.system(size: 16, weight: .semibold))
                        if !isLogin {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 13, weight: .semibold))
                        }
                    }
                    .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: GentleRadius.md)
                    .fill(
                        isLoading
                            ? AnyShapeStyle(Gentle.Primary.purple.opacity(0.5))
                            : AnyShapeStyle(Gentle.Gradient.warmPrimaryButton)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: GentleRadius.md)
                    .stroke(.white.opacity(0.2), lineWidth: 0.6)
            )
            .shadow(
                color: Gentle.Primary.purple.opacity(0.4),
                radius: isLoading ? 4 : 12,
                y: isLoading ? 2 : 6
            )
        }
        .buttonStyle(JourneyButtonStyle())
        .disabled(isLoading || !formIsValid)
        .opacity(formIsValid ? 1 : 0.5)
    }

    // MARK: - 渐隐分隔线

    private var socialDivider: some View {
        HStack(spacing: 16) {
            FadeEdgeLine()
            Text("或以下方式登录")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.3))
            FadeEdgeLine()
        }
    }

    // MARK: - 渐隐线

    struct FadeEdgeLine: View {
        var body: some View {
            LinearGradient(
                colors: [.clear, .white.opacity(0.15), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 0.8)
        }
    }

    // MARK: - 社交登录

    private var socialRow: some View {
        HStack(spacing: 14) {
            SocialLoginButton(icon: "applelogo", label: "Apple") {
                handleSocialLogin(.apple)
            }
            SocialLoginButton(icon: "g.circle.fill", label: "Google") {
                handleSocialLogin(.google)
            }
            SocialLoginButton(icon: "message.fill", label: "微信") {
                handleSocialLogin(.wechat)
            }
        }
    }

    // MARK: - 底部提示

    private var bottomHint: some View {
        Group {
            if isLogin {
                HStack(spacing: 4) {
                    Text("还没有账号？")
                        .foregroundColor(.white.opacity(0.35))
                    Button("立即注册") {
                        withAnimation(.easeInOut(duration: 0.2)) { isLogin = false }
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Gentle.Primary.lavender)
                    .buttonStyle(PlainButtonStyle())
                }
            } else {
                HStack(spacing: 4) {
                    Text("已有账号？")
                        .foregroundColor(.white.opacity(0.35))
                    Button("去登录") {
                        withAnimation(.easeInOut(duration: 0.2)) { isLogin = true }
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Gentle.Primary.lavender)
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .font(.system(size: 13))
    }

    // MARK: - 验证

    private var formIsValid: Bool {
        if isLogin {
            return !email.isEmpty && !password.isEmpty
        } else {
            return !username.isEmpty && !email.isEmpty && !password.isEmpty && password == confirmPassword
        }
    }

    // MARK: - 提交

    private func submit() {
        errorMessage = nil

        if !isLogin && password != confirmPassword {
            errorMessage = "两次密码输入不一致"
            return
        }

        if !isLogin && password.count < 6 {
            errorMessage = "密码至少 6 位"
            return
        }

        isLoading = true

        Task {
            do {
                let response: APIResponse<UserProfile>
                if isLogin {
                    response = try await NetworkService.shared.login(email: email, password: password)
                } else {
                    response = try await NetworkService.shared.register(
                        username: username, email: email, password: password
                    )
                }
                await MainActor.run {
                    isLoading = false
                    if response.success, let user = response.data {
                        saveUser(user)
                        onAuthenticated?()
                    } else {
                        errorMessage = response.message
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func saveUser(_ user: UserProfile) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: "current_user")
        }
    }

    // MARK: - 社交登录

    private enum SocialProvider { case apple, google, wechat }

    private func handleSocialLogin(_ provider: SocialProvider) {
        // TODO: 接入各平台 OAuth SDK
    }
}

// MARK: - JourneyButtonStyle（按钮点击反馈 + 水波纹）

struct JourneyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - GentleTextField（聚焦状态增强）

struct GentleTextField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    let error: String?
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(isFocused ? Gentle.Primary.lavender : .white.opacity(0.35))
                .frame(width: 20)

            TextField(placeholder, text: $text)
                .font(.system(size: 15))
                .foregroundColor(Gentle.Text.darkPrimary)   // 深色模式高对比度
                .focused($isFocused)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background(
            RoundedRectangle(cornerRadius: GentleRadius.sm)
                .fill(Color.white.opacity(isFocused ? 0.1 : 0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: GentleRadius.sm)
                        .stroke(
                            error != nil ? Gentle.State.error
                                : isFocused ? Gentle.Primary.lavender
                                : .white.opacity(0.12),
                            lineWidth: isFocused || error != nil ? 1.2 : 0.8
                        )
                )
        )
        // 聚焦时：阴影扩散
        .shadow(
            color: isFocused ? Gentle.Primary.purple.opacity(0.3) : .clear,
            radius: isFocused ? 10 : 0,
            y: 0
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// MARK: - GentleSecureField（聚焦状态增强）

struct GentleSecureField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    let error: String?
    @FocusState private var isFocused: Bool
    @State private var isRevealed = false

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(isFocused ? Gentle.Primary.lavender : .white.opacity(0.35))
                .frame(width: 20)

            Group {
                if isRevealed {
                    TextField(placeholder, text: $text)
                } else {
                    SecureField(placeholder, text: $text)
                }
            }
            .font(.system(size: 15))
            .foregroundColor(Gentle.Text.darkPrimary)
            .focused($isFocused)

            Button(action: { isRevealed.toggle() }) {
                Image(systemName: isRevealed ? "eye.slash.fill" : "eye.fill")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.3))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background(
            RoundedRectangle(cornerRadius: GentleRadius.sm)
                .fill(Color.white.opacity(isFocused ? 0.1 : 0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: GentleRadius.sm)
                        .stroke(
                            error != nil ? Gentle.State.error
                                : isFocused ? Gentle.Primary.lavender
                                : .white.opacity(0.12),
                            lineWidth: isFocused || error != nil ? 1.2 : 0.8
                        )
                )
        )
        .shadow(
            color: isFocused ? Gentle.Primary.purple.opacity(0.3) : .clear,
            radius: isFocused ? 10 : 0,
            y: 0
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// MARK: - SocialLoginButton

struct SocialLoginButton: View {
    let icon: String
    let label: String
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.09))
                        .frame(width: 48, height: 48)

                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                }
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.2), .white.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.8
                        )
                )
                // Hover / Press 辉光
                .shadow(
                    color: isPressed ? Gentle.Primary.purple.opacity(0.4) : .clear,
                    radius: 12,
                    y: 0
                )

                Text(label)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.38))
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeInOut(duration: 0.1)) { isPressed = true } }
                .onEnded  { _ in withAnimation(.easeInOut(duration: 0.15)) { isPressed = false } }
        )
    }
}
