// swift-tools-version: 6.0

import PackageDescription

// 共享 Model + 设计系统（macOS & iOS 共用）
let sharedSources: [String] = [
    "Design.swift",
    "Extensions.swift",
    "Models/Emotion.swift",
    "Models/AccountManager.swift",
    "Models/AppMode.swift",
    "Models/GentleWall.swift",
    "Models/NetworkService.swift",
    "Models/Settings.swift",
    "Models/SocialService.swift",
    "Models/ServerConfigManager.swift",
    "Models/WeatherProvider.swift",
    "Views/SplashView.swift",
    "Views/ActivationFlowView.swift",
    "Views/AuthView.swift",
    "Views/AgreementView.swift",
    "Views/AccountView.swift",
    "Views/ActivationView.swift",
    "Views/WelcomeView.swift",
    "Views/ServerSetupView.swift",
]

// macOS 专属文件
let macOSSources: [String] = [
    "GentleCompanionApp.swift",
    "ContentView.swift",
    "Views/GentleMainView.swift",
    "Views/MainView.swift",
    "Views/NewMainView.swift",
    "Views/ModeSwitchView.swift",
    "Views/EntertainmentView.swift",
    "Views/MoodQuestionView.swift",
    "Views/BubblePopGame.swift",
    "Views/GardenGame.swift",
    "Views/RhythmGame.swift",
    "Views/EfficiencyView.swift",
    "Views/SocialView.swift",
    "Views/PomodoroSubviews.swift",
    "Views/PomodoroView.swift",
    "Views/SettingsView.swift",
    "Views/SocialFeedView.swift",
    "Views/TimeModeView.swift",
    "Views/ProfileView.swift",
    "Views/BreathingView.swift",
    "Views/GentleWallView.swift",
]

// iOS 专属文件
let iOSSources: [String] = [
    "GentiOSApp.swift",
    "Views/GentiOSMainView.swift",
    "Views/GentiOSHomeView.swift",
    "Views/GentiOSProfileView.swift",
    "Views/GentiOSSocialView.swift",
    "Views/GentiOSWallView.swift",
    "Views/GentiOSMessageView.swift",
    "Views/PomodoroiOSView.swift",
    "Views/BreathingiOSView.swift",
]

let package = Package(
    name: "GentleCompanion",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .executable(name: "GentleCompanion", targets: ["GentleCompanion"]),
        .executable(name: "GentiOS", targets: ["GentiOS"]),
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "GentleCompanion",
            path: ".",
            sources: sharedSources + macOSSources,
            resources: [
                .process("Assets.xcassets"),
                .process("Resources"),
            ],
            swiftSettings: [
                .define("TARGET_MACOS"),
            ]
        ),
        .executableTarget(
            name: "GentiOS",
            path: ".",
            sources: sharedSources + iOSSources,
            resources: [
                .process("Resources"),
            ],
            swiftSettings: [
                .define("TARGET_IOS"),
            ]
        ),
    ]
)
