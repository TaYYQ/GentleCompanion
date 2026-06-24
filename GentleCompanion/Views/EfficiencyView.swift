//
//  EfficiencyView.swift
//  GentleCompanion
//
//  效率模式 — 呼吸练习 + 番茄钟
//

import SwiftUI

struct EfficiencyView: View {
    @Binding var isPresented: Bool
    @State private var showBreathing = false
    @State private var showPomodoro = false
    @State private var hoveredModule: String?
    
    var body: some View {
        ZStack {
            // 背景
            LinearGradient(
                colors: [Color(hex: "#0F172A"), Color(hex: "#1E1B4B")],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶栏
                efficiencyTopBar
                
                // 功能内容
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: GentleSpacing.xxl) {
                        // 标题区
                        heroSection
                        
                        // 功能模块
                        moduleGrid
                        
                        Spacer().frame(height: GentleSpacing.xxl)
                    }
                    .padding(.horizontal, GentleSpacing.xxl)
                }
            }
            .sheet(isPresented: $showBreathing) {
                BreathingView(isPresented: $showBreathing)
                    .frame(width: 998, height: 686)
                    .fixedSize()
            }
            .sheet(isPresented: $showPomodoro) {
                PomodoroView(currentEmotion: nil, onClose: { showPomodoro = false })
                    .frame(width: 998, height: 686)
                    .fixedSize()
            }
        }
    }
    
    // MARK: - Top Bar
    
    private var efficiencyTopBar: some View {
        HStack {
            Button {
                isPresented = false
            } label: {
                HStack(spacing: GentleSpacing.sm) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                    Text("返回")
                        .font(GentleFont.caption())
                }
                .foregroundColor(Gentle.Text.secondary)
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            Text("⚡ 效率模式")
                .font(GentleFont.headline())
                .foregroundColor(.white)
            
            Spacer()
            
            // 占位保持居中
            HStack(spacing: GentleSpacing.sm) {
                Image(systemName: "chevron.left")
                Text("返回")
            }
            .opacity(0)
        }
        .padding(.horizontal, GentleSpacing.lg)
        .padding(.vertical, GentleSpacing.md)
    }
    
    // MARK: - Hero Section
    
    private var heroSection: some View {
        VStack(spacing: GentleSpacing.lg) {
            Text("专注当下")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("呼吸放松，专注工作")
                .font(GentleFont.caption(15))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.vertical, GentleSpacing.xl)
    }
    
    // MARK: - Module Grid
    
    private var moduleGrid: some View {
        VStack(spacing: GentleSpacing.lg) {
            // 呼吸练习卡片
            breathingCard
            
            // 番茄钟卡片
            pomodoroCard
        }
    }
    
    private var breathingCard: some View {
        let isHovered = hoveredModule == "breathing"
        
        return Button {
            showBreathing = true
        } label: {
            HStack(spacing: GentleSpacing.xl) {
                // 图标
                ZStack {
                    RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#60A5FA"), Color(hex: "#8B5CF6")],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(color: Color(hex: "#60A5FA").opacity(isHovered ? 0.5 : 0.3), radius: isHovered ? 20 : 12, x: 0, y: 6)
                    
                    Image(systemName: "wind")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundColor(.white)
                }
                .scaleEffect(isHovered ? 1.08 : 1.0)
                
                // 信息
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 10) {
                        Text("呼吸练习")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("4-4-6-2")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color(hex: "#60A5FA"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule().fill(Color(hex: "#60A5FA").opacity(0.2))
                            )
                    }
                    
                    Text("跟随引导，放松身心")
                        .font(GentleFont.caption(14))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("吸气4秒 → 屏息4秒 → 呼气6秒 → 屏息2秒")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.4))
                }
                
                Spacer()
                
                // 开始按钮
                VStack(spacing: 4) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 18))
                    Text("开始")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(Color(hex: "#60A5FA"))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Capsule().fill(Color(hex: "#60A5FA").opacity(0.15))
                )
            }
            .padding(GentleSpacing.xl)
            .background(
                RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                    .fill(isHovered ? Color.white.opacity(0.08) : Color.white.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                    .stroke(Color(hex: "#60A5FA").opacity(isHovered ? 0.4 : 0.15), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                hoveredModule = hovering ? "breathing" : nil
            }
        }
    }
    
    private var pomodoroCard: some View {
        let isHovered = hoveredModule == "pomodoro"
        
        return Button {
            showPomodoro = true
        } label: {
            HStack(spacing: GentleSpacing.xl) {
                // 图标
                ZStack {
                    RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#F472B6"), Color(hex: "#A78BFA")],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(color: Color(hex: "#F472B6").opacity(isHovered ? 0.5 : 0.3), radius: isHovered ? 20 : 12, x: 0, y: 6)
                    
                    Image(systemName: "clock.fill")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundColor(.white)
                }
                .scaleEffect(isHovered ? 1.08 : 1.0)
                
                // 信息
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 10) {
                        Text("番茄钟")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("25分钟")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color(hex: "#F472B6"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule().fill(Color(hex: "#F472B6").opacity(0.2))
                            )
                    }
                    
                    Text("专注工作，科学休息")
                        .font(GentleFont.caption(14))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("专注25分钟 → 短休5分钟 → 长休15分钟")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.4))
                }
                
                Spacer()
                
                // 开始按钮
                VStack(spacing: 4) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 18))
                    Text("开始")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(Color(hex: "#F472B6"))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Capsule().fill(Color(hex: "#F472B6").opacity(0.15))
                )
            }
            .padding(GentleSpacing.xl)
            .background(
                RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                    .fill(isHovered ? Color.white.opacity(0.08) : Color.white.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                    .stroke(Color(hex: "#F472B6").opacity(isHovered ? 0.4 : 0.15), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                hoveredModule = hovering ? "pomodoro" : nil
            }
        }
    }
}
