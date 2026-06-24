// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "ZWB_SegmentedView",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(
            name: "ZWB_SegmentedView",
            targets: ["ZWB_SegmentedView"]
        )
    ],
    targets: [
        .target(
            name: "ZWB_SegmentedView",
            path: "Sources",
            resources: [
                .copy("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)

