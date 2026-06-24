//
//  AppMode.swift
//  GentleCompanion
//
//  模式切换系统 — 娱乐/效率/社交
//

import SwiftUI

// MARK: - App Mode

enum AppMode: String, CaseIterable, Identifiable {
    case entertainment = "娱乐"
    case efficiency = "效率"
    case social = "社交"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .entertainment: return "gamecontroller.fill"
        case .efficiency: return "bolt.fill"
        case .social: return "person.2.fill"
        }
    }
    
    var emoji: String {
        switch self {
        case .entertainment: return "🎮"
        case .efficiency: return "⚡"
        case .social: return "🤝"
        }
    }
    
    var subtitle: String {
        switch self {
        case .entertainment: return "小游戏 · 放松心情"
        case .efficiency: return "专注 · 深呼吸 · 计时"
        case .social: return "互动 · 分享 · 温暖"
        }
    }
    
    var gradient: LinearGradient {
        switch self {
        case .entertainment:
            return LinearGradient(
                colors: [Color(hex: "#F472B6"), Color(hex: "#A78BFA")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .efficiency:
            return LinearGradient(
                colors: [Color(hex: "#60A5FA"), Color(hex: "#8B5CF6")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .social:
            return LinearGradient(
                colors: [Color(hex: "#FCD34D"), Color(hex: "#F97316")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        }
    }
    
    var accentColor: Color {
        switch self {
        case .entertainment: return Color(hex: "#F472B6")
        case .efficiency: return Color(hex: "#60A5FA")
        case .social: return Color(hex: "#F97316")
        }
    }
}

// MARK: - Mood for Game Recommendation

enum GameMood: String, CaseIterable, Identifiable {
    case happy = "开心"
    case calm = "平静"
    case anxious = "焦虑"
    case tired = "疲惫"
    case sad = "悲伤"
    case irritated = "烦躁"
    
    var id: String { rawValue }
    
    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .calm: return "😌"
        case .anxious: return "😰"
        case .tired: return "😫"
        case .sad: return "😢"
        case .irritated: return "😠"
        }
    }
    
    var color: Color {
        switch self {
        case .happy: return Color(hex: "#FCD34D")
        case .calm: return Color(hex: "#A78BFA")
        case .anxious: return Color(hex: "#FB923C")
        case .tired: return Color(hex: "#94A3B8")
        case .sad: return Color(hex: "#60A5FA")
        case .irritated: return Color(hex: "#F87171")
        }
    }
    
    /// 推荐的游戏类型
    var recommendedGame: GameType {
        switch self {
        case .anxious, .tired: return .bubblePop
        case .calm: return .garden
        case .sad: return .garden
        case .happy, .irritated: return .rhythm
        }
    }
    
    /// 推荐语
    var recommendationMessage: String {
        switch self {
        case .happy: return "心情正好，来点节奏感！🎵"
        case .calm: return "安静的时候，照顾花园吧 🌸"
        case .anxious: return "看起来你需要放松一下 💨"
        case .tired: return "累了就戳戳泡泡吧 🫧"
        case .sad: return "让花园陪你一会儿 🌸"
        case .irritated: return "发泄一下，跟着节奏来 🎵"
        }
    }
}

// MARK: - Game Type

enum GameType: String, CaseIterable, Identifiable {
    case bubblePop = "泡泡解压"
    case garden = "花园物语"
    case rhythm = "律动圆环"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .bubblePop: return "bubble.left.and.bubble.right.fill"
        case .garden: return "flower.fill"
        case .rhythm: return "circle.circle.fill"
        }
    }
    
    var emoji: String {
        switch self {
        case .bubblePop: return "🫧"
        case .garden: return "🌸"
        case .rhythm: return "🎵"
        }
    }
    
    var category: String {
        switch self {
        case .bubblePop: return "解压"
        case .garden: return "治愈"
        case .rhythm: return "节奏"
        }
    }
    
    var description: String {
        switch self {
        case .bubblePop: return "点击泡泡，释放压力"
        case .garden: return "种花养草，收集图鉴"
        case .rhythm: return "踩中节拍，感受律动"
        }
    }
    
    var accentColor: Color {
        switch self {
        case .bubblePop: return Color(hex: "#60A5FA")
        case .garden: return Color(hex: "#34D399")
        case .rhythm: return Color(hex: "#F472B6")
        }
    }
    
    var gradient: LinearGradient {
        switch self {
        case .bubblePop:
            return LinearGradient(
                colors: [Color(hex: "#60A5FA"), Color(hex: "#818CF8")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .garden:
            return LinearGradient(
                colors: [Color(hex: "#34D399"), Color(hex: "#6EE7B7")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .rhythm:
            return LinearGradient(
                colors: [Color(hex: "#F472B6"), Color(hex: "#A78BFA")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Play Duration

enum PlayDuration: String, CaseIterable, Identifiable {
    case short = "3分钟"
    case medium = "5分钟"
    case free = "随心"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .short: return "clock.fill"
        case .medium: return "clock.fill"
        case .free: return "infinity.fill"
        }
    }
    
    var seconds: Int? {
        switch self {
        case .short: return 180
        case .medium: return 300
        case .free: return nil
        }
    }
}

// MARK: - Mode Manager

@MainActor
final class ModeManager: ObservableObject {
    static let shared = ModeManager()
    
    @Published var currentMode: AppMode = .efficiency
    
    private init() {}
    
    func switchTo(_ mode: AppMode) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentMode = mode
        }
    }
}
