//
//  GentleMainView.swift
//  GentleCompanion
//
//  全新主页面设计
//


import SwiftUI

struct GentleMainView: View {
    @StateObject private var accountManager = AccountManager.shared
    
    @State private var showSettings = false
    @State private var showAccount = false
    @State private var showPomodoro = false
    @State private var showBreathing = false
    @State private var showGentleWall = false
    @State private var showSocialFeed = false
    @State private var showEntertainment = false
    @State private var currentQuote = 0
    @State private var selectedMood: EmotionType? = .tired
    @State private var cardHovered: String? = nil
    @State private var appearAnimation = false
    
    let quotes = [
        "躺平不是放弃，是和自己的身体和解。",
        "慢慢来，比较快。",
        "允许自己偶尔休息一下。",
        "温柔对待自己，比什么都重要。",
        "今天的你，已经很棒了。",
        "深呼吸，一切都会好的。"
    ]
    
    var body: some View {
        ZStack {
            // 多层装饰背景
            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: "#FAF8FF"),
                        Color(hex: "#F3ECFF"),
                        Color(hex: "#F8F4FF")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                Circle()
                    .fill(Gentle.Primary.lavender.opacity(0.05))
                    .frame(width: 300, height: 300)
                    .blur(radius: 60)
                    .offset(x: -200, y: -150)
                
                Circle()
                    .fill(Gentle.Primary.pink.opacity(0.04))
                    .frame(width: 250, height: 250)
                    .blur(radius: 50)
                    .offset(x: 250, y: 200)
            }
            .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    topBar
                        .padding(.horizontal, GentleSpacing.xxl)
                        .padding(.top, GentleSpacing.lg)
                    
                    greetingSection
                        .padding(.horizontal, GentleSpacing.xxl)
                        .padding(.top, GentleSpacing.xl)
                    
                    moodCard
                        .padding(.horizontal, GentleSpacing.xxl)
                        .padding(.top, GentleSpacing.xl)
                    
                    featureGrid
                        .padding(.horizontal, GentleSpacing.xxl)
                        .padding(.top, GentleSpacing.xl)
                        .padding(.bottom, GentleSpacing.xxxl)
                }
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 20)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appearAnimation = true
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(isPresented: $showSettings)
                .frame(width: 1091, height: 738)
                .fixedSize()
        }
        .sheet(isPresented: $showAccount) {
            AccountView()
                .frame(width: 1180, height: 800)
                .fixedSize()
        }
        .sheet(isPresented: $showPomodoro) {
            PomodoroView(currentEmotion: nil, onClose: { showPomodoro = false })
                .frame(width: 1091, height: 738)
                .fixedSize()
        }
        .sheet(isPresented: $showBreathing) {
            BreathingView(isPresented: $showBreathing)
                .frame(width: 1091, height: 738)
                .fixedSize()
        }
        .sheet(isPresented: $showGentleWall) {
            GentleWallView(isPresented: $showGentleWall)
                .frame(width: 1091, height: 738)
                .fixedSize()
        }
        .sheet(isPresented: $showSocialFeed) {
            SocialFeedView(isPresented: $showSocialFeed)
                .frame(width: 1091, height: 738)
                .fixedSize()
        }
        .sheet(isPresented: $showEntertainment) {
            EntertainmentView(isPresented: $showEntertainment)
                .frame(width: 970, height: 686)
                .fixedSize()
        }
    }
    
    // MARK: - Top Bar
    
    private var topBar: some View {
        HStack {
            HStack(spacing: GentleSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(Gentle.Gradient.primaryButton)
                        .frame(width: 38, height: 38)
                        .shadow(color: Gentle.Primary.purple.opacity(0.25), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: -2) {
                    Text("温柔点")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(Gentle.Text.primary)
                    Text("GentleCompanion")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(Gentle.Text.tertiary)
                }
            }
            
            Spacer()
            
            Button {
                showAccount = true
            } label: {
                HStack(spacing: GentleSpacing.sm) {
                    ZStack {
                        Circle()
                            .fill(Gentle.Background.tertiary)
                            .frame(width: 34, height: 34)
                        
                        if let account = accountManager.currentAccount {
                            Text(String(account.username.prefix(1)).uppercased())
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(Gentle.Primary.lavender)
                        } else {
                            Image(systemName: "person.fill")
                                .font(.system(size: 15))
                                .foregroundColor(Gentle.Primary.lavender)
                        }
                    }
                    
                    Text(accountManager.currentAccount?.username ?? "登录")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Gentle.Text.primary)
                }
                .padding(.horizontal, GentleSpacing.md)
                .padding(.vertical, GentleSpacing.sm)
                .background(
                    Capsule()
                        .fill(.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Greeting Section
    
    private var greetingSection: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: GentleSpacing.xs) {
                Text(getGreeting())
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Gentle.Text.secondary)
                
                Text("今天感觉如何？")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(Gentle.Text.primary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(formatDate())
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Gentle.Text.secondary)
                Text(weekdayName())
                    .font(.system(size: 11))
                    .foregroundColor(Gentle.Text.tertiary)
            }
        }
    }
    
    private func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12: return "早上好 ☀️"
        case 12..<18: return "下午好 🌤️"
        case 18..<22: return "晚上好 🌙"
        default: return "夜深了 ✨"
        }
    }
    
    private func formatDate() -> String {
        let f = DateFormatter()
        f.dateFormat = "M月d日"
        return f.string(from: Date())
    }
    
    private func weekdayName() -> String {
        let f = DateFormatter()
        f.dateFormat = "EEEE"
        return f.string(from: Date())
    }
    
    // MARK: - Mood Card
    
    private var moodCard: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill((selectedMood?.color ?? Gentle.Emotion.tired).opacity(0.08))
                    .frame(width: 180, height: 180)
                
                Circle()
                    .fill((selectedMood?.color ?? Gentle.Emotion.tired).opacity(0.12))
                    .frame(width: 130, height: 130)
                
                Text(selectedMood?.emoji ?? "😴")
                    .font(.system(size: 72))
                    .shadow(color: (selectedMood?.color ?? Gentle.Emotion.tired).opacity(0.2), radius: 16, x: 0, y: 6)
            }
            .padding(.bottom, GentleSpacing.lg)
            
            // 情绪标签胶囊
            HStack(spacing: GentleSpacing.xs) {
                Circle()
                    .fill(selectedMood?.color ?? Gentle.Emotion.tired)
                    .frame(width: 7, height: 7)
                
                Text(getMoodLabel())
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(selectedMood?.color ?? Gentle.Emotion.tired)
            }
            .padding(.horizontal, GentleSpacing.md)
            .padding(.vertical, GentleSpacing.xs)
            .background(
                Capsule()
                    .fill((selectedMood?.color ?? Gentle.Emotion.tired).opacity(0.1))
            )
            .padding(.bottom, GentleSpacing.lg)
            
            // 文案
            Text(quotes[currentQuote])
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(Gentle.Text.primary)
                .multilineTextAlignment(.center)
                .lineSpacing(8)
                .padding(.horizontal, GentleSpacing.xxl)
                .padding(.bottom, GentleSpacing.xl)
                .id(currentQuote)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            
            // 情绪选择器
            HStack(spacing: GentleSpacing.sm) {
                ForEach(EmotionType.allCases, id: \.self) { emotion in
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            selectedMood = emotion
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(selectedMood == emotion ? emotion.color.opacity(0.12) : Color.clear)
                                .frame(width: 48, height: 48)
                            
                            Circle()
                                .stroke(
                                    selectedMood == emotion ? emotion.color.opacity(0.35) : Color.clear,
                                    lineWidth: 2
                                )
                                .frame(width: 48, height: 48)
                            
                            Text(emotion.emoji)
                                .font(.system(size: 24))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .scaleEffect(selectedMood == emotion ? 1.12 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedMood)
                }
            }
            .padding(.bottom, GentleSpacing.lg)
            
            // 换一句按钮
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentQuote = (currentQuote + 1) % quotes.count
                }
            } label: {
                HStack(spacing: GentleSpacing.xs) {
                    Image(systemName: "arrow.2.circlepath")
                        .font(.system(size: 11, weight: .semibold))
                    Text("换一句")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(Gentle.Text.tertiary)
                .padding(.horizontal, GentleSpacing.lg)
                .padding(.vertical, GentleSpacing.xs)
                .background(
                    Capsule()
                        .fill(Gentle.Background.tertiary.opacity(0.6))
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, GentleSpacing.xxl)
        .padding(.horizontal, GentleSpacing.xl)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: GentleRadius.xxxl, style: .continuous)
                    .fill(.white)
                
                RoundedRectangle(cornerRadius: GentleRadius.xxxl, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Gentle.Primary.lavender.opacity(0.3),
                                Gentle.Primary.pink.opacity(0.15),
                                Color.clear,
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 4)
    }
    
    private func getMoodLabel() -> String {
        guard let mood = selectedMood else { return "选择你的心情" }
        switch mood {
        case .neutral: return "平静如常"
        case .tired: return "累到不想动"
        case .happy: return "开心满满"
        case .calm: return "悠然自得"
        case .energetic: return "活力四射"
        case .grateful: return "感恩遇见"
        case .other: return "说不清楚"
        }
    }
    
    // MARK: - Feature Grid
    
    private var featureGrid: some View {
        VStack(spacing: GentleSpacing.md) {
            HStack {
                Text("功能")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Gentle.Text.secondary)
                Spacer()
            }
            .padding(.bottom, GentleSpacing.xs)
            
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: GentleSpacing.md),
                    GridItem(.flexible(), spacing: GentleSpacing.md)
                ],
                spacing: GentleSpacing.md
            ) {
                FeatureGridCard(
                    icon: "timer",
                    iconColor: Gentle.Primary.purple,
                    title: "时间模式",
                    subtitle: "番茄钟 · 25分钟专注",
                    isHovered: cardHovered == "pomodoro"
                ) {
                    showPomodoro = true
                }
                .onHover { h in cardHovered = h ? "pomodoro" : nil }
                
                FeatureGridCard(
                    icon: "heart.fill",
                    iconColor: Gentle.Primary.pink,
                    title: "温柔墙",
                    subtitle: "每日善意 · 温暖传递",
                    isHovered: cardHovered == "gentleWall"
                ) {
                    showGentleWall = true
                }
                .onHover { h in cardHovered = h ? "gentleWall" : nil }
                
                FeatureGridCard(
                    icon: "wind",
                    iconColor: Gentle.Primary.indigo,
                    title: "呼吸练习",
                    subtitle: "4-4-6-2 放松引导",
                    isHovered: cardHovered == "breathing"
                ) {
                    showBreathing = true
                }
                .onHover { h in cardHovered = h ? "breathing" : nil }
                
                FeatureGridCard(
                    icon: "person.2.fill",
                    iconColor: Gentle.State.success,
                    title: "社交动态",
                    subtitle: "分享心情 · 连接朋友",
                    isHovered: cardHovered == "social"
                ) {
                    showSocialFeed = true
                }
                .onHover { h in cardHovered = h ? "social" : nil }
                
                FeatureGridCard(
                    icon: "gamecontroller.fill",
                    iconColor: Gentle.Primary.orange,
                    title: "放松游戏",
                    subtitle: "小游戏 · 缓解压力",
                    isHovered: cardHovered == "games"
                ) {
                    showEntertainment = true
                }
                .onHover { h in cardHovered = h ? "games" : nil }
                
                FeatureGridCard(
                    icon: "gearshape.fill",
                    iconColor: Color.gray,
                    title: "设置",
                    subtitle: "个性化你的体验",
                    isHovered: cardHovered == "settings"
                ) {
                    showSettings = true
                }
                .onHover { h in cardHovered = h ? "settings" : nil }
            }
        }
    }
}

// MARK: - Feature Grid Card

struct FeatureGridCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let isHovered: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: GentleSpacing.sm) {
                HStack(spacing: 0) {
                    ZStack {
                        RoundedRectangle(cornerRadius: GentleRadius.md, style: .continuous)
                            .fill(iconColor.opacity(0.12))
                            .frame(width: 42, height: 42)
                        
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(iconColor)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Gentle.Text.tertiary.opacity(isHovered ? 0.8 : 0.4))
                        .offset(x: isHovered ? 4 : 0)
                        .opacity(isHovered ? 1 : 0.5)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Gentle.Text.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(Gentle.Text.tertiary)
                        .lineLimit(1)
                }
            }
            .padding(GentleSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                    .fill(.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                    .stroke(
                        isHovered ? iconColor.opacity(0.25) : Color.clear,
                        lineWidth: 1.5
                    )
            )
            .shadow(
                color: isHovered ? iconColor.opacity(0.12) : Color.black.opacity(0.04),
                radius: isHovered ? 12 : 6,
                x: 0,
                y: isHovered ? 6 : 2
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isHovered)
    }
}

// MARK: - Emotion Type Extension

enum EmotionType: CaseIterable {
    case neutral
    case tired
    case happy
    case calm
    case energetic
    case grateful
    case other
    
    var emoji: String {
        switch self {
        case .neutral: return "😐"
        case .tired: return "😴"
        case .happy: return "😊"
        case .calm: return "😌"
        case .energetic: return "🔥"
        case .grateful: return "🥰"
        case .other: return "✨"
        }
    }
    
    var color: Color {
        switch self {
        case .neutral: return Gentle.Text.secondary
        case .tired: return Gentle.Emotion.tired
        case .happy: return Gentle.Emotion.happy
        case .calm: return Gentle.Emotion.calm
        case .energetic: return Gentle.State.warning
        case .grateful: return Gentle.Emotion.grateful
        case .other: return Gentle.Primary.lavender
        }
    }
}

// MARK: - Preview

struct GentleMainView_Preview: PreviewProvider {
    static var previews: some View {
        GentleMainView()
            .frame(width: 998, height: 686)
    }
}
