import Testing
@testable import Manifold3D

private let unitSphereSDF: @Sendable (TestVec3) -> Double = { v in
    (v.x * v.x + v.y * v.y + v.z * v.z).squareRoot() - 1.0
}
private let sphereBounds = (TestVec3(x: -1.5, y: -1.5, z: -1.5), TestVec3(x: 1.5, y: 1.5, z: 1.5))

@Test func `context manifold(from:) matches the mesh initializer`() async throws {
    let mesh = TestManifold.sphere(radius: 1, segmentCount: 24).meshGL()

    let viaContext = try await TestManifold.ExecutionContext().manifold(from: mesh)
    let direct = try TestManifold(mesh)

    TestSupport.expectNoStatusError(viaContext)
    #expect(viaContext.triangleCount == direct.triangleCount)
    #expect(abs(viaContext.volume - direct.volume) <= 1e-9)
}

@Test func `context manifold(from:) throws for an invalid mesh`() async {
    let mesh = MeshGL<TestVec3>(
        vertices: [
            TestVec3(x: 0, y: 0, z: 0),
            TestVec3(x: 1, y: 0, z: 0),
            TestVec3(x: 0, y: 1, z: 0),
        ],
        triangles: [Triangle(0, 1, 3)]
    )

    do {
        _ = try await TestManifold.ExecutionContext().manifold(from: mesh)
        Issue.record("Expected construction to throw for invalid triangle index")
    } catch let error as ManifoldError {
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

@Test func `context smoothManifold(from:) matches the smooth initializer`() async throws {
    let mesh = TestManifold.cube(size: TestVec3(x: 2, y: 2, z: 2), center: true).meshGL()

    let viaContext = try await TestManifold.ExecutionContext().smoothManifold(from: mesh).refine(piecesPerEdge: 3)
    let direct = TestManifold(meshGL: mesh).refine(piecesPerEdge: 3)

    TestSupport.expectNoStatusError(viaContext)
    #expect(viaContext.triangleCount == direct.triangleCount)
    #expect(abs(viaContext.volume - direct.volume) <= 1e-9)
}

@Test func `context smoothManifold default smoothEdges matches explicit empty dictionary`() async throws {
    let mesh = TestManifold.cube(size: TestVec3(x: 2, y: 2, z: 2), center: true).meshGL()
    let context = TestManifold.ExecutionContext()

    let implicit = try await context.smoothManifold(from: mesh).refine(piecesPerEdge: 2)
    let explicit = try await context.smoothManifold(from: mesh, smoothEdges: [:]).refine(piecesPerEdge: 2)

    #expect(implicit.triangleCount == explicit.triangleCount)
    #expect(abs(implicit.volume - explicit.volume) <= 1e-9)
}

@Test func `context levelSet matches the static levelSet`() async throws {
    let viaContext = try await TestManifold.ExecutionContext().levelSet(bounds: sphereBounds, edgeLength: 0.3, functor: unitSphereSDF)
    let direct = TestManifold.levelSet(bounds: sphereBounds, edgeLength: 0.3, functor: unitSphereSDF)

    TestSupport.expectNoStatusError(viaContext)
    #expect(!viaContext.isEmpty)
    #expect(viaContext.triangleCount == direct.triangleCount)
    #expect(abs(viaContext.volume - direct.volume) <= 1e-9)
}

@Test func `context levelSet default tolerance matches explicit nil`() async throws {
    let context = TestManifold.ExecutionContext()

    let implicit = try await context.levelSet(bounds: sphereBounds, edgeLength: 0.5, functor: unitSphereSDF)
    let explicit = try await context.levelSet(bounds: sphereBounds, edgeLength: 0.5, tolerance: nil, functor: unitSphereSDF)

    #expect(implicit.triangleCount == explicit.triangleCount)
    #expect(!implicit.isEmpty)
}

@Test func `context reports progress in the unit interval`() async throws {
    let context = TestManifold.ExecutionContext()
    _ = try await context.levelSet(bounds: sphereBounds, edgeLength: 0.3, functor: unitSphereSDF)

    #expect(context.progress >= 0 && context.progress <= 1)
}

@Test func `a cancelled context throws CancellationError`() async {
    let context = TestManifold.ExecutionContext()
    #expect(!context.isCancelled)

    context.cancel()
    #expect(context.isCancelled)

    let mesh = TestManifold.cube(size: TestVec3(x: 1, y: 1, z: 1), center: true).meshGL()
    await #expect(throws: CancellationError.self) {
        _ = try await context.manifold(from: mesh)
    }
    await #expect(throws: CancellationError.self) {
        _ = try await context.levelSet(bounds: sphereBounds, edgeLength: 0.5, functor: unitSphereSDF)
    }
}

@Test func `cancelling the task cancels the context`() async {
    let context = TestManifold.ExecutionContext()

    // Fine enough that sampling takes long enough for the cancellation to land first.
    let task = Task {
        try await context.levelSet(bounds: sphereBounds, edgeLength: 0.01, functor: unitSphereSDF)
    }
    task.cancel()

    await #expect(throws: CancellationError.self) {
        _ = try await task.value
    }
    #expect(context.isCancelled)
}

@Test func `cancelling stops a levelSet that is already running`() async throws {
    let context = TestManifold.ExecutionContext()
    let start = ContinuousClock.now
    let task = Task {
        try await context.levelSet(bounds: sphereBounds, edgeLength: 0.02, functor: unitSphereSDF)
    }

    // An idle context reports a progress of 1, and the levelSet resets it to 0 when it starts.
    // Its first phase, sampling the grid, takes most of the run and checks for cancellation as
    // it goes, so cancelling as soon as it has started lands mid-phase.
    while context.progress == 1 {
        try await Task.sleep(for: .milliseconds(1))
        if ContinuousClock.now - start > .seconds(30) {
            Issue.record("levelSet never started")
            break
        }
    }
    context.cancel()

    await #expect(throws: CancellationError.self) {
        _ = try await task.value
    }
}

private var deferredUnion: TestManifold {
    let a: TestManifold = .cube(size: TestVec3(x: 2, y: 2, z: 2), center: true)
    return a.boolean(.union, with: a.translate(TestVec3(x: 0.5, y: 0.5, z: 0.5)))
}

@Test func `context resolve matches implicit evaluation`() async throws {
    let resolved = try await TestManifold.ExecutionContext().resolve(deferredUnion)

    TestSupport.expectNoStatusError(resolved)
    #expect(resolved.triangleCount == deferredUnion.triangleCount)
    #expect(abs(resolved.volume - deferredUnion.volume) <= 1e-9)
}

@Test func `a resolved manifold doesn't keep the context attached`() async throws {
    let context = TestManifold.ExecutionContext()
    let resolved = try await context.resolve(deferredUnion)
    context.cancel()

    // Eager operations use an attached context, so this would fail as cancelled if the
    // context were still attached.
    let refined = resolved.refine(piecesPerEdge: 2)
    TestSupport.expectNoStatusError(refined)
}

@Test func `context refine variants match the manifold methods`() async throws {
    let source = TestManifold.sphere(radius: 1, segmentCount: 16).smoothOut()
    let context = TestManifold.ExecutionContext()

    let pieces = try await context.refine(source, piecesPerEdge: 3)
    #expect(pieces.triangleCount == source.refine(piecesPerEdge: 3).triangleCount)
    #expect(abs(pieces.volume - source.refine(piecesPerEdge: 3).volume) <= 1e-9)

    let length = try await context.refine(source, edgeLength: 0.2)
    #expect(length.triangleCount == source.refine(edgeLength: 0.2).triangleCount)

    let tolerance = try await context.refine(source, tolerance: 0.01)
    #expect(tolerance.triangleCount == source.refine(tolerance: 0.01).triangleCount)
    #expect(tolerance.triangleCount > source.triangleCount)
}

@Test func `context hull matches the manifold method`() async throws {
    let source = deferredUnion
    let viaContext = try await TestManifold.ExecutionContext().hull(source)

    TestSupport.expectNoStatusError(viaContext)
    #expect(abs(viaContext.volume - source.hull().volume) <= 1e-9)
    #expect(viaContext.volume > source.volume)
}

@Test func `context minkowski operations match the manifold methods`() async throws {
    let box: TestManifold = .cube(size: TestVec3(x: 2, y: 2, z: 2), center: true)
    let ball: TestManifold = .sphere(radius: 0.25, segmentCount: 8)
    let context = TestManifold.ExecutionContext()

    let sum = try await context.minkowskiSum(box, with: ball)
    #expect(abs(sum.volume - box.minkowskiSum(with: ball).volume) <= 1e-9)
    #expect(sum.volume > box.volume)

    let difference = try await context.minkowskiDifference(box, with: ball)
    #expect(abs(difference.volume - box.minkowskiDifference(with: ball).volume) <= 1e-9)
    #expect(difference.volume < box.volume)
}

@Test func `every manifold operation refuses to run on a cancelled context`() async {
    let context = TestManifold.ExecutionContext()
    context.cancel()
    let source = deferredUnion
    let ball: TestManifold = .sphere(radius: 0.25, segmentCount: 8)

    await #expect(throws: CancellationError.self) { _ = try await context.resolve(source) }
    await #expect(throws: CancellationError.self) { _ = try await context.refine(source, piecesPerEdge: 2) }
    await #expect(throws: CancellationError.self) { _ = try await context.refine(source, edgeLength: 0.5) }
    await #expect(throws: CancellationError.self) { _ = try await context.refine(source.smoothOut(), tolerance: 0.01) }
    await #expect(throws: CancellationError.self) { _ = try await context.hull(source) }
    await #expect(throws: CancellationError.self) { _ = try await context.minkowskiSum(source, with: ball) }
    await #expect(throws: CancellationError.self) { _ = try await context.minkowskiDifference(source, with: ball) }

    // An already evaluated manifold gives upstream nothing to cancel.
    let evaluated: TestManifold = .sphere(radius: 1, segmentCount: 16)
    _ = evaluated.volume
    await #expect(throws: CancellationError.self) { _ = try await context.resolve(evaluated) }
}
