//
//  GentiOSMessageView.swift
//  GentleCompanion iOS
//
//  悄悄话 — 微信风格私信聊天
//

import SwiftUI

// MARK: - Local Message Store (离线可用)

private struct LocalMessage: Codable, Identifiable {
    let id: String
    let conversationId: String
    let senderId: String
    let receiverId: String
    let content: String
    let createdAt: Date
    var isRead: Bool
}

private struct LocalConversation: Codable, Identifiable, Equatable {
    let id: String
    let otherUserId: String
    let otherUserName: String
    var lastMessage: String
    var lastMessageTime: Date
    var unreadCount: Int
}

@MainActor
private class LocalMessageStore: ObservableObject {
    static let shared = LocalMessageStore()

    @Published var conversations: [LocalConversation] = []
    @Published var messagesByConv: [String: [LocalMessage]] = [:]

    private let convKey = "gentle_whisper_conversations"
    private let msgPrefix = "gentle_whisper_msgs_"

    private init() { load() }

    func load() {
        if let d = UserDefaults.standard.data(forKey: convKey),
           let c = try? JSONDecoder().decode([LocalConversation].self, from: d) {
            conversations = c
        }
        for conv in conversations {
            if let d = UserDefaults.standard.data(forKey: msgPrefix + conv.id),
               let m = try? JSONDecoder().decode([LocalMessage].self, from: d) {
                messagesByConv[conv.id] = m
            }
        }
    }

    private func save() {
        if let d = try? JSONEncoder().encode(conversations) {
            UserDefaults.standard.set(d, forKey: convKey)
        }
    }

    private func saveMessages(for convId: String) {
        if let msgs = messagesByConv[convId],
           let d = try? JSONEncoder().encode(msgs) {
            UserDefaults.standard.set(d, forKey: msgPrefix + convId)
        }
    }

    func getOrCreateConversation(otherUserId: String, otherUserName: String) -> LocalConversation {
        if let existing = conversations.first(where: { $0.otherUserId == otherUserId }) {
            return existing
        }
        let newConv = LocalConversation(
            id: UUID().uuidString,
            otherUserId: otherUserId,
            otherUserName: otherUserName,
            lastMessage: "",
            lastMessageTime: Date(),
            unreadCount: 0
        )
        conversations.insert(newConv, at: 0)
        save()
        return newConv
    }

    func getMessages(for convId: String) -> [LocalMessage] {
        messagesByConv[convId] ?? []
    }

    func sendMessage(convId: String, senderId: String, receiverId: String, content: String) -> LocalMessage {
        let msg = LocalMessage(
            id: UUID().uuidString,
            conversationId: convId,
            senderId: senderId,
            receiverId: receiverId,
            content: content,
            createdAt: Date(),
            isRead: false
        )
        messagesByConv[convId, default: []].append(msg)
        saveMessages(for: convId)

        if let idx = conversations.firstIndex(where: { $0.id == convId }) {
            conversations[idx].lastMessage = content
            conversations[idx].lastMessageTime = Date()
            conversations[idx].unreadCount += (senderId == AccountManager.shared.currentAccount?.id.uuidString ? 0 : 1)
            conversations.move(fromOffsets: IndexSet(integer: idx), toOffset: 0)
            save()
        }
        return msg
    }

    func markAsRead(convId: String) {
        guard let idx = conversations.firstIndex(where: { $0.id == convId }) else { return }
        conversations[idx].unreadCount = 0
        save()
        if var msgs = messagesByConv[convId] {
            for i in msgs.indices { msgs[i].isRead = true }
            messagesByConv[convId] = msgs
            saveMessages(for: convId)
        }
    }
}

// MARK: - Message View

struct GentiOSMessageView: View {
    @StateObject private var store = LocalMessageStore.shared
    @StateObject private var account = AccountManager.shared
    @ObservedObject private var theme = GentleThemeManager.shared
    @StateObject private var appState = GentleAppState.shared
    @State private var selectedConversation: LocalConversation?
    @State private var showNewChat = false
    @State private var appear = false

    var body: some View {
        ZStack {
            Gentle.Glass.darkBase.ignoresSafeArea()

            if let conv = selectedConversation {
                ChatDetailView(
                    conversation: conv,
                    store: store,
                    account: account,
                    onBack: { withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        selectedConversation = nil
                    }}
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                conversationsList
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            store.load()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { appear = true }
        }
        .onChange(of: selectedConversation) { _, new in
            appState.hideTabBar = new != nil
        }
        .sheet(isPresented: $showNewChat) {
            NewChatSheet(store: store, account: account) { conv in
                showNewChat = false
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    selectedConversation = conv
                }
            }
        }
    }

    // MARK: - Conversations List

    private var conversationsList: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("悄悄话")
                    .font(.system(size: 28, weight: .thin, design: .serif))
                    .foregroundColor(Gentle.Glass.textPrimary)
                Spacer()
                if account.isLoggedIn {
                    Button {
                        showNewChat = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 18, weight: .light))
                            .foregroundColor(Gentle.Primary.lavender)
                            .frame(width: 38, height: 38)
                            .background(
                                Circle().fill(Gentle.Primary.lavender.opacity(0.12))
                            )
                            .overlay(Circle().stroke(Gentle.Glass.borderWhite, lineWidth: 0.5))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 16)

            if !account.isLoggedIn {
                emptyLoginView
            } else if store.conversations.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 2) {
                        ForEach(store.conversations) { conv in
                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    selectedConversation = conv
                                    store.markAsRead(convId: conv.id)
                                }
                            } label: {
                                conversationRow(conv)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .scrollIndicators(.hidden)
            }
        }
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 20)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 80)
            Text("💌").font(.system(size: 52)).opacity(0.5)
            Text("还没有悄悄话")
                .font(.system(size: 17, weight: .light, design: .serif))
                .foregroundColor(Gentle.Glass.textSecondary)
            Text("点击右上角笔图标\n给好友发送一条温暖的消息")
                .font(.system(size: 13, weight: .light))
                .foregroundColor(Gentle.Glass.textTertiary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var emptyLoginView: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 80)
            Text("🔒").font(.system(size: 48)).opacity(0.4)
            Text("登录后使用悄悄话")
                .font(.system(size: 17, weight: .light, design: .serif))
                .foregroundColor(Gentle.Glass.textSecondary)
            Text("与好友分享温柔时刻")
                .font(.system(size: 13, weight: .light))
                .foregroundColor(Gentle.Glass.textTertiary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private func conversationRow(_ conv: LocalConversation) -> some View {
        HStack(spacing: 12) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#A78BFA").opacity(0.3), Color(hex: "#EC4899").opacity(0.2)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                Text(String(conv.otherUserName.prefix(1)).uppercased())
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Gentle.Glass.textPrimary)
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(conv.otherUserName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Gentle.Glass.textPrimary)
                    Spacer()
                    Text(formatConversationTime(conv.lastMessageTime))
                        .font(.system(size: 11, weight: .light))
                        .foregroundColor(Gentle.Glass.textTertiary)
                }

                HStack {
                    Text(conv.lastMessage.isEmpty ? "暂无消息" : conv.lastMessage)
                        .font(.system(size: 13, weight: .light))
                        .foregroundColor(Gentle.Glass.textSecondary)
                        .lineLimit(1)
                    Spacer()
                    if conv.unreadCount > 0 {
                        Text("\(conv.unreadCount)")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(
                                Capsule().fill(Color(hex: "#EF4444"))
                            )
                    }
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 4)
    }

    private func formatConversationTime(_ date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date) {
            let f = DateFormatter(); f.dateFormat = "HH:mm"; return f.string(from: date)
        } else if cal.isDateInYesterday(date) {
            return "昨天"
        } else if cal.isDate(date, equalTo: Date(), toGranularity: .year) {
            let f = DateFormatter(); f.dateFormat = "M月d日"; return f.string(from: date)
        } else {
            let f = DateFormatter(); f.dateFormat = "yyyy/M/d"; return f.string(from: date)
        }
    }
}

// MARK: - Chat Detail View

private struct ChatDetailView: View {
    let conversation: LocalConversation
    @ObservedObject var store: LocalMessageStore
    @ObservedObject var account: AccountManager
    let onBack: () -> Void

    @State private var messageText = ""
    @State private var messages: [LocalMessage] = []
    @FocusState private var isInputFocused: Bool

    private let myId: String

    init(conversation: LocalConversation, store: LocalMessageStore, account: AccountManager, onBack: @escaping () -> Void) {
        self.conversation = conversation
        self.store = store
        self.account = account
        self.onBack = onBack
        self.myId = account.currentAccount?.id.uuidString ?? ""
    }

    var body: some View {
        VStack(spacing: 0) {
            // Nav bar
            HStack(spacing: 12) {
                Button { onBack() } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                        Text("返回")
                            .font(.system(size: 15))
                    }
                    .foregroundColor(Gentle.Primary.lavender)
                }

                Spacer()

                VStack(spacing: 2) {
                    Text(conversation.otherUserName)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(Gentle.Glass.textPrimary)
                }

                Spacer()
                Spacer().frame(width: 60) // balance
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Gentle.Glass.darkBaseCard.opacity(0.6))

            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(messages) { msg in
                            messageBubble(msg)
                                .id(msg.id)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
                .scrollIndicators(.hidden)
                .onAppear {
                    messages = store.getMessages(for: conversation.id)
                    if let last = messages.last {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                        }
                    }
                }
                .onChange(of: messages.count) { _, _ in
                    if let last = messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }

            // Input bar
            inputBar
        }
        .background(Gentle.Glass.darkBase)
    }

    // MARK: - Message Bubble

    @ViewBuilder
    private func messageBubble(_ msg: LocalMessage) -> some View {
        let isMine = msg.senderId == myId

        HStack(alignment: .bottom, spacing: 8) {
            if isMine { Spacer(minLength: 60) }

            if !isMine {
                // Other's avatar
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color(hex: "#A78BFA").opacity(0.25), Color(hex: "#EC4899").opacity(0.15)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                        .frame(width: 32, height: 32)
                    Text(String(conversation.otherUserName.prefix(1)).uppercased())
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Gentle.Glass.textPrimary)
                }
            }

            VStack(alignment: isMine ? .trailing : .leading, spacing: 2) {
                Text(msg.content)
                    .font(.system(size: 15, weight: .light))
                    .foregroundColor(isMine ? .white : Gentle.Glass.textPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(isMine
                            ? AnyShapeStyle(LinearGradient(
                                colors: [Color(hex: "#8B5CF6"), Color(hex: "#A855F7")],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ))
                            : AnyShapeStyle(Gentle.Glass.darkBaseCard.opacity(0.7))
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(isMine ? Color.clear : Gentle.Glass.borderWhite, lineWidth: 0.5)
                    )

                Text(formatMsgTime(msg.createdAt))
                    .font(.system(size: 10, weight: .light))
                    .foregroundColor(Gentle.Glass.textTertiary)
                    .padding(.horizontal, 4)
                    .padding(.top, 2)
            }

            if !isMine { Spacer(minLength: 60) }

            if isMine {
                // My avatar
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color(hex: "#A855F7").opacity(0.3), Color(hex: "#EC4899").opacity(0.25)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                        .frame(width: 32, height: 32)
                    avatarDisplayView(account.currentAccount?.avatar ?? "🌸", size: 13)
                }
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Input Bar

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField("输入消息...", text: $messageText, axis: .vertical)
                .font(.system(size: 15))
                .foregroundColor(Gentle.Glass.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Gentle.Glass.darkBaseCard.opacity(0.6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Gentle.Glass.borderWhite, lineWidth: 0.5)
                )
                .focused($isInputFocused)
                .lineLimit(1...4)

            if !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Button {
                    send()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(Gentle.Primary.lavender)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Gentle.Glass.darkBaseCard.opacity(0.5))
        .overlay(alignment: .top) {
            Rectangle().fill(Gentle.Glass.borderWhite).frame(height: 0.5)
        }
    }

    private func send() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        messageText = ""

        let newMsg = store.sendMessage(
            convId: conversation.id,
            senderId: myId,
            receiverId: conversation.otherUserId,
            content: text
        )
        messages.append(newMsg)

        // Also try remote
        Task {
            _ = try? await SocialService.shared.sendMessage(
                toUserId: conversation.otherUserId,
                content: text
            )
        }
    }

    private func formatMsgTime(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "HH:mm"; return f.string(from: date)
    }
}

// MARK: - New Chat Sheet

private struct NewChatSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: LocalMessageStore
    @ObservedObject var account: AccountManager
    let onCreated: (LocalConversation) -> Void

    @State private var userId = ""
    @State private var userName = ""
    @State private var firstMessage = ""
    @FocusState private var focusField: FocusField?

    enum FocusField { case userId, userName, message }

    var body: some View {
        ZStack {
            Gentle.Glass.darkBase.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("取消") { dismiss() }
                        .font(.system(size: 15))
                        .foregroundColor(Gentle.Glass.textSecondary)
                    Spacer()
                    Text("新悄悄话")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(Gentle.Glass.textPrimary)
                    Spacer()
                    Button("开始") { createConversation() }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(isValid ? Gentle.Primary.lavender : Gentle.Glass.textTertiary)
                        .disabled(!isValid)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("对方用户ID")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Gentle.Glass.textTertiary)
                        TextField("输入对方ID", text: $userId)
                            .font(.system(size: 15))
                            .foregroundColor(Gentle.Glass.textPrimary)
                            .padding(.horizontal, 14).padding(.vertical, 12)
                            .liquidGlassCard(cornerRadius: 14, opacity: 0.35)
                            .focused($focusField, equals: .userId)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("对方昵称")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Gentle.Glass.textTertiary)
                        TextField("给对方起个名字", text: $userName)
                            .font(.system(size: 15))
                            .foregroundColor(Gentle.Glass.textPrimary)
                            .padding(.horizontal, 14).padding(.vertical, 12)
                            .liquidGlassCard(cornerRadius: 14, opacity: 0.35)
                            .focused($focusField, equals: .userName)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("第一条悄悄话")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Gentle.Glass.textTertiary)
                        TextField("说点什么吧...", text: $firstMessage, axis: .vertical)
                            .font(.system(size: 15))
                            .foregroundColor(Gentle.Glass.textPrimary)
                            .padding(.horizontal, 14).padding(.vertical, 12)
                            .liquidGlassCard(cornerRadius: 14, opacity: 0.35)
                            .focused($focusField, equals: .message)
                            .lineLimit(3...6)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                Spacer()
            }
        }
        .onAppear { focusField = .userName }
    }

    private var isValid: Bool {
        !userId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func createConversation() {
        let uid = userId.trimmingCharacters(in: .whitespacesAndNewlines)
        let name = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        let msg = firstMessage.trimmingCharacters(in: .whitespacesAndNewlines)

        let conv = store.getOrCreateConversation(otherUserId: uid, otherUserName: name)

        if !msg.isEmpty, let myId = account.currentAccount?.id.uuidString {
            _ = store.sendMessage(convId: conv.id, senderId: myId, receiverId: uid, content: msg)
        }

        onCreated(conv)
    }
}
