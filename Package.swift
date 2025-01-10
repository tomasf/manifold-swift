// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "manifold-swift",
    products: [
        .library(name: "Manifold", targets: ["Manifold3D"]),
    ],
    targets: [
        .target(
            name: "Clipper2",
            path: "Libraries/clipper2/CPP/Clipper2Lib",
            sources: ["src"]
        ),
        .target(
            name: "oneTBB",
            path: "Libraries/oneTBB",
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
                .define("__TBB_WAITPKG_INTRINSICS_PRESENT", to: "0")
            ]
        ),
        .target(
            name: "ManifoldCPP",
            dependencies: ["Clipper2", "oneTBB"],
            path: "Libraries/manifold",
            exclude: ["src/CMakeLists.txt", "src/meshIO"],
            sources: ["src"],
            cxxSettings: [
                .define("MANIFOLD_PAR", to: "1")
            ]
        ),
        .target(
            name: "ManifoldBridge",
            dependencies: ["ManifoldCPP"],
            path: "Libraries/manifold-bridge"
        ),
        .target(
            name: "Manifold3D",
            dependencies: ["ManifoldCPP", "ManifoldBridge"],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        )
    ],
    cxxLanguageStandard: .cxx17
)
