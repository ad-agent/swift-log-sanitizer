import Foundation
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SwiftLogSanitizer",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "SwiftLogSanitizer",
            targets: ["SwiftLogSanitizer"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.6.0"),
    ],
    targets: [
        .target(
            name: "SwiftLogSanitizer",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
            ]
        ),
        .testTarget(
            name: "SwiftLogSanitizerTests",
            dependencies: [
                "SwiftLogSanitizer",
                .product(name: "Logging", package: "swift-log"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
