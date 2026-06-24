//
//  MoodQuestionView.swift
//  GentleCompanion
//
//  心情询问 + 游戏推荐 — 全新设计
//

import SwiftUI

struct MoodQuestionView: View {
    @Binding var isPresented: Bool
    @State private var step: Int = 1
    @State private var selectedMood: GameMood?
    @State private var selectedDuration: PlayDuration = .free
    @State private var appearAnimation = false
    
    var onGameSelected: (GameType, PlayDuration) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // 步骤指示器
            stepIndicator
                .padding(.top, GentleSpacing.lg)
            
            // 内容区
            ZStack {
                if step == 1 {
                    moodSelectionStep
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .trailing)),
                            removal: .opacity.combined(with: .move(edge: .leading))
                        ))
                } else if step == 2 {
                    durationStep
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .trailing)),
                            removal: .opacity.combined(with: .move(edge: .leading))
                        ))
                } else {
                    recommendationStep
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .trailing)),
                            removal: .opacity.combined(with: .move(edge: .leading))
                        ))
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: step)
            .frame(maxHeight: .infinity)
        }
        .padding(GentleSpacing.xxl)
        .frame(width: 520, height: 480)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: GentleRadius.xxxl, style: .continuous)
                    .fill(.white)
                
                // 顶部渐变光晕
                Circle()
                    .fill(Gentle.Primary.lavender.opacity(0.06))
                    .frame(width: 200, height: 200)
                    .blur(radius: 40)
                    .offset(x: 0, y: -160)
            }
            .clipShape(RoundedRectangle(cornerRadius: GentleRadius.xxxl, style: .continuous))
        )
        .overlay(
            RoundedRectangle(cornerRadius: GentleRadius.xxxl, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Gentle.Primary.lavender.opacity(0.3),
                            Gentle.Primary.pink.opacity(0.1),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.12), radius: 24, x: 0, y: 12)
        .opacity(appearAnimation ? 1 : 0)
        .scaleEffect(appearAnimation ? 1 : 0.96)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                appearAnimation = true
            }
        }
    }
    
    // MARK: - Step Indicator
    
    private var stepIndicator: some View {
        HStack(spacing: 0) {
            ForEach(1...3, id: \.self) { s in
                HStack(spacing: 0) {
                    // 步骤圆点 + 文字
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(s <= step ? Gentle.Primary.lavender : Color.gray.opacity(0.2))
                                .frame(width: 32, height: 32)
                            
                            if s < step {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            } else {
                                Text("\(s)")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(s == step ? .white : Gentle.Text.tertiary)
                            }
                        }
                        
                        Text(stepTitle(s))
                            .font(.system(size: 11, weight: s == step ? .semibold : .regular))
                            .foregroundColor(s == step ? Gentle.Primary.lavender : Gentle.Text.tertiary)
                    }
                    
                    if s < 3 {
                        Rectangle()
                            .fill(s < step ? Gentle.Primary.lavender : Color.gray.opacity(0.15))
                            .frame(width: 60, height: 2)
                            .padding(.bottom, 22)
                    }
                }
            }
        }
    }
    
    private func stepTitle(_ s: Int) -> String {
        switch s {
        case 1: return "心情"
        case 2: return "时长"
        case 3: return "推荐"
        default: return ""
        }
    }
    
    // MARK: - Step 1: Mood Selection
    
    private var moodSelectionStep: some View {
        VStack(spacing: GentleSpacing.xl) {
            VStack(spacing: 6) {
                Text("你现在心情怎么样？")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Gentle.Text.primary)
                
                Text("选择最接近你此刻的感受")
                    .font(.system(size: 13))
                    .foregroundColor(Gentle.Text.secondary)
            }
            
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: GentleSpacing.sm), count: 3),
                spacing: GentleSpacing.sm
            ) {
                ForEach(GameMood.allCases) { mood in
                    moodCard(mood)
                }
            }
            .padding(.horizontal, GentleSpacing.md)
            
            Button {
                isPresented = false
            } label: {
                Text("跳过，我自己选")
                    .font(.system(size: 12))
                    .foregroundColor(Gentle.Text.tertiary)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private func moodCard(_ mood: GameMood) -> some View {
        let isSelected = selectedMood == mood
        
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedMood = mood
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    step = 2
                }
            }
        } label: {
            VStack(spacing: 8) {
                Text(mood.emoji)
                    .font(.system(size: 34))
                
                Text(mood.rawValue)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? mood.color : Gentle.Text.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, GentleSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: GentleRadius.lg, style: .continuous)
                    .fill(isSelected ? mood.color.opacity(0.1) : Gentle.Background.tertiary.opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: GentleRadius.lg, style: .continuous)
                    .stroke(isSelected ? mood.color.opacity(0.4) : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .shadow(
                color: isSelected ? mood.color.opacity(0.15) : Color.clear,
                radius: 8, x: 0, y: 3
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
    
    // MARK: - Step 2: Duration
    
    private var durationStep: some View {
        VStack(spacing: GentleSpacing.xl) {
            VStack(spacing: 6) {
                Text("想玩多久？")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Gentle.Text.primary)
                
                if let mood = selectedMood {
                    Text("你选择了「\(mood.emoji) \(mood.rawValue)」")
                        .font(.system(size: 13))
                        .foregroundColor(Gentle.Text.secondary)
                }
            }
            
            HStack(spacing: GentleSpacing.lg) {
                ForEach(PlayDuration.allCases) { duration in
                    durationCard(duration)
                }
            }
            
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    step = 1
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 11))
                    Text("重新选择心情")
                }
                .font(.system(size: 12))
                .foregroundColor(Gentle.Text.tertiary)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private func durationCard(_ duration: PlayDuration) -> some View {
        let isSelected = selectedDuration == duration
        
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedDuration = duration
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    step = 3
                }
            }
        } label: {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Gentle.Primary.lavender.opacity(0.12) : Gentle.Background.tertiary.opacity(0.6))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: duration.icon)
                        .font(.system(size: 22))
                        .foregroundColor(isSelected ? Gentle.Primary.lavender : Gentle.Text.secondary)
                }
                
                Text(duration.rawValue)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(isSelected ? Gentle.Primary.lavender : Gentle.Text.primary)
                
                Text(durationSubtitle(duration))
                    .font(.system(size: 10))
                    .foregroundColor(Gentle.Text.tertiary)
            }
            .frame(width: 110, height: 130)
            .background(
                RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                    .fill(.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                    .stroke(
                        isSelected ? Gentle.Primary.lavender.opacity(0.4) : Gentle.Border.light,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: isSelected ? Gentle.Primary.lavender.opacity(0.12) : Color.black.opacity(0.04),
                radius: isSelected ? 10 : 4,
                x: 0,
                y: isSelected ? 4 : 2
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
    
    private func durationSubtitle(_ duration: PlayDuration) -> String {
        switch duration {
        case .short: return "快速放松"
        case .medium: return "深度体验"
        case .free: return "不限时间"
        }
    }
    
    // MARK: - Step 3: Recommendation
    
    private var recommendationStep: some View {
        VStack(spacing: GentleSpacing.xl) {
            if let mood = selectedMood {
                VStack(spacing: 8) {
                    Text(mood.emoji)
                        .font(.system(size: 48))
                    
                    Text(mood.recommendationMessage)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Gentle.Text.primary)
                }
                
                let recommended = mood.recommendedGame
                
                VStack(spacing: GentleSpacing.sm) {
                    ForEach(GameType.allCases) { game in
                        recommendedGameCard(game, isRecommended: game == recommended)
                    }
                }
                
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        step = 2
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 11))
                        Text("重新选择")
                    }
                    .font(.system(size: 12))
                    .foregroundColor(Gentle.Text.tertiary)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private func recommendedGameCard(_ game: GameType, isRecommended: Bool) -> some View {
        Button {
            onGameSelected(game, selectedDuration)
            isPresented = false
        } label: {
            HStack(spacing: GentleSpacing.md) {
                ZStack {
                    Circle()
                        .fill(game.gradient)
                        .frame(width: isRecommended ? 48 : 40, height: isRecommended ? 48 : 40)
                        .shadow(
                            color: game.accentColor.opacity(isRecommended ? 0.35 : 0.2),
                            radius: isRecommended ? 10 : 5, x: 0, y: 3
                        )
                    
                    Text(game.emoji)
                        .font(.system(size: isRecommended ? 24 : 18))
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(game.rawValue)
                            .font(.system(size: isRecommended ? 15 : 14, weight: .semibold))
                            .foregroundColor(Gentle.Text.primary)
                        
                        if isRecommended {
                            Text("AI 推荐")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule().fill(game.accentColor)
                                )
                        }
                    }
                    
                    Text(game.description)
                        .font(.system(size: 11))
                        .foregroundColor(Gentle.Text.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text("开始")
                        .font(.system(size: 12, weight: .semibold))
                    Image(systemName: "play.fill")
                        .font(.system(size: 9))
                }
                .foregroundColor(.white)
                .padding(.horizontal, GentleSpacing.md)
                .padding(.vertical, GentleSpacing.xs + 2)
                .background(
                    Capsule()
                        .fill(game.gradient)
                )
                .shadow(color: game.accentColor.opacity(0.3), radius: 6, x: 0, y: 3)
            }
            .padding(.horizontal, GentleSpacing.md)
            .padding(.vertical, GentleSpacing.sm + 2)
            .background(
                RoundedRectangle(cornerRadius: GentleRadius.lg, style: .continuous)
                    .fill(isRecommended ? game.accentColor.opacity(0.05) : Gentle.Background.tertiary.opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: GentleRadius.lg, style: .continuous)
                    .stroke(
                        isRecommended ? game.accentColor.opacity(0.35) : Color.clear,
                        lineWidth: isRecommended ? 2 : 0
                    )
            )
            .scaleEffect(isRecommended ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
