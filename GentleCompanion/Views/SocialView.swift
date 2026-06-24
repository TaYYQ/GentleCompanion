//
//  SocialView.swift
//  GentleCompanion
//
//  社交模式 — 温柔墙 + 社交动态
//

import SwiftUI

struct SocialView: View {
    @Binding var isPresented: Bool
    @State private var showGentleWall = false
    @State private var showSocialFeed = false
    @State private var hoveredModule: String?
    
    var body: some View {
        ZStack {
            // 背景
            LinearGradient(
                colors: [Color(hex: "#1F2937"), Color(hex: "#422006")],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶栏
                socialTopBar
                
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
            .sheet(isPresented: $showGentleWall) {
                GentleWallView(isPresented: $showGentleWall)
                    .frame(width: 998, height: 686)
                    .fixedSize()
            }
            .sheet(isPresented: $showSocialFeed) {
                SocialFeedView(isPresented: $showSocialFeed)
                    .frame(width: 998, height: 686)
                    .fixedSize()
            }
        }
    }
    
    // MARK: - Top Bar
    
    private var socialTopBar: some View {
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
            
            Text("🤝 社交模式")
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
            Text("温暖连接")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("分享善意，传递温暖")
                .font(GentleFont.caption(15))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.vertical, GentleSpacing.xl)
    }
    
    // MARK: - Module Grid
    
    private var moduleGrid: some View {
        VStack(spacing: GentleSpacing.lg) {
            // 温柔墙卡片
            gentleWallCard
            
            // 社交动态卡片
            socialFeedCard
        }
    }
    
    private var gentleWallCard: some View {
        let isHovered = hoveredModule == "gentleWall"
        
        return Button {
            showGentleWall = true
        } label: {
            HStack(spacing: GentleSpacing.xl) {
                // 图标
                ZStack {
                    RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#FCD34D"), Color(hex: "#F97316")],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(color: Color(hex: "#FCD34D").opacity(isHovered ? 0.5 : 0.3), radius: isHovered ? 20 : 12, x: 0, y: 6)
                    
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundColor(.white)
                }
                .scaleEffect(isHovered ? 1.08 : 1.0)
                
                // 信息
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 10) {
                        Text("温柔墙")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("每日善意")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color(hex: "#FCD34D"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule().fill(Color(hex: "#FCD34D").opacity(0.2))
                            )
                    }
                    
                    Text("记录每天的小确幸")
                        .font(GentleFont.caption(14))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("写下今天发生的美好，传递温暖")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.4))
                }
                
                Spacer()
                
                // 进入按钮
                VStack(spacing: 4) {
                    Image(systemName: "rectangle.portrait.righthalf.inset.filled.arrow.right")
                        .font(.system(size: 18))
                    Text("进入")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(Color(hex: "#FCD34D"))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Capsule().fill(Color(hex: "#FCD34D").opacity(0.15))
                )
            }
            .padding(GentleSpacing.xl)
            .background(
                RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                    .fill(isHovered ? Color.white.opacity(0.08) : Color.white.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                    .stroke(Color(hex: "#FCD34D").opacity(isHovered ? 0.4 : 0.15), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                hoveredModule = hovering ? "gentleWall" : nil
            }
        }
    }
    
    private var socialFeedCard: some View {
        let isHovered = hoveredModule == "socialFeed"
        
        return Button {
            showSocialFeed = true
        } label: {
            HStack(spacing: GentleSpacing.xl) {
                // 图标
                ZStack {
                    RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#34D399"), Color(hex: "#10B981")],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(color: Color(hex: "#34D399").opacity(isHovered ? 0.5 : 0.3), radius: isHovered ? 20 : 12, x: 0, y: 6)
                    
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundColor(.white)
                }
                .scaleEffect(isHovered ? 1.08 : 1.0)
                
                // 信息
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 10) {
                        Text("社交动态")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("分享心情")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color(hex: "#34D399"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule().fill(Color(hex: "#34D399").opacity(0.2))
                            )
                    }
                    
                    Text("看看朋友们的近况")
                        .font(GentleFont.caption(14))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("分享你的心情，给他人点赞鼓励")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.4))
                }
                
                Spacer()
                
                // 进入按钮
                VStack(spacing: 4) {
                    Image(systemName: "rectangle.portrait.righthalf.inset.filled.arrow.right")
                        .font(.system(size: 18))
                    Text("进入")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(Color(hex: "#34D399"))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Capsule().fill(Color(hex: "#34D399").opacity(0.15))
                )
            }
            .padding(GentleSpacing.xl)
            .background(
                RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                    .fill(isHovered ? Color.white.opacity(0.08) : Color.white.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                    .stroke(Color(hex: "#34D399").opacity(isHovered ? 0.4 : 0.15), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                hoveredModule = hovering ? "socialFeed" : nil
            }
        }
    }
}
