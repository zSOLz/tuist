import ProjectDescription

let appTarget: Target = .target(
    name: "App",
    destinations: [.iPhone, .iPad, .appleVision],
    product: .app,
    bundleId: "dev.tuist.App",
    infoPlist: "Support/App-Info.plist",
    sources: "App/Sources/**",
    dependencies: [
        .target(name: "WidgetExtension", condition: .when([.ios])),
        .target(name: "WatchApp", condition: .when([.ios])),
    ]
)

let widgetExtensionTarget: Target = .target(
    name: "WidgetExtension",
    destinations: [.iPhone, .iPad],
    product: .appExtension,
    bundleId: "dev.tuist.App.WidgetExtension",
    infoPlist: .extendingDefault(with: [
        "CFBundleDisplayName": "$(PRODUCT_NAME)",
        "NSExtension": [
            "NSExtensionPointIdentifier": "com.apple.widgetkit-extension",
        ],
    ]),
    sources: "Extensions/WidgetExtension/Sources/**",
    resources: "Extensions/WidgetExtension/Resources/**"
)

let watchApp: Target = .target(
    name: "WatchApp",
    destinations: [.appleWatch],
    product: .app,
    bundleId: "dev.tuist.App.watchkitapp",
    infoPlist: nil,
    sources: "WatchApp/Sources/**",
    resources: "WatchApp/Resources/**",
    settings: .settings(
        base: [
            "GENERATE_INFOPLIST_FILE": true,
            "CURRENT_PROJECT_VERSION": "1.0",
            "MARKETING_VERSION": "1.0",
            "INFOPLIST_KEY_UISupportedInterfaceOrientations": [
                "UIInterfaceOrientationPortrait",
                "UIInterfaceOrientationPortraitUpsideDown",
            ],
            "INFOPLIST_KEY_WKCompanionAppBundleIdentifier": "dev.tuist.App",
            "INFOPLIST_KEY_WKRunsIndependentlyOfCompanionApp": false,
        ]
    )
)

let project = Project(
    name: "App",
    targets: [appTarget, widgetExtensionTarget, watchApp]
)
