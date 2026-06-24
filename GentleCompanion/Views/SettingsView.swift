//
//  SettingsView.swift
//  GentleCompanion
//
//  完整功能版设置页 - 优化版
//

import SwiftUI
import AppKit
import AVFoundation
import UserNotifications

// MARK: - Settings View

struct SettingsView: View {
    @Binding var isPresented: Bool
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var themeManager = GentleThemeManager.shared
    
    // 真实设置
    @State private var appSettings: AppSettings = SettingsManager.shared.settings
    
    // 子页面状态
    @State private var showEmotionHistory = false
    @State private var showEmotionAnalysis = false
    
    // 服务器状态
    @State private var isServerConnected = false
    @State private var isCheckingServer = false
    @State private var serverResponseTime: Double? = nil      // 响应时间（毫秒）
    @State private var serverVersion: String? = nil            // 服务器版本
    @State private var serverCheckError: String? = nil         // 错误信息
    @State private var lastCheckTime: Date? = nil              // 上次检查时间
    
    // 音效播放器
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlayingSound = false
    @State private var selectedSoundName: String = "雨声"  // 显示名称
    @State private var selectedSoundFile: String = "雨声"   // 文件名（不含扩展名）
    @State private var soundVolume: Double = 0.3
    
    // 悬浮窗引用
    @State private var floatingWindow: NSWindow?
    
    // 版本检查
    @State private var isCheckingUpdate = false
    @State private var updateMessage: String?
    
    // 提醒时间编辑
    @State private var showReminderTimeEditor = false
    
    // 动画状态
    @State private var headerScale: CGFloat = 1.0
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // 背景
            LinearGradient(
                colors: [Gentle.Background.primary, Gentle.Background.tertiary],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: GentleSpacing.lg) {
                headerBar
                settingsList
            }
            .focusable()
            .onKeyPress(.escape) {
                dismiss()
                return .handled
            }
            .onAppear {
                loadSettings()
                checkServerConnection()
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    headerScale = 1.02
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        headerScale = 1.0
                    }
                }
            }
            .sheet(isPresented: $showEmotionHistory) {
                EmotionHistoryView(isPresented: $showEmotionHistory)
            }
            .sheet(isPresented: $showEmotionAnalysis) {
                EmotionAnalysisView(isPresented: $showEmotionAnalysis)
            }
            .sheet(isPresented: $showReminderTimeEditor) {
                ReminderTimeEditorView(
                    isPresented: $showReminderTimeEditor,
                    reminderTimes: $appSettings.reminderTimes
                )
            }
        }
    }
    
    private var headerBar: some View {
        HStack {
            Button(action: { 
                dismiss()
            }) {
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
            
            VStack(spacing: GentleSpacing.xs) {
                Text("设置")
                    .font(GentleFont.headline())
                    .foregroundColor(Gentle.Text.primary)
                Text("个性化你的温柔体验")
                    .font(GentleFont.caption())
                    .foregroundColor(Gentle.Text.secondary)
            }
            .scaleEffect(headerScale)
            
            Spacer()
            
            // 保存按钮
            Button(action: { 
                saveSettings()
                // 保存成功动画
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    headerScale = 1.1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        headerScale = 1.0
                    }
                }
            }) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Gentle.Primary.purple)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, GentleSpacing.lg)
        .padding(.vertical, GentleSpacing.md)
    }
    
    private var settingsList: some View {
        ScrollView {
            VStack(spacing: GentleSpacing.lg) {
                // 通用设置
                GentleCard(padding: GentleSpacing.lg) {
                    VStack(spacing: GentleSpacing.md) {
                        SectionHeader(title: "通用设置", icon: "gearshape.fill")
                        
                        // 主题选择
                        themeSelector
                        
                        SettingToggle(
                            title: "背景音效",
                            subtitle: isPlayingSound ? "正在播放：\(selectedSoundName)" : "雨声/风声/海浪/壁炉",
                            isOn: Binding(
                                get: { appSettings.soundEnabled },
                                set: { 
                                    appSettings.soundEnabled = $0
                                    if $0 { startBackgroundSound(filename: selectedSoundFile) } else { stopBackgroundSound() }
                                }
                            )
                        )
                        
                        // 音效选择
                        if appSettings.soundEnabled {
                            SoundSelector(
                                selectedSoundName: $selectedSoundName,
                                selectedSoundFile: $selectedSoundFile,
                                volume: $soundVolume,
                                onSelect: { filename in
                                    if appSettings.soundEnabled {
                                        stopBackgroundSound()
                                        startBackgroundSound(filename: filename)
                                    }
                                },
                                onVolumeChange: { newVolume in
                                    audioPlayer?.volume = Float(newVolume)
                                }
                            )
                        }
                        
                        SettingToggle(
                            title: "全屏沉浸",
                            subtitle: "隐藏按钮和提示文字",
                            isOn: Binding(
                                get: { appSettings.immersiveFullScreenEnabled },
                                set: { 
                                    appSettings.immersiveFullScreenEnabled = $0
                                    applyFullScreenMode($0)
                                }
                            )
                        )
                        
                        SettingToggle(
                            title: "悬浮窗",
                            subtitle: floatingWindow != nil ? "悬浮窗已开启" : "显示小窗口",
                            isOn: Binding(
                                get: { appSettings.floatingWindowEnabled },
                                set: {
                                    appSettings.floatingWindowEnabled = $0
                                    if $0 { showFloatingWindow() } else { hideFloatingWindow() }
                                }
                            )
                        )
                    }
                }
                .padding(.horizontal, GentleSpacing.lg)
                
                // 提醒通知
                GentleCard(padding: GentleSpacing.lg) {
                    VStack(spacing: GentleSpacing.md) {
                        SectionHeader(title: "提醒通知", icon: "bell.fill")
                        
                        SettingToggle(
                            title: "开启提醒",
                            subtitle: "定期收到温柔提醒",
                            isOn: Binding(
                                get: { appSettings.reminderEnabled },
                                set: {
                                    appSettings.reminderEnabled = $0
                                    if $0 { requestNotificationPermission() }
                                }
                            )
                        )
                        
                        if appSettings.reminderEnabled {
                            // 频率选择
                            HStack {
                                Text("频率")
                                    .font(GentleFont.body())
                                    .foregroundColor(Gentle.Text.primary)
                                
                                Spacer()
                                
                                HStack(spacing: GentleSpacing.sm) {
                                    ForEach(["每天", "每周"], id: \.self) { option in
                                        FrequencyButton(
                                            option: option,
                                            isSelected: (appSettings.reminderFrequency == .daily ? "每天" : "每周") == option
                                        ) {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                appSettings.reminderFrequency = option == "每天" ? .daily : .weekly
                                            }
                                        }
                                    }
                                }
                            }
                            
                            SettingAction(
                                title: "提醒时间",
                                subtitle: formatReminderTimes(),
                                icon: "clock",
                                action: { showReminderTimeEditor = true }
                            )
                        }
                    }
                }
                .padding(.horizontal, GentleSpacing.lg)
                
                // 情绪管理
                GentleCard(padding: GentleSpacing.lg) {
                    VStack(spacing: GentleSpacing.md) {
                        SectionHeader(title: "情绪管理", icon: "heart.fill")
                        
                        SettingAction(
                            title: "情绪记录",
                            subtitle: "\(appSettings.emotionHistory.count) 条记录",
                            icon: "doc.text.fill",
                            action: { showEmotionHistory = true }
                        )
                        
                        SettingAction(
                            title: "情绪分析",
                            subtitle: "了解你的情绪趋势",
                            icon: "chart.bar.fill",
                            action: { showEmotionAnalysis = true }
                        )
                    }
                }
                .padding(.horizontal, GentleSpacing.lg)
                
                // 服务器连接
                GentleCard(padding: GentleSpacing.lg) {
                    VStack(spacing: GentleSpacing.md) {
                        SectionHeader(title: "服务器连接", icon: "wifi")
                        
                        // 连接状态指示器
                        HStack(spacing: GentleSpacing.sm) {
                            // 脉冲指示灯
                            ZStack {
                                if isCheckingServer {
                                    Circle()
                                        .fill(Gentle.Primary.yellow.opacity(0.2))
                                        .frame(width: 22, height: 22)
                                        .scaleEffect(pulseScale)
                                    Circle()
                                        .fill(Gentle.Primary.yellow)
                                        .frame(width: 10, height: 10)
                                } else if isServerConnected {
                                    Circle()
                                        .fill(Gentle.State.success.opacity(0.2))
                                        .frame(width: 22, height: 22)
                                        .scaleEffect(pulseScale)
                                    Circle()
                                        .fill(Gentle.State.success)
                                        .frame(width: 10, height: 10)
                                } else {
                                    Circle()
                                        .fill(Gentle.State.error.opacity(0.2))
                                        .frame(width: 22, height: 22)
                                    Circle()
                                        .fill(Gentle.State.error)
                                        .frame(width: 10, height: 10)
                                }
                            }
                            .onAppear {
                                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                                    pulseScale = 1.5
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(isCheckingServer ? "正在检测..." : (isServerConnected ? "已连接" : "未连接"))
                                    .font(GentleFont.headline(14))
                                    .foregroundColor(Gentle.Text.primary)
                                
                                if let error = serverCheckError, !isServerConnected, !isCheckingServer {
                                    Text(error)
                                        .font(GentleFont.caption(11))
                                        .foregroundColor(Gentle.State.error)
                                        .lineLimit(1)
                                } else if isServerConnected, let time = serverResponseTime {
                                    Text(String(format: "响应 %.0fms", time))
                                        .font(GentleFont.caption(11))
                                        .foregroundColor(Gentle.Text.secondary)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, GentleSpacing.xs)
                        
                        // 诊断详情
                        VStack(spacing: 0) {
                            // 服务器地址
                            DetailRow(label: "服务器地址", value: "YOUR_SERVER_IP:80")
                            
                            Divider()
                                .padding(.leading, 100)
                            
                            // 响应时间
                            DetailRow(
                                label: "响应时间",
                                value: serverResponseTime.map { String(format: "%.0f ms", $0) } ?? "—"
                            )
                            
                            Divider()
                                .padding(.leading, 100)
                            
                            // 服务器版本
                            DetailRow(
                                label: "API 版本",
                                value: serverVersion ?? "—"
                            )
                            
                            Divider()
                                .padding(.leading, 100)
                            
                            // 最后检测时间
                            DetailRow(
                                label: "上次检测",
                                value: lastCheckTime.map { formatTimeAgo($0) } ?? "—"
                            )
                        }
                        .background(Gentle.Background.tertiary.opacity(0.5))
                        .cornerRadius(GentleRadius.sm)
                        
                        // 操作按钮
                        HStack(spacing: GentleSpacing.sm) {
                            Button(action: { checkServerConnection() }) {
                                HStack(spacing: 4) {
                                    if isCheckingServer {
                                        ProgressView()
                                            .scaleEffect(0.65)
                                            .frame(width: 14, height: 14)
                                    } else {
                                        Image(systemName: "arrow.clockwise")
                                            .font(.system(size: 12, weight: .semibold))
                                    }
                                    Text(isCheckingServer ? "检测中..." : "重新检测")
                                        .font(GentleFont.caption(12))
                                }
                                .foregroundColor(Gentle.Primary.purple)
                                .padding(.horizontal, GentleSpacing.md)
                                .padding(.vertical, GentleSpacing.xs)
                                .background(
                                    RoundedRectangle(cornerRadius: GentleRadius.sm)
                                        .fill(Gentle.Primary.purple.opacity(0.08))
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(isCheckingServer)
                            
                            Spacer()
                            
                            // 一键诊断按钮
                            if !isCheckingServer && !isServerConnected {
                                Button(action: { runDiagnostics() }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "stethoscope")
                                            .font(.system(size: 12, weight: .semibold))
                                        Text("诊断")
                                            .font(GentleFont.caption(12))
                                    }
                                    .foregroundColor(Gentle.State.warning)
                                    .padding(.horizontal, GentleSpacing.md)
                                    .padding(.vertical, GentleSpacing.xs)
                                    .background(
                                        RoundedRectangle(cornerRadius: GentleRadius.sm)
                                            .fill(Gentle.State.warning.opacity(0.1))
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                .padding(.horizontal, GentleSpacing.lg)
                
                // 关于
                GentleCard(padding: GentleSpacing.lg) {
                    VStack(spacing: GentleSpacing.md) {
                        SectionHeader(title: "关于", icon: "info.circle.fill")
                        
                        SettingInfo(title: "版本", value: "1.0.0")
                        SettingInfo(title: "开发者", value: "温柔团队")
                        
                        SettingAction(
                            title: "检查更新",
                            subtitle: updateMessage ?? "查看是否有新版本",
                            icon: "arrow.up.right.circle",
                            isLoading: isCheckingUpdate,
                            action: { checkForUpdate() }
                        )
                        
                        SettingAction(
                            title: "清除数据",
                            subtitle: "重置所有设置和记录",
                            icon: "trash",
                            isDestructive: true,
                            action: { clearAllData() }
                        )
                    }
                }
                .padding(.horizontal, GentleSpacing.lg)
                .padding(.bottom, GentleSpacing.xxl)
            }
        }
    }
    
    // MARK: - Actions
    
    private func loadSettings() {
        appSettings = SettingsManager.shared.settings
    }
    
    private func saveSettings() {
        SettingsManager.shared.settings = appSettings
        NotificationManager.shared.scheduleReminders(settings: appSettings)
    }
    
    // MARK: - Background Sound
    
    /// 查找资源文件，支持 SPM 开发环境和打包后的 .app
    private func findSoundURL(filename: String) -> URL? {
        let resourceName = filename.replacingOccurrences(of: ".mp3", with: "")
        
        // 方法1: 直接从 Bundle.main 查找
        if let url = Bundle.main.url(forResource: resourceName, withExtension: "mp3") {
            return url
        }
        
        // 方法2: 从当前可执行文件目录向上查找 .bundle
        if let executablePath = Bundle.main.executablePath {
            let execDir = (executablePath as NSString).deletingLastPathComponent
            
            // 尝试: ./GentleCompanion_GentleCompanion.bundle (SPM 开发环境)
            var bundlePath = execDir + "/GentleCompanion_GentleCompanion.bundle"
            if let url = Bundle(path: bundlePath)?.url(forResource: resourceName, withExtension: "mp3") {
                return url
            }
            
            // 尝试: ../Resources/GentleCompanion_GentleCompanion.bundle (.app 打包环境)
            bundlePath = execDir + "/../Resources/GentleCompanion_GentleCompanion.bundle"
            let resolved = (bundlePath as NSString).standardizingPath
            if let url = Bundle(path: resolved)?.url(forResource: resourceName, withExtension: "mp3") {
                return url
            }
        }
        
        return nil
    }
    
    private func startBackgroundSound(filename: String = "雨声") {
        let resourceName = filename.replacingOccurrences(of: ".mp3", with: "")
        
        guard let url = findSoundURL(filename: filename) else {
            print("⚠️ 找不到背景音效文件: \(resourceName).mp3")
            // 调试信息
            if let execPath = Bundle.main.executablePath {
                print("📁 可执行文件路径: \(execPath)")
                let bundlePath = (execPath as NSString).deletingLastPathComponent + "/GentleCompanion_GentleCompanion.bundle"
                print("📁 尝试查找 bundle: \(bundlePath)")
                if let bundleContents = try? FileManager.default.contentsOfDirectory(atPath: bundlePath) {
                    let mp3s = bundleContents.filter { $0.hasSuffix(".mp3") }
                    print("📁 Bundle 中的 mp3: \(mp3s)")
                }
            }
            return
        }
        
        do {
            audioPlayer?.stop()
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.volume = Float(soundVolume)
            audioPlayer?.play()
            isPlayingSound = true
            print("🎵 开始播放: \(url.path)")
        } catch {
            print("❌ 播放失败: \(error)")
        }
    }
    
    private func stopBackgroundSound() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlayingSound = false
    }
    
    // MARK: - Helpers
    
    private func formatTimeAgo(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return "刚刚" }
        if interval < 3600 { return "\(Int(interval / 60))分钟前" }
        if interval < 86400 { return "\(Int(interval / 3600))小时前" }
        return "\(Int(interval / 86400))天前"
    }
    
    // MARK: - Full Screen
    
    private func applyFullScreenMode(_ enabled: Bool) {
        guard let window = NSApplication.shared.windows.first else { return }
        
        if enabled {
            window.styleMask.insert(.fullScreen)
            window.toggleFullScreen(nil)
        } else {
            if window.styleMask.contains(.fullScreen) {
                window.toggleFullScreen(nil)
            }
        }
    }
    
    // MARK: - Floating Window
    
    private func showFloatingWindow() {
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 200, height: 120),
            styleMask: [.nonactivatingPanel, .titled, .closable, .hudWindow],
            backing: .buffered,
            defer: false
        )
        
        panel.title = "温柔点"
        panel.level = .floating
        panel.isFloatingPanel = true
        panel.hidesOnDeactivate = false
        panel.collectionBehavior = [.canJoinAllSpaces, .stationary]
        
        let hostingView = NSHostingView(rootView: FloatingWindowContent())
        panel.contentView = hostingView
        
        // 定位到右上角
        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            panel.setFrameOrigin(NSPoint(
                x: screenFrame.maxX - 220,
                y: screenFrame.maxY - 140
            ))
        }
        
        panel.makeKeyAndOrderFront(nil)
        floatingWindow = panel
    }
    
    private func hideFloatingWindow() {
        floatingWindow?.close()
        floatingWindow = nil
    }
    
    // MARK: - Notifications
    
    private func requestNotificationPermission() {
        let currentSettings = appSettings
        NotificationManager.shared.requestAuthorization { granted in
            if granted {
                NotificationManager.shared.scheduleReminders(settings: currentSettings)
            }
        }
    }
    
    private func formatReminderTimes() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let times = appSettings.reminderTimes.prefix(3).map { formatter.string(from: $0) }
        return times.isEmpty ? "未设置" : times.joined(separator: ", ")
    }
    
    // MARK: - Server Connection
    
    private func checkServerConnection() {
        Task {
            isCheckingServer = true
            serverCheckError = nil
            serverResponseTime = nil
            serverVersion = nil
            
            let startTime = CFAbsoluteTimeGetCurrent()
            
            do {
                // 1. 先请求根路径获取基本信息
                guard let url = URL(string: "http://YOUR_SERVER_IP:80/") else {
                    isServerConnected = false
                    serverCheckError = "无效的服务器地址"
                    return
                }
                
                var request = URLRequest(url: url)
                request.timeoutInterval = 8
                
                let (data, response) = try await URLSession.shared.data(for: request)
                let elapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
                serverResponseTime = elapsed
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    isServerConnected = false
                    serverCheckError = "无法解析服务器响应"
                    return
                }
                
                let isSuccess = (200...299).contains(httpResponse.statusCode)
                
                // 解析服务器返回的 JSON（兼容 ok/running 两种状态值）
                if isSuccess, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    serverVersion = (json["version"] as? String) ?? (json["api_version"] as? String)
                    let status = json["status"] as? String ?? "unknown"
                    let service = json["service"] as? String
                    // 兼容 "ok" / "running" / "success" 等多种状态值
                    let isRunning = ["ok", "running", "success"].contains(status.lowercased())
                    // 如果有 service 字段且匹配，也算连接成功
                    let isServiceMatch = (service == "GentleCompanion API")
                    isServerConnected = isRunning || isServiceMatch
                    if !isServerConnected {
                        serverCheckError = "服务器状态异常: \(status)"
                    }
                } else if !isSuccess {
                    serverCheckError = "HTTP \(httpResponse.statusCode)"
                    isServerConnected = false
                } else {
                    isServerConnected = true
                }
                
            } catch let error as URLError {
                isServerConnected = false
                switch error.code {
                case .timedOut:
                    serverCheckError = "连接超时（8秒）"
                case .cannotConnectToHost:
                    serverCheckError = "无法连接到服务器"
                case .notConnectedToInternet:
                    serverCheckError = "无网络连接"
                case .dnsLookupFailed:
                    serverCheckError = "DNS 解析失败"
                default:
                    serverCheckError = error.localizedDescription
                }
            } catch {
                isServerConnected = false
                serverCheckError = error.localizedDescription
            }
            
            lastCheckTime = Date()
            isCheckingServer = false
        }
    }
    
    /// 一键诊断：逐步检测网络可达性、DNS 解析、HTTP 连接
    private func runDiagnostics() {
        Task {
            isCheckingServer = true
            serverCheckError = nil
            serverResponseTime = nil
            serverVersion = nil
            
            let host = "YOUR_SERVER_IP"
            let port = 80
            let startTotal = CFAbsoluteTimeGetCurrent()
            
            do {
                guard let url = URL(string: "http://\(host):\(port)/") else {
                    serverCheckError = "无效地址"
                    isServerConnected = false
                    return
                }
                
                var request = URLRequest(url: url)
                request.timeoutInterval = 5
                let (data, response) = try await URLSession.shared.data(for: request)
                let elapsed = (CFAbsoluteTimeGetCurrent() - startTotal) * 1000
                serverResponseTime = elapsed
                
                if let httpResponse = response as? HTTPURLResponse {
                    if (200...299).contains(httpResponse.statusCode) {
                        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                            serverVersion = (json["version"] as? String) ?? (json["api_version"] as? String)
                            let status = json["status"] as? String ?? ""
                            let service = json["service"] as? String
                            let isRunning = ["ok", "running", "success"].contains(status.lowercased())
                            let isServiceMatch = (service == "GentleCompanion API")
                            isServerConnected = isRunning || isServiceMatch
                            if isServerConnected {
                                serverCheckError = nil
                            } else {
                                serverCheckError = "服务异常: \(status)"
                            }
                        } else {
                            isServerConnected = true
                        }
                    } else {
                        isServerConnected = false
                        serverCheckError = "HTTP \(httpResponse.statusCode)"
                    }
                }
            } catch let error as URLError {
                isServerConnected = false
                switch error.code {
                case .timedOut:
                    serverCheckError = "连接超时 — 服务器可能未运行或防火墙阻止"
                case .cannotConnectToHost:
                    serverCheckError = "无法连接 — 请检查服务器是否启动"
                case .notConnectedToInternet:
                    serverCheckError = "本机无网络连接"
                case .dnsLookupFailed:
                    serverCheckError = "DNS 解析失败 — 请检查地址"
                default:
                    serverCheckError = error.localizedDescription
                }
            } catch {
                isServerConnected = false
                serverCheckError = error.localizedDescription
            }
            
            lastCheckTime = Date()
            isCheckingServer = false
        }
    }
    
    // MARK: - Update Check
    
    private func checkForUpdate() {
        isCheckingUpdate = true
        updateMessage = nil
        
        Task {
            do {
                guard let url = URL(string: "http://YOUR_SERVER_IP:80/") else {
                    await MainActor.run {
                        isCheckingUpdate = false
                        updateMessage = "更新检查失败"
                    }
                    return
                }
                
                var request = URLRequest(url: url)
                request.timeoutInterval = 5
                let (data, _) = try await URLSession.shared.data(for: request)
                
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let serverVersion = json["version"] as? String {
                    let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
                    if serverVersion == currentVersion {
                        await MainActor.run {
                            isCheckingUpdate = false
                            updateMessage = "已是最新版本 (\(currentVersion))"
                        }
                    } else {
                        await MainActor.run {
                            isCheckingUpdate = false
                            updateMessage = "发现新版本 \(serverVersion)"
                        }
                    }
                } else {
                    await MainActor.run {
                        isCheckingUpdate = false
                        updateMessage = "已是最新版本"
                    }
                }
            } catch {
                await MainActor.run {
                    isCheckingUpdate = false
                    updateMessage = "无法检查更新"
                }
            }
        }
    }
    
    // MARK: - Theme Selector
    
    private var themeSelector: some View {
        VStack(spacing: GentleSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: GentleSpacing.xs) {
                    Text("界面主题")
                        .font(GentleFont.body())
                        .foregroundColor(Gentle.Text.primary)
                    Text("选择 macOS 或 Windows 视觉风格")
                        .font(GentleFont.caption())
                        .foregroundColor(Gentle.Text.secondary)
                }
                Spacer()
            }
            
            HStack(spacing: GentleSpacing.sm) {
                ForEach(GentlePlatformTheme.allCases, id: \.self) { theme in
                    ThemeOptionButton(
                        theme: theme,
                        isSelected: themeManager.current == theme,
                        action: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                themeManager.apply(theme)
                            }
                        }
                    )
                }
            }
        }
        .padding(.bottom, GentleSpacing.xs)
    }
    
    // MARK: - Clear Data
    
    private func clearAllData() {
        let alert = NSAlert()
        alert.messageText = "确认清除"
        alert.informativeText = "这将清除所有设置和情绪记录，无法恢复。"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "清除")
        alert.addButton(withTitle: "取消")
        
        if alert.runModal() == .alertFirstButtonReturn {
            SettingsManager.shared.settings = AppSettings.defaultSettings
            appSettings = AppSettings.defaultSettings
            updateMessage = "数据已清除"
        }
    }
}

// MARK: - Floating Window Content

struct FloatingWindowContent: View {
    @State private var currentEmotion: Emotion?
    @State private var isHovering = false
    @State private var messageIndex = 0
    @State private var shimmerPhase: CGFloat = 0
    
    private let timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // 底层磨砂背景
            VisualEffectBlur(material: .hudWindow, blendingMode: .behindWindow)
            
            // 装饰性微光光晕
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            (emotionAccentColor).opacity(0.15),
                            .clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 80
                    )
                )
                .frame(width: 140, height: 140)
                .blur(radius: 4)
                .opacity(isHovering ? 1.0 : 0.3)
                .animation(.easeInOut(duration: 0.5), value: isHovering)
            
            // 主内容
            VStack(spacing: 0) {
                if let emotion = currentEmotion {
                    // 情绪图标
                    ZStack {
                        // 外圈光环
                        Circle()
                            .stroke(
                                emotionAccentColor.opacity(0.2),
                                lineWidth: 2
                            )
                            .frame(width: 56, height: 56)
                        
                        Circle()
                            .stroke(
                                emotionAccentColor.opacity(0.1),
                                lineWidth: 1
                            )
                            .frame(width: 64, height: 64)
                        
                        // emoji
                        Text(emotion.emoji)
                            .font(.system(size: 30))
                    }
                    .scaleEffect(isHovering ? 1.05 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isHovering)
                    
                    Spacer().frame(height: 8)
                    
                    // 情绪名称
                    HStack(spacing: 4) {
                        Circle()
                            .fill(emotionAccentColor)
                            .frame(width: 5, height: 5)
                        
                        Text(emotion.displayName)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer().frame(height: 6)
                    
                    // 温柔消息（hover 展开）
                    if isHovering {
                        Text(gentleMessages(for: emotion))
                            .font(.system(size: 10, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 12)
                            .transition(
                                .asymmetric(
                                    insertion: .opacity.combined(with: .move(edge: .bottom)).combined(with: .scale(scale: 0.95)),
                                    removal: .opacity.combined(with: .move(edge: .top)).combined(with: .scale(scale: 0.95))
                                )
                            )
                        
                        Spacer().frame(height: 6)
                        
                        // 底部分隔线
                        RoundedRectangle(cornerRadius: 1)
                            .fill(emotionAccentColor.opacity(0.25))
                            .frame(width: 28, height: 2)
                            .transition(.opacity)
                    }
                } else {
                    // 无情绪状态
                    ZStack {
                        Circle()
                            .stroke(
                                Gentle.Primary.lavender.opacity(0.15),
                                lineWidth: 2
                            )
                            .frame(width: 48, height: 48)
                        
                        Text("🌸")
                            .font(.system(size: 24))
                    }
                    
                    Spacer().frame(height: 8)
                    
                    Text("今天感觉如何？")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Spacer().frame(height: 4)
                    
                    Text("打开 GentleCompanion 记录心情")
                        .font(.system(size: 9, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary.opacity(0.7))
                        .lineLimit(1)
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
        }
        .frame(
            width: isHovering ? 190 : 150,
            height: isHovering ? 160 : 90
        )
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    isHovering
                        ? emotionAccentColor.opacity(0.2)
                        : Color.white.opacity(0.08),
                    lineWidth: 1
                )
        )
        .shadow(
            color: emotionAccentColor.opacity(isHovering ? 0.12 : 0.04),
            radius: isHovering ? 16 : 6,
            x: 0,
            y: isHovering ? 6 : 2
        )
        .opacity(isHovering ? 1.0 : 0.82)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isHovering)
        .onAppear {
            currentEmotion = SettingsManager.shared.settings.selectedEmotion
        }
        .onHover { hovering in
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                isHovering = hovering
            }
        }
        .onReceive(timer) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                messageIndex = (messageIndex + 1) % max(1, GentleMessage.messages(for: currentEmotion ?? .other).count)
            }
        }
    }
    
    // MARK: - Helpers
    
    private var emotionAccentColor: Color {
        guard let emotion = currentEmotion,
              let hex = UInt(emotion.color.dropFirst(), radix: 16) else {
            return Gentle.Primary.lavender
        }
        return Color(hex: "#\(String(format: "%06X", hex))")
    }
    
    private func gentleMessages(for emotion: Emotion) -> String {
        let msgs = GentleMessage.messages(for: emotion)
        guard !msgs.isEmpty else { return "一切都会好起来的。" }
        return msgs[messageIndex % msgs.count]
    }
}

// Visual Effect Blur for macOS
struct VisualEffectBlur: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

// MARK: - Emotion History View

struct EmotionHistoryView: View {
    @Binding var isPresented: Bool
    @State private var entries: [EmotionEntry] = []
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button("关闭") { isPresented = false }
                Spacer()
                Text("情绪记录")
                    .font(.headline)
                Spacer()
                if !entries.isEmpty {
                    Button("清除") { clearHistory() }
                }
            }
            .padding()
            
            Divider()
            
            if entries.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Text("📝")
                        .font(.system(size: 48))
                    Text("暂无情绪记录")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("开始记录你的情绪吧")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            } else {
                List {
                    ForEach(entries.reversed()) { entry in
                        EmotionEntryRow(entry: entry)
                    }
                }
            }
        }
        .frame(width: 500, height: 400)
        .onAppear { loadEntries() }
    }
    
    private func loadEntries() {
        entries = SettingsManager.shared.settings.emotionHistory
    }
    
    private func clearHistory() {
        var settings = SettingsManager.shared.settings
        settings.emotionHistory = []
        SettingsManager.shared.settings = settings
        entries = []
    }
}

struct EmotionEntryRow: View {
    let entry: EmotionEntry
    
    var body: some View {
        HStack(spacing: 12) {
            Text(entry.emotion.emoji)
                .font(.system(size: 28))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.emotion.displayName)
                    .font(.system(size: 14, weight: .medium))
                
                Text(formatDate(entry.date))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日 HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Emotion Analysis View

struct EmotionAnalysisView: View {
    @Binding var isPresented: Bool
    @State private var entries: [EmotionEntry] = []
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button("关闭") { isPresented = false }
                Spacer()
                Text("情绪分析")
                    .font(.headline)
                Spacer()
                Color.clear.frame(width: 50)
            }
            .padding()
            
            Divider()
            
            if entries.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Text("📊")
                        .font(.system(size: 48))
                    Text("暂无数据可供分析")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            } else {
                // Tab Picker
                Picker("", selection: $selectedTab) {
                    Text("概览").tag(0)
                    Text("分布").tag(1)
                    Text("趋势").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)
                
                ScrollView {
                    VStack(spacing: 20) {
                        if selectedTab == 0 {
                            overviewTab
                        } else if selectedTab == 1 {
                            distributionTab
                        } else {
                            trendTab
                        }
                    }
                    .padding()
                }
            }
        }
        .frame(width: 550, height: 550)
        .onAppear { loadEntries() }
    }
    
    private var overviewTab: some View {
        VStack(spacing: 16) {
            // 统计卡片
            HStack(spacing: 16) {
                StatCard(icon: "doc.text", iconColor: Gentle.Primary.purple, value: "\(entries.count)", label: "总记录")
                StatCard(icon: "calendar", iconColor: Gentle.Primary.purple, value: "\(recentCount)", label: "最近7天")
                StatCard(icon: "flame", iconColor: .orange, value: "\(streakDays)", label: "连续天数")
            }
            
            // 最常见情绪
            if let mostCommon = mostCommonEmotion {
                VStack(alignment: .leading, spacing: 12) {
                    Text("最常见情绪")
                        .font(.headline)
                    
                    HStack(spacing: 16) {
                        Text(mostCommon.emoji)
                            .font(.system(size: 48))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(mostCommon.displayName)
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text(mostCommon.gentleMessage)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                            
                            // 出现次数
                            let count = entries.filter { $0.emotion == mostCommon }.count
                            let percentage = entries.isEmpty ? 0 : Int(Double(count) / Double(entries.count) * 100)
                            Text("出现 \(count) 次 (\(percentage)%)")
                                .font(.caption)
                                .foregroundColor(Gentle.Primary.purple)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(12)
                }
            }
        }
    }
    
    private var distributionTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("情绪分布")
                .font(.headline)
            
            // 饼图风格的分布
            VStack(spacing: 12) {
                ForEach(Emotion.allCases, id: \.self) { emotion in
                    EmotionDistributionRow(
                        emotion: emotion,
                        count: entries.filter { $0.emotion == emotion }.count,
                        total: entries.count
                    )
                }
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(12)
        }
    }
    
    private var trendTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("最近趋势")
                .font(.headline)
            
            // 最近7天的趋势
            VStack(spacing: 8) {
                ForEach(getLast7Days().reversed(), id: \.self) { date in
                    DayTrendRow(date: date, entries: entries)
                }
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(12)
        }
    }
    
    private func loadEntries() {
        entries = SettingsManager.shared.settings.emotionHistory
    }
    
    private var recentCount: Int {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return entries.filter { $0.date > weekAgo }.count
    }
    
    private var streakDays: Int {
        // 简化计算连续天数
        let calendar = Calendar.current
        var streak = 0
        var currentDate = Date()
        
        while true {
            let dayStart = calendar.startOfDay(for: currentDate)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart
            let hasEntry = entries.contains { $0.date >= dayStart && $0.date < dayEnd }
            
            if hasEntry {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
            
            if streak > 365 { break } // 安全限制
        }
        
        return streak
    }
    
    private var mostCommonEmotion: Emotion? {
        let counts = Dictionary(grouping: entries, by: { $0.emotion })
            .mapValues { $0.count }
        return counts.max(by: { $0.value < $1.value })?.key
    }
    
    private func getLast7Days() -> [Date] {
        let calendar = Calendar.current
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: -$0, to: Date()) }
    }
}

// Day Trend Row
struct DayTrendRow: View {
    let date: Date
    let entries: [EmotionEntry]
    
    var body: some View {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: date)
        let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart
        let dayEntries = entries.filter { $0.date >= dayStart && $0.date < dayEnd }
        
        HStack(spacing: 12) {
            Text(formatDate(date))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            if dayEntries.isEmpty {
                Text("无记录")
                    .font(.caption)
                    .foregroundColor(.secondary.opacity(0.5))
            } else {
                // 显示当天的情绪
                HStack(spacing: 4) {
                    ForEach(dayEntries.prefix(5)) { entry in
                        Text(entry.emotion.emoji)
                            .font(.system(size: 16))
                    }
                    if dayEntries.count > 5 {
                        Text("+\(dayEntries.count - 5)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
}

// MARK: - Emotion Distribution Row

struct EmotionDistributionRow: View {
    let emotion: Emotion
    let count: Int
    let total: Int
    
    var body: some View {
        guard count > 0 else { return EmptyView().eraseToAnyView() }
        
        let percentage = total == 0 ? 0 : Double(count) / Double(total) * 100
        
        return HStack {
            Text(emotion.emoji)
            Text(emotion.displayName)
                .font(.subheadline)
            
            Spacer()
            
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hex: emotion.color).opacity(0.6))
                    .frame(width: geo.size.width * CGFloat(percentage / 100))
            }
            .frame(height: 8)
            .frame(width: 100)
            
            Text("\(Int(percentage))%")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 40, alignment: .trailing)
        }
        .eraseToAnyView()
    }
}

extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}

// MARK: - Reminder Time Editor

struct ReminderTimeEditorView: View {
    @Binding var isPresented: Bool
    @Binding var reminderTimes: [Date]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("取消") { isPresented = false }
                Spacer()
                Text("提醒时间")
                    .font(.headline)
                Spacer()
                Button("保存") { isPresented = false }
            }
            .padding()
            
            Divider()
            
            VStack(spacing: 16) {
                ForEach(0..<min(reminderTimes.count, 3), id: \.self) { index in
                    DatePicker(
                        "提醒 \(index + 1)",
                        selection: $reminderTimes[index],
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.compact)
                }
                
                if reminderTimes.count < 3 {
                    Button("添加提醒时间") {
                        addReminderTime()
                    }
                }
                
                if reminderTimes.count > 1 {
                    Button("移除最后一个") {
                        reminderTimes.removeLast()
                    }
                    .foregroundColor(.red)
                }
            }
            .padding()
            
            Spacer()
        }
        .frame(width: 400, height: 350)
    }
    
    private func addReminderTime() {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = 9
        components.minute = 0
        if let newTime = calendar.date(from: components) {
            reminderTimes.append(newTime)
        }
    }
}

// MARK: - UI Components

struct SectionHeader: View {
    let title: String
    var icon: String = ""
    
    var body: some View {
        HStack(spacing: GentleSpacing.sm) {
            if !icon.isEmpty {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Gentle.Primary.purple)
            }
            Text(title)
                .font(GentleFont.caption())
                .fontWeight(.semibold)
                .foregroundColor(Gentle.Text.secondary)
            
            Spacer()
        }
    }
}

// MARK: - Sound Selector

struct SoundSelector: View {
    @Binding var selectedSoundName: String
    @Binding var selectedSoundFile: String
    @Binding var volume: Double
    let onSelect: (String) -> Void
    let onVolumeChange: (Double) -> Void
    
    // 中文名对应文件名
    let sounds = [
        ("🌧", "雨声", "雨声"),
        ("🍃", "风声", "风声"),
        ("🌊", "海浪", "海浪"),
        ("🔥", "壁炉", "壁炉")
    ]
    
    var body: some View {
        VStack(spacing: GentleSpacing.md) {
            // 音效选择
            HStack(spacing: GentleSpacing.sm) {
                ForEach(sounds, id: \.1) { sound in
                    SoundButton(
                        emoji: sound.0,
                        name: sound.1,
                        isSelected: selectedSoundName == sound.1
                    ) {
                        selectedSoundName = sound.1  // 更新显示名
                        selectedSoundFile = sound.2   // 更新文件名
                        onSelect(sound.2)  // 传递文件名
                    }
                }
            }
            
            // 音量滑块
            HStack(spacing: GentleSpacing.md) {
                Image(systemName: "speaker.fill")
                    .font(.system(size: 12))
                    .foregroundColor(Gentle.Text.secondary)
                
                Slider(value: $volume, in: 0...1)
                    .accentColor(Gentle.Primary.purple)
                    .onChange(of: volume) { _, newValue in
                        onVolumeChange(newValue)
                    }
                
                Text("\(Int(volume * 100))%")
                    .font(GentleFont.caption())
                    .foregroundColor(Gentle.Text.secondary)
                    .frame(width: 35)
            }
        }
        .padding(.leading, GentleSpacing.xl)
    }
}

struct SoundButton: View {
    let emoji: String
    let name: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(emoji)
                    .font(.system(size: 20))
                Text(name)
                    .font(.system(size: 9))
                    .foregroundColor(isSelected ? .white : Gentle.Text.secondary)
            }
            .frame(width: 50, height: 50)
            .background(
                RoundedRectangle(cornerRadius: GentleRadius.md)
                    .fill(isSelected ? Gentle.Primary.purple : Gentle.Background.tertiary)
                    .shadow(
                        color: isSelected ? Gentle.Primary.purple.opacity(0.3) : .clear,
                        radius: isSelected ? 8 : 0
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Frequency Button

struct FrequencyButton: View {
    let option: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(option)
                .font(GentleFont.caption())
                .foregroundColor(isSelected ? .white : Gentle.Text.secondary)
                .padding(.horizontal, GentleSpacing.md)
                .padding(.vertical, GentleSpacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: GentleRadius.sm)
                        .fill(isSelected ? Gentle.Primary.purple : Gentle.Background.tertiary)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingToggle: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: GentleSpacing.xs) {
                Text(title)
                    .font(GentleFont.body())
                    .foregroundColor(Gentle.Text.primary)
                Text(subtitle)
                    .font(GentleFont.caption())
                    .foregroundColor(Gentle.Text.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: Gentle.Primary.purple))
        }
    }
}

struct SettingSelector: View {
    let title: String
    let options: [String]
    @Binding var selectedOption: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: GentleSpacing.sm) {
            Text(title)
                .font(GentleFont.body())
                .foregroundColor(Gentle.Text.primary)
            
            HStack(spacing: GentleSpacing.sm) {
                ForEach(options, id: \.self) { option in
                    Button(action: { selectedOption = option }) {
                        Text(option)
                            .font(GentleFont.caption())
                            .foregroundColor(selectedOption == option ? .white : Gentle.Text.secondary)
                            .padding(.horizontal, GentleSpacing.md)
                            .padding(.vertical, GentleSpacing.sm)
                            .background(
                                RoundedRectangle(cornerRadius: GentleRadius.sm)
                                    .fill(selectedOption == option ? Gentle.Primary.purple : Gentle.Background.tertiary)
                                    .shadow(color: GentleShadow.sm.color, radius: 2, x: 0, y: 1)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

struct SettingAction: View {
    let title: String
    let subtitle: String
    let icon: String
    var isLoading: Bool = false
    var isDestructive: Bool = false
    var action: (() -> Void)? = nil
    
    @State private var isHovered = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: GentleSpacing.xs) {
                Text(title)
                    .font(GentleFont.body())
                    .foregroundColor(isDestructive && isHovered ? .red : Gentle.Text.primary)
                Text(subtitle)
                    .font(GentleFont.caption())
                    .foregroundColor(Gentle.Text.secondary)
            }
            
            Spacer()
            
            HStack(spacing: GentleSpacing.sm) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.7)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isDestructive ? .red : Gentle.Primary.purple)
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Gentle.Text.secondary)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            action?()
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

struct SettingStatus: View {
    let title: String
    let status: String
    let isOnline: Bool
    var lastSync: Date?
    
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: GentleSpacing.xs) {
                Text(title)
                    .font(GentleFont.body())
                    .foregroundColor(Gentle.Text.primary)
                HStack(spacing: 4) {
                    Text(status)
                        .font(GentleFont.caption())
                        .foregroundColor(isOnline ? Gentle.Primary.purple : Gentle.Text.secondary)
                    if let lastSync = lastSync {
                        Text("• \(formatTimeAgo(lastSync))")
                            .font(GentleFont.caption())
                            .foregroundColor(Gentle.Text.secondary.opacity(0.6))
                    }
                }
            }
            
            Spacer()
            
            ZStack {
                if isOnline {
                    Circle()
                        .fill(Gentle.Primary.purple.opacity(0.2))
                        .frame(width: 20, height: 20)
                        .scaleEffect(pulseScale)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                                pulseScale = 1.5
                            }
                        }
                }
                Circle()
                    .fill(isOnline ? Gentle.Primary.purple : Gentle.Text.secondary.opacity(0.3))
                    .frame(width: 12, height: 12)
            }
            .frame(width: 20, height: 20)
        }
    }
    
    private func formatTimeAgo(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return "刚刚" }
        if interval < 3600 { return "\(Int(interval / 60))分钟前" }
        if interval < 86400 { return "\(Int(interval / 3600))小时前" }
        return "\(Int(interval / 86400))天前"
    }
}

struct SettingInfo: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(GentleFont.body())
                .foregroundColor(Gentle.Text.primary)
            
            Spacer()
            
            Text(value)
                .font(GentleFont.body())
                .foregroundColor(Gentle.Text.secondary)
        }
    }
}

/// 诊断详情行组件
struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: GentleSpacing.sm) {
            Text(label)
                .font(GentleFont.caption(11))
                .foregroundColor(Gentle.Text.secondary)
                .frame(width: 90, alignment: .leading)
            
            Text(value)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(Gentle.Text.primary)
            
            Spacer()
        }
        .padding(.horizontal, GentleSpacing.sm)
        .padding(.vertical, 6)
    }
}

// MARK: - Theme Option Button

struct ThemeOptionButton: View {
    let theme: GentlePlatformTheme
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                // 主题预览色块
                ZStack {
                    RoundedRectangle(cornerRadius: GentleRadius.lg, style: .continuous)
                        .fill(theme.background)
                        .frame(width: 100, height: 64)
                        .overlay(
                            RoundedRectangle(cornerRadius: GentleRadius.lg, style: .continuous)
                                .stroke(isSelected ? theme.focusBorder : theme.border, lineWidth: isSelected ? 2.5 : 1)
                        )
                    
                    // 模拟窗口内容
                    VStack(spacing: 6) {
                        // 窗口标题栏模拟
                        HStack(spacing: 4) {
                            Circle().fill(Color.red.opacity(0.5)).frame(width: 6, height: 6)
                            Circle().fill(Color.yellow.opacity(0.5)).frame(width: 6, height: 6)
                            Circle().fill(Color.green.opacity(0.5)).frame(width: 6, height: 6)
                            Spacer()
                        }
                        .padding(.horizontal, 8)
                        .padding(.top, 6)
                        
                        // 内容模拟
                        HStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(theme.primary.opacity(0.6))
                                .frame(width: 28, height: 4)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(theme.primary.opacity(0.3))
                                .frame(width: 18, height: 4)
                            Spacer()
                        }
                        .padding(.horizontal, 8)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(theme.primary.opacity(0.15))
                            .frame(width: 60, height: 4)
                        
                        Spacer()
                    }
                    
                    // 选中对勾
                    if isSelected {
                        Circle()
                            .fill(theme.primary)
                            .frame(width: 22, height: 22)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .shadow(color: theme.primary.opacity(0.4), radius: 6, x: 0, y: 2)
                            .offset(x: 40, y: -28)
                    }
                }
                
                // 主题名称
                VStack(spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: theme.icon)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(isSelected ? theme.primary : Gentle.Text.secondary)
                        
                        Text(theme.rawValue)
                            .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                            .foregroundColor(isSelected ? theme.primary : Gentle.Text.primary)
                    }
                    
                    Text(themeLabel(for: theme))
                        .font(.system(size: 10))
                        .foregroundColor(Gentle.Text.tertiary)
                }
            }
            .padding(GentleSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                    .fill(isSelected ? theme.primary.opacity(0.06) : Gentle.Background.tertiary.opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                    .stroke(isSelected ? theme.primary.opacity(0.35) : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.03 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
    
    private func themeLabel(for theme: GentlePlatformTheme) -> String {
        switch theme {
        case .macOS: return "优雅 · 紫调"
        case .windows: return "清爽 · 蓝调"
        }
    }
}
