//
//  BreathingiOSView.swift
//  GentleCompanion iOS
//
//  4-7-8 深呼吸引导 — iOS 26/27 玻璃态
//

import SwiftUI

struct BreathingiOSView: View {
    @Environment(\.dismiss) private var dismiss

    enum Phase: String {
        case ready = "准备"
        case inhale = "吸气"
        case hold = "屏息"
        case exhale = "呼气"

        var duration: Double {
            switch self {
            case .ready:  return 2
            case .inhale: return 4
            case .hold:   return 7
            case .exhale: return 8
            }
        }

        var color: Color {
            switch self {
            case .ready:  return Color(hex: "#A78BFA")
            case .inhale: return Color(hex: "#60A5FA")
            case .hold:   return Color(hex: "#FCD34D")
            case .exhale: return Color(hex: "#F472B6")
            }
        }

        var instruction: String {
            switch self {
            case .ready:  return "找一个舒服的姿势..."
            case .inhale: return "用鼻子慢慢吸气"
            case .hold:   return "轻轻地屏住呼吸"
            case .exhale: return "用嘴巴缓缓呼出"
            }
        }
    }

    @State private var phase: Phase = .ready
    @State private var progress: CGFloat = 0
    @State private var isActive = false
    @State private var cycleCount = 0
    @State private var totalCycles = 4
    @State private var showComplete = false

    private let phases: [Phase] = [.inhale, .hold, .exhale]

    var body: some View {
        ZStack {
            Color(hex: "#080810").ignoresSafeArea()

            VStack(spacing: 0) {
                // 导航
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                            )
                    }
                    Spacer()
                    Text("深呼吸")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                    Spacer()
                    Text("\(cycleCount)/\(totalCycles)")
                        .font(.system(size: 14, weight: .light, design: .monospaced))
                        .foregroundColor(.white.opacity(0.3))
                        .frame(width: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                Spacer()

                // 呼吸圆
                ZStack {
                    // 外围光晕
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [phase.color.opacity(0.12), .clear],
                                center: .center,
                                startRadius: 100,
                                endRadius: 200
                            )
                        )
                        .frame(width: 300, height: 300)
                        .blur(radius: 20)

                    // 背景环
                    Circle()
                        .stroke(.white.opacity(0.06), lineWidth: 2)
                        .frame(width: 240, height: 240)

                    // 进度环
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            AngularGradient(
                                colors: [phase.color, phase.color.opacity(0.5)],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 240, height: 240)
                        .rotationEffect(.degrees(-90))

                    // 呼吸球
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [phase.color.opacity(0.5), phase.color.opacity(0.05)],
                                center: .center,
                                startRadius: 0,
                                endRadius: 110 * scaleForPhase
                            )
                        )
                        .frame(width: 220 * scaleForPhase, height: 220 * scaleForPhase)
                        .animation(.easeInOut(duration: phase.duration), value: scaleForPhase)
                        .shadow(color: phase.color.opacity(0.2), radius: 40)

                    // 阶段文字
                    VStack(spacing: 10) {
                        Text(phase.rawValue)
                            .font(.system(size: 40, weight: .thin, design: .serif))
                            .foregroundColor(.white)

                        Text(phase.instruction)
                            .font(.system(size: 13, weight: .light))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }

                Spacer()

                // 底部
                VStack(spacing: 20) {
                    if showComplete {
                        completeView
                    } else if !isActive {
                        startButton
                    } else {
                        Color.clear.frame(height: 60)
                    }
                }
                .padding(.bottom, 80)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private var startButton: some View {
        Button {
            startBreathing()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "wind")
                    .font(.system(size: 16))
                Text("开始呼吸练习")
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(.white)
            .frame(maxWidth: 260)
            .frame(height: 54)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#A78BFA"), Color(hex: "#7C3AED")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: Color(hex: "#A78BFA").opacity(0.3), radius: 20, y: 8)
            )
        }
    }

    private var completeView: some View {
        VStack(spacing: 20) {
            Text("🌸")
                .font(.system(size: 52))

            Text("你做得很好")
                .font(.system(size: 24, weight: .thin, design: .serif))
                .foregroundColor(.white)

            Text("完成了 \(totalCycles) 轮深呼吸\n感觉更平静了吗？")
                .font(.system(size: 14, weight: .light))
                .foregroundColor(.white.opacity(0.4))
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Button {
                cycleCount = 0
                showComplete = false
                phase = .ready
                progress = 0
                startBreathing()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                    Text("再来一次")
                }
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.ultraThinMaterial)
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.1), lineWidth: 0.5))
                )
            }
        }
    }

    private var scaleForPhase: CGFloat {
        switch phase {
        case .ready, .hold:  return 1.0
        case .inhale: return 1.3
        case .exhale: return 0.72
        }
    }

    private func startBreathing() {
        isActive = true
        showComplete = false
        runPhase(index: 0)
    }

    private func runPhase(index: Int) {
        guard index < phases.count else {
            cycleCount += 1
            if cycleCount >= totalCycles {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isActive = false
                    showComplete = true
                    phase = .ready
                    progress = 0
                }
                return
            }
            runPhase(index: 0)
            return
        }

        let currentPhase = phases[index]
        phase = currentPhase
        progress = 0

        withAnimation(.linear(duration: currentPhase.duration)) {
            progress = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + currentPhase.duration) {
            runPhase(index: index + 1)
        }
    }
}
