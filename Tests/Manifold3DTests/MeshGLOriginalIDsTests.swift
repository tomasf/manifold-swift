import Testing
@testable import Manifold3D

// A unit cube as 12 triangles, wound counter-clockwise seen from outside. The two triangles of
// each face are adjacent in the list, so a per-face ID assignment forms contiguous runs.
private let cubeVertices: [TestVec3] = [
    TestVec3(x: 0, y: 0, z: 0), TestVec3(x: 1, y: 0, z: 0), TestVec3(x: 1, y: 1, z: 0), TestVec3(x: 0, y: 1, z: 0),
    TestVec3(x: 0, y: 0, z: 1), TestVec3(x: 1, y: 0, z: 1), TestVec3(x: 1, y: 1, z: 1), TestVec3(x: 0, y: 1, z: 1),
]

private let cubeTriangles: [Triangle] = [
    Triangle(0, 2, 1), Triangle(0, 3, 2), // bottom
    Triangle(4, 5, 6), Triangle(4, 6, 7), // top
    Triangle(0, 1, 5), Triangle(0, 5, 4), // front
    Triangle(2, 3, 7), Triangle(2, 7, 6), // back
    Triangle(0, 4, 7), Triangle(0, 7, 3), // left
    Triangle(1, 2, 6), Triangle(1, 6, 5), // right
]

@Test func `per-triangle original IDs come back grouped by ID`() throws {
    let base = TestManifold.reserveOriginalIDs(3)
    let ids = [base, base + 1, base + 2]

    // Four triangles per ID: two opposite faces each.
    let originalIDs = [ids[0], ids[0], ids[0], ids[0], ids[1], ids[1], ids[1], ids[1], ids[2], ids[2], ids[2], ids[2]]
    let mesh = MeshGL<TestVec3>(vertices: cubeVertices, triangles: cubeTriangles, originalIDs: originalIDs)

    let solid: TestManifold = try Manifold(mesh)
    TestSupport.expectNoStatusError(solid)
    #expect(abs(solid.volume - 1) <= 1e-9)

    let triangleCounts = solid.meshGL().originalIDs.mapValues(\.count)
    #expect(triangleCounts == [ids[0]: 4, ids[1]: 4, ids[2]: 4])
}

@Test func `a mesh with several original IDs is not itself an original`() throws {
    let base = TestManifold.reserveOriginalIDs(2)
    let originalIDs = Array(repeating: base, count: 6) + Array(repeating: base + 1, count: 6)
    let mesh = MeshGL<TestVec3>(vertices: cubeVertices, triangles: cubeTriangles, originalIDs: originalIDs)

    let solid: TestManifold = try Manifold(mesh)
    #expect(solid.originalID == nil)

    // Re-marking it as an original collapses every run onto one fresh ID.
    let collapsed = solid.asOriginal()
    let collapsedID = try #require(collapsed.originalID)
    #expect(collapsedID != base && collapsedID != base + 1)
    #expect(collapsed.meshGL().originalIDs.keys.count == 1)
}

@Test func `a single original ID is kept on the triangles without making the mesh an original`() throws {
    let id = TestManifold.reserveOriginalIDs(1)
    let mesh = MeshGL<TestVec3>(vertices: cubeVertices, triangles: cubeTriangles, originalIDs: Array(repeating: id, count: 12))

    let solid: TestManifold = try Manifold(mesh)
    TestSupport.expectNoStatusError(solid)

    // Supplying IDs means the mesh states its own provenance, so Manifold doesn't make it an
    // original of its own. The ID given is what the triangles carry.
    #expect(solid.originalID == nil)
    #expect(solid.meshGL().originalIDs.mapValues(\.count) == [id: 12])
}

@Test func `the same ID may appear in separate runs`() throws {
    let base = TestManifold.reserveOriginalIDs(2)
    let a = base, b = base + 1

    // a and b alternate face by face, so `a` is split over three runs and so is `b`.
    let originalIDs = [a, a, b, b, a, a, b, b, a, a, b, b]
    let mesh = MeshGL<TestVec3>(vertices: cubeVertices, triangles: cubeTriangles, originalIDs: originalIDs)

    let solid: TestManifold = try Manifold(mesh)
    TestSupport.expectNoStatusError(solid)

    let triangleCounts = solid.meshGL().originalIDs.mapValues(\.count)
    #expect(triangleCounts == [a: 6, b: 6])
}

@Test func `original IDs survive a Boolean operation`() throws {
    let base = TestManifold.reserveOriginalIDs(3)
    let ids = [base, base + 1, base + 2]
    let originalIDs = [ids[0], ids[0], ids[0], ids[0], ids[1], ids[1], ids[1], ids[1], ids[2], ids[2], ids[2], ids[2]]
    let mesh = MeshGL<TestVec3>(vertices: cubeVertices, triangles: cubeTriangles, originalIDs: originalIDs)
    let solid: TestManifold = try Manifold(mesh)

    // Cutting off one corner touches every face, so all three IDs remain, and the cutter
    // contributes its own ID for the new faces.
    let cutter: TestManifold = .cube(size: TestVec3(x: 1, y: 1, z: 1), center: false)
        .translate(TestVec3(x: 0.5, y: 0.5, z: 0.5))
    let cut = solid.boolean(.difference, with: cutter)
    TestSupport.expectNoStatusError(cut)
    #expect(abs(cut.volume - 0.875) <= 1e-9)

    let remainingIDs = Set(cut.meshGL().originalIDs.keys)
    #expect(remainingIDs.isSuperset(of: ids))

    // A pending transform hides `originalID`, so the cutter's ID is read off its own runs.
    let cutterID = try #require(cutter.meshGL().runs.first?.originalID)
    #expect(remainingIDs.contains(cutterID))
}

@Test func `an empty triangle list with no IDs builds an empty mesh`() {
    let mesh = MeshGL<TestVec3>(vertices: [], triangles: [], originalIDs: [])
    #expect(mesh.triangleCount == 0)
    #expect(mesh.runs.isEmpty)
}
