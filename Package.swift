// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TransmissionGallery",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .executable(name: "TransmissionGallery", targets: ["TransmissionGallery"])
    ],
    dependencies: [
    ],
    targets: [
        .executableTarget(
            name: "TransmissionGallery",
            dependencies: [],
            path: ".",
            exclude: ["README.md", "LICENSE", ".gitignore", "TransmissionGallery/Info.plist"],
            sources: ["TransmissionGallery"]
        )
    ]
)
