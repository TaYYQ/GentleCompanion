//
//  GentiOSSocialView.swift
//  GentleCompanion iOS
//
//  社区动态 — Liquid Glass 卡片流 + 发布器
//

import SwiftUI

// MARK: - Community Post Model

struct CommunityPost: Identifiable, Codable, Equatable {
    let id: UUID
    let authorName: String
    let content: String
    let emotion: String
    let timestamp: Date
    var likes: Int
    var isLiked: Bool
    let avatarSeed: String

    var timeAgo: String {
        let interval = Date().timeIntervalSince(timestamp)
        let m = Int(interval / 60), h = m / 60, d = h / 24
        if d > 0 { return "\(d)天前" }
        if h > 0 { return "\(h)小时前" }
        if m > 0 { return "\(m)分钟前" }
        return "刚刚"
    }
}

// MARK: - Community Manager

class CommunityManager: ObservableObject, @unchecked Sendable {
    static let shared = CommunityManager()
    @Published var posts: [CommunityPost] = []
    private let storageKey = "social_posts_v1"

    private init() {
        loadPosts()
        if posts.isEmpty { seedPosts() }
    }

    func addPost(content: String, emotion: String, author: String) {
        let post = CommunityPost(
            id: UUID(),
            authorName: author.isEmpty ? "温柔点用户" : author,
            content: content, emotion: emotion, timestamp: Date(),
            likes: 0, isLiked: false,
            avatarSeed: author.isEmpty ? UUID().uuidString : author
        )
        posts.insert(post, at: 0)
        savePosts()
    }

    func toggleLike(_ post: CommunityPost) {
        guard let idx = posts.firstIndex(where: { $0.id == post.id }) else { return }
        posts[idx].isLiked.toggle()
        posts[idx].likes += posts[idx].isLiked ? 1 : -1
        savePosts()
    }

    private func seedPosts() {
        let seeds: [(String, String, String)] = [
            ("今天完成了第一次冥想，感觉内心平静了很多 🧘", "平静", "小暖"),
            ("下雨天窝在家看书，泡了一杯热茶，这就是幸福吧 ☕📖", "开心", "茶茶"),
            ("有时候慢下来，才能听见自己内心的声音", "思考", "星空"),
            ("给妈妈打了一个小时电话，听她唠叨也很幸福", "感恩", "阳光"),
            ("加班到很晚，但同事送来了一杯咖啡，被治愈了", "感动", "夜猫"),
        ]
        for (content, emotion, author) in seeds {
            posts.append(CommunityPost(
                id: UUID(), authorName: author, content: content, emotion: emotion,
                timestamp: Date().addingTimeInterval(Double.random(in: -86400...0)),
                likes: Int.random(in: 3...42), isLiked: false, avatarSeed: author
            ))
        }
        posts.sort { $0.timestamp > $1.timestamp }
        savePosts()
    }

    private func savePosts() {
        if let data = try? JSONEncoder().encode(posts) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func loadPosts() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([CommunityPost].self, from: data) {
            posts = decoded
        }
    }
}

// MARK: - Social View

struct GentiOSSocialView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var community = CommunityManager.shared
    @StateObject private var account = AccountManager.shared
    @ObservedObject private var themeManager = GentleThemeManager.shared
    @State private var showComposer = false
    @State private var newContent = ""
    @State private var selectedEmotion = "平静"
    @State private var appear = false

    private let emotions = ["平静", "开心", "感动", "思考", "感恩", "期待"]

    var body: some View {
        ZStack {
            Gentle.Glass.darkBase.ignoresSafeArea()
            Gentle.Glass.ambientGlow(color: Color(hex: "#A78BFA"))
                .frame(width: 360, height: 360)
                .offset(y: -250)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    headerBar
                    LazyVStack(spacing: 14) {
                        ForEach(community.posts) { post in
                            postCard(post)
                                .opacity(appear ? 1 : 0)
                                .offset(y: appear ? 0 : 16)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    Spacer().frame(height: 8)
                }
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showComposer) { composerSheet }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { appear = true }
        }
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Gentle.Glass.textPrimary)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(.white.opacity(0.08))
                            .overlay(Circle().stroke(Gentle.Glass.borderWhite, lineWidth: 0.5))
                    )
            }
            .padding(.trailing, 6)

            VStack(alignment: .leading, spacing: 2) {
                Text("社区动态")
                    .font(.system(size: 28, weight: .thin, design: .serif))
                    .foregroundColor(Gentle.Glass.textPrimary)
                Text("发现身边的温柔时刻")
                    .font(.system(size: 13, weight: .light))
                    .foregroundColor(Gentle.Glass.textTertiary)
            }
            Spacer()
            Button { showComposer = true } label: {
                Label("分享", systemImage: "plus")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Gentle.Glass.textPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "#A78BFA").opacity(0.25), Color(hex: "#7C3AED").opacity(0.15)],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                    )
                    .overlay {
                        Capsule()
                            .stroke(Gentle.Glass.borderHighlight, lineWidth: 0.5)
                    }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    // MARK: - Post Card

    private func postCard(_ post: CommunityPost) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#A78BFA").opacity(0.4), Color(hex: "#EC4899").opacity(0.2)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 34, height: 34)
                        .overlay { Circle().stroke(Gentle.Glass.borderWhite, lineWidth: 0.5) }
                    Text(String(post.authorName.prefix(1)))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Gentle.Glass.textPrimary)
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text(post.authorName)
                        .font(.system(size: 13, weight: .medium)).foregroundColor(Gentle.Glass.textPrimary)
                    Text(post.timeAgo)
                        .font(.system(size: 11)).foregroundColor(Gentle.Glass.textTertiary)
                }
                Spacer()
                Text(post.emotion)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color(hex: "#A78BFA"))
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(Color(hex: "#A78BFA").opacity(0.1))
                            .overlay(Capsule().stroke(Color(hex: "#A78BFA").opacity(0.2), lineWidth: 0.5))
                    )
            }
            Text(post.content)
                .font(.system(size: 14, weight: .light, design: .rounded))
                .foregroundColor(Gentle.Glass.textPrimary)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        community.toggleLike(post)
                    }
                } label: {
                    Label("\(post.likes)", systemImage: post.isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 12))
                        .foregroundColor(post.isLiked ? Color(hex: "#F472B6") : Gentle.Glass.textTertiary)
                }
                Spacer()
            }
        }
        .padding(16)
        .liquidGlassCard(cornerRadius: GentleRadius.xl, opacity: 0.5)
    }

    // MARK: - Composer

    private var composerSheet: some View {
        NavigationStack {
            ZStack {
                Gentle.Glass.darkBase.ignoresSafeArea()

                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("此刻心情").font(.system(size: 12)).foregroundColor(Gentle.Glass.textTertiary)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(emotions, id: \.self) { e in
                                    Button {
                                        withAnimation(.spring(response: 0.3)) { selectedEmotion = e }
                                    } label: {
                                        Text(e)
                                            .font(.system(size: 12, weight: selectedEmotion == e ? .semibold : .regular))
                                            .foregroundColor(selectedEmotion == e ? Gentle.Glass.textPrimary : Gentle.Glass.textTertiary)
                                            .padding(.horizontal, 12).padding(.vertical, 6)
                                            .background(
                                                Capsule()
                                                    .fill(selectedEmotion == e ? Color(hex: "#A78BFA").opacity(0.2) : .white.opacity(0.05))
                                                    .overlay(
                                                        Capsule()
                                                            .stroke(
                                                                selectedEmotion == e ? Color(hex: "#A78BFA").opacity(0.3) : Gentle.Glass.borderWhite,
                                                                lineWidth: 0.5
                                                            )
                                                    )
                                            )
                                    }
                                }
                            }
                        }
                    }

                    TextEditor(text: $newContent)
                        .font(.system(size: 15, weight: .light, design: .rounded))
                        .foregroundColor(Gentle.Glass.textPrimary)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 140)
                        .padding(14)
                        .liquidGlassCard(cornerRadius: GentleRadius.lg, opacity: 0.4)
                        .overlay(alignment: .topLeading) {
                            if newContent.isEmpty {
                                Text("分享你的温柔时刻...")
                                    .font(.system(size: 15, weight: .light))
                                    .foregroundColor(Gentle.Glass.textTertiary)
                                    .padding(.horizontal, 18).padding(.vertical, 20)
                                    .allowsHitTesting(false)
                            }
                        }

                    Spacer()

                    Button {
                        let author = account.currentAccount?.username ?? ""
                        community.addPost(content: newContent, emotion: selectedEmotion, author: author)
                        newContent = ""
                        showComposer = false
                    } label: {
                        Label("分享温柔", systemImage: "sparkles")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Gentle.Glass.textPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: newContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                                ? [Color(hex: "#A78BFA").opacity(0.2), Color(hex: "#7C3AED").opacity(0.15)]
                                                : [Color(hex: "#A78BFA"), Color(hex: "#EC4899")],
                                            startPoint: .leading, endPoint: .trailing
                                        )
                                    )
                            }
                            .shadow(
                                color: Color(hex: "#A78BFA").opacity(
                                    newContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0 : 0.35
                                ),
                                radius: 14, x: 0, y: 7
                            )
                    }
                    .disabled(newContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .navigationTitle("分享温柔")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("取消") { showComposer = false }.foregroundColor(Color(hex: "#A78BFA"))
                }
            }
        }
    }
}
