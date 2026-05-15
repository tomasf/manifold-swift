import Testing
@testable import Manifold3D

@Test func `rayCast through a unit cube returns two hits at the front and back faces`() {
    let cube: TestManifold = .cube(size: TestVec3(x: 1, y: 1, z: 1), center: true)

    // Cast from outside on -X to outside on +X through the center.
    let hits = cube.rayCast(
        from: TestVec3(x: -2, y: 0, z: 0),
        to: TestVec3(x: 2, y: 0, z: 0)
    )

    #expect(hits.count == 2)

    let sortedHits = hits.sorted(by: { $0.parametricDistance < $1.parametricDistance })
    // Cube spans x in [-0.5, 0.5]; ray segment is [-2, 2], length 4.
    // Front face hit at x = -0.5 → t = (-0.5 - -2)/4 = 0.375
    // Back face hit at  x = +0.5 → t = (+0.5 - -2)/4 = 0.625
    #expect(Swift.abs(sortedHits[0].parametricDistance - 0.375) < 1e-9)
    #expect(Swift.abs(sortedHits[1].parametricDistance - 0.625) < 1e-9)

    // Front face normal points in -X (out of the cube along ray direction).
    TestSupport.expectVec3Close(sortedHits[0].normal, TestVec3(x: -1, y: 0, z: 0), tolerance: 1e-9)
    // Back face normal points in +X.
    TestSupport.expectVec3Close(sortedHits[1].normal, TestVec3(x: 1, y: 0, z: 0), tolerance: 1e-9)
}

@Test func `rayCast that misses the manifold returns no hits`() {
    let cube: TestManifold = .cube(size: TestVec3(x: 1, y: 1, z: 1), center: true)

    let hits = cube.rayCast(
        from: TestVec3(x: -2, y: 5, z: 5),
        to: TestVec3(x: 2, y: 5, z: 5)
    )

    #expect(hits.isEmpty)
}

@Test func `rayCast hit position lies on the parametric line between origin and endpoint`() {
    let cube: TestManifold = .cube(size: TestVec3(x: 1, y: 1, z: 1), center: true)
    let origin = TestVec3(x: -2, y: 0.1, z: 0.2)
    let endpoint = TestVec3(x: 2, y: 0.1, z: 0.2)

    let hits = cube.rayCast(from: origin, to: endpoint)

    #expect(!hits.isEmpty)
    for hit in hits {
        let expected = TestVec3(
            x: origin.x + (endpoint.x - origin.x) * hit.parametricDistance,
            y: origin.y + (endpoint.y - origin.y) * hit.parametricDistance,
            z: origin.z + (endpoint.z - origin.z) * hit.parametricDistance
        )
        TestSupport.expectVec3Close(hit.position, expected, tolerance: 1e-9)
        #expect(hit.parametricDistance >= 0 && hit.parametricDistance <= 1)
        #expect(hit.triangleIndex >= 0 && hit.triangleIndex < cube.triangleCount)
    }
}
