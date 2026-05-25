// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DailyBox",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "DailyBox",
            dependencies: ["DailyBoxLib"],
            path: "Sources/DailyBox"
        ),
        .target(
            name: "DailyBoxLib",
            path: "Sources/DailyBoxLib",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "DailyBoxTests",
            dependencies: ["DailyBoxLib"],
            path: "Tests/DailyBoxTests"
        )
    ]
)
