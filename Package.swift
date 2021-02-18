// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "Harald",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "Harald", targets: ["Harald"])
    ],
    dependencies: [],
    targets: [
        .target(name: "Harald", path: "Sources")
    ],
    swiftLanguageVersions: [.v5]
)
