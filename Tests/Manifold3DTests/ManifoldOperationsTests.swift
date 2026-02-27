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
