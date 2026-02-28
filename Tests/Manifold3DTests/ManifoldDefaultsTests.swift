import Testing
@testable import Manifold3D

@Test func `cube default matches explicit default parameters`() {
    let implicit: TestManifold = .cube()
    let explicit: TestManifold = .cube(size: TestVec3(x: 1, y: 1, z: 1), center: false)

    #expect(implicit.triangleCount == explicit.triangleCount)
    #expect(implicit.vertexCount == explicit.vertexCount)
    TestSupport.expectVec3Close(implicit.bounds.min, explicit.bounds.min)
    TestSupport.expectVec3Close(implicit.bounds.max, explicit.bounds.max)
}

@Test func `sphere default segment count matches explicit nil`() {
    let implicit: TestManifold = .sphere(radius: 2)
    let explicit: TestManifold = .sphere(radius: 2, segmentCount: nil)

    #expect(implicit.triangleCount == explicit.triangleCount)
    #expect(implicit.vertexCount == explicit.vertexCount)
}

@Test func `cylinder defaults match explicit defaults`() {
    let implicit: TestManifold = .cylinder(height: 4, bottomRadius: 1.5)
    let explicit: TestManifold = .cylinder(
        height: 4,
        bottomRadius: 1.5,
        topRadius: nil,
        segmentCount: nil,
        center: false
    )

    #expect(implicit.triangleCount == explicit.triangleCount)
    #expect(implicit.vertexCount == explicit.vertexCount)
    TestSupport.expectVec3Close(implicit.bounds.min, explicit.bounds.min)
    TestSupport.expectVec3Close(implicit.bounds.max, explicit.bounds.max)
}

@Test func `meshGL default normal channel matches explicit nil`() {
    let manifold: TestManifold = .sphere(radius: 1.2, segmentCount: 24)
    let implicit = manifold.meshGL()
    let explicit = manifold.meshGL(normalChannelIndex: nil)

    #expect(implicit.vertexCount == explicit.vertexCount)
    #expect(implicit.triangleCount == explicit.triangleCount)
    #expect(implicit.propertyCount == explicit.propertyCount)
}

@Test func `levelSet default tolerance matches explicit nil`() {
    let bounds = (TestVec3(x: -1.5, y: -1.5, z: -1.5), TestVec3(x: 1.5, y: 1.5, z: 1.5))
    let sdf: (TestVec3) -> Double = { v in (v.x * v.x + v.y * v.y + v.z * v.z).squareRoot() - 1.0 }

    let implicit = TestManifold.levelSet(bounds: bounds, edgeLength: 0.5, functor: sdf)
    let explicit = TestManifold.levelSet(bounds: bounds, edgeLength: 0.5, tolerance: nil, functor: sdf)

    #expect(implicit.triangleCount == explicit.triangleCount)
    #expect(!implicit.isEmpty)
}

@Test func `slice default height matches explicit zero`() {
    let manifold: TestManifold = .cube(size: TestVec3(x: 2, y: 2, z: 2), center: true)
    let implicit: TestCrossSection = manifold.slice()
    let explicit: TestCrossSection = manifold.slice(at: 0)

    #expect(implicit.vertexCount == explicit.vertexCount)
    #expect(implicit.contourCount == explicit.contourCount)
    #expect(abs(implicit.area - explicit.area) <= 1e-9)
}

@Test func `smoothOut default parameters match explicit defaults`() {
    let source: TestManifold = .cylinder(height: 3, bottomRadius: 1, segmentCount: 24)
    let implicit = source.smoothOut().refine(piecesPerEdge: 2)
    let explicit = source.smoothOut(minSharpAngle: 60, minSmoothness: 0).refine(piecesPerEdge: 2)

    #expect(implicit.triangleCount == explicit.triangleCount)
    #expect(abs(implicit.volume - explicit.volume) <= 1e-9)
}

@Test func `smooth initializer default smoothEdges matches explicit empty dictionary`() {
    let source: TestManifold = .cube(size: TestVec3(x: 2, y: 2, z: 2), center: true)
    let mesh = source.meshGL()

    let implicit = TestManifold(meshGL: mesh)
    let explicit = TestManifold(meshGL: mesh, smoothEdges: [:])

    #expect(implicit.triangleCount == explicit.triangleCount)
    #expect(implicit.vertexCount == explicit.vertexCount)
}

@Test func `simplify default epsilon matches explicit zero`() {
    let source: TestManifold = .sphere(radius: 1, segmentCount: 24)

    let implicit = source.simplify()
    let explicit = source.simplify(epsilon: 0)

    #expect(implicit.triangleCount == explicit.triangleCount)
    #expect(implicit.vertexCount == explicit.vertexCount)
}

@Test func `calculateNormals default minSharpAngle matches explicit sixty`() {
    let source: TestManifold = .sphere(radius: 1.5, segmentCount: 20)

    let implicit = source.calculateNormals(channelIndex: 0)
    let explicit = source.calculateNormals(channelIndex: 0, minSharpAngle: 60)

    #expect(implicit.propertyCount == explicit.propertyCount)
    #expect(implicit.propertyVertexCount == explicit.propertyVertexCount)
}
