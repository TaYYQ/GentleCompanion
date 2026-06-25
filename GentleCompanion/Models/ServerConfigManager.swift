//
//  ServerConfigManager.swift
//  GentleCompanion
//
//  服务器地址配置管理器，用户可在设置中配置自己的服务器
//

import Foundation

class ServerConfigManager {
    static let shared = ServerConfigManager()
    
    private let serverHostKey = "gentle_server_host"
    private let serverPortKey = "gentle_server_port"
    private let serverUseHTTPSKey = "gentle_server_use_https"
    
    private let defaultHost = "127.0.0.1"
    private let defaultPort = 80
    private let defaultUseHTTPS = false
    
    private init() {}
    
    /// 服务器地址（用户可配置）
    var serverHost: String {
        get { UserDefaults.standard.string(forKey: serverHostKey) ?? defaultHost }
        set { UserDefaults.standard.set(newValue, forKey: serverHostKey) }
    }
    
    /// 服务器端口
    var serverPort: Int {
        get {
            let saved = UserDefaults.standard.integer(forKey: serverPortKey)
            return saved > 0 ? saved : defaultPort
        }
        set { UserDefaults.standard.set(newValue, forKey: serverPortKey) }
    }
    
    /// 是否使用 HTTPS
    var useHTTPS: Bool {
        get {
            if UserDefaults.standard.object(forKey: serverUseHTTPSKey) == nil {
                return defaultUseHTTPS
            }
            return UserDefaults.standard.bool(forKey: serverUseHTTPSKey)
        }
        set { UserDefaults.standard.set(newValue, forKey: serverUseHTTPSKey) }
    }
    
    /// 完整的 baseURL，例如 http://127.0.0.1:80
    var baseURL: String {
        let scheme = useHTTPS ? "https" : "http"
        return "\(scheme)://\(serverHost):\(serverPort)"
    }
    
    /// 是否已配置（非默认值）
    var isConfigured: Bool {
        serverHost != defaultHost
    }
    
    /// 重置为默认值
    func resetToDefaults() {
        serverHost = defaultHost
        serverPort = defaultPort
        useHTTPS = defaultUseHTTPS
    }
}
