# Manifold-Swift

A Swift interface to the [Manifold geometry library](https://github.com/elalish/manifold), for manipulation of solid 3D meshes. 

![CI status](https://github.com/tomasf/manifold-swift/actions/workflows/swift.yml/badge.svg) ![Platforms](https://img.shields.io/badge/Platforms-macOS_%7C_iOS_%7C_tvOS_%7C_watchOS_%7C_visionOS_%7C_Linux_%7C_Windows-47D?logo=swift&logoColor=white)

This SPM package includes Manifold, as well as its dependencies Clipper2 and oneTBB as Git submodules, so no additional dependencies are needed beyond the C++ standard library. Manifold-Swift covers most of the Manifold API, and naming is similar but using Swift conventions. It works on all Apple platforms as well as Linux and Windows. 

## Usage

Add the package as a dependency in your Package.swift (or Xcode project). Because the library interfaces with C++, you need to enable C++ interoperability.

```swift
let package = Package(
    name: "manifold-swift-example",
    dependencies: [
        .package(url: "https://github.com/tomasf/manifold-swift.git", .upToNextMinor(from: "0.2.0"))
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

## Example

The library uses protocols for vectors and matrices. The `Manifold` and `CrossSection` types are generic over V, so you can plug in your own vector type.


```swift
struct MyVector: Vector3 {
    let x, y, z: Double
}

let box = Manifold.cube(size: MyVector(x: 12, y: 20, z: 20))
    .rotate(MyVector(x: 20, y: 25, z: 0))

let difference = Manifold.sphere(radius: 10, segmentCount: 25)
    .boolean(.difference, with: box)

let meshGL = difference.meshGL()
// Render or save meshGL.vertices, meshGL.triangles, etc.
```

Read the [Manifold documentation](https://manifoldcad.org/docs/html) for more information.

## Contributions

Contributions are welcome! Submit pull requests or open issues to discuss improvements or report bugs.
