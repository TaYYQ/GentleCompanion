//
//  AccountView.swift
//  GentleCompanion
//
//  全新设计的登录界面
//

import SwiftUI
import AuthenticationServices

struct AccountView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var manager = AccountManager.shared
    
    var initialMode: AccountMode = .login
    var onLoginSuccess: (() -> Void)?
    var onRegisterSuccess: (() -> Void)?

    @State private var mode: AccountMode = .login
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var confirm = ""
    @State private var rememberMe = true
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showDeleteConfirm = false
    @State private var pendingDeleteAccount: Account?
    
    @State private var hoveredSocialButton: String?
    @State private var hoveredField: String?
    @State private var breathPhase: Double = 0
    @State private var particles: [Particle] = (0..<20).map { _ in Particle() }
    @State private var dragOffset = CGSize.zero
    @State private var isClosing = false
    
    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat = .random(in: 0...1)
        var y: CGFloat = .random(in: 0...1)
        var size: CGFloat = .random(in: 2...8)
        var opacity: Double = .random(in: 0.1...0.4)
        var duration: Double = .random(in: 10...20)
        var offset: Double = .random(in: 0...(Double.pi * 2))
    }

    enum AccountMode {
        case login, register, switchAccount, main, accountChoice
    }

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            
            animatedParticles
            
            contentView
        }
        .frame(width: 1180, height: 800)
        .overlay(alignment: .topTrailing) {
            if mode == .login || mode == .register {
                closeButton
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                breathPhase = 1
            }
            if manager.isLoggedIn {
                mode = .accountChoice
            } else if initialMode != .login {
                mode = initialMode
            }
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(hex: "#FAF5FF"),
                Color(hex: "#F3E8FF"),
                Color(hex: "#EEF2FF"),
                Color(hex: "#F5F0FF")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var animatedParticles: some View {
        GeometryReader { geo in
            ZStack {
                // 大装饰圆
                Circle()
                    .fill(Gentle.Primary.lavender.opacity(0.08))
                    .frame(width: 400, height: 400)
                    .offset(x: -180, y: -150)
                    .scaleEffect(1 + breathPhase * 0.05)
                
                Circle()
                    .fill(Gentle.Primary.pink.opacity(0.06))
                    .frame(width: 300, height: 300)
                    .offset(x: 250, y: 80)
                    .scaleEffect(1 + (1 - breathPhase) * 0.06)
                
                Circle()
                    .fill(Gentle.Primary.indigo.opacity(0.05))
                    .frame(width: 250, height: 250)
                    .offset(x: -80, y: 280)
                    .scaleEffect(1 + breathPhase * 0.04)
                
                // 小粒子
                ForEach(particles) { particle in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Gentle.Primary.lavender.opacity(particle.opacity), .clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: particle.size * 2
                            )
                        )
                        .frame(width: particle.size * 4, height: particle.size * 4)
                        .blur(radius: particle.size)
                        .position(
                            x: geo.size.width * particle.x + sin(breathPhase / particle.duration * Double.pi * 2 + particle.offset) * 30,
                            y: geo.size.height * particle.y + cos(breathPhase / particle.duration * Double.pi * 2 + particle.offset) * 30
                        )
                        .opacity(particle.opacity * (0.5 + sin(breathPhase / particle.duration * Double.pi * 2 + particle.offset) * 0.5))
                }
            }
        }
    }
    
    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: 40, height: 40)
                    .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
                
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Gentle.Text.secondary)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(GentleSpacing.lg)
    }

    @ViewBuilder
    private var contentView: some View {
        switch mode {
        case .login, .register:
            authView
        case .switchAccount:
            switchAccountView
        case .main:
            accountManagementView
        case .accountChoice:
            accountChoiceView
        }
    }

    private var authView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                headerSection
                    .padding(.top, GentleSpacing.xl)
                
                modeToggleSection
                    .padding(.top, GentleSpacing.lg)
                
                formSection
                    .padding(.top, GentleSpacing.lg)
                
                rememberMeSection
                    .padding(.top, GentleSpacing.sm)
                
                errorSection
                    .padding(.top, GentleSpacing.sm)
                
                submitButtonSection
                    .padding(.top, GentleSpacing.md)
                
                bottomHintSection
                    .padding(.top, GentleSpacing.lg)
                    .padding(.bottom, GentleSpacing.xxl)
            }
        }
        .padding(.horizontal, GentleSpacing.xxl)
        .padding(.top, GentleSpacing.xxl)
        .offset(x: dragOffset.width * 0.3, y: dragOffset.height * 0.3)
        .scaleEffect(isClosing ? 0.95 : 1.0)
        .rotationEffect(.degrees(isClosing ? -5 : 0))
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { value in
                    if value.translation.height > 150 {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            isClosing = true
                            dragOffset.height = 300
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            dismiss()
                        }
                    } else if value.translation.width > 80 && mode == .register {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            mode = .login
                        }
                    } else if value.translation.width < -80 && mode == .login {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            mode = .register
                        }
                    }
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                        dragOffset = .zero
                        isClosing = false
                    }
                }
        )
    }

    private var headerSection: some View {
        VStack(spacing: GentleSpacing.xl) {
            ZStack {
                // 多层光晕
                Circle()
                    .fill(Gentle.Primary.lavender.opacity(0.15))
                    .frame(width: 140, height: 140)
                    .scaleEffect(1 + breathPhase * 0.06)
                    .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: breathPhase)
                
                Circle()
                    .fill(Gentle.Primary.pink.opacity(0.1))
                    .frame(width: 180, height: 180)
                    .scaleEffect(1 + (1 - breathPhase) * 0.05)
                    .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: breathPhase)
                
                Circle()
                    .fill(Gentle.Primary.lavender.opacity(0.06))
                    .frame(width: 220, height: 220)
                    .scaleEffect(1 + breathPhase * 0.04)
                    .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: breathPhase)
                
                // 主图标
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Gentle.Primary.lavender, Gentle.Primary.purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 90, height: 90)
                        .shadow(color: Gentle.Primary.lavender.opacity(0.4), radius: 25, x: 0, y: 10)
                    
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.white.opacity(0.4), .clear],
                                center: .topLeading,
                                startRadius: 0,
                                endRadius: 30
                            )
                        )
                        .frame(width: 90, height: 90)
                    
                    Text("🌸")
                        .font(.system(size: 44))
                }
            }
            
            VStack(spacing: GentleSpacing.sm) {
                Text(mode == .login ? "欢迎回来" : "开启新篇章")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(Gentle.Text.primary)
                    .shadow(color: Gentle.Primary.lavender.opacity(0.1), radius: 15, y: 3)
                
                Text(mode == .login ? "继续你的情绪旅程" : "在这里记录你的心情")
                    .font(.system(size: 15))
                    .foregroundColor(Gentle.Text.secondary)
            }
        }
    }

    private var modeToggleSection: some View {
        HStack(spacing: 0) {
            toggleButton("登录", isActive: mode == .login) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    mode = .login
                    errorMessage = nil
                }
            }
            toggleButton("注册", isActive: mode == .register) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    mode = .register
                    errorMessage = nil
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: GentleRadius.xxl, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 60)
    }

    private func toggleButton(_ title: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: isActive ? .bold : .medium))
                .foregroundColor(isActive ? .white : Gentle.Text.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, GentleSpacing.lg)
                .background(
                    RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                        .fill(isActive ? Gentle.Primary.lavender : Color.clear)
                )
                .shadow(
                    color: isActive ? Gentle.Primary.lavender.opacity(0.35) : Color.clear,
                    radius: isActive ? 12 : 0,
                    x: 0,
                    y: isActive ? 6 : 0
                )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isActive ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isActive)
    }

    private var formSection: some View {
        VStack(spacing: GentleSpacing.lg) {
            if mode == .register {
                inputField(
                    text: $username,
                    placeholder: "给自己起个昵称",
                    icon: "smiley.fill",
                    fieldId: "username"
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            inputField(
                text: $email,
                placeholder: "邮箱地址",
                icon: "mail.fill",
                fieldId: "email"
            )

            secureField(
                text: $password,
                placeholder: "密码",
                icon: "lock.fill",
                fieldId: "password"
            )

            if mode == .register {
                secureField(
                    text: $confirm,
                    placeholder: "确认密码",
                    icon: "lock.shield.fill",
                    fieldId: "confirm"
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: mode)
    }

    private func inputField(
        text: Binding<String>,
        placeholder: String,
        icon: String,
        fieldId: String
    ) -> some View {
        let isHovered = hoveredField == fieldId
        let hasContent = !text.wrappedValue.isEmpty
        
        return HStack(spacing: GentleSpacing.lg) {
            ZStack {
                Circle()
                    .fill(hasContent || isHovered ? Gentle.Primary.lavender : Color.white)
                    .frame(width: 44, height: 44)
                    .shadow(
                        color: hasContent || isHovered ? Gentle.Primary.lavender.opacity(0.35) : Color.black.opacity(0.05),
                        radius: hasContent || isHovered ? 10 : 6,
                        y: hasContent || isHovered ? 4 : 2
                    )
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(hasContent || isHovered ? .white : Gentle.Primary.lavender)
            }
            
            TextField(text: text) {
                Text(placeholder)
                    .font(.system(size: 15))
                    .foregroundColor(Gentle.Text.tertiary)
            }
            .font(.system(size: 16))
            .foregroundColor(Gentle.Text.primary)
            .textFieldStyle(.plain)
            
            Spacer()
            
            if hasContent {
                Button {
                    text.wrappedValue = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Gentle.Text.tertiary)
                }
                .buttonStyle(PlainButtonStyle())
                .transition(.opacity)
            }
        }
        .padding(.horizontal, GentleSpacing.xl)
        .padding(.vertical, GentleSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: GentleRadius.xxl, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: GentleRadius.xxl, style: .continuous)
                        .stroke(
                            hasContent || isHovered ? Gentle.Primary.lavender.opacity(0.5) : Gentle.Text.tertiary.opacity(0.1),
                            lineWidth: hasContent || isHovered ? 2 : 1
                        )
                )
        )
        .shadow(
            color: hasContent || isHovered ? Gentle.Primary.lavender.opacity(0.18) : Color.black.opacity(0.03),
            radius: hasContent || isHovered ? GentleShadow.lg.radius : GentleShadow.sm.radius,
            x: 0,
            y: hasContent || isHovered ? GentleShadow.lg.y : GentleShadow.sm.y
        )
        .scaleEffect(isHovered ? 1.015 : 1.0)
        .onHover { hovering in
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                hoveredField = hovering ? fieldId : nil
            }
        }
    }

    private func secureField(
        text: Binding<String>,
        placeholder: String,
        icon: String,
        fieldId: String
    ) -> some View {
        let isHovered = hoveredField == fieldId
        let hasContent = !text.wrappedValue.isEmpty
        
        return HStack(spacing: GentleSpacing.lg) {
            ZStack {
                Circle()
                    .fill(hasContent || isHovered ? Gentle.Primary.lavender : Color.white)
                    .frame(width: 44, height: 44)
                    .shadow(
                        color: hasContent || isHovered ? Gentle.Primary.lavender.opacity(0.35) : Color.black.opacity(0.05),
                        radius: hasContent || isHovered ? 10 : 6,
                        y: hasContent || isHovered ? 4 : 2
                    )
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(hasContent || isHovered ? .white : Gentle.Primary.lavender)
            }
            
            SecureField(text: text) {
                Text(placeholder)
                    .font(.system(size: 15))
                    .foregroundColor(Gentle.Text.tertiary)
            }
            .font(.system(size: 16))
            .foregroundColor(Gentle.Text.primary)
            .textFieldStyle(.plain)
            
            Spacer()
            
            if hasContent {
                Button {
                    text.wrappedValue = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Gentle.Text.tertiary)
                }
                .buttonStyle(PlainButtonStyle())
                .transition(.opacity)
            }
        }
        .padding(.horizontal, GentleSpacing.xl)
        .padding(.vertical, GentleSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: GentleRadius.xxl, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: GentleRadius.xxl, style: .continuous)
                        .stroke(
                            hasContent || isHovered ? Gentle.Primary.lavender.opacity(0.5) : Gentle.Text.tertiary.opacity(0.1),
                            lineWidth: hasContent || isHovered ? 2 : 1
                        )
                )
        )
        .shadow(
            color: hasContent || isHovered ? Gentle.Primary.lavender.opacity(0.18) : Color.black.opacity(0.03),
            radius: hasContent || isHovered ? GentleShadow.lg.radius : GentleShadow.sm.radius,
            x: 0,
            y: hasContent || isHovered ? GentleShadow.lg.y : GentleShadow.sm.y
        )
        .scaleEffect(isHovered ? 1.015 : 1.0)
        .onHover { hovering in
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                hoveredField = hovering ? fieldId : nil
            }
        }
    }

    private var rememberMeSection: some View {
        HStack(spacing: GentleSpacing.md) {
            Button {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                    rememberMe.toggle()
                }
            } label: {
                HStack(spacing: GentleSpacing.sm) {
                    ZStack {
                        RoundedRectangle(cornerRadius: GentleRadius.sm)
                            .stroke(rememberMe ? Gentle.Primary.lavender : Gentle.Text.tertiary.opacity(0.3), lineWidth: 2)
                            .frame(width: 22, height: 22)
                        
                        if rememberMe {
                            RoundedRectangle(cornerRadius: GentleRadius.sm)
                                .fill(Gentle.Primary.lavender)
                                .frame(width: 22, height: 22)
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                )
                        }
                    }
                    
                    Text("记住我")
                        .font(.system(size: 14))
                        .foregroundColor(rememberMe ? Gentle.Text.primary : Gentle.Text.secondary)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            Button {
                // 忘记密码逻辑
            } label: {
                Text("忘记密码？")
                    .font(.system(size: 14))
                    .foregroundColor(Gentle.Primary.lavender)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .opacity(mode == .login ? 1 : 0.5)
        .disabled(mode != .login)
    }

    @ViewBuilder
    private var errorSection: some View {
        if let error = errorMessage {
            HStack(spacing: GentleSpacing.sm) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Gentle.State.error)
                
                Text(error)
                    .font(.system(size: 14))
                    .foregroundColor(Gentle.State.error)
            }
            .padding(.horizontal, GentleSpacing.xl)
            .padding(.vertical, GentleSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                    .fill(Gentle.State.error.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                            .stroke(Gentle.State.error.opacity(0.3), lineWidth: 1)
                    )
            )
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
        }
    }

    private var submitButtonSection: some View {
        Button(action: submit) {
            HStack(spacing: GentleSpacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(width: 20, height: 20)
                } else {
                    Image(systemName: mode == .login ? "arrow.right" : "sparkles")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text(formIsValid ? (mode == .login ? "登录" : "注册") : "请填写完整信息")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, GentleSpacing.xl)
            .background(
                RoundedRectangle(cornerRadius: GentleRadius.xxl, style: .continuous)
                    .fill(formIsValid ? Gentle.Primary.lavender : Gentle.Background.tertiary)
            )
            .shadow(
                color: formIsValid ? Gentle.Primary.lavender.opacity(0.4) : Color.clear,
                radius: formIsValid ? GentleShadow.lg.radius : 0,
                x: 0,
                y: formIsValid ? GentleShadow.lg.y : 0
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isLoading || !formIsValid)
        .scaleEffect(isLoading || !formIsValid ? 1.0 : 1.02)
    }

    private var dividerSection: some View {
        HStack(spacing: GentleSpacing.md) {
            Rectangle()
                .fill(Gentle.Text.tertiary.opacity(0.15))
                .frame(height: 1)
                .frame(maxWidth: .infinity)
            
            Text("或")
                .font(.system(size: 13))
                .foregroundColor(Gentle.Text.tertiary)
                .padding(.horizontal, GentleSpacing.lg)
            
            Rectangle()
                .fill(Gentle.Text.tertiary.opacity(0.15))
                .frame(height: 1)
                .frame(maxWidth: .infinity)
        }
    }

    private var socialLoginSection: some View {
        HStack(spacing: GentleSpacing.xl) {
            socialButton(icon: "applelogo", label: "Apple", id: "apple") {
                handleAppleLogin()
            }
            socialButton(icon: "g.circle.fill", label: "Google", id: "google") {
                handleGoogleLogin()
            }
            socialButton(icon: "message.fill", label: "微信", id: "wechat") {
                handleWeChatLogin()
            }
        }
    }

    private func socialButton(icon: String, label: String, id: String, action: @escaping () -> Void) -> some View {
        let isHovered = hoveredSocialButton == id
        
        return Button(action: action) {
            VStack(spacing: GentleSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 56, height: 56)
                        .overlay(
                            Circle()
                                .stroke(isHovered ? Gentle.Primary.lavender.opacity(0.4) : Gentle.Text.tertiary.opacity(0.15), lineWidth: 1.5)
                        )
                        .shadow(
                            color: isHovered ? Gentle.Primary.lavender.opacity(0.25) : Color.black.opacity(0.04),
                            radius: isHovered ? GentleShadow.md.radius : GentleShadow.sm.radius,
                            x: 0,
                            y: isHovered ? GentleShadow.md.y : GentleShadow.sm.y
                        )
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(isHovered ? Gentle.Primary.lavender : Gentle.Text.secondary)
                }
                .scaleEffect(isHovered ? 1.1 : 1.0)
                
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(Gentle.Text.tertiary)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                hoveredSocialButton = hovering ? id : nil
            }
        }
    }

    private var bottomHintSection: some View {
        HStack(spacing: GentleSpacing.xs) {
            Text(mode == .login ? "还没有体验过？" : "已经有账号了？")
                .font(.system(size: 14))
                .foregroundColor(Gentle.Text.secondary)
            
            Button(mode == .login ? "立即注册" : "立即登录") {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    mode = mode == .login ? .register : .login
                    errorMessage = nil
                }
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(Gentle.Primary.lavender)
        }
    }

    private var formIsValid: Bool {
        if mode == .login {
            let valid = !email.isEmpty && !password.isEmpty
            if valid {
                print("Login form valid: email=\(!email.isEmpty), password=\(!password.isEmpty)")
            }
            return valid
        } else {
            let valid = !username.isEmpty && !email.isEmpty
                && password.count >= 6 && password == confirm
            print("Register form valid: username=\(!username.isEmpty), email=\(!email.isEmpty), passwordLength=\(password.count >= 6), passwordMatch=\(password == confirm)")
            return valid
        }
    }

    private var accountChoiceView: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: GentleSpacing.xl) {
                accountChoiceCard(
                    icon: "person.crop.circle.badge.plus",
                    title: "自定义账户",
                    subtitle: "登录或注册新账号",
                    gradient: Gentle.Gradient.primaryButton,
                    action: { withAnimation { mode = .login } }
                )
                
                accountChoiceCard(
                    icon: "person.3.sequence",
                    title: "管理名下账号",
                    subtitle: "切换或管理已有账号",
                    gradient: LinearGradient(
                        colors: [Gentle.Primary.lavender.opacity(0.9), Gentle.Primary.purple.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    action: { withAnimation { mode = .switchAccount } }
                )
            }
            .padding(.horizontal, GentleSpacing.xxl)

            Spacer()
        }
    }
    
    private func accountChoiceCard(
        icon: String,
        title: String,
        subtitle: String,
        gradient: LinearGradient,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: GentleSpacing.lg) {
                ZStack {
                    Circle()
                        .fill(gradient)
                        .frame(width: 60, height: 60)
                        .shadow(color: Gentle.Primary.lavender.opacity(0.3), radius: 15, x: 0, y: 6)
                    
                    Image(systemName: icon)
                        .font(.system(size: 26))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: GentleSpacing.xs) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Gentle.Text.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(Gentle.Text.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Gentle.Text.tertiary)
            }
            .padding(GentleSpacing.xl)
            .background(
                RoundedRectangle(cornerRadius: GentleRadius.xxl, style: .continuous)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: GentleRadius.xxl, style: .continuous)
                            .stroke(Gentle.Primary.lavender.opacity(0.2), lineWidth: 1)
                    )
            )
            .shadow(
                color: Color.black.opacity(0.04),
                radius: GentleShadow.md.radius,
                x: GentleShadow.md.x,
                y: GentleShadow.md.y
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var switchAccountView: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    withAnimation { mode = .accountChoice }
                } label: {
                    HStack(spacing: GentleSpacing.sm) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("返回")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(Gentle.Text.secondary)
                    .padding(.horizontal, GentleSpacing.md)
                    .padding(.vertical, GentleSpacing.sm)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.8))
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Text("切换账号")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Gentle.Text.primary)
                
                Spacer()
                
                Button("管理") {
                    withAnimation { mode = .main }
                }
                .font(.system(size: 14))
                .foregroundColor(Gentle.Primary.lavender)
            }
            .padding(.horizontal, GentleSpacing.xxl)
            .padding(.vertical, GentleSpacing.lg)

            ScrollView {
                VStack(spacing: GentleSpacing.md) {
                    ForEach(manager.accounts) { account in
                        accountRow(account, isCurrent: account.id == manager.currentAccount?.id) {
                            manager.switchTo(account)
                            dismiss()
                        }
                    }

                    addAccountButton
                }
                .padding(.horizontal, GentleSpacing.xxl)
                .padding(.vertical, GentleSpacing.lg)
            }
        }
    }

    private var addAccountButton: some View {
        Button {
            withAnimation { mode = .login }
        } label: {
            HStack(spacing: GentleSpacing.md) {
                ZStack {
                    Circle()
                        .stroke(Gentle.Primary.lavender.opacity(0.3), lineWidth: 1.5)
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 20))
                        .foregroundColor(Gentle.Primary.lavender)
                }

                Text("添加新账号")
                    .font(.system(size: 15))
                    .foregroundColor(Gentle.Primary.lavender)

                Spacer()
            }
            .padding(GentleSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                    .stroke(Gentle.Primary.lavender.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var accountManagementView: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    withAnimation { mode = .switchAccount }
                } label: {
                    HStack(spacing: GentleSpacing.sm) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("返回")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(Gentle.Text.secondary)
                    .padding(.horizontal, GentleSpacing.md)
                    .padding(.vertical, GentleSpacing.sm)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.8))
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Text("账号管理")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Gentle.Text.primary)
                
                Spacer()
                
                Color.clear.frame(width: 70)
            }
            .padding(.horizontal, GentleSpacing.xxl)
            .padding(.vertical, GentleSpacing.lg)

            ScrollView {
                VStack(spacing: GentleSpacing.md) {
                    ForEach(manager.accounts) { account in
                        managedAccountRow(account)
                    }
                }
                .padding(.horizontal, GentleSpacing.xxl)
                .padding(.vertical, GentleSpacing.lg)
            }
        }
        .sheet(isPresented: $showDeleteConfirm) {
            if let account = pendingDeleteAccount {
                deleteConfirmDialog(account)
            }
        }
    }

    private func accountRow(_ account: Account, isCurrent: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: GentleSpacing.lg) {
                ZStack {
                    Circle()
                        .fill(Gentle.Gradient.primaryButton)
                        .frame(width: 48, height: 48)

                    Text(String(account.username.prefix(1)).uppercased())
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: GentleSpacing.xs) {
                    HStack(spacing: GentleSpacing.sm) {
                        Text(account.username)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Gentle.Text.primary)

                        if isCurrent {
                            Text("当前")
                                .font(.system(size: 11))
                                .foregroundColor(Gentle.Primary.lavender)
                                .padding(.horizontal, GentleSpacing.sm)
                                .padding(.vertical, GentleSpacing.xs)
                                .background(
                                    Capsule()
                                        .fill(Gentle.Primary.lavender.opacity(0.12))
                                )
                        }
                    }

                    Text(account.email)
                        .font(.system(size: 13))
                        .foregroundColor(Gentle.Text.tertiary)
                }

                Spacer()

                Image(systemName: isCurrent ? "checkmark.circle.fill" : "chevron.right")
                    .font(.system(size: 18))
                    .foregroundColor(isCurrent ? Gentle.Primary.lavender : Gentle.Text.tertiary)
            }
            .padding(GentleSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                    .fill(isCurrent ? Gentle.Primary.lavender.opacity(0.06) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                            .stroke(
                                isCurrent ? Gentle.Primary.lavender.opacity(0.3) : Gentle.Text.tertiary.opacity(0.1),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(
                color: Color.black.opacity(0.04),
                radius: GentleShadow.sm.radius,
                x: GentleShadow.sm.x,
                y: GentleShadow.sm.y
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func managedAccountRow(_ account: Account) -> some View {
        HStack(spacing: GentleSpacing.lg) {
            ZStack {
                Circle()
                    .fill(Gentle.Gradient.primaryButton)
                    .frame(width: 52, height: 52)

                Text(String(account.username.prefix(1)).uppercased())
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: GentleSpacing.xs) {
                HStack(spacing: GentleSpacing.sm) {
                    Text(account.username)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Gentle.Text.primary)

                    if account.id == manager.currentAccount?.id {
                        Text("当前")
                            .font(.system(size: 11))
                            .foregroundColor(Gentle.Primary.lavender)
                            .padding(.horizontal, GentleSpacing.sm)
                            .padding(.vertical, GentleSpacing.xs)
                            .background(
                                Capsule()
                                    .fill(Gentle.Primary.lavender.opacity(0.12))
                            )
                    }
                }

                HStack(spacing: GentleSpacing.xs) {
                    Image(systemName: account.provider.iconName)
                        .font(.system(size: 11))
                    Text(account.provider.displayName)
                }
                .font(.system(size: 12))
                .foregroundColor(Gentle.Text.tertiary)

                Text(account.email)
                    .font(.system(size: 13))
                    .foregroundColor(Gentle.Text.tertiary)
            }

            Spacer()

            if manager.accounts.count > 1 {
                Button {
                    pendingDeleteAccount = account
                    showDeleteConfirm = true
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 16))
                        .foregroundColor(Gentle.State.error.opacity(0.5))
                        .padding(.all, GentleSpacing.sm)
                        .background(
                            Circle()
                                .fill(Gentle.State.error.opacity(0.1))
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(GentleSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                .fill(Color.white)
        )
        .shadow(
            color: Color.black.opacity(0.04),
            radius: GentleShadow.sm.radius,
            x: GentleShadow.sm.x,
            y: GentleShadow.sm.y
        )
    }

    private func deleteConfirmDialog(_ account: Account) -> some View {
        VStack(spacing: GentleSpacing.xl) {
            ZStack {
                Circle()
                    .fill(Gentle.State.error.opacity(0.12))
                    .frame(width: 75, height: 75)

                Image(systemName: "heart.slash")
                    .font(.system(size: 32))
                    .foregroundColor(Gentle.State.error)
            }

            VStack(spacing: GentleSpacing.sm) {
                Text("删除账号")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Gentle.Text.primary)

                Text("确定要删除「\(account.username)」吗？\n你的记录会安全地留在本地。")
                    .font(.system(size: 15))
                    .foregroundColor(Gentle.Text.secondary)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: GentleSpacing.lg) {
                Button("取消") {
                    showDeleteConfirm = false
                }
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Gentle.Text.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, GentleSpacing.lg)
                .background(
                    RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                        .fill(Gentle.Background.tertiary)
                )

                Button("删除") {
                    try? manager.deleteAccount(account)
                    showDeleteConfirm = false
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, GentleSpacing.lg)
                .background(
                    RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                        .fill(Gentle.State.error)
                )
            }
        }
        .padding(GentleSpacing.xxl)
        .background(
            RoundedRectangle(cornerRadius: GentleRadius.xxl, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: GentleRadius.xxl, style: .continuous)
                        .stroke(Gentle.Text.tertiary.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(
            color: Color.black.opacity(0.1),
            radius: GentleShadow.lg.radius,
            x: GentleShadow.lg.x,
            y: GentleShadow.lg.y
        )
        .padding(GentleSpacing.xxl)
        .presentationBackground {
            backgroundGradient
                .ignoresSafeArea()
        }
    }

    private func submit() {
        errorMessage = nil

        guard formIsValid else { return }

        if mode == .register && password != confirm {
            errorMessage = "两次密码不一致，请检查"
            return
        }

        isLoading = true

        Task {
            do {
                if mode == .login {
                    _ = try manager.login(email: email, password: password)
                    await MainActor.run {
                        isLoading = false
                        if let cb = onLoginSuccess { cb() } else { dismiss() }
                    }
                } else {
                    _ = try manager.register(username: username, email: email, password: password)
                    print("Registration successful, now auto-login...")
                    _ = try manager.login(email: email, password: password)
                    await MainActor.run {
                        isLoading = false
                        if let cb = onLoginSuccess { cb() } else { dismiss() }
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

    private func handleAppleLogin() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        let delegate = AppleLoginDelegate { result in
            switch result {
            case .success(let credentials):
                performAppleLogin(credentials)
            case .failure(let err):
                Task { @MainActor in errorMessage = err.localizedDescription }
            }
        }
        controller.delegate = delegate
        controller.performRequests()
    }

    private func performAppleLogin(_ credentials: ASAuthorizationAppleIDCredential) {
        do {
            _ = try manager.loginWithApple(
                userID: credentials.user,
                email: credentials.email,
                fullName: credentials.fullName
            )
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func handleGoogleLogin() {
        errorMessage = "Google 登录即将上线"
    }

    private func handleWeChatLogin() {
        errorMessage = "微信登录即将上线"
    }
}

private class AppleLoginDelegate: NSObject, ASAuthorizationControllerDelegate {
    private let onResult: (Result<ASAuthorizationAppleIDCredential, Error>) -> Void

    init(onResult: @escaping (Result<ASAuthorizationAppleIDCredential, Error>) -> Void) {
        self.onResult = onResult
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let credentials = authorization.credential as? ASAuthorizationAppleIDCredential else {
            onResult(.failure(AccountError.invalidCredentials))
            return
        }
        onResult(.success(credentials))
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        onResult(.failure(error))
    }
}