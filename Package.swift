// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "Extensions",
    products: [
        .library(
            name: "Extensions",
            targets: ["Extensions"]),
    ],
    dependencies: [
        .package(url: "https://github.com/mpapp/MPRateLimiter", from: "1.2")
    ],
    targets: [
        .target(
            name: "Extensions",
            dependencies: ["MPRateLimiter"])
    ]
)
