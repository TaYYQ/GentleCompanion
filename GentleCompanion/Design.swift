//
//  Design.swift
//  GentleCompanion
//
//  🏛 Centralized Design System — Single Source of Truth
//  All colors, typography, spacing, shadows, corner radii, and shared
//  component styles live here. Import this instead of hard-coding values.
//

import SwiftUI
// Color(hex:) lives in Extensions.swift — import it once here
// so this file is self-contained when referenced

// MARK: - 🖥 Platform Theme

enum GentlePlatformTheme: String, CaseIterable, Sendable {
    case macOS = "macOS"
    case windows = "Windows"

    var icon: String {
        switch self {
        case .macOS:    return "applelogo"
        case .windows:  return "rectangle.connected.to.line.below"
        }
    }

    var description: String {
        switch self {
        case .macOS:    return "检测到 macOS 系统"
        case .windows:  return "检测到 Windows 系统"
        }
    }

    var primary: Color {
        switch self {
        case .macOS:    return Color(hex: "#7C3AED")
        case .windows: return Color(hex: "#0078D4")
        }
    }

    var secondary: Color {
        switch self {
        case .macOS:    return Color(hex: "#A78BFA")
        case .windows: return Color(hex: "#60A5FA")
        }
    }

    var primaryGradient: LinearGradient {
        switch self {
        case .macOS:
            return LinearGradient(
                colors: [Color(hex: "#A78BFA"), Color(hex: "#7C3AED")],
                startPoint: .leading, endPoint: .trailing
            )
        case .windows:
            return LinearGradient(
                colors: [Color(hex: "#60A5FA"), Color(hex: "#0078D4")],
                startPoint: .leading, endPoint: .trailing
            )
        }
    }

    var background: Color {
        switch self {
        case .macOS:    return Color(hex: "#F5F0FF")
        case .windows: return Color(hex: "#F3F3F3")
        }
    }

    var cardBackground: Color {
        switch self {
        case .macOS:    return Color.white
        case .windows: return Color.white
        }
    }

    var textPrimary: Color {
        switch self {
        case .macOS:    return Color(hex: "#1F1035")
        case .windows: return Color(hex: "#1A1A2E")
        }
    }

    var textSecondary: Color {
        switch self {
        case .macOS:    return Color(hex: "#6B7280")
        case .windows: return Color(hex: "#5C6370")
        }
    }

    var border: Color {
        switch self {
        case .macOS:    return Color(hex: "#E9D5FF")
        case .windows: return Color(hex: "#D0D7DE")
        }
    }

    var focusBorder: Color {
        switch self {
        case .macOS:    return Color(hex: "#A78BFA")
        case .windows: return Color(hex: "#0078D4")
        }
    }
}

/// Global theme state — ObservableObject drives SwiftUI views
final class GentleThemeManager: ObservableObject, @unchecked Sendable {
    static let shared = GentleThemeManager()

    @Published private(set) var current: GentlePlatformTheme = .macOS
    @Published private(set) var isDetecting = true

    private init() {}

    func apply(_ theme: GentlePlatformTheme) {
        current = theme
        isDetecting = false
    }

    /// Auto-detect platform and apply theme with animation
    func detectAndApply(completion: (@Sendable () -> Void)? = nil) {
        isDetecting = true

        // Simulate detection (real impl would introspect OS)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else { return }
            #if os(macOS)
            self.apply(.macOS)
            #else
            self.apply(.windows)
            #endif
            completion?()
        }
    }
}

// MARK: - 🟣 Brand & Palette (theme-aware)

/// Gentle 设计系统 — 所有颜色通过主题管理器动态获取
enum Gentle {

    // MARK: Primary Palette — 根据当前主题返回颜色
    enum Primary {
        static var purple: Color {
            GentleThemeManager.shared.current == .macOS
                ? Color(hex: "#6B4EAA")
                : Color(hex: "#0078D4")
        }
        static var lavender: Color {
            GentleThemeManager.shared.current == .macOS
                ? Color(hex: "#A78BFA")
                : Color(hex: "#60A5FA")
        }
        static var violet: Color {
            GentleThemeManager.shared.current == .macOS
                ? Color(hex: "#7C3AED")
                : Color(hex: "#0078D4")
        }
        static let pink    = Color(hex: "#F472B6")
        static let yellow  = Color(hex: "#FCD34D")
        static let orange  = Color(hex: "#F59E0B")
        static var indigo: Color {
            GentleThemeManager.shared.current == .macOS
                ? Color(hex: "#8B5CF6")
                : Color(hex: "#60A5FA")
        }
    }

    enum Warm {
        static let amber  = Color(hex: "#F59E0B")
        static let orange = Color(hex: "#F97316")
    }

    // MARK: Semantic — Backgrounds
    enum Background {
        static var primary: Color {
            GentleThemeManager.shared.current == .macOS
                ? Color(hex: "#F5F0FF")
                : Color(hex: "#F3F3F3")
        }
        static var secondary: Color {
            GentleThemeManager.shared.current == .macOS
                ? Color.white
                : Color.white
        }
        static var tertiary: Color {
            GentleThemeManager.shared.current == .macOS
                ? Color(hex: "#EDE9FE")
                : Color(hex: "#E8E8E8")
        }
        static let overlay   = Color.black.opacity(0.4)
        static let dark      = Color(hex: "#1E1633")
        static let darkCard  = Color(hex: "#2D2447")
    }

    // MARK: Semantic — Text
    enum Text {
        static var primary: Color {
            GentleThemeManager.shared.current == .macOS
                ? Color(hex: "#1F1035")
                : Color(hex: "#1A1A2E")
        }
        static var secondary: Color {
            GentleThemeManager.shared.current == .macOS
                ? Color(hex: "#6B7280")
                : Color(hex: "#5C6370")
        }
        static let tertiary  = Color(hex: "#9CA3AF")
        static let inverse   = Color.white
        static var accent: Color { Gentle.Primary.lavender }
        static var link: Color { Gentle.Primary.indigo }
        static let darkPrimary   = Color(hex: "#EDE9FE")
        static let darkSecondary = Color(hex: "#A78BFA")
    }

    // MARK: Semantic — Borders & Dividers
    enum Border {
        static var light: Color {
            GentleThemeManager.shared.current == .macOS
                ? Color.gray.opacity(0.15)
                : Color.gray.opacity(0.18)
        }
        static var medium: Color {
            GentleThemeManager.shared.current == .macOS
                ? Color.gray.opacity(0.25)
                : Color.gray.opacity(0.28)
        }
        static var focus: Color { Gentle.Primary.lavender }
    }

    // MARK: Semantic — State
    enum State {
        static let success = Color(hex: "#34D399")
        static let warning = Color(hex: "#FBBF24")
        static let error   = Color(hex: "#F87171")
        static let info    = Color(hex: "#60A5FA")
    }

    // MARK: Emotion Palette
    enum Emotion {
        static let happy     = Color(hex: "#FCD34D")
        static let calm      = Color(hex: "#A78BFA")
        static let grateful  = Color(hex: "#F472B6")
        static let anxious   = Color(hex: "#FB923C")
        static let sad      = Color(hex: "#60A5FA")
        static let angry     = Color(hex: "#F87171")
        static let tired     = Color(hex: "#94A3B8")
    }

    // MARK: Gradients
    enum Gradient {
        static var breathing: LinearGradient {
            LinearGradient(
                colors: [
                    Primary.purple.opacity(0.95),
                    Primary.lavender.opacity(0.98),
                    Primary.pink.opacity(0.25),
                    Primary.yellow.opacity(0.12)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        static var primaryButton: LinearGradient {
            LinearGradient(
                colors: [Primary.purple, Primary.lavender],
                startPoint: .leading,
                endPoint: .trailing
            )
        }

        static var secondaryButton: LinearGradient {
            LinearGradient(
                colors: [Primary.lavender, Primary.pink],
                startPoint: .leading,
                endPoint: .trailing
            )
        }

        static var warmButton: LinearGradient {
            LinearGradient(
                colors: [Primary.yellow, Primary.orange],
                startPoint: .leading,
                endPoint: .trailing
            )
        }

        static var warmPrimaryButton: LinearGradient {
            LinearGradient(
                colors: [
                    Color(hex: "#C084FC"),
                    Color(hex: "#A78BFA"),
                    Color(hex: "#F472B6")
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        }

        static let aurora1 = RadialGradient(
            colors: [Color(hex: "#7C3AED").opacity(0.15), .clear],
            center: .center,
            startRadius: 0,
            endRadius: 160
        )

        static let aurora2 = RadialGradient(
            colors: [Color(hex: "#F472B6").opacity(0.12), .clear],
            center: .center,
            startRadius: 0,
            endRadius: 130
        )

        static let card = LinearGradient(
            colors: [Color.white.opacity(0.9), Color.white.opacity(0.6)],
            startPoint: .top,
            endPoint: .bottom
        )

        static let darkCard = LinearGradient(
            colors: [Color(hex: "#2D2447"), Color(hex: "#1E1633")],
            startPoint: .top,
            endPoint: .bottom
        )
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
    // Display — large titles / hero text
    static func display(_ size: CGFloat = 32) -> Font {
        .system(size: size, weight: .ultraLight)
    }

    // Title — section headings
    static func title(_ size: CGFloat = 22) -> Font {
        .system(size: size, weight: .semibold)
    }

    // Headline — card titles, important labels
    static func headline(_ size: CGFloat = 17) -> Font {
        .system(size: size, weight: .semibold)
    }

    // Body — main content
    static func body(_ size: CGFloat = 15) -> Font {
        .system(size: size, weight: .regular)
    }

    // Caption — timestamps, meta info
    static func caption(_ size: CGFloat = 12) -> Font {
        .system(size: size, weight: .regular)
    }

    // Mono — code, stats
    static func mono(_ size: CGFloat = 14) -> Font {
        .system(size: size, weight: .medium, design: .monospaced)
    }

    // Rounded — friendly UI labels
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
    static let xxxl: CGFloat = 36  // iOS 26 Liquid Glass
    static let xxxx: CGFloat = 40  // iOS 26 deep card
    static let full: CGFloat = 9999 // Pills / avatars
}

// MARK: - 🌫️ Shadows

enum GentleShadow {
    static let none: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) =
        (.clear, 0, 0, 0)

    static let sm: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) =
        (Color.black.opacity(0.06), 4, 0, 2)

    static let md: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) =
        (Color.black.opacity(0.10), 8, 0, 4)

    static let lg: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) =
        (Color.black.opacity(0.14), 12, 0, 6)

    static let glow: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) =
        (Color(hex: "#8B5CF6").opacity(0.4), 16, 0, 8)

    // Apply shadow to any view
    @ViewBuilder
    static func apply(_ shadow: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat),
                      @ViewBuilder content: () -> some View) -> some View {
        content()
            .shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}

// MARK: - 🎨 Reusable View Modifiers

/// GentleCard as a standalone view container — call as: GentleCard { ... }
/// or: GentleCard(padding: 20) { ... }
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
            .shadow(
                color: Color.black.opacity(0.08),
                radius: 8,
                x: 0,
                y: 2
            )
    }
}

/// GentleCard as a ViewModifier (`.gentleCard()` syntax)
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

// Convenience extensions on View
extension View {
    func gentleCard(padding: CGFloat = GentleSpacing.md,
                    cornerRadius: CGFloat = GentleRadius.md) -> some View {
        modifier(GentleCardModifier(padding: padding, cornerRadius: cornerRadius))
    }

    func gentleDivider() -> some View {
        modifier(GentleDivider())
    }
}

// MARK: - 🔘 Button Styles

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
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
            )
            .shadow(
                color: isEnabled ? Gentle.Primary.purple.opacity(configuration.isPressed ? 0.1 : 0.25)
                                 : .clear,
                radius: configuration.isPressed ? 4 : 8,
                x: 0,
                y: configuration.isPressed ? 2 : 4
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
                    .fill(isEnabled ? Gentle.Background.tertiary
                                    : Gentle.Background.tertiary.opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: GentleRadius.sm, style: .continuous)
                    .stroke(isEnabled ? Gentle.Border.medium : Gentle.Border.light,
                            lineWidth: 1)
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
                    .fill(configuration.isPressed
                          ? backgroundColor.opacity(0.7)
                          : backgroundColor)
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
            .background(
                Capsule()
                    .fill(color)
            )
    }
}

extension View {
    func gentleTag(color: Color = Gentle.Primary.lavender) -> some View {
        modifier(GentleTagStyle(color: color))
    }
}

// MARK: - 🖼️ Avatar View

struct GentleAvatar: View {
    let initials: String
    var size: CGFloat = 44
    var gradient: LinearGradient = Gentle.Gradient.primaryButton

    var body: some View {
        ZStack {
            Circle()
                .fill(gradient)
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
            .animation(
                .linear(duration: 0.9).repeatForever(autoreverses: false),
                value: isAnimating
            )
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
            if let trailing {
                trailing
            }
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
