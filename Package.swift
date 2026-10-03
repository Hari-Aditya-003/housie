// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Housie",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "HousieCore", targets: ["HousieCore"])
    ],
    targets: [
        .target(
            name: "HousieCore",
            path: "Housie/HousieCore"
        ),
        .executableTarget(
            name: "HousieCoreTests",
            dependencies: ["HousieCore"],
            path: "HousieTests",
            exclude: ["verify_caller_experience.sh"]
        )
    ]
)
