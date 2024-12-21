// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "manifold-swift",
    products: [
        .library(name: "Manifold", targets: ["Manifold"]),
    ],
    targets: [
        .target(
            name: "Clipper2",
            path: "Libraries/clipper2/CPP/Clipper2Lib",
            sources: ["src"]
        ),
        .target(
            name: "ManifoldCPP",
            dependencies: ["Clipper2"],
            path: "Libraries/manifold-wrapped",
            exclude: ["manifold/src/CMakeLists.txt", "manifold/src/meshIO"],
            sources: ["manifold/src", "wrapper.cpp"],
            publicHeadersPath: "include",
            cxxSettings: [
                .define("MANIFOLD_PAR", to: "-1")
            ]
        ),
        .target(
            name: "Manifold",
            dependencies: ["ManifoldCPP"],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
        .executableTarget(
            name: "test",
            dependencies: ["Manifold"],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
    ],
    cxxLanguageStandard: .cxx17
)
