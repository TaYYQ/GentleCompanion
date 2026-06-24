//
//  ModeSwitchView.swift
//  GentleCompanion
//
//  模式切换面板 — 娱乐 / 效率 / 社交
//

import SwiftUI

struct ModeSwitchView: View {
    @ObservedObject var modeManager = ModeManager.shared
    @State private var hoveredMode: AppMode?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 28) {
            // 标题
            VStack(spacing: 8) {
                Text("切换模式")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(Gentle.Text.primary)
                
                Text("选择你的 Gentle 体验")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Gentle.Text.secondary)
            }
            
            // 模式卡片
            HStack(spacing: 20) {
                ForEach(AppMode.allCases) { mode in
                    modeCard(mode)
                }
            }
            
            // 关闭按钮
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Gentle.Text.tertiary)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Gentle.Border.focus.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 30, x: 0, y: 15)
    }
    
    // MARK: - Mode Card
    
    private func modeCard(_ mode: AppMode) -> some View {
        let isSelected = modeManager.currentMode == mode
        let isHovered = hoveredMode == mode
        
        return Button {
            modeManager.switchTo(mode)
            dismiss()
        } label: {
            VStack(spacing: 16) {
                // 图标
                ZStack {
                    Circle()
                        .fill(mode.gradient)
                        .frame(width: 72, height: 72)
                        .shadow(color: mode.accentColor.opacity(isHovered ? 0.5 : 0.3), radius: isHovered ? 16 : 8, x: 0, y: 4)
                    
                    Text(mode.emoji)
                        .font(.system(size: 36))
                }
                .scaleEffect(isHovered ? 1.1 : 1.0)
                
                // 文字
                VStack(spacing: 6) {
                    Text(mode.rawValue)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Gentle.Text.primary)
                    
                    Text(mode.subtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Gentle.Text.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .frame(height: 28)
                }
            }
            .frame(width: 150, height: 180)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(isSelected ? mode.accentColor.opacity(0.1) : Gentle.Background.secondary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(isSelected ? mode.accentColor.opacity(0.5) : Gentle.Border.light, lineWidth: isSelected ? 2 : 1)
            )
            .scaleEffect(isHovered ? 1.05 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                hoveredMode = hovering ? mode : nil
            }
        }
    }
}
