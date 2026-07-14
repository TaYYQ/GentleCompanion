//
//  WelcomeView.swift
//  GentleCompanion iOS
//
//  注册/登录成功后显示 — 恭喜页 → "开始使用"
//

import SwiftUI

struct WelcomeView: View {
    let username: String
    let onStart: () -> Void

    @State private var appear = false
    @State private var titleScale: CGFloat = 0.6
    @State private var emojiRotation: Double = -15
    @State private var messageOpacity: Double = 0
    @State private var buttonOpacity: Double = 0
    @State private var buttonOffset: CGFloat = 30

    private var displayName: String {
        let trimmed = username.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? "温柔的你" : trimmed
    }

    var body: some View {
        ZStack {
            // 深色背景
            Color(hex: "#080810").ignoresSafeArea()

            // 顶部光晕
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "#A855F7").opacity(0.2),
                            Color(hex: "#EC4899").opacity(0.08),
                            .clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 300
                    )
                )
                .frame(width: 500, height: 500)
                .offset(y: -80)
                .blur(radius: 30)

            // 底部微光
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "#6366F1").opacity(0.1),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 250
                    )
                )
                .frame(width: 400, height: 400)
                .offset(y: 200)
                .blur(radius: 40)

            VStack(spacing: 0) {
                Spacer()

                // Emoji
                Text("🌸")
                    .font(.system(size: 64))
                    .rotationEffect(.degrees(emojiRotation))
                    .shadow(color: Color(hex: "#A855F7").opacity(0.3), radius: 30)

                Spacer().frame(height: 32)

                // 恭喜标题
                VStack(spacing: 8) {
                    Text("恭喜你，\(displayName)")
                        .font(.system(size: 30, weight: .thin, design: .serif))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text("✨")
                        .font(.system(size: 20))
                        .padding(.top, 4)
                }
                .scaleEffect(titleScale)
                .opacity(appear ? 1 : 0)

                Spacer().frame(height: 28)

                // 温柔寄语
                VStack(spacing: 16) {
                    Text("温柔点已为你准备好了一切")
                        .font(.system(size: 17, weight: .light, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))

                    Text("从今天开始，让每一天都被温柔以待")
                        .font(.system(size: 15, weight: .light))
                        .foregroundColor(.white.opacity(0.4))
                }
                .opacity(messageOpacity)

                Spacer()

                // 开始使用按钮
                Button(action: handleStart) {
                    HStack(spacing: 8) {
                        Text("开始使用")
                            .font(.system(size: 17, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
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
                    )
                    .overlay(alignment: .top) {
                        Capsule()
                            .fill(.white.opacity(0.18))
                            .frame(height: 1)
                            .padding(.horizontal, 2)
                    }
                    .shadow(color: Color(hex: "#A855F7").opacity(0.45), radius: 18, y: 8)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 48)
                .opacity(buttonOpacity)
                .offset(y: buttonOffset)
                .scaleEffect(appear ? 1 : 0.95)
                .padding(.bottom, 60)
            }
        }
        .onAppear { startAnimation() }
    }

    private func startAnimation() {
        // 1. Emoji 弹入 + 旋转归位
        withAnimation(.spring(response: 0.7, dampingFraction: 0.55)) {
            appear = true
            emojiRotation = 0
        }

        // 2. 标题从缩放弹入
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
                titleScale = 1.0
            }
        }

        // 3. 寄语淡入
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            withAnimation(.easeOut(duration: 0.6)) {
                messageOpacity = 1.0
            }
        }

        // 4. 按钮从下浮入
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.7)) {
                buttonOpacity = 1.0
                buttonOffset = 0
            }
        }
    }

    private func handleStart() {
        withAnimation(.easeInOut(duration: 0.3)) {
            appear = false
            titleScale = 0.85
            messageOpacity = 0
            buttonOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onStart()
        }
    }
}
