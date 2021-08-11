// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Galah",
    products:
    [
        .library(
            name: "Galah",
            targets: ["GalahNative","Galah"]),
    ],
    targets:
    [
        .target(name: "GalahNative", path: "Sources/GalahNative"),
        .target(name: "Galah", dependencies: ["GalahNative"], path: "Sources/Galah"),
    ]
)
