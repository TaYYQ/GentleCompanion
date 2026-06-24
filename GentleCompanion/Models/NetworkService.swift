//
//  NetworkService.swift
//  GentleCompanion
//
//  Network service for handling API requests
//

import Foundation

class NetworkService: @unchecked Sendable {
    static let shared = NetworkService()
    
    private let session: URLSession
    private let baseURL: String
    
    // JWT token 存储
    private let tokenKey = "gentle_auth_token_v1"
    private(set) var authToken: String?
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        session = URLSession(configuration: configuration)
        // 修改为你自己的服务器地址
        baseURL = "http://YOUR_SERVER_IP:80"
        // 从 Keychain/UserDefaults 恢复 token
        authToken = UserDefaults.standard.string(forKey: tokenKey)
    }
    
    /// 保存 token（登录/注册成功后调用）
    func saveToken(_ token: String) {
        authToken = token
        UserDefaults.standard.set(token, forKey: tokenKey)
    }
    
    /// 清除 token（退出登录时调用）
    func clearToken() {
        authToken = nil
        UserDefaults.standard.removeObject(forKey: tokenKey)
    }
    
    enum NetworkError: Error {
        case invalidURL
        case requestFailed(Error)
        case invalidResponse
        case decodingFailed(Error)
        case serverError(Int, String)
    }
    
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get,
        headers: [String: String]? = nil,
        body: Encodable? = nil
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // 自动附带 JWT token（如果有的话）
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add custom headers
        if let headers = headers {
            headers.forEach { key, value in
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Add body if provided
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                throw NetworkError.decodingFailed(error)
            }
        }
        
        // Perform request
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            if (200...299).contains(httpResponse.statusCode) {
                do {
                    let decoder = JSONDecoder()
                    // Support ISO8601 with/without fractional seconds
                    decoder.dateDecodingStrategy = .custom { decoder in
                        let container = try decoder.singleValueContainer()
                        let dateString = try container.decode(String.self)
                        // Try with fractional seconds first
                        let formatterWithFrac = ISO8601DateFormatter()
                        formatterWithFrac.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                        if let date = formatterWithFrac.date(from: dateString) {
                            return date
                        }
                        // Try without fractional seconds
                        let formatter = ISO8601DateFormatter()
                        formatter.formatOptions = [.withInternetDateTime]
                        if let date = formatter.date(from: dateString) {
                            return date
                        }
                        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(dateString)")
                    }
                    return try decoder.decode(T.self, from: data)
                } catch {
                    throw NetworkError.decodingFailed(error)
                }
            } else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw NetworkError.serverError(httpResponse.statusCode, errorMessage)
            }
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    // MARK: - Auth Methods
    
    func login(email: String, password: String) async throws -> APIResponse<UserProfile> {
        struct LoginRequest: Encodable {
            let email: String
            let password: String
        }
        
        let loginRequest = LoginRequest(email: email, password: password)
        
        let response: APIResponse<UserProfile> = try await self.request(
            endpoint: "/api/auth/login",
            method: .post,
            body: loginRequest
        )
        // 保存服务器返回的 token
        if let token = response.data?.token {
            saveToken(token)
        }
        return response
    }
    
    func register(username: String, email: String, password: String) async throws -> APIResponse<UserProfile> {
        struct RegisterRequest: Encodable {
            let username: String
            let email: String
            let password: String
        }
        
        let registerRequest = RegisterRequest(username: username, email: email, password: password)
        
        let response: APIResponse<UserProfile> = try await self.request(
            endpoint: "/api/auth/register",
            method: .post,
            body: registerRequest
        )
        // 保存服务器返回的 token
        if let token = response.data?.token {
            saveToken(token)
        }
        return response
    }
}

// MARK: - Network Models

struct APIResponse<T: Decodable>: Decodable, Sendable where T: Sendable {
    let success: Bool
    let message: String
    let data: T?
}

struct UserProfile: Codable, Sendable {
    let id: String
    let username: String
    let email: String
    let token: String?
    let createdAt: Date?
    let lastActive: Date?
    let streakDays: Int
    let totalPomodoros: Int
    let totalMinutes: Int
    
    // 自定义解码，兼容 id 为 Int 或 String
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // id 可能是 Int（来自 PHP）或 String（本地 fallback）
        if let intId = try? container.decode(Int.self, forKey: .id) {
            self.id = String(intId)
        } else {
            self.id = try container.decode(String.self, forKey: .id)
        }
        
        self.username = try container.decode(String.self, forKey: .username)
        self.email = try container.decode(String.self, forKey: .email)
        self.token = try container.decodeIfPresent(String.self, forKey: .token)
        self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        self.lastActive = try container.decodeIfPresent(Date.self, forKey: .lastActive)
        self.streakDays = try container.decodeIfPresent(Int.self, forKey: .streakDays) ?? 0
        self.totalPomodoros = try container.decodeIfPresent(Int.self, forKey: .totalPomodoros) ?? 0
        self.totalMinutes = try container.decodeIfPresent(Int.self, forKey: .totalMinutes) ?? 0
    }
    
    // 标准初始化器（用于本地 fallback）
    init(id: String, username: String, email: String, token: String? = nil,
         createdAt: Date? = nil, lastActive: Date? = nil,
         streakDays: Int = 0, totalPomodoros: Int = 0, totalMinutes: Int = 0) {
        self.id = id
        self.username = username
        self.email = email
        self.token = token
        self.createdAt = createdAt
        self.lastActive = lastActive
        self.streakDays = streakDays
        self.totalPomodoros = totalPomodoros
        self.totalMinutes = totalMinutes
    }
}

struct PomodoroSessionDTO: Codable {
    let id: String
    let userId: String
    let intention: String
    let duration: Int
    let completed: Bool
    let focusScore: Int?
    let timestamp: Date?
    
    // 自定义解码，兼容 id 和 userId 为 Int 或 String
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
        
        self.intention = try container.decode(String.self, forKey: .intention)
        self.duration = try container.decode(Int.self, forKey: .duration)
        self.completed = try container.decode(Bool.self, forKey: .completed)
        self.focusScore = try container.decodeIfPresent(Int.self, forKey: .focusScore)
        self.timestamp = try container.decodeIfPresent(Date.self, forKey: .timestamp)
    }
    
    init(id: String, userId: String, intention: String, duration: Int, completed: Bool, focusScore: Int?, timestamp: Date?) {
        self.id = id
        self.userId = userId
        self.intention = intention
        self.duration = duration
        self.completed = completed
        self.focusScore = focusScore
        self.timestamp = timestamp
    }
}

struct CreatePomodoroRequest: Encodable {
    let intention: String
    let duration: Int
    let completed: Bool
    let focusScore: Int?
}

struct WeatherData: Codable {
    let city: String
    let temperature: Double
    let condition: String
    let humidity: Int
    let windSpeed: Double
    let updatedAt: Date
}
