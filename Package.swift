// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DropShelf",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "DropShelf", targets: ["DropShelf"])
    ],
    targets: [
        .executableTarget(
            name: "DropShelf",
            path: "Sources"
        ),
        .testTarget(
            name: "DropShelfTests",
            dependencies: ["DropShelf"],
            path: "Tests/DropShelfTests"
        )
    ]
)
