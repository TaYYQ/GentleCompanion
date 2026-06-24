//
//  ActivationFlowView.swift
//  GentleCompanion
//
//  Gentle onboarding flow - 2 screens: Welcome + Emotion
//

import SwiftUI

struct ActivationFlowView: View {
    let complete: () -> Void
    @State private var currentStep = 1
    @State private var gradientPhase: Double = 0
    @State private var floatingParticles: [FloatingParticle] = []
    @State private var viewSize: CGSize = .zero
    @State private var particleTimer: Timer?
    
    private let totalSteps = 2
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                // Breathing gradient background
                breathingGradient
                    .ignoresSafeArea()
                
                // Floating particles
                ZStack {
                    ForEach(floatingParticles) { particle in
                        Circle()
                            .fill(particle.color)
                            .frame(width: particle.size, height: particle.size)
                            .position(particle.position)
                            .opacity(particle.opacity)
                            .blur(radius: particle.size / 2)
                    }
                }
                
                // Current step content
                currentStepContent
                
                // Progress bar at bottom
                if currentStep < totalSteps {
                    progressBar
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                handleAppear(size: proxy.size)
            }
            .onChange(of: proxy.size) { oldValue, newValue in
                updateViewSize(newValue)
            }
        }
    }
    
    private var breathingGradient: some View {
        LinearGradient(
            colors: [
                Color(hex: "#6B4EAA").opacity(0.95 + sin(gradientPhase) * 0.05),
                Color(hex: "#A78BFA").opacity(0.98 + sin(gradientPhase + .pi/3) * 0.03),
                Color(hex: "#F472B6").opacity(0.25 + sin(gradientPhase + .pi/2) * 0.04),
                Color(hex: "#FCD34D").opacity(0.12 + sin(gradientPhase + .pi) * 0.02)
            ],
            startPoint: UnitPoint(x: 0.3 + sin(gradientPhase * 0.5) * 0.1, y: 0.1 + cos(gradientPhase * 0.3) * 0.1),
            endPoint: UnitPoint(x: 0.7 + cos(gradientPhase * 0.4) * 0.1, y: 0.9 + sin(gradientPhase * 0.2) * 0.1)
        )
        .animation(.linear(duration: 15).repeatForever(autoreverses: true), value: gradientPhase)
    }
    
    private var progressBar: some View {
        VStack(spacing: 8) {
            Text("\(currentStep)/\(totalSteps)")
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.4))
            
            ZStack(alignment: .leading) {
                // Background track
                Capsule()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 4)
                
                // Progress fill
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#A78BFA"), Color(hex: "#FCD34D")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 4)
                    .frame(width: CGFloat(currentStep) / CGFloat(totalSteps) * (viewSize.width - 80))
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 20)
        }
    }
    
    @ViewBuilder
    private var currentStepContent: some View {
        switch currentStep {
        case 1:
            WelcomeScreen(next: nextStep)
        case 2:
            EmotionCheckScreen(next: completeFlow)
        default:
            WelcomeScreen(next: nextStep)
        }
    }
    
    private func nextStep() {
        withAnimation(.easeInOut(duration: 0.4)) {
            if currentStep < totalSteps {
                currentStep += 1
            }
        }
    }
    
    private func completeFlow() {
        withAnimation(.easeInOut(duration: 0.4)) {
            complete()
        }
    }
    
    private func handleAppear(size: CGSize) {
        updateViewSize(size)
        startBreathingAnimation()
    }
    
    private func updateViewSize(_ size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        if viewSize != size {
            viewSize = size
        }
        if floatingParticles.isEmpty {
            startFloatingParticles(in: size)
        }
    }
    
    private var particleBounds: CGSize {
        CGSize(width: max(viewSize.width, 600), height: max(viewSize.height, 500))
    }
    
    private func startFloatingParticles(in size: CGSize) {
        let bounds = CGSize(width: max(size.width, 600), height: max(size.height, 500))
        floatingParticles = (0..<10).map { _ in
            FloatingParticle.random(in: bounds)
        }
        
        particleTimer?.invalidate()
        particleTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            Task { @MainActor in
                let bounds = particleBounds
                for index in floatingParticles.indices {
                    floatingParticles[index].update(in: bounds)
                }
            }
        }
    }
    
    private func startBreathingAnimation() {
        withAnimation(.linear(duration: 15).repeatForever(autoreverses: true)) {
            gradientPhase = 2 * .pi
        }
    }
}

// MARK: - Screen 1: Welcome

struct WelcomeScreen: View {
    let next: () -> Void
    @State private var opacity: Double = 0
    @State private var offsetY: CGFloat = 20
    @State private var pulsePhase: Double = 0
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Text("欢迎来到这里")
                .font(.system(size: 36, weight: .ultraLight))
                .foregroundColor(.white)
                .opacity(opacity)
                .offset(y: offsetY)
            
            Text("这是属于你的温柔空间。")
                .font(.system(size: 16, weight: .light))
                .foregroundColor(Color(hex: "#E0D2FE"))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .opacity(opacity)
                .offset(y: offsetY)
            
            Spacer()
            
            Button(action: next) {
                HStack(spacing: 12) {
                    Text("开始旅程")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 50)
                .padding(.vertical, 16)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "#FCD34D"),
                                        Color(hex: "#F59E0B")
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color(hex: "#FCD34D").opacity(0.4), radius: 12, x: 0, y: 6)
                        
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.3),
                                        Color.clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )
                    }
                )
                .scaleEffect(1.0 + sin(pulsePhase) * 0.02)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.bottom, 40)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                opacity = 1
                offsetY = 0
            }
            
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                pulsePhase = .pi * 2
            }
        }
    }
}

// MARK: - Screen 2: Emotion Check

struct EmotionCheckScreen: View {
    let next: () -> Void
    @State private var selectedEmotion: Emotion?
    @State private var showOtherInput = false
    @State private var otherText = ""
    @State private var opacity: Double = 0
    @State private var offsetY: CGFloat = 20
    @State private var showCoreMessage = false
    
    let emotions: [(Emotion, String)] = [
        (.incompleteJoy, "开心"),
        (.empty, "平静"),
        (.exhausted, "疲惫"),
        (.anxious, "焦虑"),
        (.lonely, "低落"),
        (.other, "其他")
    ]
    
    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                Spacer()
                
                Text("现在，告诉我你此刻的感觉？")
                    .font(.system(size: 26, weight: .ultraLight))
                    .foregroundColor(.white)
                    .opacity(showCoreMessage ? 0 : opacity)
                    .offset(y: showCoreMessage ? -20 : offsetY)
                
                if !showCoreMessage {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 15) {
                        ForEach(emotions, id: \.0) { emotion in
                            EmotionCheckCard(
                                emotion: emotion.0,
                                label: emotion.1,
                                isSelected: selectedEmotion == emotion.0,
                                action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        if emotion.0 == .other {
                                            showOtherInput = true
                                        } else {
                                            selectedEmotion = emotion.0
                                            recordAndContinue()
                                        }
                                    }
                                }
                            )
                            .opacity(opacity)
                            .offset(y: offsetY)
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    Text("没关系，任何感受在这里都安全。")
                        .font(.system(size: 13, weight: .light))
                        .foregroundColor(.white.opacity(0.5))
                        .opacity(opacity)
                        .offset(y: offsetY)
                }
                
                if showCoreMessage {
                    VStack(spacing: 20) {
                        Image(systemName: "sun.max.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "#FCD34D"),
                                        Color(hex: "#F59E0B")
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("你可以有各种感受，\n它们都是你的一部分。")
                            .font(.system(size: 20, weight: .light))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineSpacing(8)
                    }
                    .opacity(showCoreMessage ? 1 : 0)
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }
                
                Spacer()
                
                if !showOtherInput && !showCoreMessage {
                    Button(action: {
                        if selectedEmotion != nil {
                            recordAndContinue()
                        }
                    }) {
                        Text("记录并继续")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 50)
                            .padding(.vertical, 16)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(hex: "#FCD34D"),
                                                    Color(hex: "#F59E0B")
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .shadow(color: Color(hex: "#FCD34D").opacity(0.4), radius: 12, x: 0, y: 6)
                                    
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.3),
                                                    Color.clear
                                                ],
                                                startPoint: .top,
                                                endPoint: .center
                                            )
                                        )
                                }
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(selectedEmotion == nil)
                    .padding(.bottom, 40)
                }
            }
            
            // Other emotion input sheet
            if showOtherInput {
                ZStack {
                    Color.black.opacity(0.7)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                showOtherInput = false
                            }
                        }
                    
                    VStack(spacing: 20) {
                        Text("描述你的感受")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        ZStack(alignment: .topLeading) {
                            if otherText.isEmpty {
                                Text("写下你此刻的感觉...")
                                    .foregroundColor(.white.opacity(0.4))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                            }
                            
                            TextEditor(text: $otherText)
                                .frame(height: 100)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .scrollContentBackground(.hidden)
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.15), lineWidth: 1.5)
                                )
                        )
                        
                        HStack(spacing: 12) {
                            Button("取消") {
                                withAnimation {
                                    showOtherInput = false
                                }
                            }
                            .buttonStyle(GentleButtonStyle(secondary: true))
                            
                            Button("记录") {
                                selectedEmotion = .other
                                withAnimation {
                                    showOtherInput = false
                                    recordAndContinue()
                                }
                            }
                            .buttonStyle(GentleButtonStyle())
                            .disabled(otherText.isEmpty)
                        }
                    }
                    .padding(30)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "#6B4EAA"),
                                        Color(hex: "#A78BFA")
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .padding(40)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
                opacity = 1
                offsetY = 0
            }
        }
    }
    
    private func recordAndContinue() {
        // Save selected emotion
        if let emotion = selectedEmotion {
            var newSettings = SettingsManager.shared.settings
            newSettings.selectedEmotion = emotion
            SettingsManager.shared.settings = newSettings
            SettingsManager.shared.appendEmotionEntry(emotion)
        }
        
        withAnimation(.easeInOut(duration: 0.6)) {
            showCoreMessage = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            next()
        }
    }
}

// MARK: - Emotion Check Card

struct EmotionCheckCard: View {
    let emotion: Emotion
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Text(emotion.emoji)
                    .font(.system(size: 36))
                
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color(hex: "#A78BFA") : Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isSelected ? Color.white.opacity(0.3) : Color.white.opacity(0.1), lineWidth: isSelected ? 2 : 1)
                    )
            )
            .shadow(color: isSelected ? Color(hex: "#A78BFA").opacity(0.4) : Color.clear, radius: isSelected ? 12 : 0, x: 0, y: 6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Gentle Button Style

struct GentleButtonStyle: ButtonStyle {
    var secondary: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(secondary ? .white.opacity(0.7) : .white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(secondary ? Color.white.opacity(0.1) : Color(hex: "#A78BFA"))
            )
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}
