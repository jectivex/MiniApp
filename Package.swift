// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "MiniApp",
    products: [
        .library(name: "MiniApp", targets: ["MiniApp"]),
        .library(name: "MiniAppManifest", targets: ["MiniAppManifest"]),
        .library(name: "MiniAppPackaging", targets: ["MiniAppPackaging"]),
        .library(name: "MiniAppLifecycle", targets: ["MiniAppLifecycle"]),
        .library(name: "MiniAppAddressing", targets: ["MiniAppAddressing"]),
    ],
    dependencies: [
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(name: "MiniApp", dependencies: ["MiniAppManifest", "MiniAppPackaging", "MiniAppLifecycle", "MiniAppAddressing"]),
        .testTarget(name: "MiniAppTests", dependencies: ["MiniApp"]),
        .target(name: "MiniAppManifest", dependencies: []),
        .testTarget(name: "MiniAppManifestTests", dependencies: ["MiniAppManifest"]),
        .target(name: "MiniAppPackaging", dependencies: []),
        .testTarget(name: "MiniAppPackagingTests", dependencies: ["MiniAppPackaging"]),
        .target(name: "MiniAppLifecycle", dependencies: []),
        .testTarget(name: "MiniAppLifecycleTests", dependencies: ["MiniAppLifecycle"]),
        .target(name: "MiniAppAddressing", dependencies: []),
        .testTarget(name: "MiniAppAddressingTests", dependencies: ["MiniAppAddressing"]),
    ]
)
