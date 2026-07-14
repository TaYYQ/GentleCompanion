//
//  SocialFeedView.swift
//  GentleCompanion
//
//  Optimized Modern Design - Soft Pastel Theme
//

import SwiftUI
#if canImport(AppKit)
import AppKit
#endif

// MARK: - Cross-platform image type

#if canImport(AppKit)
typealias PlatformImage = NSImage
#elseif canImport(UIKit)
import UIKit
typealias PlatformImage = UIImage
#endif

// MARK: - Image Helpers

#if canImport(AppKit)
func tiffData(_ image: NSImage) -> Data {
    guard let tiff = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let jpeg = bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.7]) else {
        return Data()
    }
    return jpeg
}
#endif

// MARK: - Social Feed View

struct SocialFeedView: View {
    @State private var posts: [SocialPost] = []
    @Binding var isPresented: Bool
    
    @State private var currentView: CurrentView = .main
    @State private var newPostContent = ""
    @State private var isPrivatePost = false
    @State private var selectedImages: [PlatformImage] = []
    @State private var hoveredPost: String?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    enum CurrentView {
        case main
        case createPost
    }
    
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
                case .createPost:
                    createPostView
                }
            }
        }
        .onAppear {
            loadFeed()
        }
    }
    
    // MARK: - Main View
    
    private var mainView: some View {
        VStack(spacing: 0) {
            headerBar
                .padding(.horizontal, GentleSpacing.xxl)
                .padding(.top, GentleSpacing.lg)
            
            postList
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
                Text("👥 社交动态")
                    .font(GentleFont.headline(20))
                    .foregroundColor(Gentle.Text.primary)
                Text("分享你的温柔时刻")
                    .font(GentleFont.caption(12))
                    .foregroundColor(Gentle.Text.tertiary)
            }
            
            Spacer()
            
            Button(action: { currentView = .createPost }) {
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
    
    private var postList: some View {
        ScrollView {
            LazyVStack(spacing: GentleSpacing.md) {
                if isLoading {
                    VStack(spacing: GentleSpacing.md) {
                        Spacer().frame(height: 60)
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("加载中...")
                            .font(GentleFont.caption(12))
                            .foregroundColor(Gentle.Text.tertiary)
                    }
                } else if let error = errorMessage {
                    errorStateView(message: error)
                } else if posts.isEmpty {
                    emptyStateView
                } else {
                    ForEach(posts) { post in
                        PostCard(post: post, isHovered: hoveredPost == post.id)
                            .onHover { hovering in withAnimation { hoveredPost = hovering ? post.id : nil } }
                    }
                }
            }
            .padding(.horizontal, GentleSpacing.xxl)
            .padding(.vertical, GentleSpacing.lg)
            .padding(.bottom, GentleSpacing.xxl)
        }
    }
    
    private func errorStateView(message: String) -> some View {
        VStack(spacing: GentleSpacing.xl) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Gentle.Primary.pink.opacity(0.1))
                    .frame(width: 140, height: 140)
                
                Image(systemName: "wifi.slash")
                    .font(.system(size: 48))
                    .foregroundColor(Gentle.Primary.pink)
            }
            
            VStack(spacing: GentleSpacing.xs) {
                Text("连接失败")
                    .font(GentleFont.body(16))
                    .foregroundColor(Gentle.Text.primary)
                
                Text(message)
                    .font(GentleFont.caption(12))
                    .foregroundColor(Gentle.Text.tertiary)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                loadFeed()
            } label: {
                HStack(spacing: GentleSpacing.sm) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 13))
                    Text("重试")
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
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
        }
        .padding(.top, GentleSpacing.xxl)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: GentleSpacing.xl) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Gentle.Primary.lavender.opacity(0.1))
                    .frame(width: 140, height: 140)
                
                Image(systemName: "person.2.fill")
                    .font(.system(size: 64))
                    .foregroundColor(Gentle.Primary.lavender)
            }
            
            VStack(spacing: GentleSpacing.xs) {
                Text("还没有社交动态")
                    .font(GentleFont.body(16))
                    .foregroundColor(Gentle.Text.primary)
                
                Text("发布你的第一条动态吧 ✨")
                    .font(GentleFont.caption(12))
                    .foregroundColor(Gentle.Text.tertiary)
            }
            
            Button { currentView = .createPost } label: {
                HStack(spacing: GentleSpacing.sm) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold))
                    Text("发布第一条动态")
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
    
    // MARK: - Create Post View
    
    private var createPostView: some View {
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
                
                Text("📝 发布动态")
                    .font(GentleFont.headline(18))
                    .foregroundColor(Gentle.Text.primary)
                
                Spacer()
                
                Button(action: createPost) {
                    Text("发布")
                        .font(GentleFont.caption(13))
                        .fontWeight(.semibold)
                        .foregroundColor(newPostContent.isEmpty ? Gentle.Text.tertiary : .white)
                        .padding(.horizontal, GentleSpacing.lg)
                        .padding(.vertical, GentleSpacing.sm)
                        .background(
                            Capsule()
                                .fill(newPostContent.isEmpty ? Gentle.Background.tertiary : Gentle.Primary.lavender)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(newPostContent.isEmpty)
            }
            .padding(.horizontal, GentleSpacing.xxl)
            .padding(.vertical, GentleSpacing.lg)
            
            ScrollView {
                VStack(spacing: GentleSpacing.xl) {
                    postInput
                    privacyToggle
                }
                .padding(.horizontal, GentleSpacing.xxl)
                .padding(.top, GentleSpacing.md)
            }
            
            Spacer()
        }
    }
    
    private var postInput: some View {
        VStack(alignment: .leading, spacing: GentleSpacing.md) {
            Text("分享你的温柔时刻")
                .font(GentleFont.caption(12))
                .fontWeight(.semibold)
                .foregroundColor(Gentle.Text.secondary)
            
            ZStack(alignment: .topLeading) {
                if newPostContent.isEmpty {
                    Text("分享你的心情或记录美好瞬间...")
                        .font(GentleFont.body(14))
                        .foregroundColor(Gentle.Text.tertiary)
                        .padding(GentleSpacing.lg)
                        .padding(.top, GentleSpacing.sm)
                }
                
                TextEditor(text: $newPostContent)
                    .font(GentleFont.body(15))
                    .foregroundColor(Gentle.Text.primary)
                    .scrollContentBackground(.hidden)
                    .frame(height: 120)
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
            
            // Image selection
            HStack(spacing: GentleSpacing.sm) {
                Button { selectImages() } label: {
                    HStack(spacing: GentleSpacing.xs) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 14))
                        Text("添加图片")
                            .font(GentleFont.caption(12))
                    }
                    .foregroundColor(Gentle.Primary.lavender)
                    .padding(.horizontal, GentleSpacing.md)
                    .padding(.vertical, GentleSpacing.sm)
                    .background(
                        Capsule()
                            .stroke(Gentle.Primary.lavender.opacity(0.4), lineWidth: 1.5)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                if !selectedImages.isEmpty {
                    Text("\(selectedImages.count) 张图片已选")
                        .font(GentleFont.caption(12))
                        .foregroundColor(Gentle.Text.secondary)
                }
                
                Spacer()
            }
        }
    }
    
    private var privacyToggle: some View {
        HStack {
            VStack(alignment: .leading, spacing: GentleSpacing.xs) {
                HStack(spacing: GentleSpacing.xs) {
                    Image(systemName: isPrivatePost ? "lock.fill" : "globe")
                        .font(.system(size: 13))
                        .foregroundColor(Gentle.Primary.lavender)
                    Text(isPrivatePost ? "私密发布" : "公开动态")
                        .font(GentleFont.caption(12))
                        .fontWeight(.semibold)
                        .foregroundColor(Gentle.Text.primary)
                }
                
                Text(isPrivatePost ? "仅自己可见" : "所有人可见")
                    .font(GentleFont.caption(11))
                    .foregroundColor(Gentle.Text.tertiary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isPrivatePost)
                .toggleStyle(SwitchToggleStyle(tint: Gentle.Primary.lavender))
        }
        .padding(GentleSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: GentleRadius.xl, style: .continuous)
                .fill(Color.white)
        )
    }
    
    private func loadFeed() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let feed = try await SocialService.shared.getSocialFeed()
                await MainActor.run {
                    self.posts = feed
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    private func createPost() {
        let content = newPostContent.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return }
        
        Task {
            do {
                let post = try await SocialService.shared.createPost(
                    content: content,
                    isPublic: !isPrivatePost
                )
                await MainActor.run {
                    self.posts.insert(post, at: 0)
                    self.newPostContent = ""
                    self.isPrivatePost = false
                    self.selectedImages = []
                    self.currentView = .main
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "发布失败: \(error.localizedDescription)"
                }
            }
        }
    }
    
    #if canImport(AppKit)
    private func selectImages() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.image]
        panel.begin { response in
            if response == .OK {
                for url in panel.urls {
                    if let image = NSImage(contentsOf: url) {
                        selectedImages.append(image)
                    }
                }
            }
        }
    }
    #else
    private func selectImages() {
        // iOS: image picker not implemented yet
    }
    #endif
}

// MARK: - Post Card

struct PostCard: View {
    let post: SocialPost
    var isHovered: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: GentleSpacing.md) {
            // Post header
            HStack {
                // Avatar
                ZStack {
                    Circle()
                        .fill(Gentle.Gradient.primaryButton)
                        .frame(width: 40, height: 40)
                    
                    Text(post.username.first?.uppercased() ?? "你")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.username)
                        .font(GentleFont.caption(13))
                        .fontWeight(.semibold)
                        .foregroundColor(Gentle.Text.primary)
                    
                    Text(getTimeAgo(from: post.createdAt ?? Date()))
                        .font(.system(size: 11))
                        .foregroundColor(Gentle.Text.tertiary)
                }
                
                Spacer()
                
                if !post.isPublic {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Gentle.Text.tertiary)
                }
            }
            
            // Post content
            Text(post.content)
                .font(GentleFont.body(15))
                .foregroundColor(Gentle.Text.primary)
                .lineSpacing(5)
            
            // Images
            if !post.imagesData.isEmpty {
                let images = post.imagesData.compactMap { PlatformImage(data: $0) }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: GentleSpacing.sm) {
                        ForEach(images.indices, id: \.self) { idx in
                            platformImage(images[idx])
                                .resizable()
                                .scaledToFill()
                                .frame(width: 160, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: GentleRadius.md, style: .continuous))
                        }
                    }
                }
            }
            
            // Focus record
            if post.pomodoroSession != nil {
                HStack(spacing: GentleSpacing.xs) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 13))
                        .foregroundColor(Gentle.Primary.lavender)
                    Text("今日专注: 24分钟")
                        .font(GentleFont.caption(12))
                        .foregroundColor(Gentle.Primary.lavender)
                }
                .padding(.horizontal, GentleSpacing.md)
                .padding(.vertical, GentleSpacing.sm)
                .background(
                    Capsule()
                        .fill(Gentle.Primary.lavender.opacity(0.1))
                )
            }
            
            // Post actions
            HStack(spacing: GentleSpacing.xl) {
                Button(action: {}) {
                    HStack(spacing: GentleSpacing.xs) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 15))
                        Text("\(post.likes)")
                            .font(GentleFont.caption(12))
                    }
                    .foregroundColor(post.isLiked ? Gentle.Primary.pink : Gentle.Text.tertiary)
                    .padding(.horizontal, GentleSpacing.md)
                    .padding(.vertical, GentleSpacing.xs)
                    .background(
                        Capsule()
                            .fill(post.isLiked ? Gentle.Primary.pink.opacity(0.1) : Gentle.Background.tertiary)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {}) {
                    HStack(spacing: GentleSpacing.xs) {
                        Image(systemName: "message")
                            .font(.system(size: 15))
                        Text("\(post.comments)")
                            .font(GentleFont.caption(12))
                    }
                    .foregroundColor(Gentle.Text.tertiary)
                    .padding(.horizontal, GentleSpacing.md)
                    .padding(.vertical, GentleSpacing.xs)
                    .background(
                        Capsule()
                            .fill(Gentle.Background.tertiary)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
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
    
    private func getTimeAgo(from date: Date) -> String {
        let now = Date()
        let components = Calendar.current.dateComponents([.minute, .hour, .day], from: date, to: now)
        
        if let minutes = components.minute, minutes < 60 {
            return "\(minutes)分钟前"
        } else if let hours = components.hour, hours < 24 {
            return "\(hours)小时前"
        } else if let days = components.day, days < 7 {
            return "\(days)天前"
        } else {
            return "很久前"
        }
    }
}

// MARK: - Cross-platform Image helper

func platformImage(_ image: PlatformImage) -> Image {
#if canImport(AppKit)
    Image(nsImage: image)
#else
    Image(uiImage: image)
#endif
}
