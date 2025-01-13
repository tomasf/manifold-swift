# Manifold-Swift

A Swift interface to the [Manifold geometry library](https://github.com/elalish/manifold), for manipulation of solid 3D meshes. 

This SPM package includes Manifold, as well as its dependencies Clipper2 and oneTBB as Git submodules, so no additional dependencies are needed beyond the C++ standard library. Manifold-Swift works on macOS, Linux and Windows. The library covers most of the Manifold API, and naming is similar but using Swift conventions.

Due to a bug in Swift that isn't fixed in the latest release (as of 2025-01-13, version 6.0.3), the library requires a development snapshot of Swift to build on Windows. Because the library interfaces with C++, you need to enable C++ interoperability when using Manifold-Swift:

```swift
let package = Package(
    name: "manifold-swift-example",
    dependencies: [
        .package(url: "https://github.com/tomasf/manifold-swift.git", .upToNextMinor(from: "0.1.0"))
    ],
    targets: [
        .executableTarget(
            name: "manifold-swift-example",
            dependencies: [.product(name: "Manifold", package: "manifold-swift")],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        )
    ]
)
```

## Usage

The library uses protocols for vectors and matrices, so you can add conformance to your own types and send them in without conversion.

```swift
import Manifold3D

struct V: Vector3 {
    let x: Double
    let y: Double
    let z: Double
}

let sphere = Manifold.sphere(radius: 10, segmentCount: 25)
let box = Manifold.cube(size: V(x: 12, y: 20, z: 20))
    .rotate(V(x: 20, y: 25, z: 0))
let difference = sphere.boolean(.difference, with: box)

let meshGL = difference.meshGL()
// Render or save meshGL.vertices, meshGL.triangles, etc.
```

Read the [Manifold documentation](https://manifoldcad.org/docs/html) for more information.

## Contributions

Contributions are welcome! Submit pull requests or open issues to discuss improvements or report bugs.
