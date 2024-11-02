// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "RP2040",
  platforms: [
    .macOS(.v13)
  ],
  products: [
    .library(name: "Blinky", type: .static, targets: ["Blinky"]),
  ],
  dependencies: [
    .package(
        url: "https://github.com/PureSwift/Bluetooth",
        branch: "feature/embedded-swift"
    )
  ],
  targets: [
    .target(
      name: "Blinky", 
      dependencies: [
        "RP2040",
        "Bluetooth"
        ]
      ),
    .target(
        name: "Support"
    ),
    .target(
        name: "RP2040",
        dependencies: [
            "Support"
        ]
    ),
  ]
)
