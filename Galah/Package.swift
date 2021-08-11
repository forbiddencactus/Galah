// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Galah",
    products:
    [
        .library(
            name: "Galah",
            targets: ["Galah"]),
    ],
    dependencies:
    [
        .package(path: "./GalahNativeTypes")
    ],
    targets:
    [
        .target(name: "Galah", dependencies: ["GalahNativeTypes"], path: "Sources/Galah"),
    ]
)
