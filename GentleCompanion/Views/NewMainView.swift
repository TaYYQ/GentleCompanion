//
//  NewMainView.swift
//  GentleCompanion
//
//  三模式主界面：娱乐 / 效率 / 社交
//  设置从顶部齿轮图标进入
//

import SwiftUI

// MARK: - Main View

struct NewMainView: View {
    @StateObject private var modeManager = ModeManager.shared
    @StateObject private var theme = GentleThemeManager.shared
    @StateObject private var accountManager = AccountManager.shared
    
    @State private var showSettings = false
    @State private var showAccount = false
    @State private var showModeSwitch = false
    
    var body: some View {
        ZStack {
            // 背景
            modeBackground
            
            VStack(spacing: 0) {
                // 顶部栏（齿轮设置 + 模式切换 + 账号）
                topBar
                    .padding(.horizontal, GentleSpacing.xxl)
                    .padding(.top, GentleSpacing.md)
                
                // 中央胶囊组件
                centralPillComponent
                    .padding(.top, GentleSpacing.lg)
                
                // 模式内容区
                modeContent
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(isPresented: $showSettings)
                .frame(width: 998, height: 686)
                .fixedSize()
        }
        .sheet(isPresented: $showAccount) {
            AccountView()
        }
        .sheet(isPresented: $showModeSwitch) {
            ModeSwitchView()
                .frame(width: 600, height: 400)
                .fixedSize()
        }
    }
    
    // MARK: - Central Pill Component
    
    private var centralPillComponent: some View {
        ZStack {
            Capsule()
                .fill(Gentle.Background.secondary.opacity(0.12))
                .frame(width: 200, height: 56)
                .overlay(
                    Capsule()
                        .stroke(Gentle.Primary.lavender.opacity(0.4), lineWidth: 1.5)
                )
                .shadow(
                    color: Gentle.Primary.lavender.opacity(0.3),
                    radius: GentleShadow.sm.radius,
                    x: GentleShadow.sm.x,
                    y: GentleShadow.sm.y
                )
            
            Text("主页面")
                .font(GentleFont.headline(18))
                .foregroundColor(Gentle.Text.inverse)
        }
    }
    
    // MARK: - Mode Background
    
    private var modeBackground: some View {
        Group {
            switch modeManager.currentMode {
            case .entertainment:
                LinearGradient(
                    colors: [Color(hex: "#1A0A2E"), Color(hex: "#16082B")],
                    startPoint: .top, endPoint: .bottom
                )
            case .efficiency:
                LinearGradient(
                    colors: [Color(hex: "#0F172A"), Color(hex: "#1E1B4B")],
                    startPoint: .top, endPoint: .bottom
                )
            case .social:
                LinearGradient(
                    colors: [Color(hex: "#1C1917"), Color(hex: "#292524")],
                    startPoint: .top, endPoint: .bottom
                )
            }
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Top Bar
    
    private var topBar: some View {
        HStack {
            // 左侧：设置齿轮
            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.08))
                    )
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            // 中间：模式切换按钮
            Button {
                showModeSwitch = true
            } label: {
                HStack(spacing: GentleSpacing.sm) {
                    Text(modeManager.currentMode.emoji)
                        .font(.system(size: 20))
                    
                    Text(modeManager.currentMode.rawValue)
                        .font(GentleFont.headline(16))
                        .foregroundColor(Gentle.Text.inverse)
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Gentle.Text.inverse.opacity(0.6))
                }
                .padding(.horizontal, GentleSpacing.xl)
                .padding(.vertical, GentleSpacing.sm)
                .background(
                    Capsule()
                        .fill(Gentle.Text.inverse.opacity(0.1))
                        .overlay(
                            Capsule()
                                .stroke(Gentle.Text.inverse.opacity(0.15), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            // 右侧：账号
            Button {
                showAccount = true
            } label: {
                HStack(spacing: GentleSpacing.xs) {
                    if let account = accountManager.currentAccount {
                        Circle()
                            .fill(modeManager.currentMode.gradient)
                            .frame(width: 32, height: 32)
                            .overlay {
                                Text(String(account.username.prefix(1)).uppercased())
                                    .font(GentleFont.headline(14))
                                    .foregroundColor(Gentle.Text.inverse)
                            }
                        
                        Text(account.username)
                            .font(GentleFont.body(13))
                            .foregroundColor(Gentle.Text.inverse.opacity(0.9))
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Gentle.Text.inverse.opacity(0.6))
                            .frame(width: 32, height: 32)
                            .background(
                                Circle().fill(Gentle.Text.inverse.opacity(0.1))
                            )
                        
                        Text("登录")
                            .font(GentleFont.body(13))
                            .foregroundColor(Gentle.Text.inverse.opacity(0.7))
                    }
                }
                .padding(.horizontal, GentleSpacing.md)
                .padding(.vertical, GentleSpacing.xs)
                .background(
                    Capsule()
                        .fill(Gentle.Text.inverse.opacity(0.08))
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Mode Content
    
    @ViewBuilder
    private var modeContent: some View {
        switch modeManager.currentMode {
        case .entertainment:
            EntertainmentModeView()
        case .efficiency:
            EfficiencyModeView()
        case .social:
            SocialModeView()
        }
    }
}

// MARK: - Entertainment Mode View

struct EntertainmentModeView: View {
    @State private var showMoodQuestion = false
    @State private var showGame: GameType?
    @State private var playDuration: PlayDuration = .free
    @State private var hoveredGame: GameType?
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题区
            VStack(spacing: GentleSpacing.sm) {
                Text("🎮 娱乐模式")
                    .font(GentleFont.title(28))
                    .foregroundColor(Gentle.Text.inverse)
                
                Text("放松心情，享受小游戏时光")
                    .font(GentleFont.body(14))
                    .foregroundColor(Gentle.Text.inverse.opacity(0.6))
            }
            .padding(.top, GentleSpacing.xl)
            .padding(.bottom, GentleSpacing.xxl)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: GentleSpacing.xxl) {
                    // 心情询问入口
                    moodEntryCard
                    
                    // 游戏网格
                    gameGrid
                    
                    Spacer().frame(height: GentleSpacing.xxl)
                }
                .padding(.horizontal, GentleSpacing.xxxxl)
            }
        }
        .sheet(isPresented: $showMoodQuestion) {
            MoodQuestionView(isPresented: $showMoodQuestion) { game, duration in
                playDuration = duration
                showGame = game
            }
        }
        .sheet(item: $showGame) { game in
            gameView(for: game)
        }
    }
    
    // MARK: - Mood Entry Card
    
    private var moodEntryCard: some View {
        Button {
            showMoodQuestion = true
        } label: {
            HStack(spacing: GentleSpacing.xl) {
                ZStack {
                    Circle()
                        .fill(Gentle.Gradient.secondaryButton)
                        .frame(width: 60, height: 60)
                        .shadow(color: Gentle.Primary.pink.opacity(0.4), radius: GentleShadow.md.radius, x: GentleShadow.md.x, y: GentleShadow.md.y)
                    
                    Text("💬")
                        .font(.system(size: 30))
                }
                
                VStack(alignment: .leading, spacing: GentleSpacing.xs) {
                    Text("不知道玩什么？")
                        .font(GentleFont.headline(18))
                        .foregroundColor(Gentle.Text.inverse)
                    
                    Text("告诉我们你的心情，为你推荐最合适的游戏")
                        .font(GentleFont.caption(13))
                        .foregroundColor(Gentle.Text.inverse.opacity(0.6))
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Gentle.Text.inverse.opacity(0.1))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "chevron.right")
                        .font(GentleFont.headline(16))
                        .foregroundColor(Gentle.Text.inverse.opacity(0.8))
                }
            }
            .padding(GentleSpacing.xl)
            .background(
                RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                    .fill(Gentle.Background.primary.opacity(0.9))
            )
            .overlay(
                RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                    .stroke(Gentle.Text.inverse.opacity(0.15), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Game Grid
    
    private var gameGrid: some View {
        VStack(spacing: GentleSpacing.lg) {
            ForEach(GameType.allCases) { game in
                gameCard(game)
            }
        }
    }
    
    private func gameCard(_ game: GameType) -> some View {
        let isHovered = hoveredGame == game
        
        return Button {
            playDuration = .free
            showGame = game
        } label: {
            HStack(spacing: GentleSpacing.xl) {
                ZStack {
                    RoundedRectangle(cornerRadius: GentleRadius.lg, style: .continuous)
                        .fill(game.gradient)
                        .frame(width: 80, height: 80)
                        .shadow(color: game.accentColor.opacity(isHovered ? 0.5 : 0.3), radius: isHovered ? 16 : 8, x: 0, y: 4)
                    
                    Text(game.emoji)
                        .font(.system(size: 40))
                }
                .scaleEffect(isHovered ? 1.08 : 1.0)
                
                VStack(alignment: .leading, spacing: GentleSpacing.sm) {
                    HStack(spacing: GentleSpacing.sm) {
                        Text(game.rawValue)
                            .font(GentleFont.headline(18))
                            .foregroundColor(Gentle.Text.inverse)
                        
                        Text(game.category)
                            .font(GentleFont.caption(11))
                            .foregroundColor(game.accentColor)
                            .padding(.horizontal, GentleSpacing.sm)
                            .padding(.vertical, GentleSpacing.xxs)
                            .background(
                                Capsule().fill(game.accentColor.opacity(0.2))
                            )
                    }
                    
                    Text(game.description)
                        .font(GentleFont.caption(13))
                        .foregroundColor(Gentle.Text.inverse.opacity(0.6))
                }
                
                Spacer()
                
                Text("开始")
                    .font(GentleFont.headline(14))
                    .foregroundColor(game.accentColor)
                    .padding(.horizontal, GentleSpacing.xl)
                    .padding(.vertical, GentleSpacing.sm)
                    .background(
                        Capsule().fill(game.accentColor.opacity(0.15))
                    )
            }
            .padding(GentleSpacing.xl)
            .background(
                RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                    .fill(isHovered ? Gentle.Text.inverse.opacity(0.08) : Gentle.Text.inverse.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                    .stroke(game.accentColor.opacity(isHovered ? 0.4 : 0.15), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                hoveredGame = hovering ? game : nil
            }
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
        case .garden:
            GardenGame(isPresented: Binding(
                get: { showGame != nil },
                set: { if !$0 { showGame = nil } }
            ), duration: playDuration)
        case .rhythm:
            RhythmGame(isPresented: Binding(
                get: { showGame != nil },
                set: { if !$0 { showGame = nil } }
            ), duration: playDuration)
        }
    }
}

// MARK: - Efficiency Mode View

struct EfficiencyModeView: View {
    @State private var showBreathing = false
    @State private var showPomodoro = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题区
            VStack(spacing: GentleSpacing.sm) {
                Text("⚡ 效率模式")
                    .font(GentleFont.title(28))
                    .foregroundColor(Gentle.Text.inverse)
                
                Text("专注工作，保持节奏")
                    .font(GentleFont.body(14))
                    .foregroundColor(Gentle.Text.inverse.opacity(0.6))
            }
            .padding(.top, GentleSpacing.xl)
            .padding(.bottom, GentleSpacing.xxl)
            
            // 功能卡片
            VStack(spacing: GentleSpacing.xxl) {
                // 呼吸练习
                featureCard(
                    emoji: "🌬️",
                    title: "呼吸练习",
                    subtitle: "4-4-6-2 放松呼吸法",
                    description: "跟随引导，调整呼吸节奏，缓解压力",
                    gradient: Gentle.Gradient.primaryButton,
                    accentColor: Gentle.Primary.indigo,
                    action: { showBreathing = true }
                )
                
                // 番茄钟
                featureCard(
                    emoji: "🍅",
                    title: "番茄钟",
                    subtitle: "25分钟专注 + 5分钟休息",
                    description: "经典时间管理方法，提升工作效率",
                    gradient: Gentle.Gradient.warmButton,
                    accentColor: Gentle.Primary.orange,
                    action: { showPomodoro = true }
                )
            }
            .padding(.horizontal, GentleSpacing.xxxxl)
            
            Spacer()
        }
        .sheet(isPresented: $showBreathing) {
            BreathingView(isPresented: $showBreathing)
                .frame(width: 998, height: 686)
                .fixedSize()
        }
        .sheet(isPresented: $showPomodoro) {
            PomodoroView(currentEmotion: nil, onClose: { showPomodoro = false })
                .frame(width: 998, height: 686)
                .fixedSize()
        }
    }
    
    private func featureCard(
        emoji: String,
        title: String,
        subtitle: String,
        description: String,
        gradient: LinearGradient,
        accentColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: GentleSpacing.xxl) {
                // 图标
                ZStack {
                    RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                        .fill(gradient)
                        .frame(width: 90, height: 90)
                        .shadow(color: accentColor.opacity(0.4), radius: GentleShadow.md.radius, x: GentleShadow.md.x, y: GentleShadow.md.y)
                    
                    Text(emoji)
                        .font(.system(size: 44))
                }
                
                // 信息
                VStack(alignment: .leading, spacing: GentleSpacing.sm) {
                    Text(title)
                        .font(GentleFont.title(22))
                        .foregroundColor(Gentle.Text.inverse)
                    
                    Text(subtitle)
                        .font(GentleFont.headline(14))
                        .foregroundColor(accentColor)
                    
                    Text(description)
                        .font(GentleFont.caption(13))
                        .foregroundColor(Gentle.Text.inverse.opacity(0.6))
                        .lineSpacing(4)
                }
                
                Spacer()
                
                // 开始按钮
                HStack(spacing: GentleSpacing.xs) {
                    Text("开始")
                        .font(GentleFont.headline(15))
                    Image(systemName: "arrow.right")
                        .font(GentleFont.caption(12))
                }
                .foregroundColor(Gentle.Text.inverse)
                .padding(.horizontal, GentleSpacing.xxl)
                .padding(.vertical, GentleSpacing.md)
                .background(
                    Capsule().fill(gradient)
                )
                .shadow(color: accentColor.opacity(0.3), radius: GentleShadow.sm.radius, x: GentleShadow.sm.x, y: GentleShadow.sm.y)
            }
            .padding(GentleSpacing.xxl)
            .background(
                RoundedRectangle(cornerRadius: GentleRadius.xxl, style: .continuous)
                    .fill(Gentle.Text.inverse.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: GentleRadius.xxl, style: .continuous)
                    .stroke(Gentle.Text.inverse.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Social Mode View

struct SocialModeView: View {
    @State private var showGentleWall = false
    @State private var showSocialFeed = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题区
            VStack(spacing: GentleSpacing.sm) {
                Text("🤝 社交模式")
                    .font(GentleFont.title(28))
                    .foregroundColor(Gentle.Text.inverse)
                
                Text("分享温暖，连接彼此")
                    .font(GentleFont.body(14))
                    .foregroundColor(Gentle.Text.inverse.opacity(0.6))
            }
            .padding(.top, GentleSpacing.xl)
            .padding(.bottom, GentleSpacing.xxl)
            
            // 功能卡片
            VStack(spacing: GentleSpacing.xxl) {
                // 温柔墙
                featureCard(
                    emoji: "💝",
                    title: "温柔墙",
                    subtitle: "每日善意留言",
                    description: "留下温暖的文字，传递善意与关怀",
                    gradient: Gentle.Gradient.secondaryButton,
                    accentColor: Gentle.Primary.pink,
                    action: { showGentleWall = true }
                )
                
                // 社交动态
                featureCard(
                    emoji: "👥",
                    title: "社交动态",
                    subtitle: "分享你的心情",
                    description: "查看好友动态，分享生活点滴",
                    gradient: Gentle.Gradient.primaryButton,
                    accentColor: Gentle.State.success,
                    action: { showSocialFeed = true }
                )
            }
            .padding(.horizontal, GentleSpacing.xxxxl)
            
            Spacer()
        }
        .sheet(isPresented: $showGentleWall) {
            GentleWallView(isPresented: $showGentleWall)
                .frame(width: 998, height: 686)
                .fixedSize()
        }
        .sheet(isPresented: $showSocialFeed) {
            SocialFeedView(isPresented: $showSocialFeed)
                .frame(width: 998, height: 686)
                .fixedSize()
        }
    }
    
    private func featureCard(
        emoji: String,
        title: String,
        subtitle: String,
        description: String,
        gradient: LinearGradient,
        accentColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: GentleSpacing.xxl) {
                // 图标
                ZStack {
                    RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                        .fill(gradient)
                        .frame(width: 90, height: 90)
                        .shadow(color: accentColor.opacity(0.4), radius: GentleShadow.md.radius, x: GentleShadow.md.x, y: GentleShadow.md.y)
                    
                    Text(emoji)
                        .font(.system(size: 44))
                }
                
                // 信息
                VStack(alignment: .leading, spacing: GentleSpacing.sm) {
                    Text(title)
                        .font(GentleFont.title(22))
                        .foregroundColor(Gentle.Text.inverse)
                    
                    Text(subtitle)
                        .font(GentleFont.headline(14))
                        .foregroundColor(accentColor)
                    
                    Text(description)
                        .font(GentleFont.caption(13))
                        .foregroundColor(Gentle.Text.inverse.opacity(0.6))
                        .lineSpacing(4)
                }
                
                Spacer()
                
                // 开始按钮
                HStack(spacing: GentleSpacing.xs) {
                    Text("进入")
                        .font(GentleFont.headline(15))
                    Image(systemName: "arrow.right")
                        .font(GentleFont.caption(12))
                }
                .foregroundColor(Gentle.Text.inverse)
                .padding(.horizontal, GentleSpacing.xxl)
                .padding(.vertical, GentleSpacing.md)
                .background(
                    Capsule().fill(gradient)
                )
                .shadow(color: accentColor.opacity(0.3), radius: GentleShadow.sm.radius, x: GentleShadow.sm.x, y: GentleShadow.sm.y)
            }
            .padding(GentleSpacing.xxl)
            .background(
                RoundedRectangle(cornerRadius: GentleRadius.xxl, style: .continuous)
                    .fill(Gentle.Text.inverse.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: GentleRadius.xxl, style: .continuous)
                    .stroke(Gentle.Text.inverse.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
