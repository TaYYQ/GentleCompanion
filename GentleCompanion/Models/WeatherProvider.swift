//
//  WeatherProvider.swift
//  GentleCompanion
//
//  Weather service using QWeather (和风天气) API
//

import Foundation

class GentleWeatherProvider: @unchecked Sendable {
    static let shared = GentleWeatherProvider()
    
    // MARK: - QWeather Configuration
    
    /// 和风天气 API Host
    private let apiHost = "https://ng6cdqkemj.re.qweatherapi.com"
    
    /// 和风天气 API KEY（在控制台创建凭据后获取）
    /// TODO: 替换为你的真实 API KEY
    private let apiKey = "5aff702b883444a4817e89fc4d75d22b"
    
    private init() {}
    
    // MARK: - Public Fetch
    
    func fetch(for settings: AppSettings, emotion: Emotion) async -> GentleWeatherSnapshot? {
        let fallbackLocation = Location(
            latitude: 39.9042,
            longitude: 116.4074,
            city: "北京",
            timezone: "Asia/Shanghai"
        )
        let storedLocation = settings.currentLocation ?? fallbackLocation
        let city = storedLocation.city ?? "你的城市"
        
        do {
            let weatherData = try await fetchQWeatherData(
                lat: storedLocation.latitude,
                lon: storedLocation.longitude
            )
            let condition = GentleWeatherCondition.from(qWeatherIcon: weatherData.icon)
            let symbolName = GentleWeatherProvider.symbolName(for: condition)
            let (line, detail) = GentleWeatherProvider.gentleLines(
                for: condition,
                emotion: emotion,
                city: city
            )
            return GentleWeatherSnapshot(
                city: city,
                condition: condition,
                symbolName: symbolName,
                line: line,
                detail: detail,
                temperature: weatherData.temperature,
                windSpeed: weatherData.windSpeed,
                humidity: weatherData.humidity,
                createdAt: Date()
            )
        } catch {
            return nil
        }
    }
    
    // MARK: - QWeather Real-time Weather API (/v7/weather/now)
    
    struct WeatherData {
        let icon: Int
        let text: String
        let temperature: Double
        let windSpeed: Double
        let humidity: Int
    }
    
    private func fetchQWeatherData(lat: Double, lon: Double) async throws -> WeatherData {
        let locationParam = String(format: "%.2f,%.2f", lon, lat)
        let urlString = "\(apiHost)/v7/weather/now?location=\(locationParam)&key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw WeatherError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw WeatherError.requestFailed
        }
        
        let decoder = JSONDecoder()
        let result = try decoder.decode(QWeatherNowResponse.self, from: data)
        
        guard let now = result.now else {
            throw WeatherError.requestFailed
        }
        
        return WeatherData(
            icon: Int(now.icon) ?? 999,
            text: now.text,
            temperature: Double(now.temp) ?? 0,
            windSpeed: Double(now.windSpeed) ?? 0,
            humidity: Int(now.humidity) ?? 0
        )
    }
    
    // MARK: - Symbol Names
    
    private static func symbolName(for condition: GentleWeatherCondition) -> String {
        switch condition {
        case .clear: return "sun.max"
        case .cloudy: return "cloud"
        case .rainy: return "cloud.rain"
        case .foggy: return "cloud.fog"
        case .snowy: return "cloud.snow"
        case .extreme: return "exclamationmark.triangle"
        case .unknown: return "sparkles"
        }
    }
    
    // MARK: - Gentle Text Lines
    
    private static func gentleLines(
        for condition: GentleWeatherCondition,
        emotion: Emotion,
        city: String
    ) -> (String, String) {
        let cityPart = city.isEmpty ? "今天" : city
        switch condition {
        case .clear:
            let line = "\(cityPart)晴，太阳在轻轻说：今天也值得被爱。"
            let detail: String
            switch emotion {
            case .empty:
                detail = "阳光洒在窗台上，也照得到这块暂时空掉的心。它不催你，只陪你。"
            case .exhausted:
                detail = "阳光很明亮，但你可以慢一点，让光先替你努力。"
            case .anxious:
                detail = "天这么亮，说明世界还在等你慢慢来，不用一下子赶上所有光。"
            default:
                detail = "阳光洒满窗台，像在提醒你：你的温柔也值得被看见。"
            }
            return (line, detail)
        case .rainy:
            let line = "\(cityPart)有雨，云在替你多想一点。"
            let detail: String
            switch emotion {
            case .exhausted:
                detail = "雨声像一条被子，把今天的疲惫都盖住了，你只负责躺一会儿就好。"
            case .empty, .lonely:
                detail = "雨在替你哭一场，没关系，哭完继续温柔地活着。"
            default:
                detail = "窗外的雨在认真地下着，像在提醒你：你的情绪也可以被认真对待。"
            }
            return (line, detail)
        case .foggy, .cloudy:
            let line = "\(cityPart)多云/有雾，世界被轻轻蒙上了一层纱。"
            let detail: String
            switch emotion {
            case .anxious:
                detail = "雾里看不清没关系，现在看不清路，也不代表你没有方向。"
            case .empty:
                detail = "天灰灰的日子，本来就适合慢一点，对自己温柔一点。"
            default:
                detail = "云层偶尔会厚一点，但太阳没有消失，就像你的力量一样。"
            }
            return (line, detail)
        case .snowy:
            let line = "\(cityPart)下雪了，世界在帮你按下慢放键。"
            let detail = "每一片落下来的雪花，都在说：可以走得更慢一点，也没关系。"
            return (line, detail)
        case .extreme:
            let line = "\(cityPart)今天有点极端天气，请先照顾好自己。"
            let detail = "不管外面怎样，你都值得被好好保护，多喝水、多休息。"
            return (line, detail)
        case .unknown:
            let line = "看不太清今天的天气，但可以先照顾好当下的你。"
            let detail = "就算天气预报说不清，现在这个你也依然值得被温柔对待。"
            return (line, detail)
        }
    }
    
    // MARK: - Internal Types
    
    enum WeatherError: Error {
        case invalidURL
        case requestFailed
    }
    
    /// QWeather /v7/weather/now 响应结构
    struct QWeatherNowResponse: Decodable {
        let code: String
        let updateTime: String?
        let now: NowData?
        
        struct NowData: Decodable {
            let obsTime: String?
            let temp: String
            let feelsLike: String?
            let icon: String
            let text: String
            let windDir: String?
            let windScale: String?
            let windSpeed: String
            let humidity: String
            let precip: String?
            let pressure: String?
            let vis: String?
            let cloud: String?
            let dew: String?
        }
    }
    
    // MARK: - QWeather City Search (Geo API)
    
    struct CityResult: Identifiable, Sendable {
        let id = UUID()
        let name: String
        let country: String
        let admin1: String
        let admin2: String
        let latitude: Double
        let longitude: Double
        let timezone: String
        let locationID: String
    }
    
    /// 使用和风天气 GeoAPI 搜索城市（支持全球城市）
    func searchCities(query: String) async -> [CityResult] {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty,
              let encoded = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(apiHost)/geo/v2/city/lookup?location=\(encoded)&number=10&range=world&lang=zh&key=\(apiKey)") else {
            return []
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                return []
            }
            
            let decoder = JSONDecoder()
            let result = try decoder.decode(QWeatherGeoResponse.self, from: data)
            
            return (result.location ?? []).map { loc in
                CityResult(
                    name: loc.name,
                    country: loc.country,
                    admin1: loc.adm1,
                    admin2: loc.adm2,
                    latitude: Double(loc.lat) ?? 0,
                    longitude: Double(loc.lon) ?? 0,
                    timezone: loc.tz,
                    locationID: loc.id
                )
            }
        } catch {
            return []
        }
    }
    
    struct QWeatherGeoResponse: Decodable {
        let code: String
        let location: [GeoLocation]?
        
        struct GeoLocation: Decodable {
            let name: String
            let id: String
            let lat: String
            let lon: String
            let adm2: String
            let adm1: String
            let country: String
            let tz: String
            let utcOffset: String?
            let isDst: String?
            let type: String?
            let rank: String?
            let fxLink: String?
        }
    }
}

// MARK: - QWeather Icon Code Mapping

extension GentleWeatherCondition {
    /// 将和风天气 icon 代码映射为 GentleWeatherCondition
    /// 参考：https://dev.qweather.com/docs/resource/icons/
    static func from(qWeatherIcon icon: Int) -> GentleWeatherCondition {
        switch icon {
        // 晴 (100: 晴-白天, 150: 晴-夜间)
        case 100, 150:
            return .clear
        
        // 多云/阴 (101-104, 151-153)
        case 101, 102, 103, 104, 151, 152, 153:
            return .cloudy
        
        // 雨 (300-399, 350-399)
        case 300...399:
            return .rainy
        
        // 雪 (400-499, 456-499)
        case 400...499:
            return .snowy
        
        // 雾/霾/沙尘 (500-515)
        case 500...515:
            return .foggy
        
        // 极端天气 (热/冷)
        case 900, 901:
            return .extreme
        
        // 未知
        case 999:
            return .unknown
        
        default:
            return .unknown
        }
    }
}
