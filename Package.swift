// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "PixelateCLI",
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            from: "1.3.0"
        )
    ],
    targets: [
        .executableTarget(
            name: "PixelateCLI",
            dependencies: [
                .product(
                    name: "ArgumentParser",
                    package: "swift-argument-parser"
                )
            ],
            linkerSettings: [
                .linkedFramework("Metal"),
                .linkedFramework("MetalKit"),
                .linkedFramework("CoreGraphics"),
            ]
        ),
        .testTarget(
            name: "PixelateCLITests",
            dependencies: ["PixelateCLI"],
            resources: [
                .copy("Resources")
            ]
        ),
    ]
)
