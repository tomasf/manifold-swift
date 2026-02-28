import Testing
@testable import Manifold3D

// Manifold-Swift testing philosophy:
//
// This package wraps Manifold's C++ API. The test suite validates wrapper contracts,
// not Manifold's core geometry algorithms.
//
// What we test:
// 1) Swift wrapper API contracts and wiring.
// 2) Default argument behavior (implicit call matches explicit defaults).
// 3) High-level invariants for successful operations:
//    - valid/non-error wrapper outputs
//    - expected non-empty or shape-level behavior
//    - stable counts/volume/bounds where appropriate
// 4) Error propagation at the Swift boundary (throws/status mapping).
// 5) New public APIs with at least one default/contract test and one happy-path behavior test.
//
// What we do not test:
// 1) Deep geometry algorithm correctness already covered by upstream Manifold tests.
// 2) Large golden meshes or brittle numeric snapshots for every operation.
// 3) Expensive, flaky, or highly stateful test scenarios when lightweight contract tests are sufficient.
//
// Style rules for new tests:
// 1) Use Swift Testing (`import Testing`) with human-readable backticked function names.
// 2) Prefer deterministic, fast tests with small primitives.
// 3) Avoid mutating global settings in ways that can race under parallel test execution.
// 4) If asserting floating point values, use tolerance-based comparisons.
//
// Shared test support types/helpers live below.

struct TestVec2: Vector2 {
    let x: Double
    let y: Double

    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

struct TestVec3: Vector3 {
    let x: Double
    let y: Double
    let z: Double

    init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
}

typealias TestManifold = Manifold<TestVec3>
typealias TestCrossSection = CrossSection<TestVec2>
typealias TestPolygon = Polygon<TestVec2>

enum TestSupport {
    static func expectNoStatusError(_ manifold: TestManifold) {
        if let status = manifold.status {
            Issue.record("Expected no status error, got: \(status)")
        }
    }

    static func expectVec3Close(_ lhs: TestVec3, _ rhs: TestVec3, tolerance: Double = 1e-9) {
        #expect(abs(lhs.x - rhs.x) <= tolerance)
        #expect(abs(lhs.y - rhs.y) <= tolerance)
        #expect(abs(lhs.z - rhs.z) <= tolerance)
    }

    static func expectVec2Close(_ lhs: TestVec2, _ rhs: TestVec2, tolerance: Double = 1e-9) {
        #expect(abs(lhs.x - rhs.x) <= tolerance)
        #expect(abs(lhs.y - rhs.y) <= tolerance)
    }
}
