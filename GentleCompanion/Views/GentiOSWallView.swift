//
//  GentiOSWallView.swift
//  GentleCompanion iOS
//
//  温柔墙 — Liquid Glass 卡片 + 漂浮粒子
//

import SwiftUI

struct GentiOSWallView: View {
    @StateObject private var wall = GentleWallManager.shared
    @StateObject private var account = AccountManager.shared
    @ObservedObject private var themeManager = GentleThemeManager.shared
    @State private var showComposer = false
    @State private var newMessage = ""
    @State private var selectedEmotion = "温暖"
    @State private var appear = false
    @State private var floatingOffsets: [UUID: CGPoint] = [:]

    private let emotions = ["温暖", "鼓励", "希望", "感恩", "坚强", "温柔"]

    var body: some View {
        ZStack {
            Gentle.Glass.darkBase.ignoresSafeArea()

            // 漂浮背景粒子
            ForEach(wall.messages.prefix(6)) { msg in
                let emoji = ["🌸","💜","✨","🌙","💫","🫧"]
                Text(emoji.randomElement()!)
                    .font(.system(size: CGFloat.random(in: 20...36)))
                    .opacity(0.06)
                    .position(
                        x: floatingOffsets[msg.id]?.x ?? CGFloat.random(in: 50...UIScreen.main.bounds.width - 50),
                        y: floatingOffsets[msg.id]?.y ?? CGFloat.random(in: 100...UIScreen.main.bounds.height - 200)
                    )
                    .animation(.easeInOut(duration: Double.random(in: 6...12)).repeatForever(), value: floatingOffsets[msg.id]?.x)
            }

            ScrollView {
                VStack(spacing: 0) {
                    headerBar

                    if wall.messages.isEmpty {
                        emptyState
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(Array(wall.messages.enumerated()), id: \.element.id) { idx, msg in
                                wallCard(msg)
                                    .opacity(appear ? 1 : 0)
                                    .offset(y: appear ? 0 : 16)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        Spacer().frame(height: 8)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showComposer) { wallComposer }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { appear = true }
            startFloating()
        }
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("温柔墙")
                    .font(.system(size: 28, weight: .thin, design: .serif))
                    .foregroundColor(Gentle.Glass.textPrimary)
                Text("\(wall.messages.count) 条温柔留言")
                    .font(.system(size: 13, weight: .light))
                    .foregroundColor(Gentle.Glass.textTertiary)
            }
            Spacer()
            Button { showComposer = true } label: {
                Label("写下温柔", systemImage: "heart.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Gentle.Glass.textPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "#EC4899").opacity(0.25), Color(hex: "#F472B6").opacity(0.15)],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                    )
                    .overlay {
                        Capsule()
                            .stroke(Gentle.Glass.borderHighlight, lineWidth: 0.5)
                    }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    // MARK: - Empty

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "#EC4899").opacity(0.12), .clear],
                            center: .center, startRadius: 20, endRadius: 90
                        )
                    )
                    .frame(width: 160, height: 160)
                Text("💌").font(.system(size: 50))
            }
            VStack(spacing: 6) {
                Text("温柔墙在等待第一句话")
                    .font(.system(size: 18, weight: .thin, design: .serif))
                    .foregroundColor(Gentle.Glass.textPrimary)
                Text("留下你的温柔，温暖每一个路过的人")
                    .font(.system(size: 13, weight: .light))
                    .foregroundColor(Gentle.Glass.textTertiary)
            }
            Button { showComposer = true } label: {
                Label("写下第一条温柔", systemImage: "pencil")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Gentle.Glass.textPrimary)
                    .padding(.horizontal, 24).padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "#EC4899").opacity(0.3), Color(hex: "#F472B6").opacity(0.2)],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                    )
                    .overlay {
                        Capsule().stroke(.white.opacity(0.12), lineWidth: 0.5)
                    }
            }
            Spacer()
        }
        .padding()
    }

    // MARK: - Wall Card

    private func wallCard(_ message: GentleWallMessage) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#FCD34D").opacity(0.3), Color(hex: "#FB923C").opacity(0.12)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 30, height: 30)
                        .overlay { Circle().stroke(.white.opacity(0.08), lineWidth: 0.5) }
                    Text("🫧").font(.system(size: 13))
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text("匿名温柔者")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Gentle.Glass.textSecondary)
                    Text(message.timeAgo)
                        .font(.system(size: 10))
                        .foregroundColor(Gentle.Glass.textTertiary)
                }
                Spacer()
                Text(message.emotion)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color(hex: "#FCD34D"))
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(Color(hex: "#FCD34D").opacity(0.1))
                            .overlay(Capsule().stroke(Color(hex: "#FCD34D").opacity(0.2), lineWidth: 0.5))
                    )
            }

            Text(message.content)
                .font(.system(size: 14, weight: .light, design: .serif))
                .foregroundColor(Gentle.Glass.textPrimary)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        wall.likeMessage(message)
                    }
                } label: {
                    Label("温柔 \(message.likes)", systemImage: "heart.fill")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: "#F472B6").opacity(message.likes > 0 ? 0.7 : 0.3))
                        .padding(.horizontal, 12).padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(Color(hex: "#F472B6").opacity(0.06))
                                .overlay(Capsule().stroke(Color(hex: "#F472B6").opacity(0.12), lineWidth: 0.5))
                        )
                }
            }
        }
        .padding(16)
        .liquidGlassCard(cornerRadius: GentleRadius.xl, opacity: 0.5)
    }

    // MARK: - Composer

    private var wallComposer: some View {
        NavigationStack {
            ZStack {
                Gentle.Glass.darkBase.ignoresSafeArea()

                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("情绪标签").font(.system(size: 12)).foregroundColor(Gentle.Glass.textTertiary)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(emotions, id: \.self) { e in
                                    Button {
                                        withAnimation(.spring(response: 0.3)) { selectedEmotion = e }
                                    } label: {
                                        Text(e)
                                            .font(.system(size: 12, weight: selectedEmotion == e ? .semibold : .regular))
                                            .foregroundColor(selectedEmotion == e ? Gentle.Glass.textPrimary : Gentle.Glass.textTertiary)
                                            .padding(.horizontal, 12).padding(.vertical, 6)
                                            .background(
                                                Capsule()
                                                    .fill(selectedEmotion == e ? Color(hex: "#EC4899").opacity(0.2) : .white.opacity(0.05))
                                                    .overlay(
                                                        Capsule()
                                                            .stroke(
                                                                selectedEmotion == e ? Color(hex: "#EC4899").opacity(0.3) : Gentle.Glass.borderWhite,
                                                                lineWidth: 0.5
                                                            )
                                                    )
                                            )
                                    }
                                }
                            }
                        }
                    }

                    TextEditor(text: $newMessage)
                        .font(.system(size: 15, weight: .light, design: .serif))
                        .foregroundColor(Gentle.Glass.textPrimary)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 160)
                        .padding(14)
                        .liquidGlassCard(cornerRadius: GentleRadius.lg, opacity: 0.4)
                        .overlay(alignment: .topLeading) {
                            if newMessage.isEmpty {
                                Text("在这里写下温柔的话...\n它会出现在温柔墙上 🌸")
                                    .font(.system(size: 15, weight: .light))
                                    .foregroundColor(Gentle.Glass.textTertiary)
                                    .padding(.horizontal, 18).padding(.vertical, 20)
                                    .allowsHitTesting(false)
                            }
                        }

                    Text("💡 所有的留言都是匿名的，你的温柔会被看见，但不会被认出")
                        .font(.system(size: 11))
                        .foregroundColor(Gentle.Glass.textTertiary)
                        .multilineTextAlignment(.center)

                    Spacer()

                    Button {
                        wall.postMessage(content: newMessage, emotion: selectedEmotion)
                        newMessage = ""
                        showComposer = false
                    } label: {
                        Label("贴在温柔墙上", systemImage: "heart.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Gentle.Glass.textPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                                ? [Color(hex: "#EC4899").opacity(0.2), Color(hex: "#F472B6").opacity(0.15)]
                                                : [Color(hex: "#EC4899"), Color(hex: "#F472B6")],
                                            startPoint: .leading, endPoint: .trailing
                                        )
                                    )
                            }
                            .shadow(
                                color: Color(hex: "#EC4899").opacity(
                                    newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0 : 0.35
                                ),
                                radius: 14, x: 0, y: 7
                            )
                    }
                    .disabled(newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .navigationTitle("写下温柔")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("取消") { showComposer = false }.foregroundColor(Color(hex: "#EC4899"))
                }
            }
        }
    }

    // MARK: - Floating

    private func startFloating() {
        for msg in wall.messages.prefix(6) {
            floatingOffsets[msg.id] = CGPoint(
                x: CGFloat.random(in: 50...UIScreen.main.bounds.width - 50),
                y: CGFloat.random(in: 100...UIScreen.main.bounds.height - 200)
            )
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0...2)) {
                withAnimation(.easeInOut(duration: Double.random(in: 6...12)).repeatForever()) {
                    floatingOffsets[msg.id] = CGPoint(
                        x: CGFloat.random(in: 50...UIScreen.main.bounds.width - 50),
                        y: CGFloat.random(in: 100...UIScreen.main.bounds.height - 200)
                    )
                }
            }
        }
    }
}
