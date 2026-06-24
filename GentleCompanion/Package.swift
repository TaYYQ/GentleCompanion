// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GentleCompanion",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "GentleCompanion", targets: ["GentleCompanion"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "GentleCompanion",
            path: ".",
            sources: [
                "GentleCompanionApp.swift",
                "ContentView.swift",
                "Design.swift",
                "Extensions.swift",
                "Models/Emotion.swift",
                "Models/AccountManager.swift",
                "Models/AppMode.swift",
                "Models/GentleWall.swift",
                "Models/NetworkService.swift",
                "Models/Settings.swift",
                "Models/SocialService.swift",
                "Views/ActivationFlowView.swift",
                "Views/AuthView.swift",
                "Views/AccountView.swift",
                "Views/GentleWallView.swift",
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
                "Views/SplashView.swift",
                "Views/TimeModeView.swift",
                "Views/ProfileView.swift",
                "Views/BreathingView.swift",
                "Views/ActivationView.swift",
                "Views/GentleMainView.swift"
            ],
            resources: [
                .process("Assets.xcassets"),
                .process("Resources")
            ],
            swiftSettings: []
        )
    ]
)