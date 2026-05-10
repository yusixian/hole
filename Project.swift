import ProjectDescription

let project: Project = .init(
    name: "Hole",
    targets: [
        .target(
            name: "Hole",
            destinations: .iOS,
            product: .app,
            bundleId: "$(BUNDLE_ID)",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .extendingDefault(
                with: [
                    "CFBundleDisplayName": "$(PRODUCT_NAME)",
                    "CFBundleShortVersionString": "$(MARKETING_VERSION)",
                    "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
                    "CFBundleDevelopmentRegion": "en",
                    "CFBundleLocalizations": ["en", "zh-Hans"],
                    "ENVIRONMENT": "$(ENVIRONMENT)",
                    "BUNDLE_ID": "$(BUNDLE_ID)",
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                    "UIUserInterfaceStyle": "Automatic",
                    "ITSAppUsesNonExemptEncryption": false,
                    "NSMicrophoneUsageDescription": "Hole needs the microphone so you can record voice entries.",
                    "NSSpeechRecognitionUsageDescription": "Hole transcribes your voice entries on-device so you can read them later.",
                    "NSPhotoLibraryUsageDescription": "Hole attaches photos you pick to your entries; nothing is uploaded.",
                    "CFBundleURLTypes": [
                        [
                            "CFBundleTypeRole": "Editor",
                            "CFBundleURLName": "io.mewtant.hole",
                            "CFBundleURLSchemes": ["hole"]
                        ]
                    ],
                ]
            ),
            sources: ["Hole/Sources/**"],
            resources: ["Hole/Resources/**"],
            dependencies: [],
            settings: .settings(
                configurations: [
                    .debug(name: "Debug", settings: [:], xcconfig: "Configurations/Dev.xcconfig"),
                    .release(name: "Staging", settings: [:], xcconfig: "Configurations/Staging.xcconfig"),
                    .release(name: "Release", settings: [:], xcconfig: "Configurations/Release.xcconfig"),
                ]
            )
        ),
        .target(
            name: "HoleTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "$(BUNDLE_ID).Tests",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .default,
            sources: ["Hole/Tests/**"],
            dependencies: [.target(name: "Hole")],
            settings: .settings(
                configurations: [
                    .debug(name: "Debug", settings: [:], xcconfig: "Configurations/Dev.xcconfig"),
                    .release(name: "Staging", settings: [:], xcconfig: "Configurations/Staging.xcconfig"),
                    .release(name: "Release", settings: [:], xcconfig: "Configurations/Release.xcconfig"),
                ]
            )
        ),
    ],
    schemes: [
        .scheme(
            name: "Hole",
            shared: true,
            buildAction: .buildAction(targets: ["Hole"]),
            testAction: .targets(["HoleTests"]),
            runAction: .runAction(configuration: "Debug"),
            archiveAction: .archiveAction(configuration: "Release"),
            profileAction: .profileAction(configuration: "Release"),
            analyzeAction: .analyzeAction(configuration: "Debug")
        ),
    ]
)
