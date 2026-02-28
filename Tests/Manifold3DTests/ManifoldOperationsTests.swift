import Testing
@testable import Manifold3D

@Test func `boolean union of overlapping primitives returns non-empty manifold`() {
    let left: TestManifold = .cube(size: TestVec3(x: 2, y: 2, z: 2), center: true)
    let right = left.translate(TestVec3(x: 0.5, y: 0.5, z: 0.5))

    let result = left.boolean(.union, with: right)

    #expect(!result.isEmpty)
    TestSupport.expectNoStatusError(result)
}

@Test func `batch boolean union returns non-empty manifold`() {
    let a: TestManifold = .cube(size: TestVec3(x: 1, y: 1, z: 1), center: true)
    let b = a.translate(TestVec3(x: 0.75, y: 0, z: 0))

    let result = TestManifold.boolean(.union, with: [a, b])

    #expect(!result.isEmpty)
    TestSupport.expectNoStatusError(result)
}

@Test func `minkowski sum returns valid non-empty manifold`() {
    let a: TestManifold = .cube(size: TestVec3(x: 1, y: 1, z: 1), center: true)
    let b: TestManifold = .sphere(radius: 0.4, segmentCount: 16)

    let result = a.minkowskiSum(with: b)

    #expect(!result.isEmpty)
    TestSupport.expectNoStatusError(result)
}

@Test func `minkowski difference returns valid manifold`() {
    let a: TestManifold = .sphere(radius: 1.2, segmentCount: 20)
    let b: TestManifold = .cube(size: TestVec3(x: 0.4, y: 0.4, z: 0.4), center: true)

    let result = a.minkowskiDifference(with: b)

    #expect(result.triangleCount > 0)
    TestSupport.expectNoStatusError(result)
}

@Test func `split by manifold returns two manifolds`() {
    let solid: TestManifold = .cube(size: TestVec3(x: 2, y: 2, z: 2), center: true)
    let cutter: TestManifold = .sphere(radius: 0.9, segmentCount: 18)

    let (intersection, difference) = solid.split(by: cutter)

    #expect(!intersection.isEmpty)
    #expect(!difference.isEmpty)
}

@Test func `split by plane returns two manifolds`() {
    let solid: TestManifold = .cube(size: TestVec3(x: 2, y: 2, z: 2), center: true)

    let (positive, negative) = solid.split(by: TestVec3(x: 0, y: 0, z: 1), originOffset: 0)

    #expect(!positive.isEmpty)
    #expect(!negative.isEmpty)
}

@Test func `trim by plane returns expected half-space result`() {
    let solid: TestManifold = .cube(size: TestVec3(x: 2, y: 2, z: 2), center: true)

    let trimmed = solid.trim(by: TestVec3(x: 0, y: 0, z: 1), originOffset: 0)

    #expect(!trimmed.isEmpty)
    #expect(trimmed.volume < solid.volume)
}

// MARK: - Transforms

@Test func `translate shifts manifold bounds`() {
    let cube: TestManifold = .cube()
    let translated = cube.translate(TestVec3(x: 3, y: 1, z: 2))

    TestSupport.expectVec3Close(translated.bounds.min, TestVec3(x: 3, y: 1, z: 2))
    TestSupport.expectVec3Close(translated.bounds.max, TestVec3(x: 4, y: 2, z: 3))
}

@Test func `scale multiplies volume by expected factor`() {
    let cube: TestManifold = .cube()
    let scaled = cube.scale(TestVec3(x: 2, y: 2, z: 2))

    #expect(abs(scaled.volume - 8.0) <= 1e-9)
}

@Test func `rotate preserves volume`() {
    let cube: TestManifold = .cube()
    let rotated = cube.rotate(TestVec3(x: 45, y: 30, z: 60))

    #expect(abs(rotated.volume - cube.volume) <= 1e-9)
    TestSupport.expectNoStatusError(rotated)
}

@Test func `mirror reflects bounds across plane`() {
    let cube: TestManifold = .cube()
    let mirrored = cube.mirror(TestVec3(x: 0, y: 0, z: 1))

    TestSupport.expectVec3Close(mirrored.bounds.min, TestVec3(x: 0, y: 0, z: -1))
    TestSupport.expectVec3Close(mirrored.bounds.max, TestVec3(x: 1, y: 1, z: 0))
}

// MARK: - Hull

@Test func `instance hull returns valid convex result`() {
    let sphere: TestManifold = .sphere(radius: 1, segmentCount: 16)
    let result = sphere.hull()

    #expect(!result.isEmpty)
    TestSupport.expectNoStatusError(result)
}

@Test func `hull of multiple manifolds encompasses all inputs`() {
    let a: TestManifold = .cube(size: TestVec3(x: 1, y: 1, z: 1))
    let b = a.translate(TestVec3(x: 3, y: 0, z: 0))
    let result = TestManifold.hull([a, b])

    #expect(!result.isEmpty)
    #expect(result.volume > a.volume)
}

@Test func `hull of points returns non-empty result`() {
    let points: [TestVec3] = [
        TestVec3(x: 0, y: 0, z: 0),
        TestVec3(x: 1, y: 0, z: 0),
        TestVec3(x: 0, y: 1, z: 0),
        TestVec3(x: 0, y: 0, z: 1),
    ]
    let result = TestManifold.hull(points)

    #expect(!result.isEmpty)
    TestSupport.expectNoStatusError(result)
}

// MARK: - Warp

@Test func `warp shifts all vertices`() {
    let cube: TestManifold = .cube()
    let warped = cube.warp { v in TestVec3(x: v.x + 5, y: v.y, z: v.z) }

    TestSupport.expectVec3Close(warped.bounds.min, TestVec3(x: 5, y: 0, z: 0))
    TestSupport.expectVec3Close(warped.bounds.max, TestVec3(x: 6, y: 1, z: 1))
}

// MARK: - Decompose

@Test func `decompose of connected solid returns one component`() {
    let sphere: TestManifold = .sphere(radius: 1, segmentCount: 8)
    let components = sphere.decompose()

    #expect(components.count == 1)
}

@Test func `decompose of disjoint solids returns separate components`() {
    let a: TestManifold = .cube(size: TestVec3(x: 1, y: 1, z: 1))
    let b = a.translate(TestVec3(x: 5, y: 0, z: 0))
    let union = TestManifold.boolean(.union, with: [a, b])
    let components = union.decompose()

    #expect(components.count == 2)
}

// MARK: - Projection

@Test func `projection of cube returns non-empty cross-section`() {
    let cube: TestManifold = .cube(size: TestVec3(x: 2, y: 3, z: 4))
    let projection: TestCrossSection = cube.projection()

    #expect(!projection.isEmpty)
    #expect(projection.area > 0)
}

// MARK: - Provenance

@Test func `asOriginal assigns a valid originalID`() {
    let primitive: TestManifold = .sphere(radius: 1, segmentCount: 8)
    let original = primitive.asOriginal()

    #expect(original.originalID != nil)
}

@Test func `reserveOriginalIDs returns non-negative start`() {
    let start = TestManifold.reserveOriginalIDs(4)

    #expect(start >= 0)
}

// MARK: - Refinement and smoothing

@Test func `refine by pieces increases triangle count`() {
    let sphere: TestManifold = .sphere(radius: 1, segmentCount: 8)
    let refined = sphere.refine(piecesPerEdge: 2)

    #expect(refined.triangleCount > sphere.triangleCount)
}

@Test func `settingTolerance changes tolerance`() {
    let cube: TestManifold = .cube()
    let adjusted = cube.settingTolerance(1e-4)

    #expect(adjusted.tolerance > 0)
    #expect(!adjusted.isEmpty)
}

// MARK: - Vertex properties

@Test func `setProperties updates property channel count`() {
    let sphere: TestManifold = .sphere(radius: 1, segmentCount: 8)
    let withProps = sphere.setProperties(channelCount: 6) { _, _ in
        [0, 0, 0, 0, 0, 0]
    }

    #expect(withProps.propertyCount == 6)
}

@Test func `calculateCurvature returns valid manifold`() {
    let sphere: TestManifold = .sphere(radius: 1, segmentCount: 8)
    let withProps = sphere.setProperties(channelCount: 5) { _, _ in [0, 0, 0, 0, 0] }
    let withCurvature = withProps.calculateCurvature(gaussianChannelIndex: 3, meanChannelIndex: 4)

    #expect(!withCurvature.isEmpty)
    TestSupport.expectNoStatusError(withCurvature)
}

// MARK: - Geometric properties

@Test func `genus of sphere is zero`() {
    let sphere: TestManifold = .sphere(radius: 1, segmentCount: 16)

    #expect(sphere.genus == 0)
}

@Test func `surface area of unit sphere approximates 4 pi`() {
    let sphere: TestManifold = .sphere(radius: 1, segmentCount: 32)

    #expect(abs(sphere.surfaceArea - 4 * Double.pi) < 0.5)
}

// MARK: - MeshGL

@Test func `meshGL vertex and triangle array counts match properties`() {
    let cube: TestManifold = .cube()
    let mesh = cube.meshGL()

    #expect(mesh.vertices.count == mesh.vertexCount)
    #expect(mesh.triangles.count == mesh.triangleCount)
}

@Test func `meshGL roundtrip preserves triangle count`() throws {
    let original: TestManifold = .sphere(radius: 1, segmentCount: 8)
    let roundtripped = try TestManifold(original.meshGL())

    #expect(roundtripped.triangleCount == original.triangleCount)
}

// MARK: - Specific shapes

@Test func `cylinder with explicit topRadius creates truncated cone`() {
    let cone = TestManifold.cylinder(height: 2, bottomRadius: 1, topRadius: 0.5)
    let cylinder = TestManifold.cylinder(height: 2, bottomRadius: 1)

    #expect(!cone.isEmpty)
    #expect(cone.volume < cylinder.volume)
}

@Test func `levelSet creates manifold from sphere SDF`() {
    let bounds = (TestVec3(x: -1.5, y: -1.5, z: -1.5), TestVec3(x: 1.5, y: 1.5, z: 1.5))
    let result = TestManifold.levelSet(bounds: bounds, edgeLength: 0.3) { v in
        (v.x * v.x + v.y * v.y + v.z * v.z).squareRoot() - 1.0
    }

    #expect(!result.isEmpty)
    #expect(result.triangleCount > 0)
}
