//
//  ContentView.swift
//  GentleCompanion
//
//  主内容入口
//

import SwiftUI

struct ContentView: View {
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "#FAF8FF"),
                    Color(hex: "#F3ECFF"),
                    Color(hex: "#F0E7FF"),
                    Color(hex: "#F5F0FF")
                ],
                startPoint: animateGradient ? .topLeading : .bottomTrailing,
                endPoint: animateGradient ? .bottomTrailing : .topLeading
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                    animateGradient = true
                }
            }
            
            VStack(spacing: GentleSpacing.xl) {
                ZStack {
                    Circle()
                        .fill(Gentle.Gradient.primaryButton)
                        .frame(width: 80, height: 80)
                        .shadow(color: Gentle.Primary.purple.opacity(0.3), radius: 20, x: 0, y: 8)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: GentleSpacing.xs) {
                    Text("温柔点")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Gentle.Text.primary)
                    
                    Text("GentleCompanion")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Gentle.Text.secondary)
                }
                
                Text("温柔对待自己，每一天都值得被善待。")
                    .font(.system(size: 15))
                    .foregroundColor(Gentle.Text.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, GentleSpacing.xxl)
            }
        }
    }
}
