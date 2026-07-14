//
//  GentiOSMainView.swift
//  GentleCompanion iOS
//
//  主界面 — 液态玻璃 TabBar + 横向滑动交互
//  支持手势滑动切换，Liquid Glass 视觉风格
//

import SwiftUI

// MARK: - Tab Definition

enum iOSTab: String, CaseIterable {
    case home = "陪伴"
    case focus = "专注"
    case whisper = "悄悄话"
    case wall = "温柔墙"
    case profile = "我的"

    var icon: String {
        switch self {
        case .home:    return "heart.fill"
        case .focus:   return "timer"
        case .whisper: return "message.fill"
        case .wall:    return "sparkles"
        case .profile: return "person.fill"
        }
    }
}

// MARK: - Main View

struct GentiOSMainView: View {
    @State private var selectedTab: iOSTab = .home
    @State private var tabBarOpacity: Double = 1
    @State private var appear = false
    @Namespace private var tabNamespace
    @ObservedObject private var themeManager = GentleThemeManager.shared
    @StateObject private var appState = GentleAppState.shared
    private var theme: GentlePlatformTheme { themeManager.current }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Background
            Gentle.Glass.baseBackground
                .ignoresSafeArea()

            // Ambient glow
            Gentle.Glass.ambientGlow(color: selectedTab == .profile
                ? Color(hex: "#EC4899")
                : theme.primary)
                .frame(width: 380, height: 380)
                .offset(y: -200)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.8), value: selectedTab)

            // Page content with swipe gesture
            TabPageContainer(selectedTab: $selectedTab)
                .ignoresSafeArea(.keyboard)

            // Glass tab bar
            glassTabBar
                .opacity(appear && !appState.hideTabBar ? 1 : 0)
                .offset(y: appear && !appState.hideTabBar ? 0 : 30)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { appear = true }
        }
    }

    // MARK: - Glass Tab Bar

    private var glassTabBar: some View {
        HStack(spacing: 0) {
            ForEach(iOSTab.allCases, id: \.self) { tab in
                tabBarItem(tab)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background {
            Capsule()
                .fill(Gentle.Glass.darkBaseCard.opacity(0.7))
        }
        .background {
            Capsule()
                .fill(.ultraThinMaterial.opacity(0.8))
        }
        .overlay {
            Capsule()
                .stroke(Gentle.Glass.borderWhite, lineWidth: 0.5)
        }
        .overlay(alignment: .top) {
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.12), .white.opacity(0.0)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(height: 1)
                .padding(.horizontal, 1)
        }
        .shadow(
            color: theme.primary.opacity(0.1),
            radius: 20, x: 0, y: 10
        )
        .shadow(
            color: Color.black.opacity(0.25),
            radius: 8, x: 0, y: 4
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 2)
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 30)
    }

    private func tabBarItem(_ tab: iOSTab) -> some View {
        let isSelected = selectedTab == tab
        return Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        } label: {
            ZStack {
                // Selected background pill
                if isSelected {
                    Capsule()
                        .fill(theme.primary.opacity(0.2))
                        .background {
                            Capsule()
                                .fill(.ultraThinMaterial)
                        }
                        .overlay {
                            Capsule()
                                .stroke(theme.primary.opacity(0.3), lineWidth: 0.5)
                        }
                        .overlay(alignment: .top) {
                            Capsule()
                                .fill(.white.opacity(0.1))
                                .frame(height: 1)
                                .padding(.horizontal, 1)
                        }
                        .matchedGeometryEffect(id: "tabPill", in: tabNamespace)
                }

                HStack(spacing: 5) {
                    Image(systemName: tab.icon)
                        .font(.system(size: isSelected ? 16 : 15, weight: isSelected ? .semibold : .regular))

                    if isSelected {
                        Text(tab.rawValue)
                            .font(.system(size: 12, weight: .medium))
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .foregroundColor(isSelected ? Gentle.Glass.textPrimary : Gentle.Glass.textTertiary)
            }
            .frame(height: 42)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: selectedTab)
    }
}

// MARK: - Tab Page Container (Swipeable)

private struct TabPageContainer: View {
    @Binding var selectedTab: iOSTab

    var body: some View {
        GeometryReader { geometry in
            let tabs = iOSTab.allCases
            let currentIndex = CGFloat(tabs.firstIndex(of: selectedTab) ?? 0)
            let pageWidth = geometry.size.width

            HStack(spacing: 0) {
                ForEach(tabs, id: \.self) { tab in
                    tabPageView(for: tab)
                        .frame(width: pageWidth, height: geometry.size.height)
                }
            }
            .frame(width: pageWidth * CGFloat(tabs.count), alignment: .leading)
            .offset(x: -currentIndex * pageWidth)
            .animation(.spring(response: 0.45, dampingFraction: 0.8), value: selectedTab)
            .gesture(
                DragGesture(minimumDistance: 20)
                    .onEnded { value in
                        let threshold: CGFloat = 40
                        let velocity = value.predictedEndTranslation.width
                        let currentIdx = tabs.firstIndex(of: selectedTab) ?? 0

                        if velocity < -threshold, currentIdx < tabs.count - 1 {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                selectedTab = tabs[currentIdx + 1]
                            }
                        } else if velocity > threshold, currentIdx > 0 {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                selectedTab = tabs[currentIdx - 1]
                            }
                        }
                    }
            )
        }
    }

    @ViewBuilder
    private func tabPageView(for tab: iOSTab) -> some View {
        switch tab {
        case .home:
            NavigationStack { GentiOSHomeView() }
        case .focus:
            NavigationStack { PomodoroiOSView() }
        case .whisper:
            NavigationStack { GentiOSMessageView() }
        case .wall:
            NavigationStack { GentiOSWallView() }
        case .profile:
            NavigationStack { GentiOSProfileView() }
        }
    }
}
