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
            url: "https://github.com/RFID-Devs/RFID-IOS-SDK/releases/download/v2.0.1/RFIDManager.xcframework.zip",
            checksum: "cb0191dfee4b97ee003063730fe74f7616d06b5fcfa76a9b41a63fa1052fd4db"
        )
    ]
)
