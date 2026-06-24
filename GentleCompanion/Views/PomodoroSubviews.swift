//
//  PomodoroSubviews.swift
//  GentleCompanion
//
//  番茄钟可复用子组件
//

import SwiftUI

// MARK: - 统计卡片

public struct StatsCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let iconColor: Color

    public var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(iconColor)
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.8))
            }
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text(subtitle)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Gentle.Gradient.card.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        )
    }
}
