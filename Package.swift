// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "blockchain-web-api",
    products: [
        .library(name: "blockchain-web-api", targets: ["App"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0"),

        // ⛓ Blockchain implementation written in swift-tools-version
        .package(url: "https://github.com/nevstad/blockchain-swift.git", from: "0.1.0")
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentSQLite", "Vapor", "BlockchainSwift"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

