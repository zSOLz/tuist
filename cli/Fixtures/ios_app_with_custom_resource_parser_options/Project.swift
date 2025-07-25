import ProjectDescription

let project = Project(
    name: "App",
    options: .options(
        developmentRegion: "fr"
    ),
    targets: [
        .target(
            name: "App",
            destinations: .iOS,
            product: .app,
            bundleId: "dev.tuist.app",
            infoPlist: .default,
            sources: ["App/Sources/**"],
            resources: [
                "App/Resources/**/*.strings",
            ]
        ),
    ],
    resourceSynthesizers: [
        .strings(parserOptions: ["separator": "/"]),
    ]
)
