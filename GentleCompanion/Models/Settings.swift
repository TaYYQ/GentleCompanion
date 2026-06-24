//
//  Settings.swift
//  GentleCompanion
//
//  App settings and user preferences
//

import Foundation
import AppKit
import UserNotifications
import CoreLocation
import WeatherKit
import SwiftUI

enum GentleWeatherCondition: String, Codable {
    case clear
    case cloudy
    case rainy
    case foggy
    case snowy
    case extreme
    case unknown
}

struct GentleWeatherSnapshot: Codable {
    let city: String
    let condition: GentleWeatherCondition
    let symbolName: String
    let line: String
    let detail: String
    let createdAt: Date
}

@available(macOS 13.0, *)
class GentleWeatherProvider: @unchecked Sendable {
    static let shared = GentleWeatherProvider()
    private let service = WeatherService.shared
    
    private init() {}
    
    func fetch(for settings: AppSettings, emotion: Emotion) async -> GentleWeatherSnapshot? {
        let fallbackLocation = Location(
            latitude: 34.0522,
            longitude: -118.2437,
            city: "洛杉矶",
            timezone: "America/Los_Angeles"
        )
        let storedLocation = settings.currentLocation ?? fallbackLocation
        let clLocation = CLLocation(latitude: storedLocation.latitude, longitude: storedLocation.longitude)
        do {
            let weather = try await service.weather(for: clLocation)
            let condition = GentleWeatherCondition(from: weather.currentWeather.condition)
            let city = storedLocation.city ?? "你的城市"
            let symbolName = GentleWeatherProvider.symbolName(for: condition)
            let (line, detail) = GentleWeatherProvider.gentleLines(
                for: condition,
                emotion: emotion,
                city: city
            )
            return GentleWeatherSnapshot(
                city: city,
                condition: condition,
                symbolName: symbolName,
                line: line,
                detail: detail,
                createdAt: Date()
            )
        } catch {
            return nil
        }
    }
    
    private static func symbolName(for condition: GentleWeatherCondition) -> String {
        switch condition {
        case .clear: return "sun.max"
        case .cloudy: return "cloud"
        case .rainy: return "cloud.rain"
        case .foggy: return "cloud.fog"
        case .snowy: return "cloud.snow"
        case .extreme: return "exclamationmark.triangle"
        case .unknown: return "sparkles"
        }
    }
    
    private static func gentleLines(for condition: GentleWeatherCondition, emotion: Emotion, city: String) -> (String, String) {
        let cityPart = city.isEmpty ? "今天" : city
        switch condition {
        case .clear:
            let line = "\(cityPart)晴，太阳在轻轻说：今天也值得被爱。"
            let detail: String
            switch emotion {
            case .empty:
                detail = "阳光洒在窗台上，也照得到这块暂时空掉的心。它不催你，只陪你。"
            case .exhausted:
                detail = "加州的阳光很明亮，但你可以慢一点，让光先替你努力。"
            case .anxious:
                detail = "天这么亮，说明世界还在等你慢慢来，不用一下子赶上所有光。"
            default:
                detail = "阳光洒满窗台，像在提醒你：你的温柔也值得被看见。"
            }
            return (line, detail)
        case .rainy:
            let line = "\(cityPart)有雨，云在替你多想一点。"
            let detail: String
            switch emotion {
            case .exhausted:
                detail = "雨声像一条被子，把今天的疲惫都盖住了，你只负责躺一会儿就好。"
            case .empty, .lonely:
                detail = "雨在替你哭一场，没关系，哭完继续温柔地活着。"
            default:
                detail = "窗外的雨在认真地下着，像在提醒你：你的情绪也可以被认真对待。"
            }
            return (line, detail)
        case .foggy, .cloudy:
            let line = "\(cityPart)多云/有雾，世界被轻轻蒙上了一层纱。"
            let detail: String
            switch emotion {
            case .anxious:
                detail = "雾里看不清没关系，现在看不清路，也不代表你没有方向。"
            case .empty:
                detail = "天灰灰的日子，本来就适合慢一点，对自己温柔一点。"
            default:
                detail = "云层偶尔会厚一点，但太阳没有消失，就像你的力量一样。"
            }
            return (line, detail)
        case .snowy:
            let line = "\(cityPart)下雪了，世界在帮你按下慢放键。"
            let detail = "每一片落下来的雪花，都在说：可以走得更慢一点，也没关系。"
            return (line, detail)
        case .extreme:
            let line = "\(cityPart)今天有点极端天气，请先照顾好自己。"
            let detail = "今天热得像抱抱太多、风大得像心事太满。不管外面怎样，你都值得被好好保护，多喝水、多休息。"
            return (line, detail)
        case .unknown:
            let line = "看不太清今天的天气，但可以先照顾好当下的你。"
            let detail = "就算天气预报说不清，现在这个你也依然值得被温柔对待。"
            return (line, detail)
        }
    }
}

@available(macOS 13.0, *)
extension GentleWeatherCondition {
    init(from condition: WeatherCondition) {
        let raw = String(describing: condition).lowercased()
        if raw.contains("clear") || raw.contains("sun") {
            self = .clear
        } else if raw.contains("cloud") {
            self = .cloudy
        } else if raw.contains("rain") || raw.contains("drizzle") {
            self = .rainy
        } else if raw.contains("snow") {
            self = .snowy
        } else if raw.contains("fog") || raw.contains("haze") {
            self = .foggy
        } else if raw.contains("storm") || raw.contains("thunder") || raw.contains("extreme") {
            self = .extreme
        } else {
            self = .unknown
        }
    }
}

enum ReminderFrequency: String, Codable, CaseIterable {
    case daily
    case weekly
}

struct EmotionEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let emotion: Emotion
    
    init(id: UUID = UUID(), date: Date, emotion: Emotion) {
        self.id = id
        self.date = date
        self.emotion = emotion
    }
}

struct PomodoroSession: Codable, Equatable {
    let timestamp: Date
    let duration: TimeInterval
    let completed: Bool
    let intention: String
    let focusScore: Int?
}



struct PomodoroStats: Codable {
    var totalSessions: Int
    var completedSessions: Int
    var totalMinutes: Int
    var streakDays: Int
    var longestStreak: Int
    var focusScore: Double
    var sessions: [PomodoroSession]
    var dailyStats: [Date: Int]

    // MARK: - Computed Properties

    var averageMinutes: Int {
        completedSessions > 0 ? totalMinutes / completedSessions : 0
    }

    var completionRate: Int {
        totalSessions > 0 ? Int(Double(completedSessions) / Double(totalSessions) * 100) : 0
    }

    static let empty = PomodoroStats(
        totalSessions: 0,
        completedSessions: 0,
        totalMinutes: 0,
        streakDays: 0,
        longestStreak: 0,
        focusScore: 0,
        sessions: [],
        dailyStats: [:]
    )
}



struct AppSettings: Codable {
    var isFirstLaunch: Bool
    var isOnboardingComplete: Bool
    var selectedEmotion: Emotion?
    var idleTimeSeconds: Int
    var dailyReminders: [Date]
    var soundEnabled: Bool
    var customMessages: [String]
    var currentLocation: Location?
    var userIntentions: [String]
    var userFocus: [String]
    var reminderTime: Date?
    var collectedStars: Int
    var reminderEnabled: Bool
    var reminderFrequency: ReminderFrequency
    var reminderWeekdays: [Int]
    var reminderTimes: [Date]
    var immersiveFullScreenEnabled: Bool
    var floatingWindowEnabled: Bool
    var emotionHistory: [EmotionEntry]
    var pomodoroStats: PomodoroStats
    
    static let defaultSettings = AppSettings(
        isFirstLaunch: true,
        isOnboardingComplete: false,
        selectedEmotion: nil,
        idleTimeSeconds: 60,
        dailyReminders: [],
        soundEnabled: false,
        customMessages: [],
        currentLocation: Location(
            latitude: 34.0522,
            longitude: -118.2437,
            city: "洛杉矶",
            timezone: "America/Los_Angeles"
        ),
        userIntentions: [],
        userFocus: [],
        reminderTime: nil,
        collectedStars: 0,
        reminderEnabled: false,
        reminderFrequency: .daily,
        reminderWeekdays: [2, 3, 4, 5, 6],
        reminderTimes: AppSettings.defaultReminderTimes(),
        immersiveFullScreenEnabled: true,
        floatingWindowEnabled: false,
        emotionHistory: [],
        pomodoroStats: PomodoroStats.empty
    )
    
    static func defaultReminderTimes() -> [Date] {
        let calendar = Calendar.current
        let base = Date()
        func makeTime(_ hour: Int, _ minute: Int) -> Date {
            var components = calendar.dateComponents([.year, .month, .day], from: base)
            components.hour = hour
            components.minute = minute
            return calendar.date(from: components) ?? base
        }
        return [makeTime(9, 0), makeTime(13, 0), makeTime(18, 0)]
    }
    
    mutating func resetEmotion() {
        selectedEmotion = nil
        isFirstLaunch = true
    }
    
    enum CodingKeys: String, CodingKey {
        case isFirstLaunch
        case isOnboardingComplete
        case selectedEmotion
        case idleTimeSeconds
        case dailyReminders
        case soundEnabled
        case customMessages
        case currentLocation
        case userIntentions
        case userFocus
        case reminderTime
        case collectedStars
        case reminderEnabled
        case reminderFrequency
        case reminderWeekdays
        case reminderTimes
        case immersiveFullScreenEnabled
        case floatingWindowEnabled
        case emotionHistory
        case pomodoroStats
    }
    
    init(
        isFirstLaunch: Bool,
        isOnboardingComplete: Bool,
        selectedEmotion: Emotion?,
        idleTimeSeconds: Int,
        dailyReminders: [Date],
        soundEnabled: Bool,
        customMessages: [String],
        currentLocation: Location?,
        userIntentions: [String],
        userFocus: [String],
        reminderTime: Date?,
        collectedStars: Int,
        reminderEnabled: Bool,
        reminderFrequency: ReminderFrequency,
        reminderWeekdays: [Int],
        reminderTimes: [Date],
        immersiveFullScreenEnabled: Bool,
        floatingWindowEnabled: Bool,
        emotionHistory: [EmotionEntry],
        pomodoroStats: PomodoroStats
    ) {
        self.isFirstLaunch = isFirstLaunch
        self.isOnboardingComplete = isOnboardingComplete
        self.selectedEmotion = selectedEmotion
        self.idleTimeSeconds = idleTimeSeconds
        self.dailyReminders = dailyReminders
        self.soundEnabled = soundEnabled
        self.customMessages = customMessages
        self.currentLocation = currentLocation
        self.userIntentions = userIntentions
        self.userFocus = userFocus
        self.reminderTime = reminderTime
        self.collectedStars = collectedStars
        self.reminderEnabled = reminderEnabled
        self.reminderFrequency = reminderFrequency
        self.reminderWeekdays = reminderWeekdays
        self.reminderTimes = reminderTimes
        self.immersiveFullScreenEnabled = immersiveFullScreenEnabled
        self.floatingWindowEnabled = floatingWindowEnabled
        self.emotionHistory = emotionHistory
        self.pomodoroStats = pomodoroStats
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let defaults = AppSettings.defaultSettings
        isFirstLaunch = try container.decodeIfPresent(Bool.self, forKey: .isFirstLaunch) ?? defaults.isFirstLaunch
        isOnboardingComplete = try container.decodeIfPresent(Bool.self, forKey: .isOnboardingComplete) ?? defaults.isOnboardingComplete
        selectedEmotion = try container.decodeIfPresent(Emotion.self, forKey: .selectedEmotion)
        idleTimeSeconds = try container.decodeIfPresent(Int.self, forKey: .idleTimeSeconds) ?? defaults.idleTimeSeconds
        dailyReminders = try container.decodeIfPresent([Date].self, forKey: .dailyReminders) ?? defaults.dailyReminders
        soundEnabled = try container.decodeIfPresent(Bool.self, forKey: .soundEnabled) ?? defaults.soundEnabled
        customMessages = try container.decodeIfPresent([String].self, forKey: .customMessages) ?? defaults.customMessages
        currentLocation = try container.decodeIfPresent(Location.self, forKey: .currentLocation)
        userIntentions = try container.decodeIfPresent([String].self, forKey: .userIntentions) ?? defaults.userIntentions
        userFocus = try container.decodeIfPresent([String].self, forKey: .userFocus) ?? defaults.userFocus
        reminderTime = try container.decodeIfPresent(Date.self, forKey: .reminderTime) ?? defaults.reminderTime
        collectedStars = try container.decodeIfPresent(Int.self, forKey: .collectedStars) ?? defaults.collectedStars
        reminderEnabled = try container.decodeIfPresent(Bool.self, forKey: .reminderEnabled) ?? defaults.reminderEnabled
        reminderFrequency = try container.decodeIfPresent(ReminderFrequency.self, forKey: .reminderFrequency) ?? defaults.reminderFrequency
        reminderWeekdays = try container.decodeIfPresent([Int].self, forKey: .reminderWeekdays) ?? defaults.reminderWeekdays
        if let decodedTimes = try container.decodeIfPresent([Date].self, forKey: .reminderTimes) {
            reminderTimes = decodedTimes
        } else if let legacyTime = reminderTime {
            reminderTimes = [legacyTime]
        } else {
            reminderTimes = defaults.reminderTimes
        }
        immersiveFullScreenEnabled = try container.decodeIfPresent(Bool.self, forKey: .immersiveFullScreenEnabled) ?? defaults.immersiveFullScreenEnabled
        floatingWindowEnabled = try container.decodeIfPresent(Bool.self, forKey: .floatingWindowEnabled) ?? defaults.floatingWindowEnabled
        emotionHistory = try container.decodeIfPresent([EmotionEntry].self, forKey: .emotionHistory) ?? defaults.emotionHistory
        pomodoroStats = try container.decodeIfPresent(PomodoroStats.self, forKey: .pomodoroStats) ?? defaults.pomodoroStats
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isFirstLaunch, forKey: .isFirstLaunch)
        try container.encode(isOnboardingComplete, forKey: .isOnboardingComplete)
        try container.encodeIfPresent(selectedEmotion, forKey: .selectedEmotion)
        try container.encode(idleTimeSeconds, forKey: .idleTimeSeconds)
        try container.encode(dailyReminders, forKey: .dailyReminders)
        try container.encode(soundEnabled, forKey: .soundEnabled)
        try container.encode(customMessages, forKey: .customMessages)
        try container.encodeIfPresent(currentLocation, forKey: .currentLocation)
        try container.encode(userIntentions, forKey: .userIntentions)
        try container.encode(userFocus, forKey: .userFocus)
        try container.encodeIfPresent(reminderTime, forKey: .reminderTime)
        try container.encode(collectedStars, forKey: .collectedStars)
        try container.encode(reminderEnabled, forKey: .reminderEnabled)
        try container.encode(reminderFrequency, forKey: .reminderFrequency)
        try container.encode(reminderWeekdays, forKey: .reminderWeekdays)
        try container.encode(reminderTimes, forKey: .reminderTimes)
        try container.encode(immersiveFullScreenEnabled, forKey: .immersiveFullScreenEnabled)
        try container.encode(floatingWindowEnabled, forKey: .floatingWindowEnabled)
        try container.encode(emotionHistory, forKey: .emotionHistory)
        try container.encode(pomodoroStats, forKey: .pomodoroStats)
    }
}

struct Location: Codable {
    let latitude: Double
    let longitude: Double
    let city: String?
    let timezone: String?
}

class SettingsManager: @unchecked Sendable {
    static let shared = SettingsManager()
    
    private let userDefaults = UserDefaults.standard
    private let settingsKey = "GentleCompanionSettings"
    
    private init() {}
    
    var settings: AppSettings {
        get {
            guard let data = userDefaults.data(forKey: settingsKey),
                  let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) else {
                return AppSettings.defaultSettings
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                userDefaults.set(encoded, forKey: settingsKey)
            }
        }
    }
    
    func saveCustomMessage(_ message: String) {
        var currentSettings = settings
        currentSettings.customMessages.append(message)
        settings = currentSettings
    }
    
    func updateLocation(_ location: Location) {
        var currentSettings = settings
        currentSettings.currentLocation = location
        settings = currentSettings
    }
    
    func clearCustomMessages() {
        var currentSettings = settings
        currentSettings.customMessages = []
        settings = currentSettings
    }
    
    func appendEmotionEntry(_ emotion: Emotion) {
        var currentSettings = settings
        currentSettings.emotionHistory.append(EmotionEntry(date: Date(), emotion: emotion))
        settings = currentSettings
    }
}

class NotificationManager: @unchecked Sendable {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization(completion: ((@Sendable (Bool) -> Void))? = nil) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            DispatchQueue.main.async {
                completion?(granted)
            }
        }
    }
    
    func scheduleReminders(settings: AppSettings) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        guard settings.reminderEnabled else { return }
        guard !settings.reminderTimes.isEmpty else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "温柔提醒"
        content.body = "今天也记得好好照顾自己。"
        content.sound = .default
        
        switch settings.reminderFrequency {
        case .daily:
            for (index, time) in settings.reminderTimes.enumerated() {
                let components = Calendar.current.dateComponents([.hour, .minute], from: time)
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                let request = UNNotificationRequest(identifier: "gentlecompanion.reminder.daily.\(index)", content: content, trigger: trigger)
                center.add(request)
            }
        case .weekly:
            let weekdays = settings.reminderWeekdays.isEmpty ? [2, 3, 4, 5, 6] : settings.reminderWeekdays
            for weekday in weekdays {
                for (index, time) in settings.reminderTimes.enumerated() {
                    var components = Calendar.current.dateComponents([.hour, .minute], from: time)
                    components.weekday = weekday
                    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                    let request = UNNotificationRequest(identifier: "gentlecompanion.reminder.weekly.\(weekday).\(index)", content: content, trigger: trigger)
                    center.add(request)
                }
            }
        }
    }
}

// MARK: - Particle types for animations

struct FloatingParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let size: CGFloat
    var opacity: Double
    let color: Color
    let speed: CGFloat
    let direction: CGPoint
    
    static func random(in size: CGSize) -> FloatingParticle {
        let width = max(size.width, 1)
        let height = max(size.height, 1)
        return FloatingParticle(
            position: CGPoint(
                x: CGFloat.random(in: 0...width),
                y: CGFloat.random(in: 0...height)
            ),
            size: CGFloat.random(in: 2...6),
            opacity: Double.random(in: 0.1...0.3),
            color: [Color.white.opacity(0.6), Color(hex: "#E0D2FE").opacity(0.4), Color(hex: "#FCD34D").opacity(0.3)].randomElement()!,
            speed: CGFloat.random(in: 0.2...0.5),
            direction: CGPoint(
                x: CGFloat.random(in: -0.3...0.3),
                y: CGFloat.random(in: -0.3...0.3)
            )
        )
    }
    
    mutating func update(in size: CGSize) {
        position.x += direction.x * speed
        position.y += direction.y * speed
        
        let width = max(size.width, 1)
        let height = max(size.height, 1)
        
        if position.x < -20 { position.x = width + 20 }
        if position.x > width + 20 { position.x = -20 }
        if position.y < -20 { position.y = height + 20 }
        if position.y > height + 20 { position.y = -20 }
    }
}

struct HugParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let size: CGFloat
    var opacity: Double
    let color: Color
}
