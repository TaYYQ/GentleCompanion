//
//  Design.swift
//  GentleCompanion
//
//  Liquid Glass Design System — iOS 18+ 液态玻璃视觉语言
//  统一的半透明质感、光影折射、模糊层级
//

import SwiftUI

// MARK: - 🎨 Theme System (7 Themes)

enum GentlePlatformTheme: String, CaseIterable, Sendable {
    case violet  = "温柔紫"
    case blue    = "清爽蓝"
    case forest  = "森林绿"
    case ocean   = "海洋蓝"
    case sunset  = "日落橙"
    case rose    = "玫瑰红"
    case midnight = "午夜靛"

    // MARK: SF Symbol

    var icon: String {
        switch self {
        case .violet:   return "sparkles"
        case .blue:     return "drop.fill"
        case .forest:   return "leaf.fill"
        case .ocean:    return "water.waves"
        case .sunset:   return "sunset.fill"
        case .rose:     return "heart.fill"
        case .midnight: return "moon.stars.fill"
        }
    }

    // MARK: Display

    var displayName: String { rawValue }

    var tagline: String {
        switch self {
        case .violet:   return "优雅 · 紫调"
        case .blue:     return "清爽 · 蓝调"
        case .forest:   return "自然 · 绿意"
        case .ocean:    return "深邃 · 海洋"
        case .sunset:   return "温暖 · 日落"
        case .rose:     return "浪漫 · 玫瑰"
        case .midnight: return "静谧 · 午夜"
        }
    }

    // MARK: Primary Colors

    var primary: Color {
        switch self {
        case .violet:   return Color(hex: "#7C3AED")
        case .blue:     return Color(hex: "#0078D4")
        case .forest:   return Color(hex: "#059669")
        case .ocean:    return Color(hex: "#0D9488")
        case .sunset:   return Color(hex: "#EA580C")
        case .rose:     return Color(hex: "#E11D48")
        case .midnight: return Color(hex: "#4F46E5")
        }
    }

    var secondary: Color {
        switch self {
        case .violet:   return Color(hex: "#A78BFA")
        case .blue:     return Color(hex: "#60A5FA")
        case .forest:   return Color(hex: "#34D399")
        case .ocean:    return Color(hex: "#5EEAD4")
        case .sunset:   return Color(hex: "#FB923C")
        case .rose:     return Color(hex: "#FDA4AF")
        case .midnight: return Color(hex: "#A5B4FC")
        }
    }

    var accent: Color {
        switch self {
        case .violet:   return Color(hex: "#C084FC")
        case .blue:     return Color(hex: "#93C5FD")
        case .forest:   return Color(hex: "#6EE7B7")
        case .ocean:    return Color(hex: "#99F6E4")
        case .sunset:   return Color(hex: "#FDBA74")
        case .rose:     return Color(hex: "#FECDD3")
        case .midnight: return Color(hex: "#C7D2FE")
        }
    }

    var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [secondary, primary],
            startPoint: .leading, endPoint: .trailing
        )
    }

    var accentGradient: LinearGradient {
        LinearGradient(
            colors: [accent, secondary, primary],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    // MARK: Backgrounds

    var background: Color {
        switch self {
        case .violet:   return Color(hex: "#F5F0FF")
        case .blue:     return Color(hex: "#F3F6FB")
        case .forest:   return Color(hex: "#F0FDF6")
        case .ocean:    return Color(hex: "#F0FDFB")
        case .sunset:   return Color(hex: "#FFF8F0")
        case .rose:     return Color(hex: "#FFF5F6")
        case .midnight: return Color(hex: "#F3F4FF")
        }
    }

    var cardBackground: Color { .white }

    var darkBase: Color {
        switch self {
        case .violet:   return Color(hex: "#080810")
        case .blue:     return Color(hex: "#080C14")
        case .forest:   return Color(hex: "#080F0C")
        case .ocean:    return Color(hex: "#080F10")
        case .sunset:   return Color(hex: "#100A06")
        case .rose:     return Color(hex: "#10080A")
        case .midnight: return Color(hex: "#0A0A16")
        }
    }

    var darkCard: Color {
        switch self {
        case .violet:   return Color(hex: "#0D0D1A")
        case .blue:     return Color(hex: "#0D111A")
        case .forest:   return Color(hex: "#0D1410")
        case .ocean:    return Color(hex: "#0D1414")
        case .sunset:   return Color(hex: "#140E0A")
        case .rose:     return Color(hex: "#140C0E")
        case .midnight: return Color(hex: "#0E0E1A")
        }
    }

    // MARK: Text

    var textPrimary: Color {
        switch self {
        case .violet:   return Color(hex: "#1F1035")
        case .blue:     return Color(hex: "#1A1A2E")
        case .forest:   return Color(hex: "#0D2818")
        case .ocean:    return Color(hex: "#0D2828")
        case .sunset:   return Color(hex: "#2E1A0A")
        case .rose:     return Color(hex: "#2E0D18")
        case .midnight: return Color(hex: "#14143A")
        }
    }

    var textSecondary: Color {
        switch self {
        case .violet:   return Color(hex: "#6B7280")
        case .blue:     return Color(hex: "#5C6370")
        case .forest:   return Color(hex: "#5C7066")
        case .ocean:    return Color(hex: "#5C7070")
        case .sunset:   return Color(hex: "#7C6B5A")
        case .rose:     return Color(hex: "#7C5C66")
        case .midnight: return Color(hex: "#686A8A")
        }
    }

    // MARK: Border

    var border: Color {
        switch self {
        case .violet:   return Color(hex: "#E9D5FF")
        case .blue:     return Color(hex: "#D0D7DE")
        case .forest:   return Color(hex: "#C6F6D5")
        case .ocean:    return Color(hex: "#CCFBF1")
        case .sunset:   return Color(hex: "#FED7AA")
        case .rose:     return Color(hex: "#FECDD3")
        case .midnight: return Color(hex: "#DDD6FE")
        }
    }

    var focusBorder: Color { secondary }

    // MARK: Glass Glow

    var glassGlow: Color {
        primary.opacity(0.20)
    }

    var glassTint: Color {
        primary.opacity(0.08)
    }
}

/// Global theme state with persistence
final class GentleThemeManager: ObservableObject, @unchecked Sendable {
    static let shared = GentleThemeManager()

    private static let storageKey = "GentlePlatformTheme"
    private static let darkModeKey = "GentleDarkMode"

    @Published private(set) var current: GentlePlatformTheme = .violet
    @Published private(set) var isDetecting = true
    @Published var useDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(useDarkMode, forKey: Self.darkModeKey)
        }
    }

    private init() {
        if let raw = UserDefaults.standard.string(forKey: Self.storageKey),
           let saved = GentlePlatformTheme(rawValue: raw) {
            current = saved
        }
        useDarkMode = UserDefaults.standard.object(forKey: Self.darkModeKey) as? Bool ?? false
    }

    func apply(_ theme: GentlePlatformTheme) {
        current = theme
        isDetecting = false
        UserDefaults.standard.set(theme.rawValue, forKey: Self.storageKey)
    }

    func detectAndApply(completion: (@Sendable () -> Void)? = nil) {
        isDetecting = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else { return }
            self.isDetecting = false
            completion?()
        }
    }
}

// MARK: - 🟣 Brand & Palette (Theme-Aware)

enum Gentle {

    // Convenience accessor for current theme
    private static var theme: GentlePlatformTheme { GentleThemeManager.shared.current }

    enum Primary {
        static var purple: Color  { theme.primary }
        static var lavender: Color { theme.secondary }
        static var violet: Color  { theme.primary }
        static let pink    = Color(hex: "#F472B6")
        static let yellow  = Color(hex: "#FCD34D")
        static let orange  = Color(hex: "#F59E0B")
        static var indigo: Color  { theme.secondary }
    }

    enum Warm {
        static let amber  = Color(hex: "#F59E0B")
        static let orange = Color(hex: "#F97316")
    }

    enum Background {
        static var primary: Color   { theme.background }
        static var secondary: Color { theme.cardBackground }
        static var tertiary: Color  { theme.border.opacity(0.6) }
        static let overlay   = Color.black.opacity(0.4)
        static var dark: Color      { theme.darkBase }
        static var darkCard: Color  { theme.darkCard }
    }

    enum Text {
        static var primary: Color   { theme.textPrimary }
        static var secondary: Color { theme.textSecondary }
        static let tertiary  = Color(hex: "#9CA3AF")
        static let inverse   = Color.white
        static var accent: Color { theme.secondary }
        static var link: Color   { theme.secondary }
        static var darkPrimary: Color   { theme.secondary.opacity(0.9) }
        static var darkSecondary: Color { theme.secondary.opacity(0.6) }
    }

    enum Border {
        static var light: Color  { Color.gray.opacity(0.15) }
        static var medium: Color { Color.gray.opacity(0.25) }
        static var focus: Color  { theme.secondary }
    }

    enum State {
        static let success = Color(hex: "#34D399")
        static let warning = Color(hex: "#FBBF24")
        static let error   = Color(hex: "#F87171")
        static let info    = Color(hex: "#60A5FA")
    }

    enum Emotion {
        static let happy     = Color(hex: "#FCD34D")
        static let calm      = Color(hex: "#A78BFA")
        static let grateful  = Color(hex: "#F472B6")
        static let anxious   = Color(hex: "#FB923C")
        static let sad      = Color(hex: "#60A5FA")
        static let angry     = Color(hex: "#F87171")
        static let tired     = Color(hex: "#94A3B8")
    }

    enum Gradient {
        static var breathing: LinearGradient {
            LinearGradient(
                colors: [
                    theme.primary.opacity(0.95), theme.secondary.opacity(0.98),
                    Color(hex: "#F472B6").opacity(0.25), Color(hex: "#FCD34D").opacity(0.12)
                ],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        }

        static var primaryButton: LinearGradient { theme.primaryGradient }

        static var secondaryButton: LinearGradient {
            LinearGradient(
                colors: [theme.secondary, Color(hex: "#F472B6")],
                startPoint: .leading, endPoint: .trailing
            )
        }

        static var warmButton: LinearGradient {
            LinearGradient(
                colors: [Color(hex: "#FCD34D"), Color(hex: "#F59E0B")],
                startPoint: .leading, endPoint: .trailing
            )
        }

        static var warmPrimaryButton: LinearGradient {
            LinearGradient(
                colors: [theme.accent, theme.secondary, Color(hex: "#F472B6")],
                startPoint: .leading, endPoint: .trailing
            )
        }

        static var aurora1: RadialGradient {
            RadialGradient(
                colors: [theme.primary.opacity(0.15), .clear],
                center: .center, startRadius: 0, endRadius: 160
            )
        }

        static var aurora2: RadialGradient {
            RadialGradient(
                colors: [Color(hex: "#F472B6").opacity(0.12), .clear],
                center: .center, startRadius: 0, endRadius: 130
            )
        }

        static let card = LinearGradient(
            colors: [Color.white.opacity(0.9), Color.white.opacity(0.6)],
            startPoint: .top, endPoint: .bottom
        )

        static var darkCard: LinearGradient {
            LinearGradient(
                colors: [theme.darkCard, theme.darkBase],
                startPoint: .top, endPoint: .bottom
            )
        }
    }

    // MARK: - Liquid Glass Materials (Dark/Light Aware)

    enum Glass {
        static let card = Material.ultraThinMaterial
        static let elevated = Material.thinMaterial

        // 当前模式
        private static var isDark: Bool { GentleThemeManager.shared.useDarkMode }
        private static var theme: GentlePlatformTheme { GentleThemeManager.shared.current }

        /// 页面底色（浅色/深色自适应）
        static var baseBackground: Color {
            isDark ? theme.darkBase : theme.background
        }

        /// 卡片底色
        static var baseCard: Color {
            isDark ? theme.darkCard : theme.cardBackground
        }

        /// 卡片材质透明度
        static var cardMaterialOpacity: CGFloat { isDark ? 0.55 : 0.7 }

        /// 高光渐变
        static var highlightGradient: LinearGradient {
            LinearGradient(
                colors: [
                    .white.opacity(isDark ? 0.15 : 0.3),
                    .white.opacity(isDark ? 0.03 : 0.08),
                    theme.primary.opacity(isDark ? 0.06 : 0.12),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        static var borderWhite: Color { .white.opacity(isDark ? 0.08 : 0.2) }
        static var borderHighlight: Color { .white.opacity(isDark ? 0.15 : 0.35) }
        static var borderPrism: Color { theme.primary.opacity(isDark ? 0.1 : 0.2) }

        static let bottomRefraction = LinearGradient(
            colors: [.white.opacity(0.06), .white.opacity(0.01), .clear],
            startPoint: .bottom, endPoint: .center
        )

        /// 文字主色
        static var textPrimary: Color {
            isDark ? .white : theme.textPrimary
        }

        /// 文字辅助色
        static var textSecondary: Color {
            isDark ? .white.opacity(0.45) : theme.textSecondary
        }

        /// 文字三级色
        static var textTertiary: Color {
            isDark ? .white.opacity(0.25) : Color(hex: "#9CA3AF")
        }

        /// 背景微光（浅色模式更淡）
        static func ambientGlow(color: Color? = nil) -> some View {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            (color ?? theme.primary).opacity(isDark ? 0.15 : 0.08),
                            (color ?? theme.primary).opacity(isDark ? 0.04 : 0.02),
                            .clear
                        ],
                        center: .center, startRadius: 0, endRadius: 320
                    )
                )
                .blur(radius: 20)
        }

        static var refractionLine: LinearGradient {
            LinearGradient(
                colors: [.white.opacity(isDark ? 0.12 : 0.25), .white.opacity(0.0)],
                startPoint: .top, endPoint: .bottom
            )
        }

        // For backward compat
        static var darkBase: Color { baseBackground }
        static var darkBaseCard: Color { baseCard }
    }
}

// MARK: - 📐 Spacing System (8pt grid)

enum GentleSpacing {
    static let xxs: CGFloat = 4
    static let xs:  CGFloat = 8
    static let sm:  CGFloat = 12
    static let md:  CGFloat = 16
    static let lg:  CGFloat = 20
    static let xl:  CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl:CGFloat = 40
    static let xxxxl:CGFloat = 48
}

// MARK: - 🔤 Typography

enum GentleFont {
    static func display(_ size: CGFloat = 32) -> Font {
        .system(size: size, weight: .ultraLight)
    }
    static func title(_ size: CGFloat = 22) -> Font {
        .system(size: size, weight: .semibold)
    }
    static func headline(_ size: CGFloat = 17) -> Font {
        .system(size: size, weight: .semibold)
    }
    static func body(_ size: CGFloat = 15) -> Font {
        .system(size: size, weight: .regular)
    }
    static func caption(_ size: CGFloat = 12) -> Font {
        .system(size: size, weight: .regular)
    }
    static func mono(_ size: CGFloat = 14) -> Font {
        .system(size: size, weight: .medium, design: .monospaced)
    }
    static func rounded(_ size: CGFloat = 15) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }
}

// MARK: - ⬛ Corner Radii

enum GentleRadius {
    static let xs:   CGFloat = 4
    static let sm:   CGFloat = 8
    static let md:   CGFloat = 12
    static let lg:   CGFloat = 16
    static let xl:   CGFloat = 20
    static let xxl:  CGFloat = 24
    static let xxxl: CGFloat = 28  // Liquid Glass 卡片
    static let xxxxl: CGFloat = 36 // Liquid Glass 大卡片
    static let full: CGFloat = 9999
}

// MARK: - 🌫️ Shadows (Theme-Aware)

enum GentleShadow {
    static let sm: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) =
        (Color.black.opacity(0.06), 4, 0, 2)
    static let md: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) =
        (Color.black.opacity(0.10), 8, 0, 4)
    static let lg: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) =
        (Color.black.opacity(0.14), 12, 0, 6)
    static var glow: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        (GentleThemeManager.shared.current.primary.opacity(0.4), 16, 0, 8)
    }
    static var glassGlow: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        (GentleThemeManager.shared.current.primary.opacity(0.2), 20, 0, 10)
    }
}

// MARK: - 🎨 Liquid Glass View Modifiers

/// Liquid Glass card style — the core glass container
struct LiquidGlassCard: ViewModifier {
    var cornerRadius: CGFloat = GentleRadius.xxxl
    var opacity: CGFloat = 0.55

    private var theme: GentlePlatformTheme { GentleThemeManager.shared.current }
    private var isDark: Bool { GentleThemeManager.shared.useDarkMode }

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Gentle.Glass.baseCard.opacity(isDark ? 0.4 : 0.6))
            }
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial.opacity(isDark ? opacity : 0.75))
            }
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Gentle.Glass.refractionLine)
                    .frame(height: 1)
                    .padding(.horizontal, 1)
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Gentle.Glass.borderWhite, lineWidth: 0.5)
            }
            .shadow(
                color: theme.primary.opacity(isDark ? 0.08 : 0.04),
                radius: 16, x: 0, y: 8
            )
            .shadow(
                color: Color.black.opacity(isDark ? 0.15 : 0.06),
                radius: 4, x: 0, y: 2
            )
    }
}

/// Liquid Glass elevated card — for modals, sheets, overlays
struct LiquidGlassElevated: ViewModifier {
    var cornerRadius: CGFloat = GentleRadius.xxxl

    private var theme: GentlePlatformTheme { GentleThemeManager.shared.current }
    private var isDark: Bool { GentleThemeManager.shared.useDarkMode }

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Gentle.Glass.baseCard.opacity(isDark ? 0.5 : 0.7))
            }
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.thinMaterial.opacity(isDark ? 0.7 : 0.85))
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Gentle.Glass.borderHighlight, lineWidth: 0.5)
            }
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(isDark ? 0.18 : 0.3), .white.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
                    .frame(height: 1.5)
                    .padding(.horizontal, 2)
            }
            .shadow(
                color: theme.primary.opacity(isDark ? 0.12 : 0.06),
                radius: 24, x: 0, y: 12
            )
            .shadow(
                color: Color.black.opacity(isDark ? 0.2 : 0.08),
                radius: 6, x: 0, y: 3
            )
    }
}

/// Liquid Glass style for buttons
struct LiquidGlassButton: ViewModifier {
    var tint: Color? = nil
    var cornerRadius: CGFloat = GentleRadius.lg

    private var effectiveTint: Color { tint ?? GentleThemeManager.shared.current.primary }

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(effectiveTint.opacity(0.15))
            }
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(effectiveTint.opacity(0.25), lineWidth: 0.5)
            }
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.white.opacity(0.1))
                    .frame(height: 1)
                    .padding(.horizontal, 1)
            }
            .shadow(color: effectiveTint.opacity(0.15), radius: 12, x: 0, y: 6)
    }
}

/// Liquid Glass gradient pill button
struct LiquidGlassPillButton: ViewModifier {
    var gradient: LinearGradient

    private var theme: GentlePlatformTheme { GentleThemeManager.shared.current }

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: GentleRadius.full, style: .continuous)
                    .fill(gradient)
            }
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: GentleRadius.full, style: .continuous)
                    .fill(.white.opacity(0.15))
                    .frame(height: 1)
                    .padding(.horizontal, 2)
            }
            .shadow(
                color: theme.primary.opacity(0.35),
                radius: 14, x: 0, y: 7
            )
    }
}

// MARK: - Convenience View Extensions

extension View {
    func liquidGlassCard(cornerRadius: CGFloat = GentleRadius.xxxl, opacity: CGFloat = 0.55) -> some View {
        modifier(LiquidGlassCard(cornerRadius: cornerRadius, opacity: opacity))
    }

    func liquidGlassElevated(cornerRadius: CGFloat = GentleRadius.xxxl) -> some View {
        modifier(LiquidGlassElevated(cornerRadius: cornerRadius))
    }

    func liquidGlassButton(tint: Color? = nil, cornerRadius: CGFloat = GentleRadius.lg) -> some View {
        modifier(LiquidGlassButton(tint: tint, cornerRadius: cornerRadius))
    }

    func liquidGlassPillButton(gradient: LinearGradient = Gentle.Gradient.primaryButton) -> some View {
        modifier(LiquidGlassPillButton(gradient: gradient))
    }

    func gentleCard(padding: CGFloat = GentleSpacing.md,
                    cornerRadius: CGFloat = GentleRadius.md) -> some View {
        modifier(GentleCardModifier(padding: padding, cornerRadius: cornerRadius))
    }

    func gentleDivider() -> some View {
        modifier(GentleDivider())
    }

    func gentleTag(color: Color = Gentle.Primary.lavender) -> some View {
        modifier(GentleTagStyle(color: color))
    }
}

// MARK: - Traditional View Modifiers (kept for macOS compatibility)

struct GentleCard<Content: View>: View {
    var padding: CGFloat = GentleSpacing.md
    var cornerRadius: CGFloat = GentleRadius.md
    @ViewBuilder let content: () -> Content

    init(padding: CGFloat = GentleSpacing.md,
         cornerRadius: CGFloat = GentleRadius.md,
         @ViewBuilder content: @escaping () -> Content) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.content = content
    }

    var body: some View {
        content()
            .padding(padding)
            .background(Gentle.Background.secondary)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}

struct GentleCardModifier: ViewModifier {
    var padding: CGFloat = GentleSpacing.md
    var cornerRadius: CGFloat = GentleRadius.md

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Gentle.Background.secondary)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: GentleShadow.md.color,
                    radius: GentleShadow.md.radius,
                    x: GentleShadow.md.x,
                    y: GentleShadow.md.y)
    }
}

struct GentleDivider: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, GentleSpacing.xs)
            .overlay {
                Rectangle()
                    .fill(Gentle.Border.light)
                    .frame(height: 1)
                    .offset(y: GentleSpacing.xs)
            }
    }
}

// MARK: - 🔘 Button Styles (traditional, macOS-safe)

struct GentlePrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(GentleFont.headline(17))
            .foregroundColor(Gentle.Text.inverse)
            .padding(.horizontal, GentleSpacing.xl)
            .padding(.vertical, GentleSpacing.sm + 4)
            .background(
                RoundedRectangle(cornerRadius: GentleRadius.sm, style: .continuous)
                    .fill(isEnabled ? Gentle.Gradient.primaryButton
                           : LinearGradient(
                               colors: [Gentle.Primary.purple.opacity(0.5), Gentle.Primary.lavender.opacity(0.5)],
                               startPoint: .leading, endPoint: .trailing
                           ))
            )
            .shadow(
                color: isEnabled ? Gentle.Primary.purple.opacity(configuration.isPressed ? 0.1 : 0.25) : .clear,
                radius: configuration.isPressed ? 4 : 8,
                x: 0, y: configuration.isPressed ? 2 : 4
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct GentleSecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(GentleFont.headline(17))
            .foregroundColor(Gentle.Text.primary)
            .padding(.horizontal, GentleSpacing.xl)
            .padding(.vertical, GentleSpacing.sm + 4)
            .background(
                RoundedRectangle(cornerRadius: GentleRadius.sm, style: .continuous)
                    .fill(isEnabled ? Gentle.Background.tertiary : Gentle.Background.tertiary.opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: GentleRadius.sm, style: .continuous)
                    .stroke(isEnabled ? Gentle.Border.medium : Gentle.Border.light, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct GentleGhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(GentleFont.body(15))
            .foregroundColor(Gentle.Text.accent)
            .padding(.horizontal, GentleSpacing.sm)
            .padding(.vertical, GentleSpacing.xs)
            .background(
                RoundedRectangle(cornerRadius: GentleRadius.sm, style: .continuous)
                    .fill(configuration.isPressed ? Gentle.Background.tertiary : Color.clear)
            )
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct GentleDestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(GentleFont.body(15))
            .foregroundColor(Gentle.Text.inverse)
            .padding(.horizontal, GentleSpacing.md)
            .padding(.vertical, GentleSpacing.xs)
            .background(
                RoundedRectangle(cornerRadius: GentleRadius.sm, style: .continuous)
                    .fill(Gentle.State.error.opacity(configuration.isPressed ? 0.7 : 1.0))
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct GentleIconButtonStyle: ButtonStyle {
    var size: CGFloat = 36
    var backgroundColor: Color = Gentle.Background.tertiary

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(configuration.isPressed ? backgroundColor.opacity(0.7) : backgroundColor)
            )
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - ✏️ TextField Style

struct GentleTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(GentleFont.body(15))
            .foregroundColor(Gentle.Text.primary)
            .padding(GentleSpacing.sm + 2)
            .background(Gentle.Background.secondary)
            .overlay(
                RoundedRectangle(cornerRadius: GentleRadius.sm, style: .continuous)
                    .stroke(Gentle.Border.light, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: GentleRadius.sm, style: .continuous))
    }
}

// MARK: - 🏷️ Tag / Pill Style

struct GentleTagStyle: ViewModifier {
    var color: Color = Gentle.Primary.lavender

    func body(content: Content) -> some View {
        content
            .font(GentleFont.caption(11))
            .foregroundColor(Gentle.Text.inverse)
            .padding(.horizontal, GentleSpacing.xs + 2)
            .padding(.vertical, 2)
            .background(Capsule().fill(color))
    }
}

// MARK: - 🖼️ Avatar View

struct GentleAvatar: View {
    let initials: String
    var size: CGFloat = 44
    var gradient: LinearGradient = Gentle.Gradient.primaryButton

    var body: some View {
        ZStack {
            Circle().fill(gradient)
            Text(initials.prefix(2).uppercased())
                .font(.system(size: size * 0.36, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - ⏳ Loading Indicator

struct GentleLoadingIndicator: View {
    @State private var isAnimating = false

    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(Gentle.Primary.lavender, lineWidth: 2.5)
            .frame(width: 24, height: 24)
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            .animation(.linear(duration: 0.9).repeatForever(autoreverses: false), value: isAnimating)
            .onAppear { isAnimating = true }
    }
}

// MARK: - 📝 Empty State View

struct GentleEmptyState: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: GentleSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(Gentle.Text.tertiary)
            Text(title)
                .font(GentleFont.headline(17))
                .foregroundColor(Gentle.Text.secondary)
            Text(message)
                .font(GentleFont.body(14))
                .foregroundColor(Gentle.Text.tertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, GentleSpacing.xl)
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(GentlePrimaryButtonStyle())
                    .padding(.top, GentleSpacing.xs)
            }
        }
        .padding(GentleSpacing.xl)
    }
}

// MARK: - 📋 Section Header

struct GentleSectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var trailing: AnyView? = nil

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(GentleFont.headline(15))
                    .foregroundColor(Gentle.Text.primary)
                if let subtitle {
                    Text(subtitle)
                        .font(GentleFont.caption(12))
                        .foregroundColor(Gentle.Text.secondary)
                }
            }
            Spacer()
            if let trailing { trailing }
        }
        .padding(.horizontal, GentleSpacing.xs)
        .padding(.bottom, GentleSpacing.xs)
    }
}

// MARK: - ⭐ Star Rating View

struct GentleStarRating: View {
    @Binding var rating: Int
    let maxRating: Int = 5
    var starSize: CGFloat = 20
    var activeColor: Color = Gentle.Primary.yellow
    var inactiveColor: Color = Color.gray.opacity(0.3)

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...maxRating, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .font(.system(size: starSize))
                    .foregroundColor(index <= rating ? activeColor : inactiveColor)
                    .onTapGesture { rating = index }
            }
        }
    }
}
