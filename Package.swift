// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RFID-IOS-SDK",
    platforms: [
        .iOS(.v12),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "RFIDManager",
            targets: ["RFIDManager"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "RFIDManager",
            url: "https://github.com/RFID-Devs/RFID-IOS-SDK/releases/download/v2.0.0/RFIDManager.xcframework.zip",
            checksum: "703d4bf26873d13fa8ada6c953da62ef61c7e2a3f7c8a0be70018050e816ae7b"
        )
    ]
)
