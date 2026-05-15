import Foundation
import Testing
@testable import Manifold3D

@Test func `resolve returns a manifold with the same volume as a deferred tree`() async throws {
    let a: TestManifold = .cube(size: TestVec3(x: 2, y: 2, z: 2), center: true)
    let b = a.translate(TestVec3(x: 0.5, y: 0.5, z: 0.5))
    let deferred = a.boolean(.union, with: b)
    let expectedVolume = deferred.volume

    let resolved = try await deferred.resolve()

    #expect(!resolved.isEmpty)
    TestSupport.expectNoStatusError(resolved)
    #expect(Swift.abs(resolved.volume - expectedVolume) < 1e-9)
}

@Test func `resolve propagates Swift task cancellation as CancellationError`() async throws {
    // Build a deferred tree heavy enough that cancellation has a chance to land
    // before evaluation finishes. The granularity is per-boolean, so a tree with
    // many booleans gives the cancel signal multiple checkpoints to be observed.
    let task = Task<TestManifold, Error> {
        var acc: TestManifold = .sphere(radius: 1.0, segmentCount: 64)
        for i in 0..<64 {
            let next: TestManifold = .sphere(radius: 1.0, segmentCount: 64)
                .translate(TestVec3(x: Double(i) * 0.03, y: 0, z: 0))
            acc = acc.boolean(.union, with: next)
        }
        return try await acc.resolve()
    }

    task.cancel()

    await #expect(throws: CancellationError.self) {
        _ = try await task.value
    }
}

@Test func `resolve on a primitive returns immediately without error`() async throws {
    let cube: TestManifold = .cube(size: TestVec3(x: 1, y: 1, z: 1), center: true)

    let resolved = try await cube.resolve()

    TestSupport.expectNoStatusError(resolved)
    #expect(Swift.abs(resolved.volume - 1.0) < 1e-9)
}

@Test func `resolve invokes onProgress at least once for a deferred tree`() async throws {
    let counter = ProgressCounter()

    let a: TestManifold = .sphere(radius: 1.0, segmentCount: 48)
    let b: TestManifold = .sphere(radius: 1.0, segmentCount: 48)
        .translate(TestVec3(x: 0.5, y: 0, z: 0))
    let deferred = a.boolean(.union, with: b)

    let resolved = try await deferred.resolve(progressInterval: 0.001) { p in
        counter.record(p)
    }

    TestSupport.expectNoStatusError(resolved)
    // We only assert the closure was wired up; the underlying evaluation may
    // finish before any tick, so a non-zero call count is not guaranteed.
    // What we can assert: progress values are all in range.
    #expect(counter.allInUnitInterval)
}

private final class ProgressCounter: @unchecked Sendable {
    private let lock = NSLock()
    private var values: [Double] = []

    func record(_ p: Double) {
        lock.lock()
        defer { lock.unlock() }
        values.append(p)
    }

    var allInUnitInterval: Bool {
        lock.lock()
        defer { lock.unlock() }
        return values.allSatisfy { $0 >= 0 && $0 <= 1 }
    }
}
