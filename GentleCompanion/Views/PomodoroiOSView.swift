//
//  PomodoroiOSView.swift
//  GentleCompanion iOS
//
//  专注番茄钟 — 主题感知 Liquid Glass 沉浸式设计
//

import SwiftUI
import ActivityKit

// MARK: - Main View

struct PomodoroiOSView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var engine = PomodoroEngine()
    @ObservedObject private var themeManager = GentleThemeManager.shared

    @State private var focusIntention: String = ""
    @State private var breathingScale: CGFloat = 1.0

    private var theme: GentlePlatformTheme { themeManager.current }

    var body: some View {
        ZStack {
            backgroundLayer

            VStack(spacing: 0) {
                topBar
                Spacer()
                timerDisplay
                Spacer()
                controlArea
            }
            .padding(.horizontal, 24)

            if engine.showComplete {
                completionOverlay
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
            }
        }
        .navigationBarHidden(true)
        .onDisappear { engine.stop() }
        .onChange(of: engine.isRunning) { _, running in
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                breathingScale = running ? 1.04 : 1.0
            }
        }
    }

    // MARK: - Background

    private var backgroundLayer: some View {
        ZStack {
            Gentle.Glass.baseBackground.ignoresSafeArea()

            // 顶部微光
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            engine.isRunning ? theme.primary.opacity(0.10) : theme.secondary.opacity(0.06),
                            .clear
                        ],
                        center: .top, startRadius: 0, endRadius: 350
                    )
                )
                .frame(width: 500, height: 500)
                .offset(y: -220)
                .animation(.easeInOut(duration: 1.0), value: engine.isRunning)

            // 底部微光
            if engine.isRunning {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [theme.accent.opacity(0.08), .clear],
                            center: .bottom, startRadius: 0, endRadius: 320
                        )
                    )
                    .frame(width: 400, height: 400)
                    .offset(y: 300)
                    .transition(.opacity)
            }

            // 浮动粒子光点
            if engine.isRunning {
                floatingParticles
            }
        }
        .ignoresSafeArea()
    }

    private var floatingParticles: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                context.blendMode = .plusLighter

                for i in 0..<8 {
                    let x = size.width * 0.5 + sin(t * 0.3 + Double(i) * 0.8) * 120
                    let y = size.height * 0.35 + cos(t * 0.4 + Double(i) * 0.7) * 100
                    let alpha = 0.08 + sin(t * 0.6 + Double(i)) * 0.04
                    context.fill(
                        Path(ellipseIn: CGRect(x: x - 2, y: y - 2, width: 4, height: 4)),
                        with: .color(theme.secondary.opacity(alpha))
                    )
                }
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button { engine.stop(); dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Gentle.Glass.textTertiary)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Gentle.Glass.borderWhite))
                    .overlay { Circle().stroke(Gentle.Glass.borderWhite, lineWidth: 0.5) }
            }

            Spacer()

            // 会话计数器
            if engine.completedSessions > 0 {
                HStack(spacing: 5) {
                    ForEach(0..<min(engine.completedSessions, 6), id: \.self) { _ in
                        Circle()
                            .fill(theme.accentGradient)
                            .frame(width: 5, height: 5)
                    }
                    Text("\(engine.completedSessions)")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(Gentle.Glass.textTertiary)
                }
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(Capsule().fill(Gentle.Glass.borderWhite))
                .overlay { Capsule().stroke(Gentle.Glass.borderWhite, lineWidth: 0.5) }
            }

            Spacer()
            Color.clear.frame(width: 36)
        }
        .padding(.top, 8)
    }

    // MARK: - Timer Display

    private var timerDisplay: some View {
        ZStack {
            // 外层呼吸光晕
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            engine.isRunning ? theme.primary.opacity(0.15) : theme.secondary.opacity(0.06),
                            .clear
                        ],
                        center: .center, startRadius: 100, endRadius: 210
                    )
                )
                .frame(width: 340, height: 340)
                .scaleEffect(breathingScale)

            // 背景环
            Circle()
                .stroke(.white.opacity(0.04), lineWidth: 8)
                .frame(width: 240, height: 240)

            // 进度环
            Circle()
                .trim(from: 0, to: engine.progress)
                .stroke(
                    AngularGradient(
                        colors: [
                            theme.secondary,
                            theme.primary,
                            theme.accent,
                            theme.secondary
                        ],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: 240, height: 240)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: engine.isRunning ? 0.3 : 0.5), value: engine.progress)

            // 进度指示点
            if engine.progress > 0.01 {
                Circle()
                    .fill(.white)
                    .frame(width: 10, height: 10)
                    .blur(radius: 3)
                    .offset(y: -120)
                    .rotationEffect(.degrees(engine.progress * 360))
                    .opacity(engine.isRunning ? 0.9 : 0.4)
            }

            // 内部呼吸环
            if engine.isRunning {
                Circle()
                    .stroke(theme.primary.opacity(0.08), lineWidth: 1)
                    .frame(width: 180, height: 180)
                    .scaleEffect(breathingScale)
            }

            // 时间与意图
            VStack(spacing: 6) {
                Text(engine.timeString)
                    .font(.system(size: 58, weight: .ultraLight, design: .monospaced))
                    .foregroundColor(Gentle.Glass.textPrimary)
                    .contentTransition(.numericText())

                if !focusIntention.isEmpty && engine.isRunning {
                    Text(focusIntention)
                        .font(.system(size: 13, weight: .light))
                        .foregroundColor(theme.secondary.opacity(0.6))
                        .lineLimit(1)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                Text(statusLabel)
                    .font(.system(size: 12, weight: .light))
                    .foregroundColor(Gentle.Glass.textTertiary)
            }
            .animation(.easeInOut(duration: 0.3), value: engine.isRunning)
        }
    }

    private var statusLabel: String {
        if engine.showComplete { return "完成！" }
        if engine.isPaused { return "已暂停" }
        if engine.isRunning { return "专注中 · 勿扰" }
        return "\(engine.selectedMinutes) 分钟专注"
    }

    // MARK: - Controls Area

    private var controlArea: some View {
        VStack(spacing: 24) {
            if !engine.isRunning {
                // 专注意图输入
                intentionInput
                    .transition(.move(edge: .bottom).combined(with: .opacity))

                // 时长选择
                durationPicker
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // 灵动岛错误提示
            if let error = engine.liveActivityError {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 12))
                    Text(error)
                        .font(.system(size: 12))
                }
                .foregroundColor(Color(hex: "#FBBF24"))
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "#FBBF24").opacity(0.1))
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "#FBBF24").opacity(0.2), lineWidth: 0.5)
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        engine.liveActivityError = nil
                    }
                }
            }

            // 主按钮
            mainButton

            // 运行时控制
            if engine.isRunning {
                HStack(spacing: 20) {
                    pauseResumeButton
                    stopButton
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .padding(.top, 4)
            }

            Spacer().frame(height: 50)
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.75), value: engine.isRunning)
    }

    // MARK: - Intention Input

    private var intentionInput: some View {
        HStack(spacing: 10) {
            Image(systemName: "target")
                .font(.system(size: 13))
                .foregroundColor(theme.secondary.opacity(0.5))

            TextField("这次专注做什么？", text: $focusIntention)
                .font(.system(size: 15, weight: .light))
                .foregroundColor(Gentle.Glass.textPrimary)

            if !focusIntention.isEmpty {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { focusIntention = "" }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Gentle.Glass.textTertiary)
                }
            }
        }
        .padding(.horizontal, 18).padding(.vertical, 14)
        .liquidGlassCard(cornerRadius: GentleRadius.xl, opacity: 0.35)
        .overlay {
            RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                .stroke(theme.secondary.opacity(0.1), lineWidth: 0.5)
        }
    }

    // MARK: - Duration Picker

    private var durationPicker: some View {
        VStack(spacing: 10) {
            HStack(spacing: 2) {
                Image(systemName: "timer")
                    .font(.system(size: 11))
                    .foregroundColor(theme.secondary.opacity(0.4))
                Text("选择时长")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Gentle.Glass.textTertiary)
                Spacer()
            }
            .padding(.horizontal, 4)

            HStack(spacing: 8) {
                ForEach(PomodoroEngine.presets, id: \.self) { mins in
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            engine.selectDuration(mins)
                        }
                    } label: {
                        VStack(spacing: 3) {
                            Text("\(mins)")
                                .font(.system(size: 20, weight: .light, design: .rounded))
                            Text("分")
                                .font(.system(size: 9, weight: .light))
                        }
                        .foregroundColor(engine.selectedMinutes == mins ? Gentle.Glass.textPrimary : Gentle.Glass.textTertiary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .liquidGlassCard(
                            cornerRadius: GentleRadius.lg,
                            opacity: engine.selectedMinutes == mins ? 0.55 : 0.25
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: GentleRadius.lg, style: .continuous)
                                .stroke(
                                    engine.selectedMinutes == mins
                                        ? theme.secondary.opacity(0.3)
                                        : .white.opacity(0.04),
                                    lineWidth: 0.5
                                )
                        }
                        .scaleEffect(engine.selectedMinutes == mins ? 1.04 : 1.0)
                    }
                    .buttonStyle(.plain)
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: engine.selectedMinutes)
        }
    }

    // MARK: - Main Button

    private var mainButton: some View {
        Button {
            if !engine.isRunning { engine.start() }
        } label: {
            ZStack {
                // 光晕
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                theme.primary.opacity(0.25),
                                theme.primary.opacity(0.06),
                                .clear
                            ],
                            center: .center, startRadius: 18, endRadius: 85
                        )
                    )
                    .frame(width: 120, height: 120)
                    .blur(radius: 5)

                // 按钮主体
                Circle()
                    .fill(theme.accentGradient)
                    .frame(width: 68, height: 68)
                    .shadow(color: theme.primary.opacity(0.45), radius: 22, y: 8)
                    .overlay {
                        Circle()
                            .stroke(.white.opacity(0.15), lineWidth: 0.5)
                    }
                    .overlay(alignment: .top) {
                        Circle()
                            .fill(.white.opacity(0.12))
                            .frame(height: 0.5)
                            .padding(.horizontal, 2)
                            .offset(y: 2)
                    }

                Image(systemName: "play.fill")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
                    .offset(x: 1)
            }
        }
        .disabled(engine.isRunning)
        .opacity(engine.isRunning ? 0 : 1)
        .scaleEffect(engine.isRunning ? 0.5 : 1)
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: engine.isRunning)
    }

    // MARK: - Pause / Resume

    private var pauseResumeButton: some View {
        Button { engine.togglePause() } label: {
            Label(
                engine.isPaused ? "继续" : "暂停",
                systemImage: engine.isPaused ? "play.fill" : "pause.fill"
            )
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(Gentle.Glass.textPrimary)
            .padding(.horizontal, 28).padding(.vertical, 15)
            .liquidGlassCard(cornerRadius: GentleRadius.xl, opacity: 0.55)
            .overlay {
                RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                    .stroke(theme.secondary.opacity(0.15), lineWidth: 0.5)
            }
        }
    }

    // MARK: - Stop

    private var stopButton: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                engine.stopAndReset()
            }
        } label: {
            Label("结束", systemImage: "stop.fill")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "#F87171"))
                .padding(.horizontal, 28).padding(.vertical, 15)
                .liquidGlassCard(cornerRadius: GentleRadius.xl, opacity: 0.35)
                .overlay {
                    RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                        .stroke(Color(hex: "#F87171").opacity(0.12), lineWidth: 0.5)
                }
        }
    }

    // MARK: - Completion Overlay

    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.65).ignoresSafeArea()

            VStack(spacing: 24) {
                // 光环
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [theme.secondary.opacity(0.2), .clear],
                                center: .center, startRadius: 10, endRadius: 80
                            )
                        )
                        .frame(width: 150, height: 150)

                    Circle()
                        .stroke(theme.secondary.opacity(0.15), lineWidth: 1)
                        .frame(width: 110, height: 110)

                    Text("🎉")
                        .font(.system(size: 56))
                }

                // 文字
                VStack(spacing: 6) {
                    Text("太棒了！")
                        .font(.system(size: 28, weight: .thin, design: .serif))
                        .foregroundColor(.white)

                    Text(focusIntention.isEmpty ? "一个番茄钟完成了" : "「\(focusIntention)」完成")
                        .font(.system(size: 15, weight: .light))
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                }

                // 按钮
                HStack(spacing: 14) {
                    Button {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            engine.dismissCompletion()
                            focusIntention = ""
                        }
                    } label: {
                        Text("继续专注")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 28).padding(.vertical, 13)
                            .background {
                                Capsule().fill(theme.accentGradient)
                            }
                            .overlay(alignment: .top) {
                                Capsule()
                                    .fill(.white.opacity(0.15))
                                    .frame(height: 0.5)
                                    .padding(.horizontal, 2)
                            }
                            .shadow(color: theme.primary.opacity(0.3), radius: 12, y: 6)
                    }

                    Button {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            engine.dismissCompletion()
                        }
                        dismiss()
                    } label: {
                        Text("休息一下")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                            .padding(.horizontal, 28).padding(.vertical, 13)
                            .background {
                                Capsule().fill(.white.opacity(0.06))
                            }
                            .overlay {
                                Capsule().stroke(.white.opacity(0.08), lineWidth: 0.5)
                            }
                    }
                }
            }
            .padding(36)
            .liquidGlassElevated(cornerRadius: 36)
        }
    }
}

// MARK: - Pomodoro Engine

final class PomodoroEngine: ObservableObject, @unchecked Sendable {
    static let presets = [15, 25, 30, 45, 60]

    @Published var selectedMinutes = 25
    @Published var remainingSeconds: Int = 25 * 60
    @Published var totalSeconds: Int = 25 * 60
    @Published var isRunning = false
    @Published var isPaused = false
    @Published var completedSessions = 0
    @Published var showComplete = false
    @Published var liveActivityError: String?

    private var timer: Timer?
    private var currentActivity: Activity<PomodoroActivityAttributes>?
    private var lastActivityUpdate: Int = -1

    var timeString: String {
        let m = remainingSeconds / 60, s = remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    var progress: CGFloat {
        guard totalSeconds > 0 else { return 0 }
        return CGFloat(totalSeconds - remainingSeconds) / CGFloat(totalSeconds)
    }

    func selectDuration(_ mins: Int) {
        selectedMinutes = mins
        remainingSeconds = mins * 60
        totalSeconds = mins * 60
        showComplete = false
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true; isPaused = false; showComplete = false
        liveActivityError = nil
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.tick() }
        }
        Task { @MainActor in
            await startLiveActivity()
        }
    }

    func togglePause() {
        if isPaused {
            isPaused = false
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                MainActor.assumeIsolated { self?.tick() }
            }
        } else {
            isPaused = true
            timer?.invalidate()
            timer = nil
        }
        updateLiveActivity()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isPaused = false
        endLiveActivity()
    }

    func stopAndReset() {
        stop()
        remainingSeconds = selectedMinutes * 60
        totalSeconds = selectedMinutes * 60
    }

    func dismissCompletion() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { showComplete = false }
        stop()
        remainingSeconds = selectedMinutes * 60
        totalSeconds = selectedMinutes * 60
        isRunning = false
    }

    private func tick() {
        guard !isPaused else { return }
        if remainingSeconds > 0 {
            remainingSeconds -= 1
            updateLiveActivity()
        } else {
            stop()
            completedSessions += 1
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { showComplete = true }
        }
    }

    @MainActor
    private func startLiveActivity() async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            liveActivityError = "请在设置中开启实时活动"
            print("【番茄钟】实时活动未授权")
            return
        }
        let attributes = PomodoroActivityAttributes()
        let state = PomodoroActivityAttributes.PomodoroStatus(
            remainingSeconds: remainingSeconds, totalSeconds: totalSeconds,
            isPaused: false, sessionNumber: completedSessions + 1
        )
        let content = ActivityContent(state: state, staleDate: nil)
        do {
            let activity = try await Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
            currentActivity = activity
            lastActivityUpdate = remainingSeconds
            print("【番茄钟】灵动岛已启动")
        } catch {
            liveActivityError = "启动失败: \(error.localizedDescription)"
            print("【番茄钟】灵动岛启动失败: \(error)")
        }
    }

    private func updateLiveActivity() {
        guard let activity = currentActivity, remainingSeconds != lastActivityUpdate else { return }
        lastActivityUpdate = remainingSeconds
        let state = PomodoroActivityAttributes.PomodoroStatus(
            remainingSeconds: remainingSeconds, totalSeconds: totalSeconds,
            isPaused: isPaused, sessionNumber: completedSessions + 1
        )
        Task {
            await activity.update(ActivityContent(state: state, staleDate: nil))
        }
    }

    private func endLiveActivity() {
        guard let activity = currentActivity else { return }
        let state = PomodoroActivityAttributes.PomodoroStatus(
            remainingSeconds: remainingSeconds, totalSeconds: totalSeconds,
            isPaused: false, sessionNumber: completedSessions + 1
        )
        Task {
            await activity.end(ActivityContent(state: state, staleDate: nil), dismissalPolicy: .immediate)
        }
        currentActivity = nil
        lastActivityUpdate = -1
    }
}
