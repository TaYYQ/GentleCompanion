//
//  AuthView.swift
//  GentleCompanion
//
//  登录 & 注册 — Liquid Glass 深色表单
//

import SwiftUI

// MARK: - AuthView (入口)

struct AuthView: View {
    @ObservedObject private var themeManager = GentleThemeManager.shared
    let initialMode: Bool
    @State private var isLogin: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var confirmPassword = ""

    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showAgreement = false
    @State private var showPrivacy = false
    @State private var showWelcome = false
    @State private var authenticatedUsername = ""

    var onAuthenticated: (() -> Void)?

    init(isLogin: Bool = true, onAuthenticated: (() -> Void)? = nil) {
        self.initialMode = isLogin
        self._isLogin = State(initialValue: isLogin)
        self.onAuthenticated = onAuthenticated
    }

    var body: some View {
        ZStack {
            Gentle.Glass.darkBase.ignoresSafeArea()
            topPurpleGlow

            ScrollView {
                VStack(spacing: 0) {
                    logoSection.padding(.top, 80)
                    titleSection.padding(.top, 28)
                    formSection.padding(.top, 40)
                    submitButton.padding(.top, 28)
                    toggleModeSection.padding(.top, 20)
                    policySection.padding(.top, 32).padding(.bottom, 40)
                }
                .padding(.horizontal, 28)
            }
            .scrollIndicators(.hidden)
        }
        .onAppear { isLogin = initialMode }
        .sheet(isPresented: $showAgreement) {
            AgreementView(title: "用户协议", content: userAgreementText)
        }
        .sheet(isPresented: $showPrivacy) {
            AgreementView(title: "隐私政策", content: privacyPolicyText)
        }
        .modifier(WelcomePresentationModifier(isPresented: $showWelcome, username: authenticatedUsername) {
            showWelcome = false
            onAuthenticated?()
        })
    }

    // MARK: - Background

    private var topPurpleGlow: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [Color(hex: "#8B5CF6").opacity(0.2), Color(hex: "#A855F7").opacity(0.06), .clear],
                    center: .center, startRadius: 10, endRadius: 240
                )
            )
            .frame(width: 440, height: 440)
            .offset(y: -140)
            .blur(radius: 30)
            .ignoresSafeArea()
    }

    // MARK: - Logo

    private var logoSection: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "#A855F7").opacity(0.2), .clear],
                        center: .center, startRadius: 10, endRadius: 60
                    )
                )
                .frame(width: 100, height: 100)
            Text("🌸").font(.system(size: 46))
        }
    }

    // MARK: - Title

    private var titleSection: some View {
        ZStack {
            HelloWatermark().offset(y: 8)
            Text(isLogin ? "登录" : "创建账户")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(Gentle.Glass.textPrimary)
        }
    }

    // MARK: - Form

    private var formSection: some View {
        VStack(spacing: 14) {
            if !isLogin {
                AuthTextField(text: $username, placeholder: "用户名", icon: "person.fill")
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
            AuthTextField(text: $email, placeholder: "邮箱地址", icon: "envelope.fill")
            AuthSecureField(text: $password, placeholder: "密码（至少 6 位）", icon: "lock.fill")
            if !isLogin {
                AuthSecureField(text: $confirmPassword, placeholder: "确认密码", icon: "lock.fill")
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
            if let error = errorMessage {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.circle.fill").font(.system(size: 12))
                    Text(error).font(.system(size: 12))
                }
                .foregroundColor(Color(hex: "#F87171"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4).padding(.top, 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    // MARK: - Submit

    private var submitButton: some View {
        Button(action: submit) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Gentle.Glass.textPrimary))
                        .scaleEffect(0.9)
                } else {
                    Text(isLogin ? "登录" : "创建账户")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Gentle.Glass.textPrimary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#8B5CF6"), Color(hex: "#A855F7")],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
            }
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.white.opacity(0.15))
                    .frame(height: 1)
                    .padding(.horizontal, 2)
            }
            .shadow(color: Color(hex: "#8B5CF6").opacity(0.4), radius: 14, x: 0, y: 7)
        }
        .buttonStyle(.plain)
        .disabled(isLoading || !formIsValid)
        .opacity(formIsValid ? 1 : 0.6)
    }

    // MARK: - Toggle Mode

    private var toggleModeSection: some View {
        HStack(spacing: 4) {
            Text(isLogin ? "没有账户？" : "已有账户？")
                .foregroundColor(Gentle.Glass.textTertiary)
            Button(isLogin ? "注册" : "登录") {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isLogin.toggle()
                    errorMessage = nil
                }
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(Gentle.Glass.textPrimary)
            .buttonStyle(.plain)
        }
        .font(.system(size: 14))
    }

    // MARK: - Policy

    private var policySection: some View {
        HStack(spacing: 4) {
            Text("继续即表示你同意")
                .font(.system(size: 11)).foregroundColor(Gentle.Glass.textTertiary)
            Button("《隐私政策》") { showPrivacy = true }
                .font(.system(size: 11, weight: .medium)).foregroundColor(Gentle.Glass.textSecondary).buttonStyle(.plain)
            Text("和").font(.system(size: 11)).foregroundColor(Gentle.Glass.textTertiary)
            Button("《用户协议》") { showAgreement = true }
                .font(.system(size: 11, weight: .medium)).foregroundColor(Gentle.Glass.textSecondary).buttonStyle(.plain)
        }
        .multilineTextAlignment(.center)
    }

    // MARK: - Validation

    private var formIsValid: Bool {
        if isLogin { return !email.isEmpty && password.count >= 6 }
        else { return !username.isEmpty && !email.isEmpty && password.count >= 6 && password == confirmPassword }
    }

    // MARK: - Submit

    private func submit() {
        errorMessage = nil
        if !isLogin && password != confirmPassword { errorMessage = "两次密码输入不一致"; return }
        if password.count < 6 { errorMessage = "密码至少 6 位"; return }

        isLoading = true
        Task {
            do {
                let response: APIResponse<UserProfile>
                if isLogin {
                    response = try await NetworkService.shared.login(email: email, password: password)
                } else {
                    response = try await NetworkService.shared.register(username: username, email: email, password: password)
                }
                await MainActor.run {
                    isLoading = false
                    if response.success, let user = response.data {
                        saveUser(user)
                        syncLocalAccount(username: user.username, email: user.email)
                        authenticatedUsername = user.username
                        showWelcome = true
                    } else { errorMessage = response.message }
                }
            } catch {
                await localAuth()
            }
        }
    }

    @MainActor
    private func syncLocalAccount(username: String, email: String) {
        do {
            if isLogin {
                _ = try AccountManager.shared.login(email: email, password: password)
            } else {
                _ = try AccountManager.shared.register(username: username, email: email, password: password)
            }
        } catch AccountError.emailAlreadyExists {
            // 账号已存在，尝试登录
            _ = try? AccountManager.shared.login(email: email, password: password)
        } catch {
            // 本地同步失败不影响远程认证结果
        }
    }

    @MainActor
    private func localAuth() {
        do {
            if isLogin {
                _ = try AccountManager.shared.login(email: email, password: password)
            } else {
                _ = try AccountManager.shared.register(username: username, email: email, password: password)
            }
            isLoading = false
            authenticatedUsername = username.isEmpty ? email : username
            showWelcome = true
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    private func saveUser(_ user: UserProfile) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: "current_user")
        }
    }
}

// MARK: - Hello Watermark

private struct HelloWatermark: View {
    private let greetings = ["Hello", "你好", "こんにちは", "Bonjour"]
    @State private var index = 0

    var body: some View {
        ZStack {
            ForEach(greetings.indices, id: \.self) { i in
                Text(greetings[i])
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(Gentle.Glass.textTertiary.opacity(0.16))
                    .opacity(i == index ? 1 : 0)
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { _ in
                Task { @MainActor in
                    withAnimation(.easeInOut(duration: 0.8)) {
                        index = (index + 1) % greetings.count
                    }
                }
            }
        }
    }
}

// MARK: - Auth Text Field

private struct AuthTextField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(Gentle.Glass.textTertiary)
                .frame(width: 22)
            TextField(placeholder, text: $text)
                .font(.system(size: 15))
                .foregroundColor(Gentle.Glass.textPrimary)
                .focused($isFocused)
                .autocorrectionDisabled()
#if os(iOS)
                .textInputAutocapitalization(.never)
#endif
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .liquidGlassCard(cornerRadius: 16, opacity: 0.35)
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isFocused ? Color(hex: "#A855F7").opacity(0.4) : Gentle.Glass.borderWhite, lineWidth: 1)
        }
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// MARK: - Auth Secure Field

private struct AuthSecureField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    @FocusState private var isFocused: Bool
    @State private var isRevealed = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(Gentle.Glass.textTertiary)
                .frame(width: 22)
            Group {
                if isRevealed { TextField(placeholder, text: $text) }
                else { SecureField(placeholder, text: $text) }
            }
            .font(.system(size: 15))
            .foregroundColor(Gentle.Glass.textPrimary)
            .focused($isFocused)
            .autocorrectionDisabled()
#if os(iOS)
            .textInputAutocapitalization(.never)
#endif
            Button(action: { isRevealed.toggle() }) {
                Image(systemName: isRevealed ? "eye.slash.fill" : "eye.fill")
                    .font(.system(size: 14))
                    .foregroundColor(Gentle.Glass.textTertiary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .liquidGlassCard(cornerRadius: 16, opacity: 0.35)
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isFocused ? Color(hex: "#A855F7").opacity(0.4) : Gentle.Glass.borderWhite, lineWidth: 1)
        }
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}
