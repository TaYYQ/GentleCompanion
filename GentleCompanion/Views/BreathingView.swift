//
//  BreathingView.swift
//  GentleCompanion
//
//  4-4-6-2 呼吸引导 — 氛围感设计
//

import SwiftUI

struct BreathingView: View {
    @Binding var isPresented: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var phase: BreathingPhase = .inhale
    @State private var countdown: Int = 4
    @State private var progress: Double = 0
    @State private var cycleCount: Int = 0
    @State private var timer: Timer?
    @State private var isRunning: Bool = false
    @State private var orbScale: CGFloat = 0.55
    @State private var orbOpacity: Double = 0.6

    private let phases: [(phase: BreathingPhase, duration: Int)] = [
        (.inhale, 4),
        (.holdIn, 4),
        (.exhale, 6),
        (.holdOut, 2)
    ]

    // MARK: - Body

    var body: some View {
        ZStack {
            darkAtmosphere
                .ignoresSafeArea()

            ParticleField(phase: phase, isRunning: isRunning)

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 32)
                    .padding(.top, 24)

                Spacer()

                breathingOrb

                Spacer()

                bottomControls
                    .padding(.horizontal, 32)
                    .padding(.bottom, 36)
            }
        }
        .onDisappear { timer?.invalidate() }
    }

    // MARK: - Background

    private var darkAtmosphere: some View {
        ZStack {
            Color(hex: "#0D0A1A")

            RadialGradient(
                colors: [phase.ambientColor.opacity(0.35), Color.clear],
                center: .center,
                startRadius: 0,
                endRadius: 400
            )

            RadialGradient(
                colors: [Color(hex: "#1A0F35").opacity(0.8), Color(hex: "#0D0A1A")],
                center: .bottom,
                startRadius: 0,
                endRadius: 500
            )

            GridNoiseOverlay()
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(width: 32, height: 32)
                    .background(.white.opacity(0.08))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Spacer()

            VStack(spacing: 2) {
                Text("呼吸练习")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))

                Text("\(cycleCount) 轮完成")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.4))
            }

            Spacer()

            Color.clear.frame(width: 32, height: 32)
        }
    }

    // MARK: - Orb

    private var breathingOrb: some View {
        ZStack {
            // 进度弧
            Circle()
                .trim(from: 0, to: progress)
                .stroke(phase.orbColor.opacity(0.25), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                .frame(width: 340, height: 340)
                .rotationEffect(.degrees(-90))
                .shadow(color: phase.orbColor.opacity(0.3), radius: 8)

            // 轨迹圆
            Circle()
                .stroke(.white.opacity(0.06), lineWidth: 1)
                .frame(width: 340, height: 340)

            // 脉冲环
            Circle()
                .stroke(phase.orbColor.opacity(0.12), lineWidth: 24)
                .frame(width: 280, height: 280)
                .scaleEffect(orbScale * 1.08)
                .opacity(isRunning ? 1 : 0.3)

            // 光晕
            Circle()
                .fill(
                    RadialGradient(colors: [phase.orbColor.opacity(0.15), Color.clear], center: .center, startRadius: 0, endRadius: 140)
                )
                .frame(width: 280, height: 280)
                .scaleEffect(orbScale)
                .blur(radius: 20)

            // 主球体
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.white.opacity(0.75), phase.orbColor.opacity(0.75), phase.orbColor.opacity(0.25)],
                        center: UnitPoint(x: 0.35, y: 0.35),
                        startRadius: 0,
                        endRadius: 110
                    )
                )
                .frame(width: 220, height: 220)
                .scaleEffect(orbScale)
                .shadow(color: phase.orbColor.opacity(0.5), radius: 30, x: 0, y: 0)
                .shadow(color: phase.orbColor.opacity(0.25), radius: 60, x: 0, y: 10)

            // 中心文字
            VStack(spacing: 0) {
                if isRunning {
                    // 阶段标签
                    Text(phase.displayText)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(phase.orbColor.opacity(0.9))
                        .tracking(6)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 5)
                        .background(phase.orbColor.opacity(0.15))
                        .clipShape(Capsule())
                        .padding(.bottom, 14)

                    // 倒计时数字
                    Text("\(countdown)")
                        .font(.system(size: 58, weight: .light, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, phase.orbColor.opacity(0.85)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.2), value: countdown)
                        .frame(width: 80)

                    // 秒
                    Text("秒")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundStyle(.white.opacity(0.35))
                        .padding(.top, 4)
                } else {
                    Image(systemName: "wind")
                        .font(.system(size: 22, weight: .light))
                        .foregroundStyle(.white.opacity(0.35))
                        .padding(.bottom, 8)

                    Text("准备好了吗")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
            .scaleEffect(orbScale * 1.1) // 跟随球体呼吸，稍大一点确保可见
        }
    }

    // MARK: - Bottom Controls

    private var bottomControls: some View {
        VStack(spacing: 24) {
            rhythmTrack
            mainButton
        }
    }

    private var rhythmTrack: some View {
        HStack(spacing: 8) {
            ForEach(Array(phases.enumerated()), id: \.offset) { idx, item in
                VStack(spacing: 6) {
                    Circle()
                        .fill(
                            item.phase == phase
                                ? item.phase.orbColor
                                : (isPhasePast(item.phase) ? item.phase.orbColor.opacity(0.4) : .white.opacity(0.15))
                        )
                        .frame(width: 8, height: 8)
                        .overlay {
                            if item.phase == phase && isRunning {
                                Circle()
                                    .stroke(item.phase.orbColor, lineWidth: 1.5)
                                    .frame(width: 16, height: 16)
                                    .scaleEffect(orbScale)
                                    .opacity(orbOpacity)
                            }
                        }

                    Text(item.phase.displayText)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(item.phase == phase ? .white.opacity(0.9) : .white.opacity(0.3))

                    Text("\(item.duration)秒")
                        .font(.system(size: 10))
                        .foregroundStyle(item.phase.orbColor.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .background(.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var mainButton: some View {
        Button {
            isRunning ? stopBreathing() : startBreathing()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: isRunning ? "stop.fill" : "play.fill")
                    .font(.system(size: 13, weight: .semibold))
                Text(isRunning ? "停止" : "开始练习")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(btnBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                if !isRunning {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                }
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
    }

    private var btnBackground: some ShapeStyle {
        isRunning
            ? AnyShapeStyle(Color.white.opacity(0.1))
            : AnyShapeStyle(LinearGradient(colors: [phase.orbColor, phase.orbColor.opacity(0.7)], startPoint: .leading, endPoint: .trailing))
    }

    // MARK: - Helpers

    private func isPhasePast(_ targetPhase: BreathingPhase) -> Bool {
        guard let currentIdx = phases.firstIndex(where: { $0.phase == phase }),
              let targetIdx  = phases.firstIndex(where: { $0.phase == targetPhase }) else {
            return false
        }
        return targetIdx < currentIdx
    }

    // MARK: - Timer

    private func startBreathing() {
        isRunning = true
        cycleCount = 0
        progress = 0
        runPhase(at: 0)
    }

    private func stopBreathing() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        withAnimation(.easeInOut(duration: 0.8)) {
            orbScale = 0.55
            orbOpacity = 0.6
            progress = 0
        }
        phase = .inhale
        countdown = 4
    }

    private func runPhase(at index: Int) {
        guard isRunning else { return }
        let item = phases[index]
        phase = item.phase
        countdown = item.duration
        progress = 0

        let duration = Double(item.duration)

        withAnimation(.easeInOut(duration: duration)) {
            switch item.phase {
            case .inhale:
                orbScale = 1.0; orbOpacity = 1.0
            case .holdIn:
                orbScale = 1.0; orbOpacity = 0.85
            case .exhale:
                orbScale = 0.55; orbOpacity = 0.6
            case .holdOut:
                orbScale = 0.55; orbOpacity = 0.45
            }
        }

        withAnimation(.linear(duration: duration)) {
            progress = 1.0
        }

        if index == 0 { cycleCount += 1 }

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
            Task { @MainActor in
                runPhase(at: (index + 1) % phases.count)
            }
        }
    }
}

// MARK: - BreathingPhase

enum BreathingPhase: CaseIterable {
    case inhale, holdIn, exhale, holdOut

    var displayText: String {
        switch self {
        case .inhale:  return "吸气"
        case .holdIn:  return "保持"
        case .exhale:  return "呼气"
        case .holdOut: return "保持"
        }
    }

    var orbColor: Color {
        switch self {
        case .inhale:  return Color(hex: "#C084FC")
        case .holdIn:  return Color(hex: "#818CF8")
        case .exhale:  return Color(hex: "#F472B6")
        case .holdOut: return Color(hex: "#6366F1")
        }
    }

    var ambientColor: Color {
        switch self {
        case .inhale:  return Color(hex: "#7C3AED")
        case .holdIn:  return Color(hex: "#4F46E5")
        case .exhale:  return Color(hex: "#DB2777")
        case .holdOut: return Color(hex: "#4338CA")
        }
    }
}

// MARK: - ParticleField

struct ParticleField: View {
    let phase: BreathingPhase
    let isRunning: Bool

    @State private var particles: [BreathParticle] = (0..<20).map { BreathParticle(index: $0) }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 60.0)) { timeline in
            Canvas { ctx, size in
                let t = timeline.date.timeIntervalSinceReferenceDate

                for p in particles {
                    let cycle = size.height * 1.5
                    let yOffset = CGFloat(t * p.speed + p.delay).truncatingRemainder(dividingBy: cycle)
                    let xDrift = CGFloat(sin(t * p.speed + p.delay)) * 18

                    let x = CGFloat(p.x) * size.width + xDrift
                    let y = size.height - yOffset + cycle / 2

                    let alpha = isRunning ? p.opacity : p.opacity * 0.25

                    ctx.fill(
                        Circle().path(in: CGRect(x: x, y: y, width: p.size, height: p.size)),
                        with: .color(phase.orbColor.opacity(alpha))
                    )
                }
            }
        }
    }
}

// MARK: - BreathParticle

struct BreathParticle {
    let index: Int
    let x: CGFloat = .random(in: 0.05...0.95)
    let y: CGFloat = .random(in: 0...1)
    let size: CGFloat = .random(in: 1.5...4.5)
    let speed: Double = .random(in: 0.2...0.7)
    let delay: Double = .random(in: 0...6)
    let opacity: Double = .random(in: 0.08...0.35)
}

// MARK: - Grid Noise Overlay

struct GridNoiseOverlay: View {
    var body: some View {
        Canvas { ctx, size in
            let spacing: CGFloat = 40
            ctx.stroke(
                Path { p in
                    var x: CGFloat = 0
                    while x <= size.width {
                        p.move(to: CGPoint(x: x, y: 0))
                        p.addLine(to: CGPoint(x: x, y: size.height))
                        x += spacing
                    }
                    var y: CGFloat = 0
                    while y <= size.height {
                        p.move(to: CGPoint(x: 0, y: y))
                        p.addLine(to: CGPoint(x: size.width, y: y))
                        y += spacing
                    }
                },
                with: .color(.white.opacity(0.025)),
                lineWidth: 0.5
            )
        }
    }
}

#Preview {
    BreathingView(isPresented: .constant(true))
}
