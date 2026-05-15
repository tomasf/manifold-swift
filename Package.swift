// swift-tools-version: 6.0

import PackageDescription

// If you get "invalid custom path" errors, you probably forgot to initialize submodules.
// git submodule update --init --recursive

let package = Package(
    name: "manifold-swift",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "Manifold", targets: ["Manifold3D"]),
    ],
    targets: [
        .target(
            name: "Clipper2",
            path: "External/clipper2/CPP/Clipper2Lib",
            sources: ["src"]
        ),
        .target(
            name: "oneTBB",
            path: "External/oneTBB",
            exclude: [
                "examples",
                "src/tbb/CMakeLists.txt",
                "src/tbb/tbb.rc",
            ],
            sources: ["src/tbb"],
            publicHeadersPath: "include",
            cxxSettings: [
                .define("_XOPEN_SOURCE", to: "700"),
                .define("_DARWIN_C_SOURCE"),
                .define("__TBB_DYNAMIC_LOAD_ENABLED", to: "0"),
                .define("__TBB_WAITPKG_INTRINSICS_PRESENT", to: "0"),
                .define("__TBB_TSX_INTRINSICS_PRESENT", to: "0"),
                .define("__TBB_BUILD", to: "1")
            ]
        ),
        .target(
            name: "ManifoldCPP",
            dependencies: ["Clipper2", "oneTBB"],
            path: "External/manifold",
            exclude: [
                "src/CMakeLists.txt",
                // Upstream offers two CrossSection backends; CMake picks one at
                // build time. SwiftPM compiles every source it sees, so exclude
                // the non-clipper2 implementation to avoid duplicate symbols.
                "src/cross_section/cross_section_boolean2.cpp",
            ],
            sources: ["src"],
            cxxSettings: [
                .define("MANIFOLD_PAR", to: "1"),
                .define("__TBB_NO_IMPLICIT_LINKAGE", to: "1")
            ]
        ),
        .target(
            name: "ManifoldBridge",
            dependencies: ["ManifoldCPP"]
        ),
        .target(
            name: "Manifold3D",
            dependencies: ["ManifoldCPP", "ManifoldBridge"],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
        .testTarget(
            name: "Manifold3DTests",
            dependencies: ["Manifold3D"],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        )
    ],
    cxxLanguageStandard: .cxx17
)
