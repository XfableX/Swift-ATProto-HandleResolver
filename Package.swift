// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

import class Foundation.FileManager

var caresExclude = [
    "./c-ares/src/lib/cares.rc",
    "./c-ares/src/lib/CMakeLists.txt",
    "./c-ares/src/lib/ares_config.h.cmake",
    "./c-ares/src/lib/Makefile.am",
    "./c-ares/src/lib/Makefile.inc",
]

do {
    if try !(FileManager.default.contentsOfDirectory(atPath: "./Sources/CAsyncDNSResolver/c-ares/CMakeFiles").isEmpty) {
        caresExclude.append("./c-ares/CMakeFiles/")
    }
} catch {
    // Assume CMakeFiles does not exist so no need to exclude it
}

let package = Package(
    name: "SwiftAtprotoOauth",
    platforms: [
        SupportedPlatform
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftAtprotoOauth",
            targets: ["SwiftAtprotoOauth"]),
    ],
    dependencies: [
       // .package(url: "https://github.com/apple/swift-async-dns-resolver", .upToNextMajor(from: "0.4.0")),
        .package(url: "https://github.com/p2/OAuth2", .upToNextMajor(from: "5.3.5")),
    ],
    
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        
        .target(
            name: "CAsyncDNSResolver",
            dependencies: [],
            exclude: caresExclude,
            sources: ["./c-ares/src/lib"],
            cSettings: [
                .headerSearchPath("./c-ares/include"),
                .headerSearchPath("./c-ares/src/lib"),
                .define("HAVE_CONFIG_H", to: "1"),
            ]
        ),
        .target(
            name: "SwiftAtprotoOauth",
            dependencies: [
                "AsyncDNSResolver", "OAuth2"
            ]),
        .target(
            name: "AsyncDNSResolver",
            dependencies: [
                "CAsyncDNSResolver"
            ]
        ),

        .testTarget(
            name: "SwiftAtprotoOauthTests",
            dependencies: ["SwiftAtprotoOauth"]
        ),
 
    ]
)
for target in package.targets {
    var settings = target.swiftSettings ?? []
    settings.append(.enableExperimentalFeature("StrictConcurrency=complete"))
    target.swiftSettings = settings
}
