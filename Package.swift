// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "AsyncBinding",
    platforms: [
        .iOS(.v15),
        .tvOS(.v15),
        .macOS(.v12),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "AsyncBinding",
            targets: ["AsyncBinding"]
        )
    ],
    targets: [
        .target(
            name: "AsyncBinding",
            path: "Sources/"
        )
    ]
)
