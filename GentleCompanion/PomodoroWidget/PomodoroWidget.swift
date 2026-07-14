//
//  PomodoroWidget.swift
//  PomodoroWidget
//
//  番茄钟灵动岛 & 锁屏实时活动 — 重构版
//

import WidgetKit
import SwiftUI
import ActivityKit

// MARK: - Live Activity Widget

struct PomodoroLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PomodoroActivityAttributes.self) { context in
            lockScreenView(context)
        } dynamicIsland: { context in
            DynamicIsland {
                // ── 左侧：状态图标 ──
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: context.state.isPaused ? "pause.fill" : "flame.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(
                            context.state.isPaused
                                ? Color(hex: "#FBBF24")
                                : Color(hex: "#C084FC")
                        )
                }

                // ── 右侧：进度百分比 ──
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(Int(context.state.progress * 100))%")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(
                            context.state.isPaused
                                ? Color(hex: "#FBBF24").opacity(0.7)
                                : Color(hex: "#A78BFA").opacity(0.7)
                        )
                        .contentTransition(.numericText())
                }

                // ── 中央：大时间 + 进度条 ──
                DynamicIslandExpandedRegion(.center) {
                    GeometryReader { geo in
                        VStack(spacing: 6) {
                            Text(context.state.timeString)
                                .font(.system(size: 34, weight: .regular, design: .monospaced))
                                .foregroundColor(.white)
                                .contentTransition(.numericText())
                                .frame(maxWidth: .infinity, alignment: .center)

                            // 发光进度条
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(.white.opacity(0.06))
                                    .frame(height: 3)

                                RoundedRectangle(cornerRadius: 2)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(hex: "#7C3AED"),
                                                Color(hex: "#A78BFA"),
                                                Color(hex: "#EC4899")
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(
                                        width: max(3, geo.size.width * context.state.progress),
                                        height: 3
                                    )
                                    .shadow(
                                        color: Color(hex: "#A78BFA").opacity(0.5),
                                        radius: 3, x: 0, y: 0
                                    )

                                // 进度头光点
                                if context.state.progress > 0.01 {
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 4, height: 4)
                                        .shadow(
                                            color: Color(hex: "#A78BFA").opacity(0.8),
                                            radius: 4, x: 0, y: 0
                                        )
                                        .offset(
                                            x: max(2, geo.size.width * context.state.progress - 2)
                                        )
                                }
                            }
                            .padding(.horizontal, 2)
                        }
                    }
                }

                // ── 底部：番茄编号 ──
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text(context.state.isPaused ? "已暂停" : "深度专注")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(
                                context.state.isPaused
                                    ? Color(hex: "#FBBF24").opacity(0.6)
                                    : Color(hex: "#A78BFA").opacity(0.5)
                            )
                        Spacer()
                        HStack(spacing: 4) {
                            ForEach(0..<3) { i in
                                Image(systemName: i < context.state.sessionNumber % 3 + 1
                                    ? "flame.fill"
                                    : "flame"
                                )
                                .font(.system(size: 10))
                                .foregroundColor(
                                    i < context.state.sessionNumber % 3 + 1
                                        ? Color(hex: "#F59E0B").opacity(0.8)
                                        : .white.opacity(0.1)
                                )
                            }
                        }
                        .padding(.trailing, 2)
                    }
                    .padding(.horizontal, 6)
                    .padding(.bottom, 4)
                }

            // ── 紧凑模式 ──
            } compactLeading: {
                HStack(spacing: 3) {
                    Image(systemName: context.state.isPaused ? "pause.fill" : "flame.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(
                            context.state.isPaused
                                ? Color(hex: "#FBBF24")
                                : Color(hex: "#C084FC")
                        )
                    Text(context.state.timeString)
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white)
                }
            } compactTrailing: {
                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.1), lineWidth: 2)
                        .frame(width: 18, height: 18)
                    Circle()
                        .trim(from: 0, to: context.state.progress)
                        .stroke(
                            AngularGradient(
                                colors: [Color(hex: "#A78BFA"), Color(hex: "#EC4899")],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 2, lineCap: .round)
                        )
                        .frame(width: 18, height: 18)
                        .rotationEffect(.degrees(-90))
                }
            } minimal: {
                Circle()
                    .trim(from: 0, to: context.state.progress)
                    .stroke(
                        AngularGradient(
                            colors: [Color(hex: "#A78BFA"), Color(hex: "#EC4899")],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                    )
                    .frame(width: 16, height: 16)
                    .rotationEffect(.degrees(-90))
            }
        }
    }

    // MARK: - Lock Screen

    @ViewBuilder
    private func lockScreenView(_ context: ActivityViewContext<PomodoroActivityAttributes>) -> some View {
        HStack(spacing: 18) {
            // 进度圆环
            ZStack {
                Circle()
                    .stroke(.white.opacity(0.06), lineWidth: 5)
                    .frame(width: 58, height: 58)

                Circle()
                    .trim(from: 0, to: context.state.progress)
                    .stroke(
                        AngularGradient(
                            colors: [
                                Color(hex: "#7C3AED"),
                                Color(hex: "#A78BFA"),
                                Color(hex: "#EC4899")
                            ],
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(270)
                        ),
                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                    )
                    .frame(width: 58, height: 58)

                Image(systemName: context.state.isPaused ? "pause.fill" : "flame.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(
                        context.state.isPaused
                            ? Color(hex: "#FBBF24")
                            : Color(hex: "#F59E0B")
                    )
            }

            // 右侧信息
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(context.state.isPaused ? "已暂停" : "深度专注")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.35))
                    if context.state.isPaused {
                        Circle()
                            .fill(Color(hex: "#FBBF24").opacity(0.6))
                            .frame(width: 4, height: 4)
                    }
                    Spacer()
                }

                Text(context.state.timeString)
                    .font(.system(size: 36, weight: .thin, design: .monospaced))
                    .foregroundColor(.white)
                    .contentTransition(.numericText())

                // 进度条
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(.white.opacity(0.05))
                            .frame(height: 3)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "#7C3AED"), Color(hex: "#EC4899")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(3, geo.size.width * context.state.progress), height: 3)
                            .shadow(color: Color(hex: "#A78BFA").opacity(0.3), radius: 3, x: 0, y: 0)
                    }
                }
                .frame(height: 3)

                HStack {
                    Text("\(context.state.totalSeconds / 60) 分钟")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.3))
                    Spacer()
                    Text("第\(context.state.sessionNumber)个番茄")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(hex: "#FCD34D").opacity(0.4))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

// MARK: - Color Extension

private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
