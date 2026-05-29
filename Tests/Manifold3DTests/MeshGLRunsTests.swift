import Testing
@testable import Manifold3D

@Test func `runs on a primitive contain one run covering every triangle`() {
    let cube: TestManifold = .cube(size: TestVec3(x: 1, y: 1, z: 1), center: true)
    let mesh = cube.meshGL()

    let runs = mesh.runs

    #expect(runs.count == 1)
    #expect(runs[0].triangleRange == 0..<mesh.triangleCount)
    #expect(runs[0].isBackside == false)
}

@Test func `runs cover every triangle exactly once and originalIDs agree`() {
    let a: TestManifold = .cube(size: TestVec3(x: 2, y: 2, z: 2), center: true)
    let b: TestManifold = .sphere(radius: 1.4, segmentCount: 20)
        .translate(TestVec3(x: 0.6, y: 0, z: 0))
    let mesh = a.boolean(.difference, with: b).meshGL()

    let runs = mesh.runs
    #expect(runs.count >= 1)

    // Triangle ranges form a partition of [0, triangleCount).
    let totalCovered = runs.map(\.triangleRange.count).reduce(0, +)
    #expect(totalCovered == mesh.triangleCount)

    var sorted = runs.sorted(by: { $0.triangleRange.lowerBound < $1.triangleRange.lowerBound })
    #expect(sorted.first?.triangleRange.lowerBound == 0)
    #expect(sorted.last?.triangleRange.upperBound == mesh.triangleCount)
    for (lhs, rhs) in zip(sorted, sorted.dropFirst()) {
        #expect(lhs.triangleRange.upperBound == rhs.triangleRange.lowerBound)
    }

    // `runs` and `originalIDs` should describe the same partition by originalID.
    let runsByID: [Manifold.OriginalID: Int] = runs.reduce(into: [:]) { result, run in
        result[run.originalID, default: 0] += run.triangleRange.count
    }
    let idsByID: [Manifold.OriginalID: Int] = mesh.originalIDs.mapValues(\.count)
    #expect(runsByID == idsByID)
}

@Test func `subtraction marks the subtracted geometry's run as backside`() {
    let a: TestManifold = .cube(size: TestVec3(x: 2, y: 2, z: 2), center: true)
    let b: TestManifold = .sphere(radius: 0.9, segmentCount: 20)
    let mesh = a.boolean(.difference, with: b).meshGL()

    let runs = mesh.runs
    // A subtraction inverts the subtracted geometry — at least one run should be backside.
    #expect(runs.contains { $0.isBackside })
}
