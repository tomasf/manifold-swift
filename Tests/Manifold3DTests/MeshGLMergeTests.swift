import Testing
@testable import Manifold3D

// A closed tetrahedron whose corners are NOT shared by index: every face carries its own three
// vertices (12 positions, 4 distinct corners). This is the shape a file-format round-trip (e.g. STL)
// produces — geometrically closed, but non-manifold by index because no edge has a twin.
private func splitTetrahedron() -> MeshGL<TestVec3> {
    let a = TestVec3(x: 0, y: 0, z: 0)
    let b = TestVec3(x: 1, y: 0, z: 0)
    let c = TestVec3(x: 0, y: 1, z: 0)
    let d = TestVec3(x: 0, y: 0, z: 1)
    return MeshGL<TestVec3>(
        vertices: [a, c, b,  a, b, d,  a, d, c,  b, c, d],
        triangles: [Triangle(0, 1, 2), Triangle(3, 4, 5), Triangle(6, 7, 8), Triangle(9, 10, 11)]
    )
}

@Test func `merged reconnects split vertices so a closed mesh is accepted`() throws {
    let split = splitTetrahedron()

    // Without merging the surface is closed but non-manifold by index, so construction fails.
    let unmerged: TestManifold? = try? Manifold(split)
    #expect(unmerged == nil)

    // After merging, the coincident corners are reconnected and the mesh is accepted.
    let solid: TestManifold = try Manifold(split.merged())
    TestSupport.expectNoStatusError(solid)
    #expect(!solid.isEmpty)
    #expect(abs(solid.volume - 1.0 / 6.0) <= 1e-9)
}

@Test func `merged is a no-op for an already-connected mesh`() throws {
    let cube: TestManifold = .cube(size: TestVec3(x: 1, y: 1, z: 1), center: true)
    let mesh = cube.meshGL()

    let remerged: TestManifold = try Manifold(mesh.merged())
    TestSupport.expectNoStatusError(remerged)
    #expect(abs(remerged.volume - cube.volume) <= 1e-9)
}
