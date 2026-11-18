// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Prioritizer",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "Prioritizer",
            path: "Sources/Prioritizer"
        )
    ]
)
