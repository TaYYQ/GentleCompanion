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
    @State private var showServerSetup = false
    @State private var showActivation = false
    @StateObject private var theme    = GentleThemeManager.shared
    @AppStorage("hasCompletedActivation") private var hasCompletedActivation = false
    @AppStorage("hasConfiguredServer") private var hasConfiguredServer = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                // 主视图
                GentleMainView()

                // 启动检测页（主题 + 平台检测）
                if showSplash {
                    SplashView(isPresented: $showSplash)
                        .transition(.opacity)
                }

            // 服务器配置页
            if showServerSetup {
                // 黑色遮罩——在配置期间完全覆盖主界面
                Color.black
                    .ignoresSafeArea()
                    .transition(.opacity)

                ServerSetupView(
                    onComplete: {
                        hasConfiguredServer = true
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showServerSetup = false
                        }
                        proceedToActivation()
                    },
                    onSkip: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showServerSetup = false
                        }
                        proceedToActivation()
                    }
                )
                .transition(.opacity)
            }

            // 首次激活页
            if showActivation {
                // 黑色遮罩——在激活期间完全覆盖主界面
                Color.black
                    .ignoresSafeArea()
                    .transition(.opacity)

                ActivationView()
                    .transition(.opacity)
                    .onReceive(NotificationCenter.default.publisher(for: .activationComplete)) { _ in
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showActivation = false
                        }
                        hasCompletedActivation = true
                    }
            }
            }
            .animation(.easeInOut(duration: 0.5), value: showSplash)
            .animation(.easeInOut(duration: 0.5), value: showServerSetup)
            .animation(.easeInOut(duration: 0.5), value: showActivation)
            .id(theme.current)
            .onChange(of: showSplash) { _, newValue in
                guard !newValue else { return }
                // Splash 完成后：首次启动显示服务器配置，然后激活界面
                if !hasCompletedActivation {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showServerSetup = true
                    }
                }
            }
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1091, height: 738)
    }

    private func proceedToActivation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.5)) {
                showActivation = true
            }
        }
    }
}
