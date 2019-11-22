// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Swifty_Flux",
    platforms: [
        .iOS(.v10), .macOS(.v10_12), .tvOS(.v10), .watchOS(.v3)
    ],
    products: [
        .library(name: "Swifty_Flux", targets: ["Swifty_Flux"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Swifty_Flux",
            path: "Source"
        ),
        .testTarget(
            name: "Swifty_FluxTests",
            dependencies: ["Swifty_Flux"],
            path: "Tests"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
