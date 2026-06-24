//
//  GentleWall.swift
//  GentleCompanion
//
//  匿名温柔墙 - 数据模型与本地存储
//

import Foundation
import SwiftUI

// MARK: - 温柔墙消息

struct GentleWallMessage: Identifiable, Codable, Equatable {
    let id: UUID
    let content: String
    let timestamp: Date
    let emotion: String  // 情绪标签
    let isAnonymous: Bool
    var likes: Int
    
    init(id: UUID = UUID(), content: String, emotion: String, isAnonymous: Bool = true, likes: Int = 0) {
        self.id = id
        self.content = content
        self.timestamp = Date()
        self.emotion = emotion
        self.isAnonymous = isAnonymous
        self.likes = likes
    }
    
    // 格式化时间显示
    var timeAgo: String {
        let interval = Date().timeIntervalSince(timestamp)
        let minutes = Int(interval / 60)
        let hours = minutes / 60
        let days = hours / 24
        
        if days > 0 {
            return "\(days)天前"
        } else if hours > 0 {
            return "\(hours)小时前"
        } else if minutes > 0 {
            return "\(minutes)分钟前"
        } else {
            return "刚刚"
        }
    }
}

// MARK: - 温柔墙管理器

class GentleWallManager: ObservableObject, @unchecked Sendable {
    static let shared = GentleWallManager()
    
    @Published var messages: [GentleWallMessage] = []
    
    private let storageKey = "gentle_wall_messages"
    private let maxMessages = 100  // 最多保存100条消息
    
    private init() {
        loadMessages()
    }
    
    // MARK: - 公开方法
    
    /// 发布新消息
    func postMessage(content: String, emotion: String) {
        let message = GentleWallMessage(content: content, emotion: emotion, isAnonymous: true)
        messages.insert(message, at: 0)  // 最新消息在最前面
        
        // 限制消息数量
        if messages.count > maxMessages {
            messages = Array(messages.prefix(maxMessages))
        }
        
        saveMessages()
    }
    
    /// 点赞消息
    func likeMessage(_ message: GentleWallMessage) {
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            messages[index].likes += 1
            saveMessages()
        }
    }
    
    /// 删除消息
    func deleteMessage(_ message: GentleWallMessage) {
        messages.removeAll { $0.id == message.id }
        saveMessages()
    }
    
    /// 按情绪筛选
    func filterByEmotion(_ emotion: String?) -> [GentleWallMessage] {
        guard let emotion = emotion else { return messages }
        return messages.filter { $0.emotion == emotion }
    }
    
    /// 清空所有消息
    func clearAllMessages() {
        messages.removeAll()
        saveMessages()
    }
    
    // MARK: - 持久化
    
    private func saveMessages() {
        if let encoded = try? JSONEncoder().encode(messages) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    private func loadMessages() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([GentleWallMessage].self, from: data) {
            messages = decoded
        }
    }
}
