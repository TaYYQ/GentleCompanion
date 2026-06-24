//
//  AccountManager.swift
//  GentleCompanion
//
//  本地账户系统 — UserDefaults + PBKDF2-SHA256
//

import Foundation
import CryptoKit
import AuthenticationServices

// MARK: - Account Model

struct Account: Codable, Identifiable, Equatable {
    let id: UUID
    var username: String
    var email: String
    var passwordHash: String
    var provider: AccountProvider
    var createdAt: Date
    var lastLoginAt: Date?

    // 个人资料
    var gender: Gender?
    var birthday: Date?
    var weight: Double?         // kg
    var interests: [Interest]
    var onboardingCompleted: Bool

    init(
        id: UUID = UUID(),
        username: String,
        email: String,
        passwordHash: String,
        provider: AccountProvider = .local,
        createdAt: Date = Date(),
        lastLoginAt: Date? = nil,
        gender: Gender? = nil,
        birthday: Date? = nil,
        weight: Double? = nil,
        interests: [Interest] = [],
        onboardingCompleted: Bool = false
    ) {
        self.id = id
        self.username = username
        self.email = email
        self.passwordHash = passwordHash
        self.provider = provider
        self.createdAt = createdAt
        self.lastLoginAt = lastLoginAt
        self.gender = gender
        self.birthday = birthday
        self.weight = weight
        self.interests = interests
        self.onboardingCompleted = onboardingCompleted
    }
}

enum Gender: String, Codable, CaseIterable {
    case male   = "男"
    case female = "女"
    case other  = "其他"

    var icon: String {
        switch self {
        case .male:   return "👦"
        case .female: return "👧"
        case .other:  return "🌈"
        }
    }
}

enum Interest: String, Codable, CaseIterable, Identifiable {
    case music        = "🎵 音乐"
    case movie        = "🎬 电影"
    case reading      = "📚 阅读"
    case travel       = "✈️ 旅行"
    case food         = "🍜 美食"
    case fitness      = "🏃 运动"
    case photography  = "📷 摄影"
    case gaming       = "🎮 游戏"
    case art          = "🎨 绘画"
    case writing      = "✍️ 写作"
    case cooking      = "🍳 烹饪"
    case pets         = "🐾 宠物"
    case gardening    = "🌱 园艺"
    case fashion      = "👗 时尚"
    case tech         = "💻 科技"
    case outdoors     = "🏕️ 户外"
    case meditation   = "🧘 冥想"
    case sports       = "⚽ 体育"
    case dancing      = "💃 舞蹈"
    case crafts       = "🧶 手工艺"
    case anime        = "💮 动漫"
    case drama        = "🎭 戏剧"
    case makeup       = "💄 美容"
    case parenting    = "👶 育儿"

    var id: String { rawValue }

    var emoji: String {
        let parts = rawValue.split(separator: " ", maxSplits: 1)
        return String(parts.first ?? Substring("🏷️"))
    }
    var label: String {
        let parts = rawValue.split(separator: " ", maxSplits: 1)
        return String(parts.count > 1 ? parts[1] : Substring(rawValue))
    }
}

enum AccountProvider: String, Codable {
    case local
    case apple
    case google
    case wechat

    var displayName: String {
        switch self {
        case .local:  return "本地账号"
        case .apple:  return "Apple 登录"
        case .google: return "Google"
        case .wechat: return "微信"
        }
    }

    var iconName: String {
        switch self {
        case .local:  return "person.fill"
        case .apple:  return "applelogo"
        case .google: return "g.circle.fill"
        case .wechat: return "message.fill"
        }
    }
}

// MARK: - AccountManager

@MainActor
final class AccountManager: ObservableObject {

    static let shared = AccountManager()

    @Published private(set) var currentAccount: Account?
    @Published private(set) var accounts: [Account] = []
    @Published private(set) var isLoggedIn: Bool = false

    private let ACCOUNTS_KEY = "gentle_accounts_v1"
    private let CURRENT_KEY   = "gentle_current_account_id"
    private let SALT_KEY      = "gentle_password_salt"

    // MARK: - Init

    private init() {
        loadAccounts()
        loadCurrentAccount()
    }

    // MARK: - Password Hashing (PBKDF2-SHA256, 10k iterations)

    private func hashPassword(_ password: String, salt: String) -> String {
        let input = Data((password + salt).utf8)
        let saltData = Data(salt.utf8)

        var derivedKey = [UInt8](repeating: 0, count: 32)

        input.withUnsafeBytes { inputBuf in
            saltData.withUnsafeBytes { saltBuf in
                CCKeyDerivationPBKDF(
                    CCPBKDFAlgorithm(kCCPBKDF2),
                    inputBuf.baseAddress?.assumingMemoryBound(to: Int8.self),
                    input.count,
                    saltBuf.baseAddress?.assumingMemoryBound(to: UInt8.self),
                    saltData.count,
                    CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
                    10_000,
                    &derivedKey,
                    32
                )
            }
        }

        return derivedKey.map { String(format: "%02x", $0) }.joined()
    }

    private func getOrCreateSalt() -> String {
        if let existing = UserDefaults.standard.string(forKey: SALT_KEY) {
            return existing
        }
        let salt = UUID().uuidString
        UserDefaults.standard.set(salt, forKey: SALT_KEY)
        return salt
    }

    // MARK: - Register

    func register(username: String, email: String, password: String) throws -> Account {
        let trimmedEmail = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedName  = username.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else { throw AccountError.invalidUsername }
        guard trimmedEmail.contains("@") && trimmedEmail.contains(".") else { throw AccountError.invalidEmail }
        guard password.count >= 6 else { throw AccountError.weakPassword }
        guard !accounts.contains(where: { $0.email.lowercased() == trimmedEmail }) else {
            throw AccountError.emailAlreadyExists
        }

        let salt = getOrCreateSalt()
        let hash = hashPassword(password, salt: salt)

        let account = Account(
            username: trimmedName,
            email: trimmedEmail,
            passwordHash: hash,
            provider: .local,
            createdAt: Date(),
            lastLoginAt: Date()
        )

        accounts.append(account)
        saveAccounts()
        setCurrent(account)
        return account
    }

    // MARK: - Login

    func login(email: String, password: String) throws -> Account {
        let trimmedEmail = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let salt = getOrCreateSalt()
        let hash = hashPassword(password, salt: salt)

        guard let account = accounts.first(where: {
            $0.email.lowercased() == trimmedEmail && $0.passwordHash == hash
        }) else {
            throw AccountError.invalidCredentials
        }

        var updated = account
        updated.lastLoginAt = Date()
        updateAccount(updated)
        setCurrent(updated)
        return updated
    }

    // MARK: - Apple Sign In

    func loginWithApple(userID: String, email: String?, fullName: PersonNameComponents?) throws -> Account {
        let given  = fullName?.givenName  ?? ""
        let family = fullName?.familyName ?? ""
        let name = [given, family].filter { !$0.isEmpty }.joined(separator: " ")
        let displayName = name.isEmpty ? "Apple 用户" : name
        let emailAddr   = email ?? "\(userID)@privaterelay.appleid.com"

        // Find existing or create new
        if let existing = accounts.first(where: { $0.provider == .apple && $0.email == emailAddr }) {
            var updated = existing
            updated.lastLoginAt = Date()
            updateAccount(updated)
            setCurrent(updated)
            return updated
        }

        let account = Account(
            username: displayName,
            email: emailAddr,
            passwordHash: userID,
            provider: .apple,
            createdAt: Date(),
            lastLoginAt: Date()
        )

        accounts.append(account)
        saveAccounts()
        setCurrent(account)
        return account
    }

    // MARK: - Logout

    func logout() {
        UserDefaults.standard.removeObject(forKey: CURRENT_KEY)
        currentAccount = nil
        isLoggedIn = false
    }

    // MARK: - Profile Update

    func updateProfile(gender: Gender?, birthday: Date?, weight: Double?, interests: [Interest]) {
        guard var account = currentAccount else { return }
        account.gender = gender
        account.birthday = birthday
        account.weight = weight
        account.interests = interests
        updateAccount(account)
    }

    func completeOnboarding() {
        guard var account = currentAccount else { return }
        account.onboardingCompleted = true
        updateAccount(account)
    }

    var hasCompletedOnboarding: Bool {
        currentAccount?.onboardingCompleted ?? false
    }

    // MARK: - Switch Account

    func switchTo(_ account: Account) {
        var updated = account
        updated.lastLoginAt = Date()
        updateAccount(updated)
        setCurrent(updated)
    }

    // MARK: - Delete Account

    func deleteAccount(_ account: Account) throws {
        guard accounts.count > 1 else { throw AccountError.cannotDeleteLastAccount }

        accounts.removeAll { $0.id == account.id }
        saveAccounts()

        if currentAccount?.id == account.id {
            setCurrent(accounts.first!)
        }
    }

    // MARK: - Update Account

    func updateAccount(_ account: Account) {
        if let idx = accounts.firstIndex(where: { $0.id == account.id }) {
            accounts[idx] = account
            saveAccounts()
        }
        if currentAccount?.id == account.id {
            currentAccount = account
        }
    }

    // MARK: - Private

    private func setCurrent(_ account: Account) {
        UserDefaults.standard.set(account.id.uuidString, forKey: CURRENT_KEY)
        currentAccount = account
        isLoggedIn = true
    }

    private func loadAccounts() {
        guard let data = UserDefaults.standard.dictionary(forKey: ACCOUNTS_KEY),
              let json = try? JSONSerialization.data(withJSONObject: data),
              let decoded = try? JSONDecoder().decode([Account].self, from: json) else {
            accounts = []; return
        }
        accounts = decoded
    }

    private func saveAccounts() {
        guard let data = try? JSONEncoder().encode(accounts),
              let dict  = try? JSONSerialization.jsonObject(with: data) else { return }
        UserDefaults.standard.set(dict, forKey: ACCOUNTS_KEY)
    }

    private func loadCurrentAccount() {
        guard let idString = UserDefaults.standard.string(forKey: CURRENT_KEY),
              let uuid = UUID(uuidString: idString),
              let account = accounts.first(where: { $0.id == uuid }) else {
            currentAccount = nil
            isLoggedIn = false
            return
        }
        currentAccount = account
        isLoggedIn = true
    }
}

// MARK: - Account Errors

enum AccountError: LocalizedError {
    case invalidUsername
    case invalidEmail
    case weakPassword
    case emailAlreadyExists
    case invalidCredentials
    case cannotDeleteLastAccount

    var errorDescription: String? {
        switch self {
        case .invalidUsername:    return "用户名不能为空"
        case .invalidEmail:       return "邮箱格式不正确"
        case .weakPassword:       return "密码至少 6 位"
        case .emailAlreadyExists: return "该邮箱已被注册"
        case .invalidCredentials: return "邮箱或密码错误"
        case .cannotDeleteLastAccount: return "至少保留一个账号"
        }
    }
}

// MARK: - CommonCrypto Bridge

import CommonCrypto

private typealias CC_SHA256_CTX = CC_SHA256state_st
