// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PortHole",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "PortHole",
            path: "Sources/PortHole"
        )
    ]
)
