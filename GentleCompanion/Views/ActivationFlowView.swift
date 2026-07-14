//
//  ActivationFlowView.swift
//  GentleCompanion
//
//  Login entry — Liquid Glass 深色风格
//

import SwiftUI

// MARK: - Activation Flow (Login entry)

struct ActivationFlowView: View {
    let complete: () -> Void

    var body: some View {
        LoginScreen(complete: complete)
    }
}

// MARK: - Login Entry Screen

struct LoginScreen: View {
    @ObservedObject private var themeManager = GentleThemeManager.shared
    let complete: () -> Void

    @State private var opacity: Double = 0
    @State private var offsetY: CGFloat = 20
    @State private var showAuth = false
    @State private var authIsLogin = true
    @State private var showAgreement = false
    @State private var showPrivacy = false

    var body: some View {
        ZStack {
            Gentle.Glass.darkBase.ignoresSafeArea()

            // 背景光晕
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "#8B5CF6").opacity(0.15), .clear],
                        center: .center, startRadius: 20, endRadius: 280
                    )
                )
                .frame(width: 500, height: 500)
                .offset(y: -80)
                .blur(radius: 20)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color(hex: "#A855F7").opacity(0.2), .clear],
                                center: .center, startRadius: 10, endRadius: 70
                            )
                        )
                        .frame(width: 120, height: 120)
                    Text("🌸").font(.system(size: 52))
                }
                .padding(.bottom, 32)

                // Titles
                Text("温柔点")
                    .font(.system(size: 34, weight: .thin, design: .serif))
                    .foregroundColor(Gentle.Glass.textPrimary)
                Text("Gentle Companion")
                    .font(.system(size: 15, weight: .light, design: .serif))
                    .foregroundColor(Gentle.Glass.textSecondary)
                    .padding(.top, 4)
                Text("开启你的情感陪伴之旅")
                    .font(.system(size: 15, weight: .light))
                    .foregroundColor(Gentle.Glass.textTertiary)
                    .padding(.top, 14)

                Spacer()

                // Buttons
                VStack(spacing: 14) {
                    Button {
                        authIsLogin = false
                        showAuth = true
                    } label: {
                        Text("创建账户")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Gentle.Glass.textPrimary)
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
                                    .frame(height: 1).padding(.horizontal, 2)
                            }
                            .shadow(color: Color(hex: "#8B5CF6").opacity(0.4), radius: 14, x: 0, y: 7)
                    }
                    .buttonStyle(.plain)

                    Button {
                        authIsLogin = true
                        showAuth = true
                    } label: {
                        Text("已有账户？登录")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Gentle.Glass.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .liquidGlassCard(cornerRadius: 24, opacity: 0.4)
                            .overlay {
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .stroke(.white.opacity(0.15), lineWidth: 0.8)
                            }
                    }
                    .buttonStyle(.plain)
                }

                // Policy agreement
                HStack(spacing: 4) {
                    Text("继续即表示你同意")
                        .font(.system(size: 11)).foregroundColor(Gentle.Glass.textTertiary)
                    Button("《隐私政策》") { showPrivacy = true }
                        .font(.system(size: 11, weight: .medium)).foregroundColor(Gentle.Glass.textSecondary).buttonStyle(.plain)
                    Text("和").font(.system(size: 11)).foregroundColor(Gentle.Glass.textTertiary)
                    Button("《用户协议》") { showAgreement = true }
                        .font(.system(size: 11, weight: .medium)).foregroundColor(Gentle.Glass.textSecondary).buttonStyle(.plain)
                }
                .padding(.top, 24)

                // Skip
                Button("跳过，随便逛逛") { complete() }
                    .font(.system(size: 13, weight: .light))
                    .foregroundColor(Gentle.Glass.textTertiary)
                    .padding(.top, 16).padding(.bottom, 28)
            }
            .padding(.horizontal, 32)
            .opacity(opacity).offset(y: offsetY)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                opacity = 1
                offsetY = 0
            }
        }
#if os(iOS)
        .fullScreenCover(isPresented: $showAuth) {
            AuthView(isLogin: authIsLogin, onAuthenticated: complete)
        }
#endif
        .sheet(isPresented: $showAgreement) {
            AgreementView(title: "用户协议", content: userAgreementText)
        }
        .sheet(isPresented: $showPrivacy) {
            AgreementView(title: "隐私政策", content: privacyPolicyText)
        }
    }
}
