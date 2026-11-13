// swift-tools-version: 6.0
//
// Builds the app's platform-independent model layer (WeightandBalance/Model) as a library so it
// can be unit-tested with `swift test` on macOS or Linux, without a simulator. The iOS app itself
// is built from WeightandBalance.xcodeproj, which compiles the same files directly into the app.

import PackageDescription

let package = Package(
    name: "WeightAndBalanceCore",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "WeightAndBalanceCore", targets: ["WeightAndBalanceCore"]),
    ],
    targets: [
        .target(
            name: "WeightAndBalanceCore",
            path: "WeightandBalance/Model"
        ),
        .testTarget(
            name: "WeightAndBalanceCoreTests",
            dependencies: ["WeightAndBalanceCore"],
            path: "Tests/WeightAndBalanceCoreTests",
            // Fixtures are read via #filePath so the tests also check the app's real DefaultTypes.json.
            exclude: ["Fixtures"]
        ),
    ]
)
