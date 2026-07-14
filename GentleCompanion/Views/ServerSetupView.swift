//
//  ServerSetupView.swift
//  GentleCompanion
//
//  服务器配置引导页 · 首次启动时让用户选择服务器
//  选项 1：阿里云服务器（一键连接）
//  选项 2：自行配置服务器地址
//

import SwiftUI

struct ServerSetupView: View {
    var onComplete: () -> Void
    var onSkip: () -> Void

    // 选择模式：nil = 未选, true = 阿里云, false = 自行配置
    @State private var selectedOption: ServerOption? = nil

    enum ServerOption {
        case aliyun
        case custom
    }

    // 阿里云默认配置
    private let aliyunHost = "114.55.132.45"
    private let aliyunPort = 8000

    // 自行配置字段
    @State private var customHost: String = ""
    @State private var customPort: String = "8000"
    @State private var customUseHTTPS: Bool = false

    // 连接测试状态
    @State private var isTestingAliyun = false
    @State private var aliyunStatus: AliyunTestStatus = .untested
    @State private var aliyunResponseTime: Double? = nil

    @State private var isTestingCustom = false
    @State private var customConnected = false
    @State private var customResponseTime: Double? = nil
    @State private var customTestError: String? = nil

    // 动画
    @State private var animateContent = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var configExpanded = false

    enum AliyunTestStatus: Equatable {
        case untested
        case testing
        case connected
        case failed(String)

        static func == (lhs: AliyunTestStatus, rhs: AliyunTestStatus) -> Bool {
            switch (lhs, rhs) {
            case (.untested, .untested), (.testing, .testing), (.connected, .connected):
                return true
            case (.failed(let a), .failed(let b)):
                return a == b
            default:
                return false
            }
        }
    }

    var body: some View {
        ZStack {
            // 深色背景 + 光晕
            Color.black
                .ignoresSafeArea()

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "#7C3AED").opacity(0.15),
                            Color(hex: "#EC4899").opacity(0.06),
                            .clear
                        ],
                        center: .top,
                        startRadius: 0,
                        endRadius: 500
                    )
                )
                .frame(width: 800, height: 500)
                .offset(y: -200)
                .blur(radius: 40)

            // 主体
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer().frame(height: 60)

                    heroSection
                        .offset(y: animateContent ? 0 : 20)
                        .opacity(animateContent ? 1 : 0)

                    Spacer().frame(height: 40)

                    // 两个选项卡片
                    optionsSection
                        .offset(y: animateContent ? 0 : 30)
                        .opacity(animateContent ? 1 : 0)

                    // 自行配置展开区域
                    if selectedOption == .custom {
                        customConfigSection
                            .transition(
                                .asymmetric(
                                    insertion: .opacity.combined(with: .move(edge: .bottom).combined(with: .scale(scale: 0.96))),
                                    removal: .opacity.combined(with: .move(edge: .bottom))
                                )
                            )
                    }

                    Spacer().frame(height: 32)

                    // 底部按钮
                    bottomActions
                        .offset(y: animateContent ? 0 : 30)
                        .opacity(animateContent ? 1 : 0)

                    Spacer().frame(height: 48)
                }
                .padding(.horizontal, 48)
            }
        }
        #if os(macOS)
        .frame(width: 998, height: 687)
        #endif
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.15)) {
                animateContent = true
            }
            // 自动检测阿里云服务器连通性
            testAliyunConnection()
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 90, height: 90)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color(hex: "#7C3AED").opacity(0.4),
                                             Color(hex: "#A78BFA").opacity(0.25)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )

                Image(systemName: "server.rack")
                    .font(.system(size: 36, weight: .thin))
                    .foregroundColor(Color(hex: "#A78BFA"))
            }
            .shadow(color: Color(hex: "#7C3AED").opacity(0.2), radius: 30)

            VStack(spacing: 8) {
                Text("连接服务器")
                    .font(.system(size: 32, weight: .thin, design: .rounded))
                    .foregroundColor(.white)

                Text("选择你的温柔点服务端")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.45))
            }
        }
    }

    // MARK: - Options Section

    private var optionsSection: some View {
        VStack(spacing: 16) {
            // ——— 选项 1：阿里云服务器 ———
            optionCard(
                isSelected: selectedOption == .aliyun,
                icon: "cloud.fill",
                title: "阿里云服务器",
                subtitle: "官方推荐，稳定高速",
                detail: {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text("http://\(aliyunHost):\(aliyunPort)")
                                .font(.system(size: 13, weight: .medium, design: .monospaced))
                                .foregroundColor(Color.white.opacity(0.5))
                        }
                        // 状态
                        HStack(spacing: 6) {
                            switch aliyunStatus {
                            case .untested:
                                Image(systemName: "circle")
                                    .font(.system(size: 7))
                                    .foregroundColor(Color.white.opacity(0.25))
                                Text("等待检测...")
                                    .font(.system(size: 11))
                                    .foregroundColor(Color.white.opacity(0.3))
                            case .testing:
                                ProgressView()
                                    .scaleEffect(0.55)
                                    .frame(width: 10, height: 10)
                                Text("正在检测...")
                                    .font(.system(size: 11))
                                    .foregroundColor(Color.white.opacity(0.4))
                            case .connected:
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(Color(hex: "#10B981"))
                                Text(String(format: "已连接 · %.0fms", aliyunResponseTime ?? 0))
                                    .font(.system(size: 11))
                                    .foregroundColor(Color(hex: "#10B981"))
                            case .failed(let err):
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(Color(hex: "#F59E0B"))
                                Text(err)
                                    .font(.system(size: 11))
                                    .foregroundColor(Color(hex: "#F59E0B").opacity(0.8))
                            }
                        }
                    }
                },
                badge: nil,
                onTap: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        selectedOption = .aliyun
                        configExpanded = false
                    }
                }
            )

            // ——— 选项 2：自行配置 ———
            optionCard(
                isSelected: selectedOption == .custom,
                icon: "gearshape.2.fill",
                title: "自行配置",
                subtitle: "输入你自己的服务器地址",
                detail: {
                    Text("使用私有或第三方服务器")
                        .font(.system(size: 11))
                        .foregroundColor(Color.white.opacity(0.3))
                },
                badge: nil,
                onTap: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        selectedOption = .custom
                        configExpanded = true
                    }
                }
            )
        }
        .frame(maxWidth: 480)
    }

    // MARK: - Custom Config Section

    private var customConfigSection: some View {
        VStack(spacing: 20) {
            // 协议 + 地址
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "globe")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: "#A78BFA"))
                    Text("服务器地址")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.55))
                }

                HStack(spacing: 0) {
                    // HTTP/HTTPS 切换
                    HStack(spacing: 6) {
                        Button {
                            customUseHTTPS = false
                        } label: {
                            Text("HTTP")
                                .font(.system(size: 11, weight: customUseHTTPS ? .regular : .semibold, design: .monospaced))
                                .foregroundColor(customUseHTTPS ? Color.white.opacity(0.3) : Color(hex: "#A78BFA"))
                        }
                        .buttonStyle(.plain)
                        Button {
                            customUseHTTPS = true
                        } label: {
                            Text("HTTPS")
                                .font(.system(size: 11, weight: customUseHTTPS ? .semibold : .regular, design: .monospaced))
                                .foregroundColor(customUseHTTPS ? Color(hex: "#10B981") : Color.white.opacity(0.3))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.white.opacity(0.06))
                    )

                    Text("://")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(Color.white.opacity(0.2))
                        .padding(.horizontal, 3)

                    TextField("IP 或域名", text: $customHost)
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(.white)
                        .tint(Color(hex: "#A78BFA"))
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 10)
                        .frame(height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color.white.opacity(0.06))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                }
            }

            // 端口
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "number")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: "#A78BFA"))
                    Text("端口号")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.55))
                }

                HStack {
                    TextField("例如 8000", text: $customPort)
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(.white)
                        .tint(Color(hex: "#A78BFA"))
                        .textFieldStyle(.plain)
                        .frame(width: 100, height: 40)
                        .padding(.horizontal, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color.white.opacity(0.06))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                        .onChange(of: customPort) { _, newValue in
                            let filtered = newValue.filter { $0.isNumber }
                            if filtered != newValue { customPort = filtered }
                        }
                    Spacer()
                }
            }

            // 测试连接
            Button(action: testCustomConnection) {
                HStack(spacing: 8) {
                    if isTestingCustom {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.7)
                        Text("正在检测...")
                            .font(.system(size: 13, weight: .medium))
                    } else if customConnected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14, weight: .semibold))
                        Text("连接成功")
                            .font(.system(size: 13, weight: .medium))
                    } else {
                        Image(systemName: "arrow.triangle.swap")
                            .font(.system(size: 12, weight: .medium))
                        Text("测试连接")
                            .font(.system(size: 13, weight: .medium))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: 440)
                .frame(height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(
                            customConnected
                                ? Color(hex: "#10B981").opacity(0.3)
                                : Color(hex: "#7C3AED").opacity(0.45)
                        )
                )
            }
            .buttonStyle(.plain)
            .disabled(isTestingCustom || customHost.trimmingCharacters(in: .whitespaces).isEmpty)

            // 连接结果
            if let time = customResponseTime, customConnected {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "#10B981"))
                    Text(String(format: "响应 %.0fms", time))
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "#10B981"))
                    Spacer()
                }
            } else if let err = customTestError {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "#F87171"))
                    Text(err)
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "#F87171"))
                        .lineLimit(2)
                    Spacer()
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
        .frame(maxWidth: 480)
        .padding(.top, 16)
    }

    // MARK: - Option Card Component

    @ViewBuilder
    private func optionCard(
        isSelected: Bool,
        icon: String,
        title: String,
        subtitle: String,
        @ViewBuilder detail: () -> some View,
        badge: String?,
        onTap: @escaping () -> Void
    ) -> some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // 左侧图标
                ZStack {
                    Circle()
                        .fill(isSelected ? Color(hex: "#7C3AED").opacity(0.25) : Color.white.opacity(0.08))
                        .frame(width: 46, height: 46)

                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(isSelected ? Color(hex: "#A78BFA") : Color.white.opacity(0.5))
                }

                // 中间文字
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.system(size: 16, weight: isSelected ? .semibold : .medium))
                            .foregroundColor(.white)

                        if let badge = badge {
                            Text(badge)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(Color(hex: "#FCD34D"))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(Color(hex: "#FCD34D").opacity(0.15))
                                )
                        }
                    }

                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(Color.white.opacity(0.4))

                    detail()
                        .padding(.top, 2)
                }

                Spacer()

                // 右侧选中指示器
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color(hex: "#A78BFA") : Color.white.opacity(0.15), lineWidth: 2)
                        .frame(width: 22, height: 22)

                    if isSelected {
                        Circle()
                            .fill(Color(hex: "#A78BFA"))
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? Color(hex: "#7C3AED").opacity(0.12) : Color.white.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(
                        isSelected ? Color(hex: "#A78BFA").opacity(0.35) : Color.white.opacity(0.06),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Bottom Actions

    private var bottomActions: some View {
        VStack(spacing: 10) {
            // 确认按钮
            Button(action: confirmAndContinue) {
                Text(confirmButtonTitle)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: 360)
                    .frame(height: 52)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "#7C3AED"), Color(hex: "#6D28D9")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .opacity(selectedOption != nil ? 1 : 0.4)
                    )
                    .shadow(color: Color(hex: "#7C3AED").opacity(selectedOption != nil ? 0.35 : 0), radius: 14, y: 4)
            }
            .buttonStyle(.plain)
            .frame(maxWidth: 360)
            .disabled(selectedOption == nil)

            // 跳过
            Button(action: onSkip) {
                Text("跳过，稍后配置")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.35))
            }
            .buttonStyle(.plain)
        }
    }

    private var confirmButtonTitle: String {
        guard let option = selectedOption else { return "请选择服务器" }
        switch option {
        case .aliyun:
            return aliyunStatus == .connected ? "连接阿里云服务器" : "使用阿里云服务器"
        case .custom:
            return customConnected ? "连接自定义服务器" : "使用自定义服务器"
        }
    }

    // MARK: - Aliyun Connection Test

    private func testAliyunConnection() {
        isTestingAliyun = true
        aliyunStatus = .testing

        guard let url = URL(string: "http://\(aliyunHost):\(aliyunPort)/") else {
            aliyunStatus = .failed("无效地址")
            isTestingAliyun = false
            return
        }

        Task {
            let startTime = CFAbsoluteTimeGetCurrent()
            do {
                var request = URLRequest(url: url)
                request.timeoutInterval = 6
                let (_, response) = try await URLSession.shared.data(for: request)

                if let httpResponse = response as? HTTPURLResponse,
                   (200...299).contains(httpResponse.statusCode) {
                    aliyunResponseTime = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
                    aliyunStatus = .connected
                } else {
                    aliyunStatus = .failed("服务异常")
                }
            } catch let error as URLError {
                switch error.code {
                case .timedOut:
                    aliyunStatus = .failed("连接超时")
                case .cannotConnectToHost:
                    aliyunStatus = .failed("无法连接")
                case .dnsLookupFailed:
                    aliyunStatus = .failed("DNS 解析失败")
                default:
                    aliyunStatus = .failed("无法连接")
                }
            } catch {
                aliyunStatus = .failed("无法连接")
            }
            isTestingAliyun = false
        }
    }

    // MARK: - Custom Connection Test

    private func testCustomConnection() {
        let host = customHost.trimmingCharacters(in: .whitespaces)
        guard !host.isEmpty else { return }

        isTestingCustom = true
        customConnected = false
        customResponseTime = nil
        customTestError = nil

        let scheme = customUseHTTPS ? "https" : "http"
        let port = Int(customPort.trimmingCharacters(in: .whitespaces)) ?? 8000

        guard let url = URL(string: "\(scheme)://\(host):\(port)/") else {
            customTestError = "无效地址"
            isTestingCustom = false
            return
        }

        Task {
            let startTime = CFAbsoluteTimeGetCurrent()
            do {
                var request = URLRequest(url: url)
                request.timeoutInterval = 8
                let (_, response) = try await URLSession.shared.data(for: request)
                if let httpResponse = response as? HTTPURLResponse,
                   (200...299).contains(httpResponse.statusCode) {
                    customResponseTime = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
                    customConnected = true
                    customTestError = nil
                } else {
                    customConnected = false
                    customTestError = "HTTP \((response as? HTTPURLResponse)?.statusCode ?? 0)"
                }
            } catch let error as URLError {
                customConnected = false
                switch error.code {
                case .timedOut: customTestError = "连接超时（8秒）"
                case .cannotConnectToHost: customTestError = "无法连接到服务器"
                case .notConnectedToInternet: customTestError = "无网络连接"
                case .dnsLookupFailed: customTestError = "DNS 解析失败"
                default: customTestError = error.localizedDescription
                }
            } catch {
                customConnected = false
                customTestError = error.localizedDescription
            }
            isTestingCustom = false
        }
    }

    // MARK: - Confirm & Continue

    private func confirmAndContinue() {
        guard let option = selectedOption else { return }

        switch option {
        case .aliyun:
            ServerConfigManager.shared.serverHost = aliyunHost
            ServerConfigManager.shared.serverPort = aliyunPort
            ServerConfigManager.shared.useHTTPS = false

        case .custom:
            let host = customHost.trimmingCharacters(in: .whitespaces)
            let port = Int(customPort.trimmingCharacters(in: .whitespaces)) ?? 8000
            if !host.isEmpty && port > 0 && port <= 65535 {
                ServerConfigManager.shared.serverHost = host
                ServerConfigManager.shared.serverPort = port
                ServerConfigManager.shared.useHTTPS = customUseHTTPS
            }
        }

        NetworkService.shared.reloadBaseURL()
        onComplete()
    }
}

#Preview {
    ServerSetupView(onComplete: {}, onSkip: {})
}
