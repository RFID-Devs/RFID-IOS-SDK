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
            checksum: "22a35f4627bb7b9e95c79a5de6085e61b26d2de7fd01c8f112d1023bd99aadaa"
        )
    ]
)
