// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "FlSwift",
    platforms: [
        .iOS(.v10), .macOS(.v10_12), .tvOS(.v10), .watchOS(.v3)
    ],
    products: [
        .library(name: "FlSwift", targets: ["FlSwift"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "FlSwift",
            path: "Source"
        ),
        .testTarget(
            name: "FlSwiftTests",
            dependencies: ["FlSwift"],
            path: "Tests"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
