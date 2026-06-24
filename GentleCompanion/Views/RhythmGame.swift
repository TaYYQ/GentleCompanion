//
//  RhythmGame.swift
//  GentleCompanion
//
//  律动圆环 — 节奏踩点游戏
//

import SwiftUI

struct RhythmGame: View {
    @Binding var isPresented: Bool
    let duration: PlayDuration
    
    @State private var score: Int = 0
    @State private var combo: Int = 0
    @State private var maxCombo: Int = 0
    @State private var isPlaying: Bool = false
    @State private var timeRemaining: Int?
    @State private var rings: [RhythmRing] = []
    @State private var showResult: Bool = false
    @State private var pulseScale: CGFloat = 1.0
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let ringTimer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // 浅紫渐变背景
            LinearGradient(
                colors: [Color(hex: "#F8F0FF"), Color(hex: "#F0E7FF"), Color(hex: "#F5F0FF")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶栏
                topBar
                
                if showResult {
                    resultView
                } else if isPlaying {
                    gameView
                } else {
                    startView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onReceive(timer) { _ in
            if isPlaying, let time = timeRemaining, time > 0 {
                timeRemaining = time - 1
                if timeRemaining == 0 {
                    endGame()
                }
            }
        }
        .onReceive(ringTimer) { _ in
            if isPlaying {
                updateRings()
            }
        }
    }
    
    // MARK: - Top Bar
    
    private var topBar: some View {
        HStack {
            Button {
                isPresented = false
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
            
            VStack(spacing: 2) {
                Text("🎵 律动圆环")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Gentle.Text.primary)
                
                Text("跟随节奏，放松心情")
                    .font(.system(size: 12))
                    .foregroundColor(Gentle.Text.secondary)
            }
            
            Spacer()
            
            // 时间/分数显示
            if isPlaying {
                HStack(spacing: 16) {
                    if let time = timeRemaining {
                        Text("\(time)s")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(Gentle.Text.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Gentle.Background.primary)
                                    .overlay(
                                        Capsule()
                                            .stroke(Gentle.Primary.lavender.opacity(0.2), lineWidth: 1)
                                    )
                            )
                    }
                    
                    Text("分数: \(score)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Gentle.Primary.pink)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Gentle.Background.primary)
                                .overlay(
                                    Capsule()
                                        .stroke(Gentle.Primary.pink.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
    
    // MARK: - Start View
    
    private var startView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // 游戏图标
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#F472B6"), Color(hex: "#A78BFA")],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: Color(hex: "#F472B6").opacity(0.5), radius: 20, x: 0, y: 10)
                
                Text("🎵")
                    .font(.system(size: 60))
            }
            .scaleEffect(pulseScale)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    pulseScale = 1.1
                }
            }
            
            VStack(spacing: 12) {
                Text("律动圆环")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("当圆环收缩到中心圆时点击，踩中节奏！")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            
            // 开始按钮
            Button {
                startGame()
            } label: {
                HStack(spacing: 8) {
                    Text("开始游戏")
                        .font(.system(size: 18, weight: .bold))
                    Image(systemName: "play.fill")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 16)
                .background(
                    Capsule().fill(
                        LinearGradient(
                            colors: [Color(hex: "#F472B6"), Color(hex: "#A78BFA")],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                )
                .shadow(color: Color(hex: "#F472B6").opacity(0.4), radius: 12, x: 0, y: 6)
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
        }
    }
    
    // MARK: - Game View
    
    private var gameView: some View {
        VStack(spacing: 24) {
            // 连击显示
            if combo > 1 {
                Text("\(combo)x 连击!")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#FCD34D"))
                    .transition(.scale.combined(with: .opacity))
            }
            
            Spacer()
            
            // 游戏区域
            ZStack {
                // 中心圆（目标区域）
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 4)
                    .frame(width: 100, height: 100)
                
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                // 收缩的圆环
                ForEach(rings) { ring in
                    Circle()
                        .stroke(ring.color, lineWidth: 6)
                        .frame(width: ring.size, height: ring.size)
                        .opacity(ring.opacity)
                }
            }
            .frame(width: 400, height: 400)
            .contentShape(Rectangle())
            .onTapGesture {
                tapRing()
            }
            
            Spacer()
            
            // 提示
            Text("点击屏幕踩中节奏")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(.horizontal, 48)
    }
    
    // MARK: - Result View
    
    private var resultView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("🎉")
                    .font(.system(size: 64))
                
                Text("游戏结束")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                VStack(spacing: 8) {
                    HStack(spacing: 24) {
                        resultItem(label: "分数", value: "\(score)", color: Color(hex: "#F472B6"))
                        resultItem(label: "最高连击", value: "\(maxCombo)x", color: Color(hex: "#FCD34D"))
                    }
                }
            }
            
            HStack(spacing: 20) {
                Button {
                    startGame()
                } label: {
                    Text("再来一局")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(
                            Capsule().fill(
                                LinearGradient(
                                    colors: [Color(hex: "#F472B6"), Color(hex: "#A78BFA")],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                        )
                }
                .buttonStyle(PlainButtonStyle())
                
                Button {
                    isPresented = false
                } label: {
                    Text("返回")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(
                            Capsule().fill(Color.white.opacity(0.15))
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Spacer()
        }
    }
    
    private func resultItem(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
    }
    
    // MARK: - Game Logic
    
    private func startGame() {
        score = 0
        combo = 0
        maxCombo = 0
        rings = []
        showResult = false
        isPlaying = true
        timeRemaining = duration.seconds
        
        // 开始生成圆环
        spawnRing()
    }
    
    private func endGame() {
        isPlaying = false
        showResult = true
    }
    
    private func spawnRing() {
        guard isPlaying else { return }
        
        let ring = RhythmRing(
            id: UUID(),
            size: 350,
            targetSize: 100,
            speed: 3.5 + Double.random(in: 0...1),
            color: Color(hex: "#F472B6")
        )
        rings.append(ring)
        
        // 随机间隔生成下一个
        let delay = Double.random(in: 0.8...1.5)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            spawnRing()
        }
    }
    
    private func updateRings() {
        for i in rings.indices {
            rings[i].size -= rings[i].speed
            rings[i].opacity = max(0, min(1, (rings[i].size - 50) / 150))
        }
        
        // 移除已经收缩过头的圆环（miss）
        let missedRings = rings.filter { $0.size < 80 }
        for ring in missedRings {
            if ring.size < 80 {
                combo = 0
            }
        }
        rings.removeAll { $0.size < 80 }
    }
    
    private func tapRing() {
        // 找到最接近目标大小的圆环
        if let closestRing = rings.min(by: { abs($0.size - 100) < abs($1.size - 100) }) {
            let distance = abs(closestRing.size - 100)
            
            if distance < 30 {
                // 完美击中
                let points = distance < 10 ? 100 : (distance < 20 ? 80 : 60)
                score += points * max(1, combo + 1)
                combo += 1
                maxCombo = max(maxCombo, combo)
                
                // 移除击中的圆环
                rings.removeAll { $0.id == closestRing.id }
            } else if distance < 50 {
                // 勉强击中
                score += 20
                combo = max(0, combo - 1)
                rings.removeAll { $0.id == closestRing.id }
            }
        }
    }
}

// MARK: - Rhythm Ring Model

struct RhythmRing: Identifiable {
    let id: UUID
    var size: Double
    let targetSize: Double
    let speed: Double
    let color: Color
    var opacity: Double = 1.0
}
