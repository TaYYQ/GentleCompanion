//
//  ActivationView.swift
//  GentleCompanion
//
//  首次启动激活页 · iPhone 激活界面风格
//  深色背景 + 光晕 + 大标题居中 + 底部胶囊按钮
//

import SwiftUI

struct ActivationView: View {
    @ObservedObject private var theme = GentleThemeManager.shared
    @StateObject private var manager = AccountManager.shared

    @State private var showForm = false
    @State private var formMode: AuthMode = .register
    @State private var animateContent = false
    @State private var showPrivacySheet = false
    @State private var privacySheetType: PrivacySheetType = .policy

    // 登录/注册表单字段
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var errorMessage: String? = nil
    @State private var isLoading = false
    @State private var showWelcome = false
    @State private var authenticatedUsername = ""

    /// iPhone 风格：多语言问候语轮播
    @State private var greetingIndex = 0
    private let greetings: [(primary: String, subtitle: String)] = [
        ("温柔点",       "Gentle Companion"),
        ("你好",         "Hello"),
        ("欢迎",         "Welcome"),
        ("Bonjour",      "Bienvenue"),
        ("こんにちは",    "Hello"),
        ("안녕하세요",    "Welcome"),
        ("Hola",         "Bienvenido"),
        ("Ciao",         "Benvenuto"),
    ]

    /// 轮播定时器
    private let greetingTimer = Timer.publish(every: 2.2, on: .main, in: .common).autoconnect()

    enum AuthMode {
        case login, register

        var title: String {
            switch self {
            case .register: return "创建账户"
            case .login:    return "登录"
            }
        }
    }

    var body: some View {
        ZStack {
            // 深色背景 + 顶部光晕
            iphoneStyleBackground

            // 粒子
            ActivationParticles()

            // 主体内容
            VStack(spacing: 0) {
                Spacer()

                // 大标题 · iPhone Hello 风格
                heroSection
                    .offset(y: animateContent ? 0 : 20)
                    .opacity(animateContent ? 1 : 0)

                Spacer()

                // 底部操作区
                bottomActions
                    .offset(y: animateContent ? 0 : 30)
                    .opacity(animateContent ? 1 : 0)
            }
            .padding(.horizontal, 48)

            // 登录/注册表单覆盖层
            if showForm {
                authFormOverlay
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .bottom).combined(with: .scale(scale: 0.95))),
                        removal: .opacity.combined(with: .move(edge: .bottom))
                    ))
            }
        }
        #if os(macOS)
        .frame(width: 998, height: 687)
        #endif
        .animation(.spring(response: 0.7, dampingFraction: 0.8), value: animateContent)
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: showForm)
        .onReceive(greetingTimer) { _ in
            withAnimation {
                greetingIndex = (greetingIndex + 1) % greetings.count
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.15)) {
                animateContent = true
            }
            if manager.isLoggedIn {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    NotificationCenter.default.post(name: .activationComplete, object: nil)
                }
            }
        }
        .sheet(isPresented: $showPrivacySheet) {
            PrivacySheetView(type: privacySheetType)
        }
        .modifier(WelcomePresentationModifier(isPresented: $showWelcome, username: authenticatedUsername) {
            showWelcome = false
            NotificationCenter.default.post(name: .activationComplete, object: nil)
        })
    }

    // MARK: - 背景（iPhone 深色 + 顶部光晕风格）

    private var iphoneStyleBackground: some View {
        ZStack {
            // 纯黑底
            Color.black

            // 顶部紫粉光晕
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "#A855F7").opacity(0.18),
                            Color(hex: "#EC4899").opacity(0.08),
                            .clear
                        ],
                        center: .top,
                        startRadius: 0,
                        endRadius: 600
                    )
                )
                .frame(width: 900, height: 600)
                .offset(y: -180)
                .blur(radius: 40)

            // 底部微光
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "#6366F1").opacity(0.1),
                            .clear
                        ],
                        center: .bottom,
                        startRadius: 0,
                        endRadius: 500
                    )
                )
                .frame(width: 700, height: 400)
                .offset(y: 240)
                .blur(radius: 50)
        }
        .ignoresSafeArea()
    }

    // MARK: - 大标题 Hero 区域（iPhone 多语言轮播风格）

    private var heroSection: some View {
        VStack(spacing: 24) {
            // Logo 图标
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 100, height: 100)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color(hex: "#A855F7").opacity(0.5),
                                             Color(hex: "#EC4899").opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )

                Text("🌸")
                    .font(.system(size: 48))
            }
            .shadow(color: Color(hex: "#A855F7").opacity(0.25), radius: 40)

            // 多语言问候语轮播 · iPhone 风格淡入淡出
            VStack(spacing: 6) {
                Text(greetings[greetingIndex].primary)
                    .font(.system(size: 42, weight: .thin, design: .rounded))
                    .foregroundColor(.white)
                    .id("greeting-\(greetingIndex)")
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .bottom).combined(with: .scale(scale: 0.96))),
                            removal: .opacity.combined(with: .move(edge: .top).combined(with: .scale(scale: 1.04)))
                        )
                    )

                Text(greetings[greetingIndex].subtitle)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.5))
                    .tracking(2)
                    .id("sub-\(greetingIndex)")
                    .transition(.opacity)
            }
            .animation(.spring(response: 0.55, dampingFraction: 0.75), value: greetingIndex)

            // 分隔描述
            Text("开启你的情感陪伴之旅")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color.white.opacity(0.4))
                .padding(.top, 4)
        }
    }

    // MARK: - 底部操作区（iPhone 胶囊按钮风格）

    private var bottomActions: some View {
        VStack(spacing: 14) {
            // 主按钮 — 注册（渐变胶囊）
            Button {
                formMode = .register
                clearForm()
                withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                    showForm = true
                }
            } label: {
                Text("创建账户")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "#A855F7"), Color(hex: "#7C3AED")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .shadow(color: Color(hex: "#A855F7").opacity(0.4), radius: 12, y: 4)
            }
            .buttonStyle(.plain)
            .frame(maxWidth: 360)
            .scaleEffect(animateContent ? 1 : 0.95)

            // 次要按钮 — 登录（玻璃胶囊）
            Button {
                formMode = .login
                clearForm()
                withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                    showForm = true
                }
            } label: {
                Text("已有账户？登录")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.18), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .frame(maxWidth: 360)

            // 隐私提示（iPhone 风格：继续即表示同意…）
            privacyNotice

            // 跳过
            Button {
                NotificationCenter.default.post(name: .activationComplete, object: nil)
            } label: {
                Text("跳过，随便逛逛")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.45))
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
        }
        .padding(.bottom, 48)
    }

    // MARK: - 登录 / 注册表单（高级 iPhone 风格）

    private var authFormOverlay: some View {
        ZStack {
            // 全屏深色背景，完全遮住底层激活页
            Color.black.opacity(0.92)
                .ignoresSafeArea()

            // 顶部环境光晕
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "#A855F7").opacity(0.12), .clear],
                        center: .top,
                        startRadius: 0,
                        endRadius: 400
                    )
                )
                .frame(width: 800, height: 500)
                .offset(y: -180)
                .blur(radius: 30)

            VStack(spacing: 0) {
                // 顶部关闭按钮
                HStack {
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showForm = false
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white.opacity(0.5))
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(.white.opacity(0.08))
                                    .overlay(Circle().stroke(.white.opacity(0.1), lineWidth: 1))
                            )
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 24)
                    .padding(.leading, 24)

                    Spacer()
                }

                Spacer()

                // 表单卡片
                VStack(spacing: 32) {
                    // Logo + 标题
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "#A855F7").opacity(0.3),
                                                 Color(hex: "#EC4899").opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 76, height: 76)

                            Text("🌸")
                                .font(.system(size: 34))
                        }

                        Text(formMode.title)
                            .font(.system(size: 28, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                    }

                    // 输入框
                    VStack(spacing: 14) {
                        if formMode == .register {
                            ActivationTextField(
                                placeholder: "用户名",
                                text: $username,
                                icon: "person.fill"
                            )
                        }

                        ActivationTextField(
                            placeholder: "邮箱地址",
                            text: $email,
                            icon: "envelope.fill"
                        )

                        ActivationSecureField(
                            placeholder: "密码（至少 6 位）",
                            text: $password,
                            icon: "lock.fill"
                        )
                    }
                    .frame(maxWidth: 400)

                    // 错误提示
                    if let error = errorMessage {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.system(size: 12))
                            Text(error)
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(Color(hex: "#F87171"))
                        .padding(.vertical, 6)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }

                    // 提交按钮
                    Button(action: handleSubmit) {
                        HStack(spacing: 10) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.85)
                            }
                            Text(formMode == .register ? "创建账户" : "登录")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: 400)
                        .frame(height: 54)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "#A855F7"), Color(hex: "#7C3AED")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .opacity(isLoading ? 0.65 : 1)
                        )
                        .shadow(color: Color(hex: "#A855F7").opacity(0.45), radius: 18, y: 6)
                    }
                    .buttonStyle(.plain)
                    .disabled(isLoading)
                    .frame(maxWidth: 400)

                    // 切换模式
                    HStack(spacing: 4) {
                        Text(formMode == .register ? "已有账户？" : "没有账户？")
                            .foregroundColor(Color.white.opacity(0.4))
                        Button {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                formMode = formMode == .register ? .login : .register
                                errorMessage = nil
                            }
                        } label: {
                            Text(formMode == .register ? "登录" : "注册")
                                .foregroundColor(Color(hex: "#A78BFA"))
                                .fontWeight(.semibold)
                        }
                        .buttonStyle(.plain)
                    }
                    .font(.system(size: 14))
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)

                Spacer()
            }
        }
    }

    // MARK: - 提交登录/注册

    private func handleSubmit() {
        errorMessage = nil

        guard !isLoading else { return }

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        // 基本校验
        if formMode == .register {
            guard !username.trimmingCharacters(in: .whitespaces).isEmpty else {
                withAnimation { errorMessage = "请输入用户名" }; return
            }
        }
        guard trimmedEmail.contains("@"), trimmedEmail.contains(".") else {
            withAnimation { errorMessage = "请输入有效的邮箱地址" }; return
        }
        guard password.count >= 6 else {
            withAnimation { errorMessage = "密码至少需要 6 位" }; return
        }

        isLoading = true

        Task {
            do {
                if formMode == .register {
                    _ = try manager.register(username: username, email: trimmedEmail, password: password)
                } else {
                    _ = try manager.login(email: trimmedEmail, password: password)
                }

                isLoading = false
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showForm = false
                }
                try? await Task.sleep(nanoseconds: 350_000_000)
                authenticatedUsername = username
                showWelcome = true
            } catch {
                isLoading = false
                withAnimation {
                    errorMessage = (error as? AccountError)?.errorDescription ?? error.localizedDescription
                }
            }
        }
    }

    private func clearForm() {
        email = ""
        password = ""
        username = ""
        errorMessage = nil
        isLoading = false
    }

    // MARK: - 隐私提示（iPhone 风格）

    private var privacyNotice: some View {
        HStack(spacing: 4) {
            Text("继续即表示你同意")
                .foregroundColor(Color.white.opacity(0.3))
            Button {
                privacySheetType = .policy
                showPrivacySheet = true
            } label: {
                Text("《隐私政策》")
                    .foregroundColor(Color(hex: "#A78BFA"))
            }
            .buttonStyle(.plain)
            Text("和")
                .foregroundColor(Color.white.opacity(0.3))
            Button {
                privacySheetType = .terms
                showPrivacySheet = true
            } label: {
                Text("《用户协议》")
                    .foregroundColor(Color(hex: "#A78BFA"))
            }
            .buttonStyle(.plain)
        }
        .font(.system(size: 12))
        .padding(.horizontal, 40)
    }
}

// MARK: - 激活页专用输入框（高级暗色风格）

struct ActivationTextField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String = ""

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 14) {
            if !icon.isEmpty {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isFocused ? Color(hex: "#A78BFA") : Color.white.opacity(0.35))
                    .frame(width: 22)
            }

            TextField(placeholder, text: $text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .tint(Color(hex: "#A78BFA"))
                .focused($isFocused)
                .textFieldStyle(.plain)
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(
                    isFocused ? Color(hex: "#A78BFA").opacity(0.6) : Color.white.opacity(0.1),
                    lineWidth: isFocused ? 1.5 : 1
                )
        )
        .shadow(
            color: isFocused ? Color(hex: "#A78BFA").opacity(0.2) : .clear,
            radius: 12,
            y: 0
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

struct ActivationSecureField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String = ""

    @FocusState private var isFocused: Bool
    @State private var isVisible = false

    var body: some View {
        HStack(spacing: 14) {
            if !icon.isEmpty {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isFocused ? Color(hex: "#A78BFA") : Color.white.opacity(0.35))
                    .frame(width: 22)
            }

            Group {
                if isVisible {
                    TextField(placeholder, text: $text)
                } else {
                    SecureField(placeholder, text: $text)
                }
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.white)
            .tint(Color(hex: "#A78BFA"))
            .focused($isFocused)
            .textFieldStyle(.plain)

            Button {
                isVisible.toggle()
            } label: {
                Image(systemName: isVisible ? "eye.slash.fill" : "eye.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.white.opacity(isVisible ? 0.7 : 0.35))
            }
            .buttonStyle(.plain)
            .frame(width: 32)
        }
        .padding(.leading, 16)
        .padding(.trailing, 6)
        .frame(height: 52)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(
                    isFocused ? Color(hex: "#A78BFA").opacity(0.6) : Color.white.opacity(0.1),
                    lineWidth: isFocused ? 1.5 : 1
                )
        )
        .shadow(
            color: isFocused ? Color(hex: "#A78BFA").opacity(0.2) : .clear,
            radius: 12,
            y: 0
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// MARK: - 粒子动画（保持不变）

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

// MARK: - 隐私弹窗

enum PrivacySheetType {
    case policy, terms

    var title: String {
        switch self {
        case .policy: return "隐私政策"
        case .terms:  return "用户协议"
        }
    }

    var content: String {
        switch self {
        case .policy:
            return """
            隐私政策

            最后更新日期：2026年7月10日

            温柔点（GentleCompanion）重视你的隐私。

            一、我们收集的信息
            • 账户信息：当你注册账户时，我们收集你提供的用户名和联系方式。
            • 使用数据：为改善服务体验，我们收集匿名化的使用统计数据。
            • 位置信息：仅在获取天气信息时使用，不会存储精确位置。

            二、信息的使用
            你的信息仅用于：
            • 提供和维护服务功能
            • 改善用户体验
            • 与你沟通重要更新

            三、信息的存储与安全
            我们采用行业标准的安全措施保护你的数据，数据仅在必要的期限内保存。

            四、你的权利
            你可以随时查看、修改或删除你的账户信息。
            如需行使这些权利，请通过应用内设置与我们联系。

            五、儿童隐私
            本服务不面向13岁以下儿童。

            如有任何疑问，请通过应用内反馈渠道联系我们。
            """

        case .terms:
            return """
            用户协议

            最后更新日期：2026年7月10日

            欢迎使用温柔点（GentleCompanion）。

            一、服务说明
            温柔点是一款情感陪伴应用，提供心情记录、效率工具和社交功能。
            使用本应用即表示你同意遵守本协议。

            二、账户管理
            你需对账户下的所有活动负责。
            请妥善保管登录凭据，不得将账户转让给他人使用。

            三、使用规范
            你同意不会：
            • 发布违法、侵权或骚扰性内容
            • 干扰或破坏服务的正常运行
            • 利用服务进行任何非法活动

            四、知识产权
            应用内的设计、代码、品牌标识均归温柔点所有。
            未经授权不得复制、修改或分发。

            五、免责声明
            本应用按"现状"提供，我们不对服务的可用性、准确性做任何明示或暗示保证。

            六、协议变更
            我们可能会不时更新本协议，重大变更将通过应用内通知告知。

            如继续使用本服务，即视为同意修改后的协议。
            """
        }
    }
}

struct PrivacySheetView: View {
    let type: PrivacySheetType
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Text(type.title)
                    .font(.system(size: 18, weight: .semibold))
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 12)

            Divider()

            // 内容
            ScrollView {
                Text(type.content)
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
                    .lineSpacing(6)
                    .padding(20)
            }
        }
        .frame(width: 520, height: 500)
        .background(Color(hex: "#F5F0FF").opacity(0.98))
    }
}

// MARK: - Welcome Presentation (platform-compatible)

struct WelcomePresentationModifier: ViewModifier {
    @Binding var isPresented: Bool
    let username: String
    let onDismiss: () -> Void

    func body(content: Content) -> some View {
        #if os(iOS)
        content.fullScreenCover(isPresented: $isPresented) {
            WelcomeView(username: username, onStart: onDismiss)
        }
        #else
        content.sheet(isPresented: $isPresented) {
            WelcomeView(username: username, onStart: onDismiss)
                .frame(width: 560, height: 500)
        }
        #endif
    }
}
