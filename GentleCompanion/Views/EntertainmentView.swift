//
//  EntertainmentView.swift
//  GentleCompanion
//
//  娱乐模式 — 全新沉浸式游戏画廊设计
//

import SwiftUI

// MARK: - 游戏详情数据模型
struct GameDetailInfo {
    let emoji: String
    let title: String
    let subtitle: String
    let category: String
    let gradient: [Color]
    let accentColor: Color
    let tagline: String
    let features: [String]
    
    static func forGame(_ game: GameType) -> GameDetailInfo {
        switch game {
        case .bubblePop:
            return GameDetailInfo(
                emoji: "🫧",
                title: "泡泡解压",
                subtitle: "Bubble Pop",
                category: "解压放松",
                gradient: [Color(hex: "#60A5FA"), Color(hex: "#818CF8"), Color(hex: "#A78BFA")],
                accentColor: Color(hex: "#60A5FA"),
                tagline: "轻触泡泡 · 释放所有压力",
                features: ["无限泡泡模式", "柔和触感反馈", "治愈音效陪伴", "压力指数追踪"]
            )
        case .garden:
            return GameDetailInfo(
                emoji: "🌸",
                title: "花园物语",
                subtitle: "Garden Tale",
                category: "治愈养成",
                gradient: [Color(hex: "#34D399"), Color(hex: "#6EE7B7"), Color(hex: "#A7F3D0")],
                accentColor: Color(hex: "#34D399"),
                tagline: "种下一颗种子 · 收获满园温柔",
                features: ["多种花卉解锁", "每日浇水打卡", "花园图鉴收集", "成长日记记录"]
            )
        case .rhythm:
            return GameDetailInfo(
                emoji: "🎵",
                title: "律动圆环",
                subtitle: "Rhythm Ring",
                category: "节奏冥想",
                gradient: [Color(hex: "#F472B6"), Color(hex: "#C084FC"), Color(hex: "#A78BFA")],
                accentColor: Color(hex: "#F472B6"),
                tagline: "跟随节拍 · 找回内心的节奏",
                features: ["多首舒缓音乐", "自适应难度", "节拍可视化", "专注度评分"]
            )
        }
    }
}

// MARK: - Entertainment View

struct EntertainmentView: View {
    @Binding var isPresented: Bool
    @State private var showMoodQuestion = false
    @State private var showGame: GameType?
    @State private var playDuration: PlayDuration = .free
    @State private var hoveredGame: GameType?
    @State private var appearAnimation = false
    @State private var selectedTab: GameType = .bubblePop
    
    private let info: [GameType: GameDetailInfo] = [
        .bubblePop: .forGame(.bubblePop),
        .garden: .forGame(.garden),
        .rhythm: .forGame(.rhythm)
    ]
    
    var body: some View {
        ZStack {
            // MARK: 多层装饰背景
            ZStack {
                // 基底渐变
                LinearGradient(
                    colors: [
                        Color(hex: "#FAF8FF"),
                        Color(hex: "#F3ECFF"),
                        Color(hex: "#F8F4FF")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // 装饰光斑 - 左上
                Circle()
                    .fill(Gentle.Primary.lavender.opacity(0.06))
                    .frame(width: 260, height: 260)
                    .blur(radius: 50)
                    .offset(x: -160, y: -120)
                
                // 装饰光斑 - 右下
                Circle()
                    .fill(Gentle.Primary.pink.opacity(0.05))
                    .frame(width: 220, height: 220)
                    .blur(radius: 45)
                    .offset(x: 200, y: 180)
                
                // 装饰光斑 - 中右
                Circle()
                    .fill(Gentle.Primary.indigo.opacity(0.04))
                    .frame(width: 160, height: 160)
                    .blur(radius: 40)
                    .offset(x: 280, y: -60)
            }
            .ignoresSafeArea()
            
            // MARK: 主内容
            VStack(spacing: 0) {
                // 顶栏
                topBar
                    .padding(.horizontal, GentleSpacing.xxl)
                    .padding(.top, GentleSpacing.xl)
                
                // 滚动内容
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: GentleSpacing.xxl) {
                        // 心情入口 Banner
                        moodBanner
                        
                        // 游戏标签切换
                        gameTabBar
                        
                        // 当前选中游戏的详情大卡
                        gameDetailCard(for: selectedTab)
                        
                        // 所有游戏快速启动区
                        quickLaunchSection
                        
                        Spacer().frame(height: GentleSpacing.xxl)
                    }
                    .padding(.horizontal, GentleSpacing.xxl)
                }
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 16)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                appearAnimation = true
            }
        }
        .sheet(isPresented: $showMoodQuestion) {
            MoodQuestionView(isPresented: $showMoodQuestion) { game, duration in
                playDuration = duration
                showGame = game
            }
            .frame(minWidth: 970, minHeight: 686)
            .fixedSize()
        }
        .sheet(item: $showGame) { game in
            gameView(for: game)
        }
    }
    
    // MARK: - Top Bar
    
    private var topBar: some View {
        HStack {
            // 返回按钮
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isPresented = false
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(.white)
                        .frame(width: 40, height: 40)
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
                        .overlay(
                            Circle()
                                .stroke(Gentle.Primary.lavender.opacity(0.25), lineWidth: 1)
                        )
                    
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Gentle.Text.primary)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            // 标题区
            VStack(spacing: 2) {
                HStack(spacing: 6) {
                    Text("🎮")
                        .font(.system(size: 20))
                    Text("放松一下")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Gentle.Text.primary)
                }
                Text("选择一个游戏，让心情变好")
                    .font(.system(size: 12))
                    .foregroundColor(Gentle.Text.tertiary)
            }
            
            Spacer()
            
            // 设置按钮（保持对称）
            Button {
                showMoodQuestion = true
            } label: {
                ZStack {
                    Circle()
                        .fill(.white)
                        .frame(width: 40, height: 40)
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
                        .overlay(
                            Circle()
                                .stroke(Gentle.Primary.lavender.opacity(0.25), lineWidth: 1)
                        )
                    
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Gentle.Primary.lavender)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.bottom, GentleSpacing.md)
    }
    
    // MARK: - Mood Banner
    
    private var moodBanner: some View {
        Button {
            showMoodQuestion = true
        } label: {
            HStack(spacing: GentleSpacing.lg) {
                // 左侧图标
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Gentle.Primary.pink, Gentle.Primary.lavender, Gentle.Primary.indigo],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                        .shadow(color: Gentle.Primary.pink.opacity(0.35), radius: 14, x: 0, y: 6)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("不知道玩什么？")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Gentle.Text.primary)
                    
                    Text("告诉我们你的心情，AI 为你推荐最合适的游戏")
                        .font(.system(size: 12))
                        .foregroundColor(Gentle.Text.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text("开始")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.horizontal, GentleSpacing.md)
                .padding(.vertical, GentleSpacing.sm)
                .background(
                    Capsule()
                        .fill(Gentle.Gradient.primaryButton)
                )
                .shadow(color: Gentle.Primary.purple.opacity(0.25), radius: 8, x: 0, y: 4)
            }
            .padding(GentleSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                    .fill(.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Gentle.Primary.lavender.opacity(0.35),
                                Gentle.Primary.pink.opacity(0.15),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Game Tab Bar
    
    private var gameTabBar: some View {
        HStack(spacing: GentleSpacing.xs) {
            ForEach(GameType.allCases) { game in
                let detail = info[game]!
                let isSelected = selectedTab == game
                
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selectedTab = game
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(detail.emoji)
                            .font(.system(size: 16))
                        Text(detail.title)
                            .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
                            .foregroundColor(isSelected ? detail.accentColor : Gentle.Text.secondary)
                    }
                    .padding(.horizontal, GentleSpacing.md)
                    .padding(.vertical, GentleSpacing.sm + 2)
                    .background(
                        Capsule()
                            .fill(isSelected ? detail.accentColor.opacity(0.1) : Color.clear)
                    )
                    .overlay(
                        Capsule()
                            .stroke(
                                isSelected ? detail.accentColor.opacity(0.3) : Color.clear,
                                lineWidth: 1.5
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Spacer()
            
            Text("\(GameType.allCases.count) 个游戏")
                .font(.system(size: 11))
                .foregroundColor(Gentle.Text.tertiary)
        }
    }
    
    // MARK: - Game Detail Card
    
    private func gameDetailCard(for game: GameType) -> some View {
        let detail = info[game]!
        let isHovered = hoveredGame == game
        
        return VStack(spacing: 0) {
            // 顶部大图区
            ZStack(alignment: .bottomLeading) {
                // 渐变背景
                RoundedRectangle(cornerRadius: GentleRadius.xxl, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: detail.gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 180)
                
                // 装饰圆
                Circle()
                    .fill(.white.opacity(0.08))
                    .frame(width: 160, height: 160)
                    .offset(x: 180, y: -40)
                
                Circle()
                    .fill(.white.opacity(0.06))
                    .frame(width: 100, height: 100)
                    .offset(x: -30, y: 40)
                
                // 游戏 emoji
                Text(detail.emoji)
                    .font(.system(size: 80))
                    .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 8)
                    .offset(x: 24, y: -20)
                
                // 左下角信息
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(detail.title)
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(detail.category)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(.white.opacity(0.2))
                            )
                    }
                    
                    Text(detail.tagline)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.leading, 24)
                .padding(.bottom, 20)
            }
            
            // 下半部分：特性列表 + 开始按钮
            HStack(alignment: .bottom, spacing: GentleSpacing.xl) {
                VStack(alignment: .leading, spacing: GentleSpacing.sm) {
                    Text("游戏特色")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Gentle.Text.tertiary)
                        .padding(.top, GentleSpacing.lg)
                    
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: GentleSpacing.sm),
                            GridItem(.flexible(), spacing: GentleSpacing.sm)
                        ],
                        spacing: GentleSpacing.sm
                    ) {
                        ForEach(detail.features, id: \.self) { feature in
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 11))
                                    .foregroundColor(detail.accentColor)
                                Text(feature)
                                    .font(.system(size: 12))
                                    .foregroundColor(Gentle.Text.secondary)
                            }
                            .padding(.horizontal, GentleSpacing.sm)
                            .padding(.vertical, GentleSpacing.xs)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: GentleRadius.sm, style: .continuous)
                                    .fill(detail.accentColor.opacity(0.06))
                            )
                        }
                    }
                }
                
                Spacer()
                
                // 开始按钮
                Button {
                    showGame = game
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 22))
                        Text("开始游戏")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(width: 100, height: 100)
                    .background(
                        RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: detail.gradient,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .shadow(color: detail.accentColor.opacity(0.35), radius: 14, x: 0, y: 6)
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(isHovered ? 1.05 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
            }
            .padding(.horizontal, GentleSpacing.xl)
            .padding(.bottom, GentleSpacing.lg)
        }
        .background(
            RoundedRectangle(cornerRadius: GentleRadius.xxl, style: .continuous)
                .fill(.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: GentleRadius.xxl, style: .continuous)
                .stroke(Gentle.Border.light, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
        .onHover { hovering in
            hoveredGame = hovering ? game : nil
        }
    }
    
    // MARK: - Quick Launch Section
    
    private var quickLaunchSection: some View {
        VStack(spacing: GentleSpacing.md) {
            HStack {
                Text("快速启动")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Gentle.Text.secondary)
                Spacer()
            }
            
            HStack(spacing: GentleSpacing.md) {
                ForEach(GameType.allCases) { game in
                    quickLaunchCard(game)
                }
            }
        }
    }
    
    private func quickLaunchCard(_ game: GameType) -> some View {
        let detail = info[game]!
        let isHovered = hoveredGame == game
        
        return Button {
            showGame = game
        } label: {
            VStack(spacing: GentleSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: detail.gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)
                        .shadow(color: detail.accentColor.opacity(0.3), radius: 10, x: 0, y: 4)
                    
                    Text(detail.emoji)
                        .font(.system(size: 32))
                }
                
                Text(detail.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Gentle.Text.primary)
                
                Text(detail.category)
                    .font(.system(size: 10))
                    .foregroundColor(detail.accentColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(detail.accentColor.opacity(0.1))
                    )
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, GentleSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                    .fill(.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                    .stroke(
                        isHovered ? detail.accentColor.opacity(0.25) : Color.clear,
                        lineWidth: 1.5
                    )
            )
            .shadow(
                color: isHovered ? detail.accentColor.opacity(0.1) : Color.black.opacity(0.04),
                radius: isHovered ? 12 : 6,
                x: 0,
                y: isHovered ? 6 : 2
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isHovered ? 1.03 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isHovered)
        .onHover { hovering in
            hoveredGame = hovering ? game : nil
        }
    }
    
    // MARK: - Game View Router
    
    @ViewBuilder
    private func gameView(for game: GameType) -> some View {
        switch game {
        case .bubblePop:
            BubblePopGame(isPresented: Binding(
                get: { showGame != nil },
                set: { if !$0 { showGame = nil } }
            ), duration: playDuration)
            .frame(width: 970, height: 686)
            .fixedSize()
        case .garden:
            GardenGame(isPresented: Binding(
                get: { showGame != nil },
                set: { if !$0 { showGame = nil } }
            ), duration: playDuration)
            .frame(width: 970, height: 686)
            .fixedSize()
        case .rhythm:
            RhythmGame(isPresented: Binding(
                get: { showGame != nil },
                set: { if !$0 { showGame = nil } }
            ), duration: playDuration)
            .frame(width: 970, height: 686)
            .fixedSize()
        }
    }
}