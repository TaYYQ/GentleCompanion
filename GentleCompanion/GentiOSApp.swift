//
//  GentiOSApp.swift
//  GentleCompanion iOS
//
//  App 入口：电影级启动动画 → 主界面
//

import SwiftUI

@MainActor
final class GentleAppState: ObservableObject {
    static let shared = GentleAppState()
    @Published var hideTabBar: Bool = false
    private init() {}
}

@main
struct GentiOSApp: App {
    @State private var showSplash = true
    @State private var showServerSetup = false
    @State private var showActivation = false
    @StateObject private var theme = GentleThemeManager.shared
    @AppStorage("hasCompletedActivation") private var hasCompletedActivation = false
    @AppStorage("hasConfiguredServer") private var hasConfiguredServer = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                GentiOSMainView()
                    .opacity(showSplash ? 0 : 1)

                if showSplash {
                    CinematicSplashView(isPresented: $showSplash)
                        .zIndex(100)
                }

                if showServerSetup {
                    ServerSetupView(
                        onComplete: {
                            hasConfiguredServer = true
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                showServerSetup = false
                            }
                            proceedToActivation()
                        },
                        onSkip: {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                showServerSetup = false
                            }
                            proceedToActivation()
                        }
                    )
                    .zIndex(98)
                }

                if showActivation {
                    ActivationView()
                        .zIndex(99)
                        .onReceive(NotificationCenter.default.publisher(for: .activationComplete)) { _ in
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                showActivation = false
                            }
                            hasCompletedActivation = true
                        }
                }
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showSplash)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showServerSetup)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showActivation)
            .onChange(of: showSplash) { _, newValue in
                guard !newValue else { return }
                if !hasCompletedActivation {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            showServerSetup = true
                        }
                    }
                }
            }
        }
    }

    private func proceedToActivation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showActivation = true
            }
        }
    }
}

// MARK: - Cinematic Splash Animation
//  启动动画与 App 图标深度融合：
//  图标核心元素：珊瑚红心形 + 两侧白色胶囊 → 平滑演进为品牌紫调启动画面
//
//  时间线 (总长约 4.2s):
//    0.0s — 图标元素淡入
//    0.35s — 心跳脉动, 胶囊溶解
//    0.8s — 色彩演变（珊瑚→紫调）, 粒子绽放
//    1.5s — 柔光极光层浮现（替代生硬光球/光环）
//    2.0s — 标题"温柔点"从极光中浮现, 停留 1.4s
//    3.4s — 全场景优雅渐隐 + 微亮过渡

enum CinematicPhase {
    case iconManifest    // 0.0s: 图标元素呈现（心形+胶囊）
    case iconPulse       // 0.35s: 心跳脉动，胶囊溶解
    case chromaticEvolve // 0.8s: 色彩演变（珊瑚→紫调）
    case brandAwaken     // 1.5s: 柔光极光浮现
    case titleReveal     // 2.0s: 标题呈现
    case dissolve        // 3.4s: 优雅渐隐
}

struct CinematicSplashView: View {
    @Binding var isPresented: Bool
    @State private var phase: CinematicPhase = .iconManifest
    @State private var tick: Double = 0

    // ——— 图标层：心形 + 胶囊 ———
    @State private var iconOpacity: Double = 0
    @State private var iconScale: CGFloat = 0.82
    @State private var heartBeatScale: CGFloat = 1.0
    @State private var heartGlowRadius: CGFloat = 0
    @State private var heartGlowOpacity: Double = 0

    // 胶囊溶解
    @State private var leftCapsuleOpacity: Double = 0
    @State private var rightCapsuleOpacity: Double = 0
    @State private var leftCapsuleXOffset: CGFloat = -22
    @State private var rightCapsuleXOffset: CGFloat = 22
    @State private var capsuleBlur: CGFloat = 0

    // 色彩演变
    @State private var coralToVioletBlend: Double = 0       // 0=珊瑚, 1=紫
    @State private var bgTransitionProgress: Double = 0     // 0=图标暗色, 1=深空

    // ——— 绽放粒子 ———
    @State private var bloomParticles: [BloomParticle] = []
    @State private var phase2Tick: Double = -999

    // ——— 柔光极光层（替代光球+光环）———
    @State private var auroraOpacity: Double = 0
    @State private var auroraScale: CGFloat = 0.4
    @State private var auroraInnerGlow: CGFloat = 0

    // 漂浮光点
    @State private var floatingMotes: [FloatingMote] = []

    // 背景星点
    @State private var bgStarParticles: [SplashParticle] = []

    // ——— 标题 ———
    @State private var titleChars: [CharState] = []
    @State private var titleYOffset: CGFloat = 40       // 标题整体位移
    @State private var titleEntranceOpacity: Double = 0 // 标题区入场
    @State private var dividerWidth: CGFloat = 0
    @State private var subtitleOpacity: Double = 0
    @State private var subtitleOffset: CGFloat = 16

    // ——— 渐隐过渡 ———
    @State private var dissolveProgress: Double = 0     // 0=正常, 1=完全过渡
    @State private var sceneBrightness: CGFloat = 0     // 场景提亮
    @State private var sceneOpacity: Double = 1         // 场景整体透明度

    // MARK: - Visual Constants

    private let titleText = "温柔点"
    private let iconCoral   = Color(hex: "#F47A6A")
    private let coralWarm   = Color(hex: "#FBA08C")
    private let coralDeep   = Color(hex: "#E86050")
    private let violetPrimary = Color(hex: "#7C3AED")
    private let violetSecondary = Color(hex: "#A78BFA")
    private let violetAccent = Color(hex: "#C084FC")
    private let pinkAccent  = Color(hex: "#EC4899")
    private let iconBgDark  = Color(hex: "#151518")
    private let spaceDeep   = Color(hex: "#060610")

    // 当前心形颜色（插值）
    private var heartColor: Color {
        blendColor(from: iconCoral, to: violetSecondary, progress: coralToVioletBlend)
    }

    // 当前背景色
    private var currentBg: Color {
        blendColor(from: iconBgDark, to: spaceDeep, progress: bgTransitionProgress)
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let iconSize = min(geo.size.width, geo.size.height) * 0.22

            ZStack {
                // ——— 动态背景 ———
                currentBg
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 1.2), value: bgTransitionProgress)

                // ——— 背景星点 ———
                ForEach(bgStarParticles) { p in
                    Circle()
                        .fill(p.color)
                        .frame(width: p.size, height: p.size)
                        .position(p.position)
                        .opacity(p.opacity * min(bgTransitionProgress * 2, 1.0))
                        .blur(radius: p.blur)
                }

                // ——— 暗纹网格 ———
                subtleGrid(geo: geo)
                    .opacity(bgTransitionProgress > 0.6 ? (bgTransitionProgress - 0.6) * 0.06 : 0)

                // ==========================================
                // 阶段 0–1: 图标元素层（心形 + 胶囊）
                // ==========================================

                // 心跳辉光
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                blendColor(from: coralWarm, to: violetPrimary, progress: coralToVioletBlend).opacity(0.35),
                                blendColor(from: iconCoral, to: violetSecondary, progress: coralToVioletBlend).opacity(0.12),
                                .clear
                            ],
                            center: .center, startRadius: heartGlowRadius * 0.3, endRadius: heartGlowRadius
                        )
                    )
                    .frame(width: heartGlowRadius * 2, height: heartGlowRadius * 2)
                    .opacity(heartGlowOpacity)
                    .position(center)

                // 心形
                Image(systemName: "heart.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: iconSize, height: iconSize)
                    .foregroundStyle(heartColor)
                    .scaleEffect(iconScale * heartBeatScale)
                    .opacity(iconOpacity)
                    .shadow(color: heartColor.opacity(0.5), radius: heartGlowRadius * 0.3, y: 0)
                    .position(center)

                // 左侧胶囊
                Capsule()
                    .fill(.white)
                    .frame(width: iconSize * 0.38, height: iconSize * 0.18)
                    .offset(x: leftCapsuleXOffset - iconSize * 0.55, y: iconSize * 0.05)
                    .scaleEffect(iconScale)
                    .opacity(leftCapsuleOpacity * iconOpacity)
                    .blur(radius: capsuleBlur)
                    .position(center)

                // 右侧胶囊
                Capsule()
                    .fill(.white)
                    .frame(width: iconSize * 0.38, height: iconSize * 0.18)
                    .offset(x: rightCapsuleXOffset + iconSize * 0.55, y: iconSize * 0.05)
                    .scaleEffect(iconScale)
                    .opacity(rightCapsuleOpacity * iconOpacity)
                    .blur(radius: capsuleBlur)
                    .position(center)

                // ==========================================
                // 阶段 2: 绽放粒子
                // ==========================================
                ForEach(bloomParticles) { p in
                    let prog = p.travelProgress(at: tick, phaseStart: phase2Tick)
                    let opac = p.displayOpacity(at: tick, phaseStart: phase2Tick)
                    Circle()
                        .fill(
                            blendColor(from: p.startColor, to: p.endColor, progress: coralToVioletBlend)
                        )
                        .frame(width: p.size, height: p.size)
                        .position(x: center.x + p.offsetX * prog, y: center.y + p.offsetY * prog)
                        .opacity(opac)
                        .blur(radius: p.blur)
                }

                // ==========================================
                // 阶段 3: 柔光极光层
                // ==========================================

                // 外层大面积柔光
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                violetSecondary.opacity(0.18),
                                violetPrimary.opacity(0.08),
                                pinkAccent.opacity(0.05),
                                .clear
                            ],
                            center: .center, startRadius: 0, endRadius: 280
                        )
                    )
                    .frame(width: 560, height: 560)
                    .blur(radius: 50)
                    .scaleEffect(auroraScale)
                    .opacity(auroraOpacity * 0.7)
                    .position(center)

                // 中层流动光晕（旋转）
                Circle()
                    .fill(
                        AngularGradient(
                            colors: [
                                violetSecondary.opacity(0.25),
                                pinkAccent.opacity(0.15),
                                violetPrimary.opacity(0.2),
                                Color(hex: "#FCD34D").opacity(0.06),
                                violetAccent.opacity(0.18),
                                violetSecondary.opacity(0.25)
                            ],
                            center: .center
                        )
                    )
                    .frame(width: 220, height: 220)
                    .blur(radius: 35)
                    .rotationEffect(.degrees(tick * 15))
                    .scaleEffect(auroraScale)
                    .opacity(auroraOpacity * 0.6)
                    .position(center)

                // 内核亮点
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                .white.opacity(0.2),
                                violetSecondary.opacity(0.1),
                                .clear
                            ],
                            center: .center, startRadius: 0, endRadius: auroraInnerGlow
                        )
                    )
                    .frame(width: auroraInnerGlow * 2, height: auroraInnerGlow * 2)
                    .opacity(auroraOpacity * 0.8)
                    .position(center)

                // ——— 漂浮光点 ———
                ForEach(floatingMotes) { m in
                    Circle()
                        .fill(m.color)
                        .frame(width: m.size, height: m.size)
                        .position(
                            x: center.x + cos(m.baseAngle + tick * m.orbitSpeed) * m.orbitRadius * auroraScale,
                            y: center.y + sin(m.baseAngle + tick * m.orbitSpeed) * m.orbitRadius * 0.5 * auroraScale - m.floatOffset(tick: tick)
                        )
                        .opacity(m.baseOpacity * auroraOpacity)
                        .blur(radius: m.blur)
                }

                // ==========================================
                // 阶段 4: 标题区域（从极光中浮现）
                // ==========================================
                VStack(spacing: 0) {
                    Spacer()

                    HStack(spacing: 0) {
                        ForEach(Array(titleChars.enumerated()), id: \.offset) { idx, ch in
                            Text(String(ch.character))
                                .font(.system(size: 52, weight: .thin, design: .serif))
                                .foregroundColor(.white)
                                .opacity(ch.opacity)
                                .offset(y: ch.offset)
                                .shadow(color: violetSecondary.opacity(0.6), radius: 20, y: 0)
                        }
                    }
                    .opacity(titleEntranceOpacity)
                    .offset(y: titleYOffset)

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.clear, violetSecondary.opacity(0.35), pinkAccent.opacity(0.2), .clear],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(width: dividerWidth, height: 0.5)
                        .padding(.top, 20)
                        .opacity(titleEntranceOpacity)

                    Text("让每一天都被温柔以待")
                        .font(.system(size: 14, weight: .light, design: .rounded))
                        .foregroundColor(.white.opacity(0.4))
                        .opacity(subtitleOpacity)
                        .offset(y: subtitleOffset)
                        .padding(.top, 16)
                        .opacity(titleEntranceOpacity)

                    Spacer()
                }

                // ——— 优雅渐隐过渡层 ———
                // 场景整体亮度提升 + 透明度降低，平滑过渡到主界面
                Rectangle()
                    .fill(.white)
                    .ignoresSafeArea()
                    .opacity(dissolveProgress * 0.12)   // 微白提亮（不是刺眼白闪）

                // 深色柔边遮罩（从四周向内收缩）
                Rectangle()
                    .fill(Color(hex: "#060610"))
                    .ignoresSafeArea()
                    .opacity(sceneOpacity < 1 ? (1 - sceneOpacity) : 0)
            }
            .opacity(sceneOpacity)
        }
        .onAppear { begin() }
    }

    // MARK: - Color Blend Helper

    private func blendColor(from c1: Color, to c2: Color, progress: Double) -> Color {
        let u1 = UIColor(c1)
        let u2 = UIColor(c2)
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        u1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        u2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        let p = max(0, min(1, progress))
        return Color(
            red:   Double(r1 + (r2 - r1) * p),
            green: Double(g1 + (g2 - g1) * p),
            blue:  Double(b1 + (b2 - b1) * p),
            opacity: Double(a1 + (a2 - a1) * p)
        )
    }

    // MARK: - Subtle Grid

    private func subtleGrid(geo: GeometryProxy) -> some View {
        Canvas { ctx, size in
            let spacing: CGFloat = 40
            for x in stride(from: 0, through: size.width, by: spacing) {
                for y in stride(from: 0, through: size.height, by: spacing) {
                    let dot = Path(ellipseIn: CGRect(x: x, y: y, width: 1, height: 1))
                    ctx.fill(dot, with: .color(.white.opacity(0.15)))
                }
            }
        }
    }

    // MARK: - Animation Director

    private func begin() {
        let w = UIScreen.main.bounds.width
        let h = UIScreen.main.bounds.height

        titleChars = titleText.map { CharState(character: $0, opacity: 0, offset: 16) }

        // 背景星点
        bgStarParticles = (0..<50).map { _ in
            SplashParticle(
                position: CGPoint(x: CGFloat.random(in: -20...w+20), y: CGFloat.random(in: -20...h+20)),
                size: CGFloat.random(in: 1...4),
                opacity: Double.random(in: 0.06...0.25),
                blur: CGFloat.random(in: 1...5),
                color: [violetSecondary.opacity(0.5), violetAccent.opacity(0.35),
                        Color(hex: "#FCD34D").opacity(0.18), .white.opacity(0.2),
                        pinkAccent.opacity(0.28)].randomElement()!
            )
        }

        // 绽放粒子
        bloomParticles = (0..<45).map { _ in
            let angle = Double.random(in: 0...(2 * .pi))
            let distance = CGFloat.random(in: 60...350)
            return BloomParticle(
                offsetX: cos(angle) * distance,
                offsetY: sin(angle) * distance,
                size: CGFloat.random(in: 2...8),
                baseOpacity: Double.random(in: 0.25...0.7),
                blur: CGFloat.random(in: 0...4),
                travelDuration: Double.random(in: 2.0...3.5),
                startDelay: Double.random(in: 0...0.6),
                startColor: [iconCoral, coralWarm, .white, coralDeep].randomElement()!,
                endColor: [violetSecondary, violetPrimary, violetAccent, pinkAccent].randomElement()!
            )
        }

        // 漂浮光点（绕极光区域旋转 + 缓慢上浮）
        floatingMotes = (0..<15).map { _ in
            FloatingMote(
                baseAngle: Double.random(in: 0...(2 * .pi)),
                orbitRadius: CGFloat.random(in: 50...160),
                orbitSpeed: Double.random(in: 0.15...0.6),
                floatSpeed: CGFloat.random(in: 0.03...0.12),
                size: CGFloat.random(in: 2...6),
                baseOpacity: Double.random(in: 0.3...0.8),
                blur: CGFloat.random(in: 0...3),
                color: [violetSecondary, violetAccent, pinkAccent.opacity(0.7),
                        Color(hex: "#FCD34D").opacity(0.6), .white.opacity(0.5)].randomElement()!
            )
        }

        let displayLink = DisplayLink { dt in
            tick += dt * 2.5
        }

        // ═══════════════════════════════════════════
        // 阶段 0: 图标元素呈现  0.0–0.35s
        // ═══════════════════════════════════════════
        phase = .iconManifest
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            iconOpacity = 1.0
            iconScale = 1.0
            leftCapsuleOpacity = 1.0
            rightCapsuleOpacity = 1.0
        }

        // ═══════════════════════════════════════════
        // 阶段 1: 心跳脉动 + 胶囊溶解  0.35s
        // ═══════════════════════════════════════════
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            phase = .iconPulse

            // 心跳第一拍
            withAnimation(.easeInOut(duration: 0.18)) {
                heartBeatScale = 1.25
                heartGlowRadius = 80
                heartGlowOpacity = 0.7
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                withAnimation(.easeInOut(duration: 0.18)) { heartBeatScale = 0.95 }
            }

            // 心跳第二拍
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.36) {
                withAnimation(.easeInOut(duration: 0.22)) {
                    heartBeatScale = 1.35
                    heartGlowRadius = 130
                    heartGlowOpacity = 0.9
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { heartBeatScale = 1.0 }
                }
            }

            // 胶囊飘散
            withAnimation(.easeOut(duration: 0.5)) {
                leftCapsuleOpacity = 0
                rightCapsuleOpacity = 0
                leftCapsuleXOffset = -60
                rightCapsuleXOffset = 60
                capsuleBlur = 8
            }
        }

        // ═══════════════════════════════════════════
        // 阶段 2: 色彩演变 + 粒子绽放  0.8s
        // ═══════════════════════════════════════════
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            phase = .chromaticEvolve
            phase2Tick = tick

            withAnimation(.easeInOut(duration: 1.0)) { coralToVioletBlend = 1.0 }
            withAnimation(.easeInOut(duration: 1.2)) { bgTransitionProgress = 1.0 }

            // 心形渐隐
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation(.easeOut(duration: 0.45)) {
                    iconOpacity = 0
                    heartGlowOpacity = 0
                }
            }
        }

        // ═══════════════════════════════════════════
        // 阶段 3: 柔光极光浮现  1.5s
        // ═══════════════════════════════════════════
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            phase = .brandAwaken

            // 极光由小变大，柔和浮现
            withAnimation(.spring(response: 1.5, dampingFraction: 0.5)) {
                auroraScale = 1.0
                auroraOpacity = 1.0
                auroraInnerGlow = 60
            }
        }

        // ═══════════════════════════════════════════
        // 阶段 4: 标题从极光中浮现  2.0s
        // ═══════════════════════════════════════════
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            phase = .titleReveal

            // 标题整体从下方浮入
            withAnimation(.spring(response: 0.9, dampingFraction: 0.65)) {
                titleYOffset = 0
                titleEntranceOpacity = 1.0
            }

            // 逐字动画（在整体浮入的同时逐字点亮）
            for (idx, _) in titleText.enumerated() {
                let delay = Double(idx) * 0.1
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
                        titleChars[idx].opacity = 1.0
                        titleChars[idx].offset = 0
                    }
                }
            }

            // 分割线展开
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeOut(duration: 0.8)) { dividerWidth = 180 }
            }

            // 副标题
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    subtitleOpacity = 1.0
                    subtitleOffset = 0
                }
            }
        }

        // ═══════════════════════════════════════════
        // 阶段 5: 优雅渐隐过渡  3.4s
        // ═══════════════════════════════════════════
        // 标题停留了 1.4s 后，缓缓淡出，而不是突然白光
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.4) {
            phase = .dissolve

            // 场景整体缓慢降低透明度，同时微微提亮
            withAnimation(.easeInOut(duration: 0.8)) {
                sceneOpacity = 0
                dissolveProgress = 1.0
                auroraOpacity = 0.3
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
                displayLink.invalidate()
                isPresented = false
            }
        }
    }
}

// MARK: - Char State

struct CharState {
    var character: Character
    var opacity: Double
    var offset: CGFloat
}

// MARK: - Particle Models

struct SplashParticle: Identifiable {
    let id = UUID()
    let position: CGPoint
    let size: CGFloat
    let opacity: Double
    let blur: CGFloat
    let color: Color
}

struct BloomParticle: Identifiable {
    let id = UUID()
    let offsetX: CGFloat
    let offsetY: CGFloat
    let size: CGFloat
    let baseOpacity: Double
    let blur: CGFloat
    let travelDuration: Double
    let startDelay: Double
    let startColor: Color
    let endColor: Color

    /// 基于全局 tick 计算移动进度 (0→1)
    func travelProgress(at tick: Double, phaseStart: Double) -> Double {
        let local = tick - phaseStart - startDelay
        if local <= 0 { return 0 }
        let p = local / travelDuration
        return min(p, 1.0)
    }

    /// 基于全局 tick 计算透明度（先微亮 → 尾段淡出）
    func displayOpacity(at tick: Double, phaseStart: Double) -> Double {
        let p = travelProgress(at: tick, phaseStart: phaseStart)
        if p <= 0 { return 0 }
        if p < 0.65 {
            return baseOpacity * (0.6 + 0.4 * (p / 0.65))
        } else {
            let fade = (p - 0.65) / 0.35
            return baseOpacity * (1.0 - fade)
        }
    }
}

struct OrbitParticle: Identifiable {
    let id = UUID()
    let angle: Double
    let radius: CGFloat
    let speed: Double
    let size: CGFloat
    let opacity: Double
    let blur: CGFloat
    let color: Color
}

struct FloatingMote: Identifiable {
    let id = UUID()
    let baseAngle: Double
    let orbitRadius: CGFloat
    let orbitSpeed: Double
    let floatSpeed: CGFloat
    let size: CGFloat
    let baseOpacity: Double
    let blur: CGFloat
    let color: Color

    /// 上浮偏移量（基于 tick）
    func floatOffset(tick: Double) -> CGFloat {
        tick * floatSpeed * 30
    }
}

// MARK: - DisplayLink (CADisplayLink wrapper for continuous tick)

private class DisplayLink {
    private var link: CADisplayLink?
    private let callback: (Double) -> Void
    private var lastTimestamp: CFTimeInterval?

    init(callback: @escaping (Double) -> Void) {
        self.callback = callback
        link = CADisplayLink(target: self, selector: #selector(step))
        link?.add(to: .main, forMode: .common)
    }

    @objc private func step(_ link: CADisplayLink) {
        let now = link.timestamp
        if let last = lastTimestamp {
            callback(now - last)
        }
        lastTimestamp = now
    }

    func invalidate() {
        link?.invalidate()
        link = nil
    }
}
