import Testing
@testable import Manifold3D

@Test func `cross section init default fillRule matches explicit positive`() {
    let polygon = TestPolygon(vertices: [
        TestVec2(x: 0, y: 0),
        TestVec2(x: 2, y: 0),
        TestVec2(x: 2, y: 1),
        TestVec2(x: 0, y: 1),
    ])

    let implicit = TestCrossSection(polygons: [polygon])
    let explicit = TestCrossSection(polygons: [polygon], fillRule: .positive)

    #expect(implicit.vertexCount == explicit.vertexCount)
    #expect(implicit.contourCount == explicit.contourCount)
    #expect(abs(implicit.area - explicit.area) <= 1e-9)
}

@Test func `square default center matches explicit false`() {
    let implicit = TestCrossSection.square(size: TestVec2(x: 2, y: 3))
    let explicit = TestCrossSection.square(size: TestVec2(x: 2, y: 3), center: false)

    TestSupport.expectVec2Close(implicit.bounds.min, explicit.bounds.min)
    TestSupport.expectVec2Close(implicit.bounds.max, explicit.bounds.max)
    #expect(implicit.vertexCount == explicit.vertexCount)
}

@Test func `circle default segment count matches explicit nil`() {
    let implicit = TestCrossSection.circle(radius: 1)
    let explicit = TestCrossSection.circle(radius: 1, segmentCount: nil)

    #expect(implicit.vertexCount == explicit.vertexCount)
    #expect(implicit.contourCount == explicit.contourCount)
}

@Test func `offset defaults match explicit round and miter values`() {
    let source = TestCrossSection.circle(radius: 1, segmentCount: 20)

    let implicit = source.offset(amount: 0.2)
    let explicit = source.offset(amount: 0.2, joinType: .round, miterLimit: 2.0, circularSegments: nil)

    #expect(implicit.vertexCount == explicit.vertexCount)
    #expect(abs(implicit.area - explicit.area) <= 1e-9)
}

@Test func `revolve defaults match explicit full revolution`() {
    let profile = TestCrossSection.square(size: TestVec2(x: 0.4, y: 0.4), center: false)

    let implicit: TestManifold = profile.revolve()
    let explicit: TestManifold = profile.revolve(degrees: 360, circularSegments: nil)

    #expect(implicit.triangleCount == explicit.triangleCount)
    #expect(implicit.vertexCount == explicit.vertexCount)
}

@Test func `extrude defaults match explicit parameters`() {
    let profile = TestCrossSection.square(size: TestVec2(x: 1.0, y: 1.5), center: false)

    let implicit: TestManifold = profile.extrude(height: 2)
    let explicit: TestManifold = profile.extrude(height: 2, divisions: 0, twist: 0, scaleTop: nil)

    #expect(implicit.triangleCount == explicit.triangleCount)
    #expect(abs(implicit.volume - explicit.volume) <= 1e-9)
}
