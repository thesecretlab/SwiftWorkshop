// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "TodoList",
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 1),
        .Package(url: "https://github.com/IBM-Swift/HeliumLogger.git", majorVersion: 1),
        .Package(url: "https://github.com/IBM-Swift/CloudConfiguration.git", majorVersion: 2)
    ]
)