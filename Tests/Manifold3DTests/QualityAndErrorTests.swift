import Testing
@testable import Manifold3D

@Test func `quality circularSegmentCount returns positive value`() {
    let count = Quality.circularSegmentCount(for: 2.0)
    #expect(count > 0)
}

@Test func `polygon triangulate returns triangles for a convex quad`() {
    let polygon = TestPolygon(vertices: [
        TestVec2(x: 0, y: 0),
        TestVec2(x: 2, y: 0),
        TestVec2(x: 2, y: 1),
        TestVec2(x: 0, y: 1),
    ])

    let triangles = polygon.triangulate(epsilon: 1e-6)

    #expect(triangles.count == 2)
}

@Test func `invalid mesh initializer throws for out of bounds triangle`() {
    let mesh = MeshGL<TestVec3>(
        vertices: [
            TestVec3(x: 0, y: 0, z: 0),
            TestVec3(x: 1, y: 0, z: 0),
            TestVec3(x: 0, y: 1, z: 0),
        ],
        triangles: [Triangle(0, 1, 3)]
    )

    do {
        _ = try TestManifold(mesh)
        Issue.record("Expected initialization to throw for invalid triangle index")
    } catch let error as ManifoldError {
        // Wrapper contract: invalid mesh input throws a ManifoldError.
        // Exact case can vary based on which validation fails first internally.
        switch error {
        case .notManifold, .vertexOutOfBounds:
            break
        default:
            Issue.record("Unexpected ManifoldError: \(error)")
        }
    } catch {
        Issue.record("Unexpected error type: \(error)")
    }
}

@Test func `empty manifold has no status error`() {
    let manifold: TestManifold = .empty

    if let status = manifold.status {
        Issue.record("Expected nil status for empty manifold, got: \(status)")
    }
}

@Test func `minimumGap returns finite bounded value`() {
    let left: TestManifold = .cube(size: TestVec3(x: 1, y: 1, z: 1), center: false)
    let right = left.translate(TestVec3(x: 3, y: 0, z: 0))

    let gap = left.minimumGap(to: right, searchLength: 10)

    #expect(gap.isFinite)
    #expect(gap > 0)
    #expect(gap <= 10)
}
