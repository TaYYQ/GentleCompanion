//
//  GentleCompanionApp.swift
//  GentleCompanion
//
//  App entry: SplashView → ActivationView (first launch) → GentleMainView
//


import SwiftUI

@main
struct GentleCompanionApp: App {
    @State private var showSplash     = true
    @State private var showActivation = false
    @StateObject private var theme    = GentleThemeManager.shared

    var body: some Scene {
        WindowGroup {
            ZStack {
                // 主视图
                GentleMainView()

                // 启动检测页（主题 + 平台检测）
                if showSplash {
                    SplashView(isPresented: $showSplash)
                        .transition(.opacity)
                        .onChange(of: showSplash) { _, newValue in
                            if !newValue {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        showSplash = false
                                        showActivation = true
                                    }
                                }
                            }
                        }
                }

                // 首次激活页
                if showActivation && !showSplash {
                    ActivationView()
                        .transition(.opacity)
                        .onReceive(NotificationCenter.default.publisher(for: .activationComplete)) { _ in
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showActivation = false
                            }
                        }
                }
            }
            .animation(.easeInOut(duration: 0.5), value: showSplash)
            .animation(.easeInOut(duration: 0.5), value: showActivation)
            .id(theme.current)  // 主题切换时强制刷新整个视图树
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1091, height: 738)
    }
}
