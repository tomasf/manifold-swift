import Testing
@testable import Manifold3D

// MARK: - Boolean operations

@Test func `cross section boolean union returns larger area`() {
    let a = TestCrossSection.circle(radius: 1, segmentCount: 32)
    let b = a.translate(TestVec2(x: 0.5, y: 0))
    let result = a.boolean(.union, with: b)

    #expect(result.area > a.area)
}

@Test func `cross section boolean difference returns smaller area`() {
    let base = TestCrossSection.circle(radius: 1, segmentCount: 32)
    let cutter = TestCrossSection.circle(radius: 0.5, segmentCount: 32)
    let result = base.boolean(.difference, with: cutter)

    #expect(!result.isEmpty)
    #expect(result.area < base.area)
}

@Test func `cross section batch boolean union returns non-empty result`() {
    let a = TestCrossSection.square(size: TestVec2(x: 1, y: 1))
    let b = a.translate(TestVec2(x: 0.5, y: 0))
    let result = TestCrossSection.boolean(.union, with: [a, b])

    #expect(!result.isEmpty)
    #expect(result.area > a.area)
}

// MARK: - Transforms

@Test func `cross section translate shifts bounds`() {
    let square = TestCrossSection.square(size: TestVec2(x: 1, y: 1))
    let translated = square.translate(TestVec2(x: 3, y: 2))

    TestSupport.expectVec2Close(translated.bounds.min, TestVec2(x: 3, y: 2))
    TestSupport.expectVec2Close(translated.bounds.max, TestVec2(x: 4, y: 3))
}

@Test func `cross section scale changes area`() {
    let square = TestCrossSection.square(size: TestVec2(x: 1, y: 1))
    let scaled = square.scale(TestVec2(x: 2, y: 3))

    #expect(abs(scaled.area - 6.0) <= 1e-9)
}

@Test func `cross section rotate preserves area`() {
    let square = TestCrossSection.square(size: TestVec2(x: 2, y: 3))
    let rotated = square.rotate(45)

    #expect(abs(rotated.area - square.area) <= 1e-9)
}

@Test func `cross section mirror preserves area`() {
    let square = TestCrossSection.square(size: TestVec2(x: 1, y: 1))
    let mirrored = square.mirror(TestVec2(x: 1, y: 0))

    #expect(abs(mirrored.area - square.area) <= 1e-9)
    #expect(!mirrored.isEmpty)
}

// MARK: - Offset

@Test func `offset with positive amount increases area`() {
    let circle = TestCrossSection.circle(radius: 1, segmentCount: 32)
    let expanded = circle.offset(amount: 0.5, circularSegments: 16)

    #expect(expanded.area > circle.area)
}

@Test func `offset with negative amount decreases area`() {
    let circle = TestCrossSection.circle(radius: 1, segmentCount: 32)
    let shrunk = circle.offset(amount: -0.3, circularSegments: 16)

    #expect(!shrunk.isEmpty)
    #expect(shrunk.area < circle.area)
}

// MARK: - Hull

@Test func `cross section hull of points returns non-empty result`() {
    let points: [TestVec2] = [
        TestVec2(x: 0, y: 0),
        TestVec2(x: 2, y: 0),
        TestVec2(x: 2, y: 2),
        TestVec2(x: 0, y: 2),
        TestVec2(x: 1, y: 1),
    ]
    let result = TestCrossSection.hull(points)

    #expect(!result.isEmpty)
    #expect(abs(result.area - 4.0) <= 0.01)
}

@Test func `cross section hull of multiple cross sections returns non-empty result`() {
    let a = TestCrossSection.circle(radius: 0.5, segmentCount: 16)
    let b = a.translate(TestVec2(x: 2, y: 0))
    let result = TestCrossSection.hull([a, b])

    #expect(!result.isEmpty)
    #expect(result.area > a.area)
}

@Test func `instance hull of cross section returns non-empty result`() {
    let circle = TestCrossSection.circle(radius: 1, segmentCount: 32)
    let result = circle.hull()

    #expect(!result.isEmpty)
    #expect(result.area > 0)
}

// MARK: - Decompose

@Test func `cross section decompose of disjoint shapes returns separate components`() {
    let a = TestCrossSection.square(size: TestVec2(x: 1, y: 1))
    let b = a.translate(TestVec2(x: 5, y: 0))
    let union = TestCrossSection.boolean(.union, with: [a, b])
    let components = union.decompose()

    #expect(components.count == 2)
}

// MARK: - Polygons

@Test func `polygons returns contours for non-empty cross section`() {
    let circle = TestCrossSection.circle(radius: 1, segmentCount: 16)
    let polygons = circle.polygons()

    #expect(polygons.count == 1)
    #expect(polygons[0].vertices.count > 0)
}

// MARK: - Warp

@Test func `cross section warp shifts vertices`() {
    let square = TestCrossSection.square(size: TestVec2(x: 1, y: 1))
    let warped = square.warp { v in TestVec2(x: v.x + 4, y: v.y) }

    #expect(warped.bounds.min.x > 3)
}

// MARK: - Simplify

@Test func `simplify does not increase vertex count`() {
    let circle = TestCrossSection.circle(radius: 1, segmentCount: 64)
    let simplified = circle.simplify(epsilon: 0.01)

    #expect(!simplified.isEmpty)
    #expect(simplified.vertexCount <= circle.vertexCount)
}

// MARK: - Extrude and revolve

@Test func `extrude produces manifold with expected volume`() {
    let square = TestCrossSection.square(size: TestVec2(x: 1, y: 1))
    let extruded: TestManifold = square.extrude(height: 2)

    #expect(abs(extruded.volume - 2.0) <= 1e-9)
}

@Test func `revolve with partial angle produces smaller volume than full revolution`() {
    let profile = TestCrossSection.square(size: TestVec2(x: 0.3, y: 0.3), center: false)
    let partial: TestManifold = profile.revolve(degrees: 180)
    let full: TestManifold = profile.revolve(degrees: 360)

    #expect(!partial.isEmpty)
    #expect(partial.volume < full.volume)
}
