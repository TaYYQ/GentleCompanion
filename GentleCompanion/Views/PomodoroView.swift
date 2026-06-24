//
//  PomodoroView.swift
//  GentleCompanion
//
//  iOS 26 Liquid Glass 风格 — 极致透明 + 大圆角 + SF Symbols
//

import SwiftUI

// MARK: - 番茄钟状态

enum PomodoroPhase {
    case preparation
    case focusing
    case paused
    case breakTime
}

// MARK: - iOS 26 Liquid Glass 面板

struct GlassPanel<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(20)
            .background(
                GlassBackground()
            )
    }
}

struct GlassBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: GentleRadius.xxxl, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: GentleRadius.xxxl, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.6),
                                .white.opacity(0.15),
                                .white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
            )
            .shadow(color: .black.opacity(0.08), radius: 20, y: 10)
    }
}

struct GlassPill: View {
    let icon: String
    let label: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                Text(label)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(isActive ? .white : .white.opacity(0.7))
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: GentleRadius.full, style: .continuous)
                    .fill(isActive ? Color.white.opacity(0.3) : Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: GentleRadius.full, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(isActive ? 0.5 : 0.2),
                                        .white.opacity(isActive ? 0.2 : 0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.6
                            )
                    )
            )
            .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct GlassCircleButton: View {
    let icon: String
    let size: CGFloat
    let gradient: LinearGradient
    let shadowColor: Color
    let action: () -> Void

    init(
        icon: String,
        size: CGFloat = 80,
        gradient: LinearGradient = Gentle.Gradient.primaryButton,
        shadowColor: Color = Gentle.Primary.lavender,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.size = size
        self.gradient = gradient
        self.shadowColor = shadowColor
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                // 渐变底色
                Circle()
                    .fill(gradient)
                    .frame(width: size, height: size)

                // 毛玻璃层
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: size, height: size)

                // 高光描边
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.4), .white.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
                    .frame(width: size, height: size)

                // 图标（在圆形正中间）
                Image(systemName: icon)
                    .font(.system(size: size * 0.35, weight: .medium))
                    .foregroundColor(.white)
            }
            .shadow(color: shadowColor.opacity(0.4), radius: 16, y: 8)
            .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - iOS 26 Liquid Glass 快捷标签

struct LiquidTag: View {
    let tag: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(tag)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
                .background(
                    RoundedRectangle(cornerRadius: GentleRadius.full, style: .continuous)
                        .fill(isSelected
                              ? Color.white.opacity(0.28)
                              : Color.white.opacity(0.08)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: GentleRadius.full, style: .continuous)
                                .stroke(
                                    isSelected
                                                                ? LinearGradient(
                                                                    colors: [.white.opacity(0.5), .white.opacity(0.2)],
                                                                    startPoint: .topLeading,
                                                                    endPoint: .bottomTrailing
                                                                )
                                                                : LinearGradient(
                                                                    colors: [.white.opacity(0.2), .white.opacity(0.05)],
                                                                    startPoint: .topLeading,
                                                                    endPoint: .bottomTrailing
                                                                ),
                                    lineWidth: isSelected ? 1.0 : 0.5
                                )
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 粒子

struct GlowParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var opacity: Double
    var color: Color
}

// MARK: - 主视图

@MainActor
struct PomodoroView: View {
    let currentEmotion: Emotion?
    let onClose: () -> Void

    @State private var phase: PomodoroPhase = .preparation
    @State private var selectedTag: String? = nil
    @State private var remainingTime: TimeInterval = 25 * 60
    @State private var totalTime: TimeInterval = 25 * 60
    @State private var progress: Double = 0
    @State private var gradientPhase: Double = 0
    @State private var sunOpacity: Double = 0
    @State private var showStats: Bool = false

    @State private var glowParticles: [GlowParticle] = []
    @State private var hugParticles: [GlowParticle] = []
    @State private var viewSize: CGSize = .zero
    @State private var timer: Timer?
    @State private var tickCount: Int = 0

    private let settings = SettingsManager.shared
    private let quickTags = ["清掉邮件", "写完那段文字", "静静呼吸", "整理思绪"]

    var body: some View {
        ZStack {
            // 深度渐变背景
            LiquidBackground(phase: phase, phaseValue: gradientPhase)

            // 漂浮光点
            ForEach(glowParticles) { p in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [p.color.opacity(p.opacity), Color.clear],
                            center: .center, startRadius: 0, endRadius: p.size
                        )
                    )
                    .frame(width: p.size * 2, height: p.size * 2)
                    .position(p.position)
                    .blur(radius: p.size * 0.6)
            }

            // 拥抱粒子
            ForEach(hugParticles) { p in
                Circle()
                    .fill(p.color)
                    .frame(width: p.size * 1.5, height: p.size * 1.5)
                    .position(p.position)
                    .opacity(p.opacity)
                    .blur(radius: 4)
            }

            // 阶段内容
            GeometryReader { geo in
                Color.clear.onAppear { viewSize = geo.size }
                Color.clear.onChange(of: geo.size) { _, ns in viewSize = ns }

                switch phase {
                case .preparation:
                    preparationScreen(in: geo.size)
                case .focusing, .paused:
                    focusingScreen(in: geo.size)
                case .breakTime:
                    breakScreen(in: geo.size)
                }
            }

            // 右上角统计按钮
            VStack {
                HStack {
                    Spacer()
                    Button(action: { withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) { showStats.toggle() } }) {
                        Image(systemName: "chart.bar.xaxis")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 38, height: 38)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        Circle()
                                            .stroke(.white.opacity(0.2), lineWidth: 0.6)
                                    )
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, 16)
                    .padding(.top, 16)
                }
                Spacer()
            }

            // 统计浮层
            if showStats {
                statsOverlay
            }
        }
        .onAppear { initParticles(size: viewSize) }
        .onChange(of: tickCount) { _, _ in handleTick() }
    }

    private func handleTick() {
        guard phase == .focusing else { return }
        if remainingTime > 0 {
            remainingTime -= 1
            progress = 1.0 - (remainingTime / totalTime)
        } else {
            timer?.invalidate()
            completePomodoro()
        }
    }

    // MARK: - Preparation Screen

    @ViewBuilder
    private func preparationScreen(in size: CGSize) -> some View {
        VStack(spacing: 0) {
            // 顶部关闭
            HStack {
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .overlay(Circle().stroke(.white.opacity(0.15), lineWidth: 0.5))
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing, 16)
                .padding(.top, 16)
            }

            Spacer()

            // 玻璃主卡片
            GlassPanel {
                VStack(spacing: 28) {
                    // 标题
                    Text("今天专注一件事")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)

                    // 快捷标签
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(quickTags, id: \.self) { tag in
                            LiquidTag(tag: tag, isSelected: selectedTag == tag) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedTag = (selectedTag == tag) ? nil : tag
                                }
                            }
                        }
                    }

                    // 情绪提示
                    if currentEmotion == .empty || currentEmotion == .exhausted {
                        Text("🌱 从一小步开始，没关系。")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }

                    // 开始按钮
                    Button(action: startFocus) {
                        HStack(spacing: 8) {
                            Text("开始专注")
                                .font(.system(size: 16, weight: .semibold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 36)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
                                .fill(.white)
                                .shadow(color: .white.opacity(0.3), radius: 12, y: 6)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .frame(maxWidth: min(size.width - 48, 380))

            Spacer()
        }
    }

    // MARK: - Focusing Screen

    @ViewBuilder
    private func focusingScreen(in size: CGSize) -> some View {
        VStack(spacing: 0) {
            // 顶部栏
            HStack(spacing: 16) {
                Button(action: cancelFocus) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 13, weight: .semibold))
                        Text("放弃")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: GentleRadius.full, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay(RoundedRectangle(cornerRadius: GentleRadius.full, style: .continuous).stroke(.white.opacity(0.15), lineWidth: 0.5))
                    )
                }
                .buttonStyle(PlainButtonStyle())

                Spacer()

                // 状态标签
                Text(phase == .focusing ? "专注中" : "已暂停")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(Capsule().stroke(.white.opacity(0.2), lineWidth: 0.5))
                    )

                Spacer()

                // 时间选择
                HStack(spacing: 8) {
                    ForEach([15, 25, 45], id: \.self) { m in
                        let t = TimeInterval(m * 60)
                        Button(action: { setTimer(minutes: m) }) {
                            Text("\(m)")
                                .font(.system(size: 12, weight: selectedTimerMinutes == m ? .semibold : .regular))
                                .foregroundColor(selectedTimerMinutes == m ? .white : .white.opacity(0.5))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(selectedTimerMinutes == m ? Color.white.opacity(0.2) : Color.clear)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(Capsule().stroke(.white.opacity(0.15), lineWidth: 0.5))
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            Spacer()

            // 已选意图
            if let tag = selectedTag {
                Text(tag)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(Capsule().stroke(.white.opacity(0.15), lineWidth: 0.5))
                    )
                    .padding(.bottom, 16)
            }

            // 大时间显示
            LiquidTimerDisplay(
                remainingTime: remainingTime,
                totalTime: totalTime,
                progress: progress,
                phase: gradientPhase
            )

            Spacer()

            // 控制按钮
            HStack(spacing: 24) {
                // 跳过
                Button(action: skipToBreak) {
                    VStack(spacing: 5) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 18))
                        Text("跳过")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(.white.opacity(0.45))
                    .frame(width: 60, height: 60)
                }
                .buttonStyle(PlainButtonStyle())

                // 暂停/继续
                GlassCircleButton(
                    icon: phase == .focusing ? "pause.fill" : "play.fill",
                    size: 80,
                    gradient: phase == .focusing ? Gentle.Gradient.warmButton : Gentle.Gradient.primaryButton,
                    shadowColor: phase == .focusing ? Gentle.Primary.orange : Gentle.Primary.lavender
                ) {
                    togglePause()
                }

                // 放弃
                Button(action: cancelFocus) {
                    VStack(spacing: 5) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18))
                        Text("放弃")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(.white.opacity(0.45))
                    .frame(width: 60, height: 60)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.bottom, 48)
        }
    }

    // MARK: - Break Screen

    @ViewBuilder
    private func breakScreen(in size: CGSize) -> some View {
        VStack(spacing: 0) {
            Spacer()

            // 太阳光效
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Gentle.Primary.yellow.opacity(sunOpacity * 0.6),
                                Gentle.Primary.orange.opacity(sunOpacity * 0.3),
                                Color.clear
                            ],
                            center: .center, startRadius: 0, endRadius: 120
                        )
                    )
                    .frame(width: 180, height: 180)
                    .scaleEffect(1.0 + (1 - sunOpacity) * 0.2)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Gentle.Primary.yellow, Gentle.Primary.orange.opacity(0.8)],
                            center: .center, startRadius: 0, endRadius: 40
                        )
                    )
                    .frame(width: 80, height: 80)
                    .opacity(sunOpacity)
                    .shadow(color: Gentle.Primary.yellow.opacity(0.6), radius: 20)
            }

            Spacer()

            // 玻璃卡片
            GlassPanel {
                VStack(spacing: 20) {
                    Text("做得很好 🌟")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)

                    Text("休息一下吧")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.65))

                    // 抱抱按钮
                    Button(action: triggerHug) {
                        HStack(spacing: 10) {
                            Text("🤗")
                                .font(.system(size: 20))
                            Text("抱抱")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: GentleRadius.full, style: .continuous)
                                .fill(Color.white.opacity(0.15))
                                .overlay(
                                    RoundedRectangle(cornerRadius: GentleRadius.full, style: .continuous)
                                        .stroke(.white.opacity(0.25), lineWidth: 0.8)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())

                    Divider()
                        .background(.white.opacity(0.15))
                        .padding(.horizontal, 8)

                    HStack(spacing: 24) {
                        Button(action: startNextPomodoro) {
                            Text("继续")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .buttonStyle(PlainButtonStyle())

                        Button(action: endSession) {
                            Text("结束")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.4))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .frame(maxWidth: min(viewSize.width - 48, 360))

            Spacer()
        }
    }

    // MARK: - Stats Overlay

    private var statsOverlay: some View {
        ZStack {
            // 背景遮罩
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .transition(.opacity)
                .onTapGesture { withAnimation(.easeOut(duration: 0.25)) { showStats = false } }

            // 玻璃内容卡
            GlassPanel {
                VStack(spacing: 16) {
                    HStack {
                        Text("专注统计")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: { withAnimation(.easeOut) { showStats = false } }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                    HStack(spacing: 10) {
                        LiquidStatCard(
                            icon: "checkmark.circle.fill",
                            value: "\(stats.completedSessions)",
                            label: "完成次数",
                            color: Gentle.Primary.lavender
                        )
                        LiquidStatCard(
                            icon: "clock.fill",
                            value: "\(stats.totalMinutes)",
                            label: "总分钟数",
                            color: Gentle.Primary.yellow
                        )
                    }

                    HStack(spacing: 10) {
                        LiquidStatCard(
                            icon: "flame.fill",
                            value: "\(stats.streakDays)",
                            label: "连续天数",
                            color: Gentle.Primary.pink
                        )
                        LiquidStatCard(
                            icon: "trophy.fill",
                            value: "\(stats.completionRate)%",
                            label: "完成率",
                            color: Gentle.Primary.orange
                        )
                    }
                }
            }
            .frame(width: min(viewSize.width * 0.88, 380))
            .transition(.opacity.combined(with: .scale(scale: 0.92, anchor: .center)))
        }
    }

    // MARK: - Private

    private var selectedTimerMinutes: Int {
        Int(totalTime / 60)
    }

    private var stats: PomodoroStats {
        settings.settings.pomodoroStats
    }

    private func initParticles(size: CGSize) {
        guard size.width > 0 else { return }
        let b = CGSize(width: max(size.width, 600), height: max(size.height, 400))
        glowParticles = (0..<10).map { _ in
            GlowParticle(
                position: CGPoint(x: .random(in: 0...b.width), y: .random(in: 0...b.height)),
                size: .random(in: 30...80),
                opacity: .random(in: 0.06...0.18),
                color: [Gentle.Primary.lavender, Gentle.Primary.yellow, Gentle.Primary.pink].randomElement()!
            )
        }
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: true)) {
            gradientPhase = 2 * .pi
        }
    }

    private func setTimer(minutes: Int) {
        guard phase == .focusing || phase == .paused else { return }
        totalTime = TimeInterval(minutes * 60)
        remainingTime = totalTime
        progress = 0
    }

    private func startFocus() {
        timer?.invalidate()
        phase = .focusing
        remainingTime = totalTime
        progress = 0
        tickCount = 0

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [self] t in
            Task { @MainActor in
                self.tickCount += 1
            }
        }
    }

    private func togglePause() {
        phase = (phase == .focusing) ? .paused : .focusing
    }

    private func cancelFocus() {
        timer?.invalidate()
        recordSession(completed: false)
        withAnimation(.easeOut(duration: 0.35)) { phase = .preparation }
    }

    private func skipToBreak() {
        timer?.invalidate()
        completePomodoro()
    }

    private func completePomodoro() {
        withAnimation(.easeInOut(duration: 1.5)) {
            phase = .breakTime
            sunOpacity = 1.0
        }
        recordSession(completed: true)
        var s = settings.settings
        s.collectedStars += 1
        settings.settings = s
    }

    private func triggerHug() {
        let b = CGSize(width: max(viewSize.width, 600), height: max(viewSize.height, 400))
        hugParticles = (0..<18).map { _ in
            GlowParticle(
                position: CGPoint(
                    x: .random(in: b.width * 0.3...b.width * 0.7),
                    y: .random(in: b.height * 0.35...b.height * 0.65)
                ),
                size: .random(in: 12...30),
                opacity: 0.8,
                color: [Gentle.Primary.lavender, Gentle.Warm.amber, Color.white].randomElement()!
            )
        }

        withAnimation(.easeOut(duration: 1.8)) {
            hugParticles = hugParticles.map { p in
                var u = p
                let angle = Double.random(in: 0...(2 * .pi))
                let dist: CGFloat = .random(in: 70...160)
                u.position.x += cos(angle) * dist
                u.position.y += sin(angle) * dist
                u.opacity = 0
                return u
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
            hugParticles = []
        }
    }

    private func startNextPomodoro() {
        withAnimation(.easeInOut(duration: 0.6)) { sunOpacity = 0 }
        remainingTime = 25 * 60
        totalTime = 25 * 60
        selectedTag = nil
        progress = 0
        withAnimation(.easeInOut(duration: 0.35)) { phase = .preparation }
    }

    private func endSession() {
        timer?.invalidate()
        onClose()
    }

    private func recordSession(completed: Bool) {
        let session = PomodoroSession(
            timestamp: Date(),
            duration: totalTime - remainingTime,
            completed: completed,
            intention: selectedTag ?? "",
            focusScore: completed ? Int((totalTime - remainingTime) / totalTime * 100) : nil
        )

        var s = settings.settings
        var st = s.pomodoroStats
        st.totalSessions += 1
        if completed { st.completedSessions += 1 }
        st.totalMinutes += Int((totalTime - remainingTime) / 60)
        st.sessions.append(session)

        let today = Calendar.current.startOfDay(for: Date())
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        st.dailyStats[today] = (st.dailyStats[today] ?? 0) + 1
        if st.dailyStats[yesterday] != nil {
            st.streakDays += 1
        } else {
            st.streakDays = 1
        }
        st.longestStreak = max(st.longestStreak, st.streakDays)

        s.pomodoroStats = st
        settings.settings = s
    }
}

// MARK: - Liquid Timer Display

struct LiquidTimerDisplay: View {
    let remainingTime: TimeInterval
    let totalTime: TimeInterval
    let progress: Double
    let phase: Double

    private func formatTime(_ t: TimeInterval) -> String {
        String(format: "%02d:%02d", Int(t) / 60, Int(t) % 60)
    }

    var body: some View {
        ZStack {
            // 光晕背景
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Gentle.Primary.lavender.opacity(0.15),
                            Gentle.Primary.pink.opacity(0.08),
                            Color.clear
                        ],
                        center: .center, startRadius: 0, endRadius: 200
                    )
                )
                .frame(width: 340, height: 340)
                .scaleEffect(1.0 + sin(phase * 0.3) * 0.015)

            // 进度环（发光）
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [
                            Gentle.Primary.lavender,
                            Gentle.Primary.pink,
                            Gentle.Primary.orange
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .frame(width: 260, height: 260)
                .rotationEffect(.degrees(-90))
                .shadow(color: Gentle.Primary.lavender.opacity(0.5), radius: 12)
                .shadow(color: Gentle.Primary.pink.opacity(0.3), radius: 6)

            // 底环
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: 20)
                .frame(width: 260, height: 260)

            // 中心光斑
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.white.opacity(0.12), .white.opacity(0.03), .clear],
                        center: .center, startRadius: 0, endRadius: 80
                    )
                )
                .frame(width: 160, height: 160)

            // 时间文字
            VStack(spacing: 4) {
                Text(formatTime(remainingTime))
                    .font(.system(size: 80, weight: .ultraLight, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: Gentle.Primary.lavender.opacity(0.2), radius: 10)
                    .shadow(color: .black.opacity(0.1), radius: 2)

                Text("\(Int(progress * 100))% 完成")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.45))
            }
        }
    }
}

// MARK: - Liquid Stat Card

struct LiquidStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(color)
                Text(label)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.6))
            }
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: GentleRadius.lg, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: GentleRadius.lg, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.2), .white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.6
                        )
                )
        )
    }
}

// MARK: - Liquid Background

struct LiquidBackground: View {
    let phase: PomodoroPhase
    let phaseValue: Double

    private var colors: [Color] {
        switch phase {
        case .preparation:
            return [
                Color(hex: "#0F0A1E"),
                Color(hex: "#1A1040").opacity(0.95 + sin(phaseValue) * 0.05),
                Color(hex: "#2A1560").opacity(0.6),
                Color(hex: "#1E1040").opacity(0.8)
            ]
        case .focusing:
            return [
                Color(hex: "#0A0A1A"),
                Color(hex: "#15102E"),
                Color(hex: "#1E1050").opacity(0.7)
            ]
        case .paused:
            return [
                Color(hex: "#0A0A1A"),
                Color(hex: "#1A1030"),
                Color(hex: "#2A1840").opacity(0.5)
            ]
        case .breakTime:
            return [
                Color(hex: "#100A20"),
                Color(hex: "#1E1030"),
                Color(hex: "#2A1848").opacity(0.5)
            ]
        }
    }

    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: UnitPoint(x: 0.2 + sin(phaseValue * 0.4) * 0.1, y: 0),
            endPoint: UnitPoint(x: 0.8 + cos(phaseValue * 0.3) * 0.1, y: 1)
        )
    }
}
