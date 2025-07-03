// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TransmissionGallery",
    platforms: [
        .iOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/nathantannar4/Transmission", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "TransmissionGallery",
            dependencies: ["Transmission"],
            path: "TransmissionGallery"
        )
    ]
)
