//
//  SocialService.swift
//  GentleCompanion
//
//  Social service for handling social features
//

import Foundation

class SocialService: @unchecked Sendable {
    static let shared = SocialService()
    
    private let networkService = NetworkService.shared
    
    private init() {}
    
    // MARK: - User Relationships
    
    func followUser(userId: String) async throws -> Bool {
        struct FollowResponse: Decodable {
            let success: Bool
            let message: String
        }
        
        let response: APIResponse<FollowResponse> = try await networkService.request(
            endpoint: "/api/social/follow/\(userId)",
            method: .post
        )
        
        return response.data?.success ?? false
    }
    
    func unfollowUser(userId: String) async throws -> Bool {
        struct UnfollowResponse: Decodable {
            let success: Bool
            let message: String
        }
        
        let response: APIResponse<UnfollowResponse> = try await networkService.request(
            endpoint: "/api/social/unfollow/\(userId)",
            method: .post
        )
        
        return response.data?.success ?? false
    }
    
    func getFollowers() async throws -> [UserProfile] {
        let response: APIResponse<[UserProfile]> = try await networkService.request(
            endpoint: "/api/social/followers"
        )
        
        return response.data ?? []
    }
    
    func getFollowing() async throws -> [UserProfile] {
        let response: APIResponse<[UserProfile]> = try await networkService.request(
            endpoint: "/api/social/following"
        )
        
        return response.data ?? []
    }
    
    // MARK: - Social Feed
    
    func getSocialFeed(page: Int = 1, limit: Int = 20) async throws -> [SocialPost] {
        let response: APIResponse<[SocialPost]> = try await networkService.request(
            endpoint: "/api/social/feed?page=\(page)&limit=\(limit)"
        )
        
        return response.data ?? []
    }
    
    func createPost(content: String, isPublic: Bool = true) async throws -> SocialPost {
        struct APIError: Swift.Error, LocalizedError {
            let message: String
            var errorDescription: String? { message }
        }
        
        struct CreatePostRequest: Encodable {
            let content: String
            let isPublic: Bool
        }
        
        let request = CreatePostRequest(content: content, isPublic: isPublic)
        let response: APIResponse<SocialPost> = try await networkService.request(
            endpoint: "/api/social/posts",
            method: .post,
            body: request
        )
        
        guard let data = response.data else {
            throw APIError(message: "发布失败: \(response.message)")
        }
        return data
    }
    
    // MARK: - Pomodoro Sharing
    
    func sharePomodoro(session: PomodoroSessionDTO, message: String? = nil) async throws -> Bool {
        struct SharePomodoroRequest: Encodable {
            let session: PomodoroSessionDTO
            let message: String?
        }
        
        let request = SharePomodoroRequest(session: session, message: message)
        let response: APIResponse<Bool> = try await networkService.request(
            endpoint: "/api/social/share-pomodoro",
            method: .post,
            body: request
        )
        
        return response.data ?? false
    }
    
    // MARK: - Leaderboards
    
    func getLeaderboard(category: LeaderboardCategory, period: LeaderboardPeriod) async throws -> [LeaderboardEntry] {
        let response: APIResponse<[LeaderboardEntry]> = try await networkService.request(
            endpoint: "/api/social/leaderboard?category=\(category.rawValue)&period=\(period.rawValue)"
        )
        
        return response.data ?? []
    }
    
    // MARK: - Friend Requests
    
    func sendFriendRequest(userId: String) async throws -> Bool {
        struct SendFriendRequestResponse: Decodable {
            let success: Bool
            let message: String
        }
        
        let response: APIResponse<SendFriendRequestResponse> = try await networkService.request(
            endpoint: "/api/social/friend-requests",
            method: .post,
            body: ["userId": userId]
        )
        
        return response.data?.success ?? false
    }
    
    func getFriendRequests() async throws -> [FriendRequest] {
        let response: APIResponse<[FriendRequest]> = try await networkService.request(
            endpoint: "/api/social/friend-requests"
        )
        
        return response.data ?? []
    }
    
    func respondToFriendRequest(requestId: String, accept: Bool) async throws -> Bool {
        struct RespondFriendRequestResponse: Decodable {
            let success: Bool
            let message: String
        }
        
        let response: APIResponse<RespondFriendRequestResponse> = try await networkService.request(
            endpoint: "/api/social/friend-requests/\(requestId)/respond",
            method: .post,
            body: ["accept": accept]
        )
        
        return response.data?.success ?? false
    }
    
    func getFriends() async throws -> [Friend] {
        let response: APIResponse<[Friend]> = try await networkService.request(
            endpoint: "/api/social/friends"
        )
        
        return response.data ?? []
    }
    
    func removeFriend(userId: String) async throws -> Bool {
        struct RemoveFriendResponse: Decodable {
            let success: Bool
            let message: String
        }
        
        let response: APIResponse<RemoveFriendResponse> = try await networkService.request(
            endpoint: "/api/social/friends/\(userId)",
            method: .delete
        )
        
        return response.data?.success ?? false
    }
    
    // MARK: - Messages
    
    func getConversations() async throws -> [Conversation] {
        let response: APIResponse<[Conversation]> = try await networkService.request(
            endpoint: "/api/social/conversations"
        )
        
        return response.data ?? []
    }
    
    func getMessages(conversationId: String, page: Int = 1, limit: Int = 50) async throws -> [Message] {
        let response: APIResponse<[Message]> = try await networkService.request(
            endpoint: "/api/social/conversations/\(conversationId)/messages?page=\(page)&limit=\(limit)"
        )
        
        return response.data ?? []
    }
    
    func sendMessage(toUserId: String, content: String) async throws -> Message {
        struct APIError: Swift.Error, LocalizedError {
            let message: String
            var errorDescription: String? { message }
        }
        
        struct SendMessageRequest: Encodable {
            let toUserId: String
            let content: String
        }
        
        let request = SendMessageRequest(toUserId: toUserId, content: content)
        let response: APIResponse<Message> = try await networkService.request(
            endpoint: "/api/social/messages",
            method: .post,
            body: request
        )
        
        guard let data = response.data else {
            throw APIError(message: "发送失败: \(response.message)")
        }
        return data
    }
    
    func markMessagesAsRead(conversationId: String) async throws -> Bool {
        struct MarkReadResponse: Decodable {
            let success: Bool
        }
        
        let response: APIResponse<MarkReadResponse> = try await networkService.request(
            endpoint: "/api/social/conversations/\(conversationId)/mark-read",
            method: .post
        )
        
        return response.data?.success ?? false
    }
}

// MARK: - Social Models

struct SocialPost: Codable, Identifiable {
    let id: String
    let userId: String
    let username: String
    let content: String
    let createdAt: Date?
    let isPublic: Bool
    var likes: Int
    let comments: Int
    var isLiked: Bool
    var imagesData: [Data]
    let pomodoroSession: PomodoroSessionDTO?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let intId = try? container.decode(Int.self, forKey: .id) {
            self.id = String(intId)
        } else {
            self.id = try container.decode(String.self, forKey: .id)
        }
        
        if let intUserId = try? container.decode(Int.self, forKey: .userId) {
            self.userId = String(intUserId)
        } else {
            self.userId = try container.decode(String.self, forKey: .userId)
        }
        
        self.username = try container.decode(String.self, forKey: .username)
        self.content = try container.decode(String.self, forKey: .content)
        
        if let dateString = try? container.decode(String.self, forKey: .createdAt) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            self.createdAt = formatter.date(from: dateString)
        } else {
            self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        }
        
        self.isPublic = try container.decodeIfPresent(Bool.self, forKey: .isPublic) ?? true
        self.likes = try container.decodeIfPresent(Int.self, forKey: .likes) ?? 0
        self.comments = try container.decodeIfPresent(Int.self, forKey: .comments) ?? 0
        self.isLiked = try container.decodeIfPresent(Bool.self, forKey: .isLiked) ?? false
        self.imagesData = try container.decodeIfPresent([Data].self, forKey: .imagesData) ?? []
        self.pomodoroSession = try container.decodeIfPresent(PomodoroSessionDTO.self, forKey: .pomodoroSession)
    }
    
    init(id: String, userId: String, username: String, content: String, createdAt: Date?, isPublic: Bool, likes: Int, comments: Int, isLiked: Bool, imagesData: [Data], pomodoroSession: PomodoroSessionDTO?) {
        self.id = id
        self.userId = userId
        self.username = username
        self.content = content
        self.createdAt = createdAt
        self.isPublic = isPublic
        self.likes = likes
        self.comments = comments
        self.isLiked = isLiked
        self.imagesData = imagesData
        self.pomodoroSession = pomodoroSession
    }
}

struct LeaderboardEntry: Codable, Identifiable {
    let id: String
    let userId: String
    let username: String
    let score: Int
    let rank: Int
    let streakDays: Int
    let totalPomodoros: Int
    let totalMinutes: Int
}

enum LeaderboardCategory: String {
    case streak = "streak"
    case totalPomodoros = "total_pomodoros"
    case totalMinutes = "total_minutes"
    case focusScore = "focus_score"
}

enum LeaderboardPeriod: String {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    case allTime = "all_time"
}

struct Comment: Codable, Identifiable {
    let id: String
    let postId: String
    let userId: String
    let username: String
    let content: String
    let createdAt: Date
}

struct Like: Codable {
    let postId: String
    let userId: String
    let createdAt: Date
}

// MARK: - Friend Models

struct FriendRequest: Codable, Identifiable {
    let id: String
    let senderId: String
    let senderUsername: String
    let receiverId: String
    let createdAt: Date
    let status: FriendRequestStatus
}

enum FriendRequestStatus: String, Codable {
    case pending = "pending"
    case accepted = "accepted"
    case rejected = "rejected"
}

struct Friend: Codable, Identifiable {
    let id: String
    let userId: String
    let username: String
    let avatar: String?
    let lastSeen: Date?
    let mutualFriends: Int
}

// MARK: - Message Models

struct Message: Codable, Identifiable {
    let id: String
    let conversationId: String
    let senderId: String
    let receiverId: String
    let content: String
    let createdAt: Date
    var isRead: Bool
}

struct Conversation: Codable, Identifiable {
    let id: String
    let participants: [String]
    let lastMessage: Message?
    let unreadCount: Int
    let updatedAt: Date
}
