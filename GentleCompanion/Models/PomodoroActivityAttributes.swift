//
//  PomodoroActivityAttributes.swift
//  GentleCompanion
//
//  Live Activity 数据模型 — 番茄钟灵动岛
//

import ActivityKit
import Foundation

struct PomodoroActivityAttributes: ActivityAttributes {
    public typealias ContentState = PomodoroStatus

    public struct PomodoroStatus: Codable, Hashable, Sendable {
        var remainingSeconds: Int
        var totalSeconds: Int
        var isPaused: Bool
        var sessionNumber: Int

        var progress: Double {
            guard totalSeconds > 0 else { return 0 }
            return Double(totalSeconds - remainingSeconds) / Double(totalSeconds)
        }

        var timeString: String {
            let m = remainingSeconds / 60
            let s = remainingSeconds % 60
            return String(format: "%02d:%02d", m, s)
        }
    }
}
