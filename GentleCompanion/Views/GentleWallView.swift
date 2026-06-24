//
//  GentleWallView.swift
//  GentleCompanion
//
//  Optimized Modern Design - Soft Pastel Theme
//

import SwiftUI

// MARK: - Gentle Wall View

struct GentleWallView: View {
    @StateObject private var wallManager = GentleWallManager.shared
    @Binding var isPresented: Bool
    
    @State private var currentView: CurrentView = .main
    @State private var newMessageContent = ""
    @State private var selectedEmotion = "其他"
    @State private var filterEmotion: String? = nil
    @State private var hoveredFilter: String?
    @State private var hoveredMessage: UUID?
    
    enum CurrentView {
        case main
        case postMessage
    }
    
    private let emotionTags = ["疲惫", "焦虑", "压力大", "孤独", "难过", "空虚", "迷茫", "挫败", "其他"]
    
    var body: some View {
        ZStack {
            // Enhanced gradient background
            LinearGradient(
                colors: [
                    Color(hex: "#F8F0FF"),
                    Color(hex: "#F0E7FF"),
                    Color(hex: "#F5F0FF")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            Group {
                switch currentView {
                case .main:
                    mainView
                case .postMessage:
                    postMessageView
                }
            }
        }
    }
    
    // MARK: - Main View
    
    private var mainView: some View {
        VStack(spacing: 0) {
            headerBar
                .padding(.horizontal, GentleSpacing.xxl)
                .padding(.top, GentleSpacing.lg)
            
            emotionFilterBar
                .padding(.top, GentleSpacing.lg)
            
            messageList
        }
    }
    
    private var headerBar: some View {
        HStack {
            Button(action: { isPresented = false }) {
                HStack(spacing: GentleSpacing.sm) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                    Text("返回")
                        .font(GentleFont.caption())
                }
                .foregroundColor(Gentle.Text.secondary)
                .padding(.horizontal, GentleSpacing.md)
                .padding(.vertical, GentleSpacing.sm)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.7))
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            VStack(spacing: GentleSpacing.xs) {
                Text("💕 温柔墙")
                    .font(GentleFont.headline(20))
                    .foregroundColor(Gentle.Text.primary)
                Text("匿名分享，互相温柔")
                    .font(GentleFont.caption(12))
                    .foregroundColor(Gentle.Text.tertiary)
            }
            
            Spacer()
            
            Button(action: { currentView = .postMessage }) {
                HStack(spacing: GentleSpacing.xs) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold))
                    Text("发布")
                        .font(GentleFont.caption(12))
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, GentleSpacing.lg)
                .padding(.vertical, GentleSpacing.sm)
                .background(
                    Capsule()
                        .fill(Gentle.Gradient.primaryButton)
                )
                .shadow(
                    color: Gentle.Primary.lavender.opacity(0.3),
                    radius: GentleShadow.md.radius,
                    x: GentleShadow.md.x,
                    y: GentleShadow.md.y
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private var emotionFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: GentleSpacing.sm) {
                FilterChip(title: "全部", isSelected: filterEmotion == nil, isHovered: hoveredFilter == "全部") {
                    filterEmotion = nil
                }
                .onHover { hovering in withAnimation { hoveredFilter = hovering ? "全部" : nil } }
                
                ForEach(emotionTags, id: \.self) { emotion in
                    FilterChip(title: emotion, isSelected: filterEmotion == emotion, isHovered: hoveredFilter == emotion) {
                        filterEmotion = emotion
                    }
                    .onHover { hovering in withAnimation { hoveredFilter = hovering ? emotion : nil } }
                }
            }
            .padding(.horizontal, GentleSpacing.xxl)
            .padding(.vertical, GentleSpacing.sm)
        }
    }
    
    private var messageList: some View {
        ScrollView {
            LazyVStack(spacing: GentleSpacing.md) {
                let filtered = wallManager.filterByEmotion(filterEmotion)
                
                if filtered.isEmpty {
                    emptyStateView
                } else {
                    ForEach(filtered) { message in
                        MessageCard(message: message, isHovered: hoveredMessage == message.id)
                            .onHover { hovering in withAnimation { hoveredMessage = hovering ? message.id : nil } }
                    }
                }
            }
            .padding(.horizontal, GentleSpacing.xxl)
            .padding(.vertical, GentleSpacing.lg)
            .padding(.bottom, GentleSpacing.xxl)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: GentleSpacing.xl) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Gentle.Primary.lavender.opacity(0.1))
                    .frame(width: 140, height: 140)
                
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 64))
                    .foregroundColor(Gentle.Primary.lavender)
            }
            
            VStack(spacing: GentleSpacing.xs) {
                Text("这里还没有温柔消息")
                    .font(GentleFont.body(16))
                    .foregroundColor(Gentle.Text.primary)
                
                Text("成为第一个分享温柔的人吧 ✨")
                    .font(GentleFont.caption(12))
                    .foregroundColor(Gentle.Text.tertiary)
            }
            
            Button { currentView = .postMessage } label: {
                HStack(spacing: GentleSpacing.sm) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold))
                    Text("发布第一条消息")
                        .font(GentleFont.caption(13))
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, GentleSpacing.lg)
                .padding(.vertical, GentleSpacing.md)
                .background(
                    Capsule()
                        .fill(Gentle.Gradient.primaryButton)
                )
                .shadow(
                    color: Gentle.Primary.lavender.opacity(0.3),
                    radius: GentleShadow.md.radius,
                    x: GentleShadow.md.x,
                    y: GentleShadow.md.y
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
        }
        .padding(.top, GentleSpacing.xxl)
    }
    
    // MARK: - Post Message View
    
    private var postMessageView: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { currentView = .main }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Gentle.Text.secondary)
                        .padding(.all, GentleSpacing.sm)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.7))
                        )
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Text("💌 发布温柔")
                    .font(GentleFont.headline(18))
                    .foregroundColor(Gentle.Text.primary)
                
                Spacer()
                
                Button(action: postMessage) {
                    Text("发布")
                        .font(GentleFont.caption(13))
                        .fontWeight(.semibold)
                        .foregroundColor(newMessageContent.isEmpty ? Gentle.Text.tertiary : .white)
                        .padding(.horizontal, GentleSpacing.lg)
                        .padding(.vertical, GentleSpacing.sm)
                        .background(
                            Capsule()
                                .fill(newMessageContent.isEmpty ? Gentle.Background.tertiary : Gentle.Primary.lavender)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(newMessageContent.isEmpty)
            }
            .padding(.horizontal, GentleSpacing.xxl)
            .padding(.vertical, GentleSpacing.lg)
            
            ScrollView {
                VStack(spacing: GentleSpacing.xl) {
                    emotionSelector
                    messageInput
                }
                .padding(.horizontal, GentleSpacing.xxl)
                .padding(.top, GentleSpacing.md)
            }
            
            Spacer()
        }
    }
    
    private var emotionSelector: some View {
        VStack(alignment: .leading, spacing: GentleSpacing.md) {
            Text("选择情绪标签")
                .font(GentleFont.caption(12))
                .fontWeight(.semibold)
                .foregroundColor(Gentle.Text.secondary)
            
            FlowLayout(spacing: GentleSpacing.sm) {
                ForEach(emotionTags, id: \.self) { emotion in
                    EmotionChip(title: emotion, isSelected: selectedEmotion == emotion) {
                        selectedEmotion = emotion
                    }
                }
            }
        }
    }
    
    private var messageInput: some View {
        VStack(alignment: .leading, spacing: GentleSpacing.md) {
            Text("写下你的温柔")
                .font(GentleFont.caption(12))
                .fontWeight(.semibold)
                .foregroundColor(Gentle.Text.secondary)
            
            ZStack(alignment: .topLeading) {
                if newMessageContent.isEmpty {
                    Text("分享你的心情或温柔的话语...")
                        .font(GentleFont.body(14))
                        .foregroundColor(Gentle.Text.tertiary)
                        .padding(GentleSpacing.lg)
                        .padding(.top, GentleSpacing.sm)
                }
                
                TextEditor(text: $newMessageContent)
                    .font(GentleFont.body(15))
                    .foregroundColor(Gentle.Text.primary)
                    .scrollContentBackground(.hidden)
                    .frame(height: 150)
                    .padding(GentleSpacing.lg)
                    .padding(.top, GentleSpacing.sm)
            }
            .background(
                RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                            .stroke(Gentle.Primary.lavender.opacity(0.3), lineWidth: 1)
                    )
            )
            .shadow(
                color: Color.black.opacity(0.04),
                radius: GentleShadow.sm.radius,
                x: GentleShadow.sm.x,
                y: GentleShadow.sm.y
            )
        }
    }
    
    private func postMessage() {
        let content = newMessageContent.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return }
        
        wallManager.postMessage(content: content, emotion: selectedEmotion)
        
        newMessageContent = ""
        selectedEmotion = "其他"
        currentView = .main
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    var isHovered: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(GentleFont.caption(12))
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : (isHovered ? Gentle.Text.primary : Gentle.Text.secondary))
                .padding(.horizontal, GentleSpacing.lg)
                .padding(.vertical, GentleSpacing.sm)
                .background(
                    Capsule()
                        .fill(isSelected ? Gentle.Primary.lavender : (isHovered ? Color.white : Gentle.Background.tertiary))
                )
                .shadow(
                    color: isSelected ? Gentle.Primary.lavender.opacity(0.3) : Color.clear,
                    radius: isSelected ? 8 : 0,
                    x: 0,
                    y: isSelected ? 4 : 0
                )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isHovered)
    }
}

// MARK: - Emotion Chip

struct EmotionChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(GentleFont.caption(12))
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : Gentle.Text.secondary)
                .padding(.horizontal, GentleSpacing.md)
                .padding(.vertical, GentleSpacing.sm)
                .background(
                    Capsule()
                        .fill(isSelected ? Gentle.Primary.lavender : Gentle.Background.tertiary)
                )
                .shadow(
                    color: isSelected ? Gentle.Primary.lavender.opacity(0.25) : Color.clear,
                    radius: isSelected ? GentleShadow.sm.radius : 0,
                    x: isSelected ? GentleShadow.sm.x : 0,
                    y: isSelected ? GentleShadow.sm.y : 0
                )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Message Card

struct MessageCard: View {
    let message: GentleWallMessage
    var isHovered: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: GentleSpacing.md) {
            HStack {
                HStack(spacing: GentleSpacing.sm) {
                    Circle()
                        .fill(Gentle.Primary.lavender.opacity(0.2))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Text("🐻")
                                .font(.system(size: 16))
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("匿名温柔")
                            .font(GentleFont.caption(12))
                            .fontWeight(.semibold)
                            .foregroundColor(Gentle.Text.primary)
                        
                        Text(message.timeAgo)
                            .font(.system(size: 10))
                            .foregroundColor(Gentle.Text.tertiary)
                    }
                }
                
                Spacer()
                
                Text(message.emotion)
                    .font(GentleFont.caption(11))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, GentleSpacing.sm)
                    .padding(.vertical, GentleSpacing.xs)
                    .background(
                        Capsule()
                            .fill(Gentle.Gradient.primaryButton)
                    )
            }
            
            Text(message.content)
                .font(GentleFont.body(15))
                .foregroundColor(Gentle.Text.primary)
                .lineSpacing(6)
            
            HStack {
                Button(action: {}) {
                    HStack(spacing: GentleSpacing.xs) {
                        Image(systemName: message.likes > 0 ? "heart.fill" : "heart")
                            .font(.system(size: 14))
                        Text("\(message.likes)")
                            .font(GentleFont.caption(12))
                    }
                    .foregroundColor(message.likes > 0 ? Gentle.Primary.purple : Gentle.Text.tertiary)
                    .padding(.horizontal, GentleSpacing.md)
                    .padding(.vertical, GentleSpacing.xs)
                    .background(
                        Capsule()
                            .fill(message.likes > 0 ? Gentle.Primary.purple.opacity(0.1) : Gentle.Background.tertiary)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "heart")
                        .font(.system(size: 13))
                        .foregroundColor(Gentle.Text.tertiary)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(GentleSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: GentleRadius.xxl, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: GentleRadius.xxl, style: .continuous)
                        .stroke(isHovered ? Gentle.Primary.lavender.opacity(0.4) : Color.clear, lineWidth: 1.5)
                )
        )
        .shadow(
            color: isHovered ? Gentle.Primary.lavender.opacity(0.15) : Color.black.opacity(0.04),
            radius: isHovered ? GentleShadow.md.radius : GentleShadow.sm.radius,
            x: isHovered ? 0 : GentleShadow.sm.x,
            y: isHovered ? GentleShadow.md.y : GentleShadow.sm.y
        )
        .scaleEffect(isHovered ? 1.01 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isHovered)
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = GentleSpacing.sm
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var frames: [CGRect] = []
        var size: CGSize = .zero
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(origin: CGPoint(x: x, y: y), size: size))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}
