//
//  BubblePopGame.swift
//  GentleCompanion
//
//  🫧 泡泡解压 — 点击泡泡释放压力
//

import SwiftUI

struct BubblePopGame: View {
    @Binding var isPresented: Bool
    @Environment(\.dismiss) private var dismiss
    let duration: PlayDuration
    
    @State private var bubbles: [Bubble] = []
    @State private var particles: [PopParticle] = []
    @State private var score: Int = 0
    @State private var combo: Int = 0
    @State private var lastPopTime: Date = .distantPast
    @State private var remainingSeconds: Int?
    @State private var timer: Timer?
    @State private var spawnTimer: Timer?
    
    // 泡泡颜色
    private let bubbleColors: [Color] = [
        Color(hex: "#60A5FA"), Color(hex: "#A78BFA"), Color(hex: "#F472B6"),
        Color(hex: "#FCD34D"), Color(hex: "#34D399"), Color(hex: "#FB923C"),
        Color(hex: "#818CF8"), Color(hex: "#F87171")
    ]
    
    struct Bubble: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        var color: Color
        var opacity: Double
        var wobblePhase: Double
        var scale: CGFloat = 1.0
    }
    
    struct PopParticle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var color: Color
        var angle: Double
        var speed: CGFloat
        var opacity: Double = 1.0
        var size: CGFloat
    }
    
    var body: some View {
        ZStack {
            // 浅紫渐变背景
            LinearGradient(
                colors: [Color(hex: "#F8F0FF"), Color(hex: "#F0E7FF"), Color(hex: "#F5F0FF")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // 泡泡区域
            GeometryReader { geo in
                ZStack {
                    // 泡泡
                    ForEach(bubbles) { bubble in
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        bubble.color.opacity(0.9),
                                        bubble.color.opacity(0.4),
                                        bubble.color.opacity(0.1)
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: bubble.size / 2
                                )
                            )
                            .frame(width: bubble.size, height: bubble.size)
                            .overlay(
                                // 高光
                                Circle()
                                    .fill(Color.white.opacity(0.3))
                                    .frame(width: bubble.size * 0.3, height: bubble.size * 0.2)
                                    .offset(x: -bubble.size * 0.15, y: -bubble.size * 0.15)
                                    .blur(radius: 2)
                            )
                            .scaleEffect(bubble.scale)
                            .position(x: bubble.x, y: bubble.y)
                            .onTapGesture {
                                popBubble(bubble, in: geo.size)
                            }
                    }
                    
                    // 爆炸粒子
                    ForEach(particles) { particle in
                        Circle()
                            .fill(particle.color)
                            .frame(width: particle.size, height: particle.size)
                            .opacity(particle.opacity)
                            .position(x: particle.x, y: particle.y)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // 顶部 UI
            VStack {
                gameTopBar
                
                Spacer()
                
                // 底部分数
                bottomScoreBar
            }
            .frame(maxWidth: .infinity)
        }
        .onAppear {
            startGame()
        }
        .onDisappear {
            timer?.invalidate()
            spawnTimer?.invalidate()
        }
    }
    
    // MARK: - Top Bar
    
    private var gameTopBar: some View {
        HStack {
            Button {
                isPresented = false
                dismiss()
            } label: {
                ZStack {
                    Circle()
                        .fill(Gentle.Background.primary)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle()
                                .stroke(Gentle.Primary.lavender.opacity(0.3), lineWidth: 1)
                        )
                    
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Gentle.Text.primary)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            // 计时器
            if let remaining = remainingSeconds {
                Text(formatTime(remaining))
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                    .foregroundColor(Gentle.Text.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Gentle.Background.primary))
            }
            
            Spacer()
            
            // 连击
            if combo > 1 {
                Text("\(combo)x 连击!")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(Gentle.Primary.pink)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Gentle.Primary.pink.opacity(0.15)))
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, GentleSpacing.lg)
        .padding(.top, GentleSpacing.lg)
    }
    
    // MARK: - Bottom Score
    
    private var bottomScoreBar: some View {
        HStack {
            Text("🫧 \(score)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(Gentle.Text.primary)
            
            Spacer()
            
            Text("点击泡泡来解压")
                .font(GentleFont.caption(13))
                .foregroundColor(Gentle.Text.secondary)
        }
        .padding(.horizontal, GentleSpacing.xl)
        .padding(.vertical, GentleSpacing.lg)
        .background(
            Rectangle()
                .fill(Gentle.Background.primary.opacity(0.8))
        )
    }
    
    // MARK: - Game Logic
    
    private func startGame() {
        let gameBounds = CGSize(width: 970, height: 686)
        
        for _ in 0..<12 {
            spawnBubble(in: gameBounds)
        }
        
        spawnTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { _ in
            Task { @MainActor in
                if bubbles.count < 25 {
                    spawnBubble(in: gameBounds)
                }
            }
        }
        
        if let seconds = duration.seconds {
            remainingSeconds = seconds
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                Task { @MainActor in
                    if let remaining = remainingSeconds, remaining > 0 {
                        remainingSeconds = remaining - 1
                    } else {
                        timer?.invalidate()
                        spawnTimer?.invalidate()
                    }
                }
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 1.0/30.0, repeats: true) { _ in
            Task { @MainActor in
                updateParticles()
            }
        }
    }
    
    private func spawnBubble(in bounds: CGSize = CGSize(width: 970, height: 686)) {
        let size = CGFloat.random(in: 40...80)
        let bubble = Bubble(
            x: CGFloat.random(in: size...bounds.width - size),
            y: CGFloat.random(in: 120...bounds.height - size - 100),
            size: size,
            color: bubbleColors.randomElement()!,
            opacity: 0.8,
            wobblePhase: Double.random(in: 0...Double.pi * 2)
        )
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            bubbles.append(bubble)
        }
    }
    
    private func popBubble(_ bubble: Bubble, in size: CGSize) {
        let now = Date()
        if now.timeIntervalSince(lastPopTime) < 0.8 {
            combo += 1
        } else {
            combo = 1
        }
        lastPopTime = now
        
        let points = 10 * combo
        score += points
        
        withAnimation(.easeOut(duration: 0.15)) {
            bubbles.removeAll { $0.id == bubble.id }
        }
        
        // 生成爆炸粒子
        for _ in 0..<12 {
            let particle = PopParticle(
                x: bubble.x,
                y: bubble.y,
                color: bubble.color,
                angle: Double.random(in: 0...Double.pi * 2),
                speed: CGFloat.random(in: 3...8),
                size: CGFloat.random(in: 4...12)
            )
            particles.append(particle)
        }
    }
    
    private func updateParticles() {
        for i in particles.indices {
            particles[i].x += cos(particles[i].angle) * particles[i].speed
            particles[i].y += sin(particles[i].angle) * particles[i].speed
            particles[i].opacity -= 0.04
            particles[i].speed *= 0.95
        }
        particles.removeAll { $0.opacity <= 0 }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}
