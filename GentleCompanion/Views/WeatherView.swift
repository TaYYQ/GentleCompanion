//
//  WeatherView.swift
//  GentleCompanion
//
//  天气心情页面 — 精致天气卡片设计 + 动态天气壁纸效果
//

import SwiftUI

// MARK: - WeatherView

struct WeatherView: View {
    let weatherSnapshot: GentleWeatherSnapshot?
    let isLoading: Bool
    @Binding var isPresented: Bool
    @State private var appearAnimation = false
    @State private var refreshHovered = false
    @State private var showCityPicker = false
    @State private var citySearchText = ""
    @State private var cityResults: [GentleWeatherProvider.CityResult] = []
    @State private var isSearchingCity = false
    @State private var searchTask: Task<Void, Never>?
    
    var body: some View {
        ZStack {
            // 动态天气背景
            weatherBackground
                .ignoresSafeArea()
            
            // 天气动态特效（类似 iPhone 天气壁纸）
            if let snapshot = weatherSnapshot, !isLoading {
                weatherEffect(for: snapshot.condition)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
            
            // 装饰光晕
            decorativeGlows
            
            VStack(spacing: 0) {
                topNavigation
                    .padding(.horizontal, GentleSpacing.xxl)
                    .padding(.top, GentleSpacing.lg)
                
                if isLoading {
                    loadingState
                } else if let snapshot = weatherSnapshot {
                    weatherContent(snapshot)
                } else {
                    emptyState
                }
            }
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 16)
            
            // 城市选择器（内嵌覆盖层，不弹新窗口）
            if showCityPicker {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                    .onTapGesture { closeCityPicker() }
                    .transition(.opacity)
                
                cityPickerSheet
                    .frame(width: 1091, height: 738)
                    .background(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .shadow(color: .black.opacity(0.15), radius: 30, x: 0, y: 10)
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.05)) {
                appearAnimation = true
            }
        }
        .onExitCommand {
            if showCityPicker {
                closeCityPicker()
            } else {
                withAnimation(.easeInOut(duration: 0.25)) { isPresented = false }
            }
        }
    }
    
    // MARK: - Weather Effects (iPhone-style)
    
    @ViewBuilder
    private func weatherEffect(for condition: GentleWeatherCondition) -> some View {
        switch condition {
        case .clear:
            SunEffectView()
        case .cloudy:
            CloudEffectView()
        case .rainy:
            RainEffectView()
        case .foggy:
            FogEffectView()
        case .snowy:
            SnowEffectView()
        case .extreme:
            StormEffectView()
        case .unknown:
            EmptyView()
        }
    }
    
    // MARK: - Background
    
    @ViewBuilder
    private var weatherBackground: some View {
        if let snapshot = weatherSnapshot {
            backgroundForCondition(snapshot.condition)
        } else {
            defaultBackground
        }
    }
    
    private var defaultBackground: some View {
        LinearGradient(
            colors: [
                Color(hex: "#FAF8FF"),
                Color(hex: "#F3ECFF"),
                Color(hex: "#F8F4FF")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    @ViewBuilder
    private func backgroundForCondition(_ condition: GentleWeatherCondition) -> some View {
        switch condition {
        case .clear:
            LinearGradient(
                colors: [
                    Color(hex: "#FFFBEB"),
                    Color(hex: "#FEF3C7"),
                    Color(hex: "#FDE68A")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .cloudy:
            LinearGradient(
                colors: [
                    Color(hex: "#F8FAFC"),
                    Color(hex: "#E2E8F0"),
                    Color(hex: "#CBD5E1")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .rainy:
            LinearGradient(
                colors: [
                    Color(hex: "#EFF6FF"),
                    Color(hex: "#BFDBFE"),
                    Color(hex: "#93C5FD")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .foggy:
            LinearGradient(
                colors: [
                    Color(hex: "#FAFAFA"),
                    Color(hex: "#E4E4E7"),
                    Color(hex: "#D4D4D8")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .snowy:
            LinearGradient(
                colors: [
                    Color(hex: "#F0F9FF"),
                    Color(hex: "#BAE6FD"),
                    Color(hex: "#7DD3FC")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .extreme:
            LinearGradient(
                colors: [
                    Color(hex: "#1E1B4B"),
                    Color(hex: "#312E81"),
                    Color(hex: "#4338CA")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .unknown:
            defaultBackground
        }
    }
    
    private var decorativeGlows: some View {
        ZStack {
            Circle()
                .fill(Gentle.Primary.lavender.opacity(0.04))
                .frame(width: 180, height: 180)
                .blur(radius: 50)
                .offset(x: -150, y: -100)
            
            Circle()
                .fill(Gentle.Primary.pink.opacity(0.03))
                .frame(width: 130, height: 130)
                .blur(radius: 35)
                .offset(x: 160, y: 60)
        }
        .allowsHitTesting(false)
    }
    
    // MARK: - Top Navigation
    
    private var topNavigation: some View {
        HStack {
            HStack(spacing: GentleSpacing.sm) {
                Image(systemName: "cloud.sun.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Gentle.Primary.indigo)
                Text("天气心情")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Gentle.Text.primary)
            }
            
            Spacer()
            
            if weatherSnapshot != nil {
                Button {
                    refreshWeather()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Gentle.Text.tertiary)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(refreshHovered ? Gentle.Background.tertiary : Color.clear)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .onHover { refreshHovered = $0 }
            }
            
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isPresented = false
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(Gentle.Text.tertiary.opacity(0.6))
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Loading
    
    private var loadingState: some View {
        VStack(spacing: GentleSpacing.lg) {
            Spacer()
            ZStack {
                Circle()
                    .stroke(Gentle.Primary.lavender.opacity(0.12), lineWidth: 3)
                    .frame(width: 48, height: 48)
                ProgressView()
                    .scaleEffect(1.1)
            }
            VStack(spacing: GentleSpacing.xs) {
                Text("正在获取天气...")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(Gentle.Text.secondary)
                Text("为你准备温柔天气签")
                    .font(.system(size: 12))
                    .foregroundColor(Gentle.Text.tertiary)
            }
            Spacer()
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: GentleSpacing.md) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Gentle.Background.tertiary.opacity(0.6))
                    .frame(width: 72, height: 72)
                Image(systemName: "wifi.slash")
                    .font(.system(size: 30))
                    .foregroundColor(Gentle.Text.tertiary)
            }
            VStack(spacing: GentleSpacing.xs) {
                Text("暂时无法获取天气信息")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(Gentle.Text.secondary)
                Text("请检查网络连接后重试")
                    .font(.system(size: 12))
                    .foregroundColor(Gentle.Text.tertiary)
            }
            Button {
                refreshWeather()
            } label: {
                HStack(spacing: GentleSpacing.xs) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 11, weight: .semibold))
                    Text("重新获取")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(Gentle.Primary.indigo)
                .padding(.horizontal, GentleSpacing.lg)
                .padding(.vertical, GentleSpacing.xs)
                .background(Capsule().fill(Gentle.Primary.lavender.opacity(0.1)))
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, GentleSpacing.sm)
            Spacer()
        }
    }
    
    // MARK: - Weather Content
    
    private func weatherContent(_ snapshot: GentleWeatherSnapshot) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: GentleSpacing.xl) {
                weatherMainCard(snapshot)
                    .padding(.horizontal, GentleSpacing.xxl)
                    .padding(.top, GentleSpacing.lg)
                
                if snapshot.temperature != nil || snapshot.humidity != nil || snapshot.windSpeed != nil {
                    weatherDetailCard(snapshot)
                        .padding(.horizontal, GentleSpacing.xxl)
                }
                
                gentleTextCard(snapshot)
                    .padding(.horizontal, GentleSpacing.xxl)
                    .padding(.bottom, GentleSpacing.xxxl)
            }
        }
    }
    
    // MARK: - Main Weather Card
    
    private func weatherMainCard(_ snapshot: GentleWeatherSnapshot) -> some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(conditionColor(snapshot.condition).opacity(0.1))
                    .frame(width: 96, height: 96)
                Circle()
                    .fill(conditionColor(snapshot.condition).opacity(0.06))
                    .frame(width: 72, height: 72)
                Image(systemName: snapshot.symbolName)
                    .font(.system(size: 38, weight: .medium))
                    .foregroundColor(conditionColor(snapshot.condition))
            }
            .padding(.top, GentleSpacing.xl)
            .padding(.bottom, GentleSpacing.md)
            
            if let temp = snapshot.temperature {
                Text(formatTemperature(temp))
                    .font(.system(size: 48, weight: .thin, design: .rounded))
                    .foregroundColor(Gentle.Text.primary)
                    .padding(.bottom, 2)
            }
            
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showCityPicker = true
                }
                citySearchText = ""
                cityResults = []
            } label: {
                HStack(spacing: GentleSpacing.xs) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 11))
                        .foregroundColor(Gentle.Text.tertiary)
                    Text(snapshot.city)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Gentle.Text.primary)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(Gentle.Text.tertiary)
                }
                .padding(.horizontal, GentleSpacing.md)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.black.opacity(0.03)))
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.bottom, GentleSpacing.xs)
            
            Text(conditionTitle(snapshot.condition))
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(conditionColor(snapshot.condition))
                .padding(.horizontal, GentleSpacing.md)
                .padding(.vertical, 3)
                .background(Capsule().fill(conditionColor(snapshot.condition).opacity(0.1)))
                .padding(.bottom, GentleSpacing.xl)
            
            Rectangle()
                .fill(Gentle.Border.light)
                .frame(height: 1)
                .padding(.horizontal, GentleSpacing.xxl)
            
            HStack {
                HStack(spacing: GentleSpacing.xs) {
                    Image(systemName: "clock")
                        .font(.system(size: 9))
                        .foregroundColor(Gentle.Text.tertiary)
                    Text("刚刚更新")
                        .font(.system(size: 11))
                        .foregroundColor(Gentle.Text.tertiary)
                }
                Spacer()
                HStack(spacing: GentleSpacing.xs) {
                    Circle().fill(Gentle.State.success).frame(width: 5, height: 5)
                    Text("实时天气")
                        .font(.system(size: 11))
                        .foregroundColor(Gentle.State.success)
                }
            }
            .padding(.horizontal, GentleSpacing.xxl)
            .padding(.vertical, GentleSpacing.md)
        }
        .background(
            RoundedRectangle(cornerRadius: GentleRadius.xxxl, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: GentleRadius.xxxl, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            conditionColor(snapshot.condition).opacity(0.2),
                            conditionColor(snapshot.condition).opacity(0.05),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
    }
    
    // MARK: - Weather Detail Card
    
    private func weatherDetailCard(_ snapshot: GentleWeatherSnapshot) -> some View {
        HStack(spacing: 0) {
            if let temp = snapshot.temperature {
                weatherMetric(
                    icon: "thermometer.medium",
                    iconColor: .orange,
                    value: formatTemperature(temp),
                    label: "温度",
                    subtitle: temp < 10 ? "偏冷" : temp < 25 ? "舒适" : temp < 32 ? "温暖" : "炎热"
                )
            }
            if let humidity = snapshot.humidity {
                Rectangle().fill(Gentle.Border.light).frame(width: 1, height: 40)
                weatherMetric(
                    icon: "humidity", iconColor: .blue,
                    value: "\(humidity)%", label: "湿度",
                    subtitle: humidity < 30 ? "偏干" : humidity < 60 ? "舒适" : "偏湿"
                )
            }
            if let speed = snapshot.windSpeed {
                Rectangle().fill(Gentle.Border.light).frame(width: 1, height: 40)
                weatherMetric(
                    icon: "wind", iconColor: .cyan,
                    value: String(format: "%.1f", speed), label: "风速 km/h",
                    subtitle: speed < 5 ? "微风" : speed < 20 ? "和风" : "大风"
                )
            }
        }
        .padding(.vertical, GentleSpacing.lg)
        .padding(.horizontal, GentleSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                .stroke(Gentle.Border.light, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 2)
    }
    
    private func weatherMetric(icon: String, iconColor: Color, value: String, label: String, subtitle: String) -> some View {
        VStack(spacing: GentleSpacing.xs) {
            Image(systemName: icon).font(.system(size: 14)).foregroundColor(iconColor)
            Text(value).font(.system(size: 17, weight: .semibold, design: .rounded)).foregroundColor(Gentle.Text.primary).fixedSize()
            Text(label).font(.system(size: 10)).foregroundColor(Gentle.Text.tertiary).fixedSize()
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Gentle Text Card
    
    private func gentleTextCard(_ snapshot: GentleWeatherSnapshot) -> some View {
        VStack(spacing: GentleSpacing.md) {
            ZStack {
                Circle().fill(Gentle.Primary.lavender.opacity(0.08)).frame(width: 44, height: 44)
                Image(systemName: "quote.bubble").font(.system(size: 18)).foregroundColor(Gentle.Primary.lavender)
            }
            .padding(.top, GentleSpacing.xl)
            
            Text(snapshot.line)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundColor(Gentle.Text.primary)
                .multilineTextAlignment(.center)
                .lineSpacing(8)
                .padding(.horizontal, GentleSpacing.lg)
            
            Text(snapshot.detail)
                .font(.system(size: 13))
                .foregroundColor(Gentle.Text.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal, GentleSpacing.md)
                .padding(.bottom, GentleSpacing.xl)
        }
        .background(
            RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Gentle.Primary.lavender.opacity(0.15), Gentle.Primary.pink.opacity(0.08)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - City Picker
    
    private var cityPickerSheet: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "#FAF8FF"), Color(hex: "#F3ECFF")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Text("选择城市")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(Gentle.Text.primary)
                    Spacer()
                    Button { closeCityPicker() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22)).foregroundColor(Gentle.Text.tertiary.opacity(0.6))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, GentleSpacing.xxl)
                .padding(.top, GentleSpacing.xl)
                .padding(.bottom, GentleSpacing.lg)
                
                HStack(spacing: GentleSpacing.sm) {
                    Image(systemName: "magnifyingglass").font(.system(size: 14)).foregroundColor(Gentle.Text.tertiary)
                    TextField("输入城市名称搜索...", text: $citySearchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.system(size: 14))
                        .foregroundColor(Gentle.Text.primary)
                        .onChange(of: citySearchText) { newValue in
                            searchTask?.cancel()
                            let query = newValue.trimmingCharacters(in: .whitespaces)
                            guard query.count >= 2 else { cityResults = []; return }
                            searchTask = Task {
                                try? await Task.sleep(nanoseconds: 300_000_000)
                                guard !Task.isCancelled else { return }
                                isSearchingCity = true
                                let results = await GentleWeatherProvider.shared.searchCities(query: query)
                                guard !Task.isCancelled else { return }
                                await MainActor.run { cityResults = results; isSearchingCity = false }
                            }
                        }
                    if !citySearchText.isEmpty {
                        Button { citySearchText = ""; cityResults = [] } label: {
                            Image(systemName: "xmark.circle.fill").font(.system(size: 12)).foregroundColor(Gentle.Text.tertiary)
                        }.buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, GentleSpacing.md)
                .padding(.vertical, GentleSpacing.xs + 2)
                .background(RoundedRectangle(cornerRadius: GentleRadius.md, style: .continuous).fill(.white))
                .overlay(RoundedRectangle(cornerRadius: GentleRadius.md, style: .continuous).stroke(Gentle.Border.light, lineWidth: 1))
                .padding(.horizontal, GentleSpacing.xxl)
                .padding(.bottom, GentleSpacing.md)
                
                if isSearchingCity {
                    Spacer(); ProgressView().scaleEffect(0.9); Spacer()
                } else if citySearchText.trimmingCharacters(in: .whitespaces).count < 2 {
                    Spacer()
                    VStack(spacing: GentleSpacing.sm) {
                        Image(systemName: "building.2").font(.system(size: 28)).foregroundColor(Gentle.Text.tertiary.opacity(0.5))
                        Text("输入城市名称开始搜索").font(.system(size: 13)).foregroundColor(Gentle.Text.tertiary)
                    }
                    Spacer()
                } else if cityResults.isEmpty {
                    Spacer()
                    VStack(spacing: GentleSpacing.sm) {
                        Image(systemName: "mappin.slash").font(.system(size: 28)).foregroundColor(Gentle.Text.tertiary.opacity(0.5))
                        Text("未找到匹配城市").font(.system(size: 13)).foregroundColor(Gentle.Text.tertiary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: GentleSpacing.xs) {
                            ForEach(cityResults) { city in
                                Button { selectCity(city) } label: { cityRow(city) }
                                    .buttonStyle(PlainButtonStyle())
                            }
                        }.padding(.horizontal, GentleSpacing.xxl)
                    }
                }
                Spacer(minLength: 0)
            }
        }
    }
    
    private func cityRow(_ city: GentleWeatherProvider.CityResult) -> some View {
        HStack(spacing: GentleSpacing.md) {
            ZStack {
                Circle().fill(Gentle.Primary.lavender.opacity(0.1)).frame(width: 34, height: 34)
                Image(systemName: "mappin.and.ellipse").font(.system(size: 14)).foregroundColor(Gentle.Primary.lavender)
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(city.name).font(.system(size: 14, weight: .medium)).foregroundColor(Gentle.Text.primary)
                HStack(spacing: 4) {
                    Text(city.admin1).font(.system(size: 11)).foregroundColor(Gentle.Text.tertiary)
                    if !city.country.isEmpty { Text("· \(city.country)").font(.system(size: 11)).foregroundColor(Gentle.Text.tertiary) }
                }
            }
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 11, weight: .semibold)).foregroundColor(Gentle.Text.tertiary.opacity(0.4))
        }
        .padding(.horizontal, GentleSpacing.md)
        .padding(.vertical, GentleSpacing.xs + 2)
        .background(RoundedRectangle(cornerRadius: GentleRadius.md, style: .continuous).fill(.white.opacity(0.7)))
    }
    
    private func selectCity(_ city: GentleWeatherProvider.CityResult) {
        let location = Location(latitude: city.latitude, longitude: city.longitude, city: city.name, timezone: city.timezone)
        SettingsManager.shared.updateLocation(location)
        closeCityPicker()
        refreshWeather()
    }
    
    private func closeCityPicker() {
        withAnimation(.easeInOut(duration: 0.25)) {
            showCityPicker = false
        }
    }
    
    // MARK: - Helpers
    
    private func refreshWeather() {
        NotificationCenter.default.post(name: NSNotification.Name("RefreshWeather"), object: nil)
    }
    
    private func formatTemperature(_ temp: Double) -> String {
        String(format: "%.0f°", temp)
    }
    
    private func conditionColor(_ condition: GentleWeatherCondition) -> Color {
        switch condition {
        case .clear: return Color.orange
        case .cloudy: return Color(hex: "#94A3B8")
        case .rainy: return Color(hex: "#6366F1")
        case .foggy: return Color(hex: "#A1A1AA")
        case .snowy: return Color(hex: "#06B6D4")
        case .extreme: return Color(hex: "#EF4444")
        case .unknown: return Gentle.Primary.lavender
        }
    }
    
    private func conditionTitle(_ condition: GentleWeatherCondition) -> String {
        switch condition {
        case .clear: return "晴朗 ☀️"
        case .cloudy: return "多云 ⛅"
        case .rainy: return "下雨 🌧️"
        case .foggy: return "有雾 🌫️"
        case .snowy: return "下雪 ❄️"
        case .extreme: return "极端天气 ⚡"
        case .unknown: return "天气未知"
        }
    }
}

// MARK: - ☀️ Sun Effect

struct SunEffectView: View {
    @State private var rotation: Double = 0
    @State private var pulse: Double = 1.0
    
    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                let center = CGPoint(x: size.width * 0.82, y: size.height * 0.12)
                let sunRadius: CGFloat = 55
                
                // Sun glow
                for i in 0..<4 {
                    let r = sunRadius + CGFloat(i) * 18
                    let alpha = 0.18 - CGFloat(i) * 0.04 + CGFloat(sin(time * 0.8 + Double(i))) * 0.04
                    context.fill(
                        Path(ellipseIn: CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2)),
                        with: .color(Color.orange.opacity(alpha))
                    )
                }
                
                // Sun rays
                let rayCount = 16
                let rayLen: CGFloat = 80
                let rotationSpeed = time * 0.15
                for i in 0..<rayCount {
                    let angle = Double(i) / Double(rayCount) * 2 * .pi + rotationSpeed
                    let innerR = sunRadius + 5
                    let outerR = sunRadius + rayLen + CGFloat(sin(time * 2.5 + Double(i))) * 12
                    
                    let innerPoint = CGPoint(x: center.x + cos(angle) * innerR, y: center.y + sin(angle) * innerR)
                    let outerPoint = CGPoint(x: center.x + cos(angle) * outerR, y: center.y + sin(angle) * outerR)
                    
                    var path = Path()
                    path.move(to: innerPoint)
                    path.addLine(to: outerPoint)
                    context.stroke(path, with: .color(Color.orange.opacity(0.15)), lineWidth: 2)
                }
                
                // Sun core
                context.fill(
                    Path(ellipseIn: CGRect(x: center.x - sunRadius, y: center.y - sunRadius, width: sunRadius * 2, height: sunRadius * 2)),
                    with: .color(Color.orange.opacity(0.25 + sin(time * 1.2) * 0.05))
                )
            }
        }
    }
}

// MARK: - ☁️ Cloud Effect

struct CloudEffectView: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                // Multiple drifting clouds at different speeds
                drawCloud(context: context, size: size, time: time, offset: 0, speed: 0.08, yPos: size.height * 0.22, scale: 1.3, alpha: 0.25)
                drawCloud(context: context, size: size, time: time, offset: 180, speed: 0.12, yPos: size.height * 0.30, scale: 0.8, alpha: 0.18)
                drawCloud(context: context, size: size, time: time, offset: 350, speed: 0.06, yPos: size.height * 0.15, scale: 1.6, alpha: 0.15)
                drawCloud(context: context, size: size, time: time, offset: 60, speed: 0.1, yPos: size.height * 0.38, scale: 1.0, alpha: 0.12)
            }
        }
    }
    
    private func drawCloud(context: GraphicsContext, size: CGSize, time: Double, offset: CGFloat, speed: Double, yPos: CGFloat, scale: CGFloat, alpha: Double) {
        let totalWidth = size.width + 300
        let xBase = fmod(time * speed * 30 + offset, totalWidth) - 150
        
        let cloudColor = Color(hex: "#F1F5F9").opacity(alpha)
        let darkCloudColor = Color(hex: "#CBD5E1").opacity(alpha * 0.6)
        
        let w: CGFloat = 100 * scale
        let h: CGFloat = 35 * scale
        let x = xBase
        
        // Overlapping circles for cloud shape
        context.fill(Path(ellipseIn: CGRect(x: x, y: yPos + h * 0.5, width: w * 0.55, height: h * 0.5)), with: .color(cloudColor))
        context.fill(Path(ellipseIn: CGRect(x: x + w * 0.25, y: yPos, width: w * 0.5, height: h * 0.7)), with: .color(cloudColor))
        context.fill(Path(ellipseIn: CGRect(x: x + w * 0.5, y: yPos + h * 0.3, width: w * 0.4, height: h * 0.5)), with: .color(cloudColor))
        context.fill(Path(ellipseIn: CGRect(x: x + w * 0.15, y: yPos + h * 0.4, width: w * 0.65, height: h * 0.45)), with: .color(darkCloudColor))
    }
}

// MARK: - 🌧️ Rain Effect

struct RainEffectView: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                let dropCount = 80
                for i in 0..<dropCount {
                    let seed = Double(i) * 17.3 + 42.1
                    let xBase = fmod(seed * 0.7, size.width)
                    let drift = sin(time * 0.4 + seed) * 30
                    let x = xBase + drift
                    let speed = 40 + fmod(seed, 30)
                    let progress = fmod(time * speed * 0.6 + seed * 13, size.height + 60)
                    let y = progress - 30
                    
                    let alpha = 0.25 * (1.0 - min(progress / size.height, 1.0) * 0.5)
                    let endY = y + 25
                    
                    var path = Path()
                    path.move(to: CGPoint(x: x - 1, y: y))
                    path.addLine(to: CGPoint(x: x + 1, y: endY))
                    context.stroke(path, with: .color(Color.white.opacity(alpha)), lineWidth: 1.5)
                }
            }
        }
    }
}

// MARK: - ❄️ Snow Effect

struct SnowEffectView: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                let flakeCount = 50
                for i in 0..<flakeCount {
                    let seed = Double(i) * 23.7 + 17.3
                    let xBase = fmod(seed * 1.1, size.width)
                    let sway = sin(time * 0.7 + seed * 0.8) * 40
                    let x = xBase + sway
                    let speed = 15 + fmod(seed, 25)
                    let progress = fmod(time * speed * 0.35 + seed * 11, size.height + 40)
                    let y = progress - 20
                    let alpha = 0.6 * (1.0 - min(progress / size.height, 1.0) * 0.4)
                    let flakeSize: CGFloat = 2 + CGFloat(fmod(seed, 100)) * 0.04
                    
                    context.fill(
                        Path(ellipseIn: CGRect(x: x - flakeSize, y: y - flakeSize, width: flakeSize * 2, height: flakeSize * 2)),
                        with: .color(Color.white.opacity(alpha))
                    )
                }
            }
        }
    }
}

// MARK: - 🌫️ Fog Effect

struct FogEffectView: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                let layerCount = 5
                for layer in 0..<layerCount {
                    let layerOffset = Double(layer) * 50
                    let speed = 0.05 + Double(layer) * 0.02
                    let xOffset = fmod(time * speed * 20 + layerOffset, size.width + 200) - 100
                    let yBase = size.height * (0.15 + Double(layer) * 0.16)
                    let alpha = 0.12 - Double(layer) * 0.02 + sin(time * 0.3 + Double(layer)) * 0.02
                    
                    context.fill(
                        Path(ellipseIn: CGRect(x: xOffset, y: yBase, width: 280, height: 50)),
                        with: .color(Color.white.opacity(alpha))
                    )
                    context.fill(
                        Path(ellipseIn: CGRect(x: xOffset + 60, y: yBase - 10, width: 220, height: 40)),
                        with: .color(Color.white.opacity(alpha * 0.6))
                    )
                }
            }
        }
    }
}

// MARK: - ⚡ Storm Effect

struct StormEffectView: View {
    @State private var lightningOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Rain
            RainEffectView()
            
            // Lightning flashes
            TimelineView(.animation) { timeline in
                let time = timeline.date.timeIntervalSinceReferenceDate
                Canvas { context, size in
                    let flashPhase = fmod(time * 0.07, 100)
                    
                    if flashPhase < 0.6 {
                        let alpha = flashPhase < 0.3 ? 0.3 * (flashPhase / 0.3) : 0.3 * (1.0 - (flashPhase - 0.3) / 0.3)
                        
                        // Lightning bolt
                        let centerX = size.width * 0.6
                        var path = Path()
                        path.move(to: CGPoint(x: centerX, y: 0))
                        path.addLine(to: CGPoint(x: centerX - 30, y: size.height * 0.25))
                        path.addLine(to: CGPoint(x: centerX + 10, y: size.height * 0.28))
                        path.addLine(to: CGPoint(x: centerX - 50, y: size.height * 0.55))
                        path.addLine(to: CGPoint(x: centerX, y: size.height * 0.6))
                        path.addLine(to: CGPoint(x: centerX - 20, y: size.height * 0.85))
                        context.stroke(path, with: .color(Color.yellow.opacity(alpha)), lineWidth: 3)
                        
                        // Glow around lightning
                        context.fill(
                            Path(ellipseIn: CGRect(x: centerX - 150, y: -20, width: 300, height: size.height + 40)),
                            with: .color(Color.white.opacity(alpha * 0.15))
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Preview

struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WeatherView(
                weatherSnapshot: GentleWeatherSnapshot(
                    city: "杭州", condition: .clear, symbolName: "sun.max",
                    line: "杭州晴，太阳在轻轻说：今天也值得被爱。",
                    detail: "阳光洒满窗台，像在提醒你：你的温柔也值得被看见。",
                    temperature: 23.0, windSpeed: 8.5, humidity: 55, createdAt: Date()
                ),
                isLoading: false, isPresented: .constant(true)
            )
            .frame(width: 500, height: 600)
            
            WeatherView(
                weatherSnapshot: GentleWeatherSnapshot(
                    city: "北京", condition: .rainy, symbolName: "cloud.rain",
                    line: "北京有雨，云在替你多想一点。",
                    detail: "窗外的雨在认真地下着，像在提醒你：你的情绪也可以被认真对待。",
                    temperature: 16.0, windSpeed: 12.0, humidity: 82, createdAt: Date()
                ),
                isLoading: false, isPresented: .constant(true)
            )
            .frame(width: 500, height: 600)
        }
    }
}
