import Foundation
internal import ManifoldCPP
internal import ManifoldBridge

// The context's `manifold(from:)` method shadows the C++ namespace inside it, so name these here.
internal typealias CxxExecutionContext = manifold.ExecutionContext
internal typealias CxxManifold = manifold.Manifold
internal typealias CxxSmoothness = manifold.Smoothness

public extension Manifold {
    /// Runs slow operations so that they can be cancelled and report their progress.
    ///
    /// Create a context, await one of its operations, and read ``progress`` or call ``cancel()``
    /// from elsewhere while it runs. Cancelling the task that awaits an operation cancels the
    /// context too.
    ///
    /// ```swift
    /// let context = Manifold.ExecutionContext()
    /// let surface = try await context.levelSet(bounds: bounds, edgeLength: 0.1) { distance(to: $0) }
    /// ```
    ///
    /// Cancellation is permanent: once a context is cancelled, every later operation on it throws
    /// `CancellationError`. Use a separate context for each operation you want to cancel on its own.
    /// Operations can share a context and run at the same time, but its ``progress`` is then
    /// meaningless.
    final class ExecutionContext: @unchecked Sendable {
        internal let cxx: CxxExecutionContext

        /// Creates a context that hasn't been cancelled.
        public init() {
            cxx = CxxExecutionContext()
        }

        /// Cancels the context. Operations running on it stop at their next checkpoint and throw
        /// `CancellationError`, and later operations on it throw right away.
        public func cancel() {
            bridge.Cancel(cxx)
        }

        /// Whether the context has been cancelled.
        public var isCancelled: Bool {
            cxx.Cancelled()
        }

        /// The progress of the operation running on this context, from `0` to `1`. It's `1` before
        /// any operation has started, and isn't guaranteed to reach `1` when an operation finishes.
        public var progress: Double {
            cxx.Progress()
        }
    }
}

public extension Manifold.ExecutionContext {
    /// Creates a manifold from a mesh, validating that it is closed and manifold.
    ///
    /// This is the cancellable form of ``Manifold/init(_:)``.
    /// - Parameter meshGL: The mesh to construct from.
    /// - Returns: The new manifold.
    /// - Throws: A ``ManifoldError`` if the mesh is not valid, or `CancellationError` if the
    ///   context is cancelled.
    func manifold(from meshGL: MeshGL<Vector>) async throws -> Manifold<Vector> {
        nonisolated(unsafe) let mesh = meshGL.meshGL
        return try await run { bridge.FromMeshGL($0, mesh) }
    }

    /// Creates a smooth manifold from a mesh with per-edge smoothness values.
    ///
    /// This is the cancellable form of ``Manifold/init(meshGL:smoothEdges:)``.
    /// - Parameter meshGL: The input mesh.
    /// - Parameter smoothEdges: A dictionary mapping edge references to smoothness values (0 to 1). Defaults to an empty dictionary.
    /// - Returns: The new manifold.
    /// - Throws: A ``ManifoldError`` if the mesh is not valid, or `CancellationError` if the
    ///   context is cancelled.
    func smoothManifold(
        from meshGL: MeshGL<Vector>,
        smoothEdges: [MeshGL<Vector>.EdgeReference: Double] = [:]
    ) async throws -> Manifold<Vector> {
        nonisolated(unsafe) let mesh = meshGL.meshGL
        let smoothness = smoothEdges.map {
            CxxSmoothness(halfedge: $0.key.index, smoothness: $0.value)
        }
        return try await run { bridge.Smooth($0, mesh, .init(smoothness)) }
    }

    /// Creates a manifold from a signed distance function, with the surface
    /// extracted where the function equals `level` using marching tetrahedra.
    ///
    /// This is the cancellable form of ``Manifold/levelSet(bounds:edgeLength:level:tolerance:functor:)``.
    /// - Parameter bounds: The bounding box to evaluate the function within.
    /// - Parameter edgeLength: The grid cell size. Smaller values produce finer detail.
    /// - Parameter level: The iso-value at which to extract the surface. Defaults to `0`.
    /// - Parameter tolerance: The precision for surface location. Use `nil` for automatic (default).
    /// - Parameter functor: A function returning the signed distance at each point.
    ///   Negative values are inside the surface. It's called from several threads at once.
    /// - Returns: The new manifold.
    /// - Throws: `CancellationError` if the context is cancelled.
    func levelSet(
        bounds: (Vector, Vector),
        edgeLength: Double,
        level: Double = 0,
        tolerance: Double? = nil,
        functor: @escaping @Sendable (Vector) -> Double
    ) async throws -> Manifold<Vector> {
        try await run {
            bridge.LevelSet($0, { functor(.init($0)) }, .init(bounds.0.vec3, bounds.1.vec3), edgeLength, level, tolerance ?? -1, true)
        }
    }
}

public extension Manifold.ExecutionContext {
    /// Evaluates any deferred operations of a manifold, such as Booleans and transforms.
    ///
    /// This is the cancellable form of the evaluation that queries like ``Manifold/volume`` and
    /// ``Manifold/meshGL(normalChannelIndex:)`` do implicitly. Cancellation is checked between
    /// Boolean operations, so a single large Boolean may run to completion first.
    /// - Parameter manifold: The manifold to evaluate.
    /// - Returns: The evaluated manifold. Queries on it are inexpensive.
    /// - Throws: A ``ManifoldError`` if evaluation fails, or `CancellationError` if the context
    ///   is cancelled.
    func resolve(_ manifold: Manifold<Vector>) async throws -> Manifold<Vector> {
        try await run {
            let attached = manifold.mesh.WithContext($0)
            _ = attached.Status()
            // Evaluation returns the same manifold with this context still attached, which would
            // make later operations on it cancellable through this context. Hand back a copy
            // attached to a context nobody can cancel instead.
            return attached.WithContext(CxxExecutionContext())
        }
    }

    /// Subdivides each edge into the given number of pieces, applying smoothing if set.
    ///
    /// This is the cancellable form of ``Manifold/refine(piecesPerEdge:)``.
    /// - Parameter manifold: The manifold to refine.
    /// - Parameter piecesPerEdge: The number of pieces to split each edge into.
    /// - Returns: The refined manifold.
    /// - Throws: A ``ManifoldError`` if evaluation fails, or `CancellationError` if the context
    ///   is cancelled.
    func refine(_ manifold: Manifold<Vector>, piecesPerEdge: Int) async throws -> Manifold<Vector> {
        try await run { manifold.mesh.WithContext($0).Refine(Int32(piecesPerEdge)) }
    }

    /// Subdivides edges to achieve a target edge length, applying smoothing if set.
    ///
    /// This is the cancellable form of ``Manifold/refine(edgeLength:)``.
    /// - Parameter manifold: The manifold to refine.
    /// - Parameter edgeLength: The target maximum edge length.
    /// - Returns: The refined manifold.
    /// - Throws: A ``ManifoldError`` if evaluation fails, or `CancellationError` if the context
    ///   is cancelled.
    func refine(_ manifold: Manifold<Vector>, edgeLength: Double) async throws -> Manifold<Vector> {
        try await run { manifold.mesh.WithContext($0).RefineToLength(edgeLength) }
    }

    /// Subdivides edges to achieve a target surface tolerance, applying smoothing if set.
    ///
    /// This is the cancellable form of ``Manifold/refine(tolerance:)``.
    /// - Parameter manifold: The manifold to refine.
    /// - Parameter tolerance: The maximum distance the refined surface may deviate from the smooth ideal.
    /// - Returns: The refined manifold.
    /// - Throws: A ``ManifoldError`` if evaluation fails, or `CancellationError` if the context
    ///   is cancelled.
    func refine(_ manifold: Manifold<Vector>, tolerance: Double) async throws -> Manifold<Vector> {
        try await run { manifold.mesh.WithContext($0).RefineToTolerance(tolerance) }
    }

    /// Returns the convex hull of a manifold.
    ///
    /// This is the cancellable form of ``Manifold/hull()``. Cancellation is checked between the
    /// main phases of the hull computation.
    /// - Parameter manifold: The manifold to wrap.
    /// - Returns: The convex hull.
    /// - Throws: A ``ManifoldError`` if evaluation fails, or `CancellationError` if the context
    ///   is cancelled.
    func hull(_ manifold: Manifold<Vector>) async throws -> Manifold<Vector> {
        try await run { manifold.mesh.WithContext($0).Hull() }
    }

    /// Returns the Minkowski sum of two manifolds.
    ///
    /// This is the cancellable form of ``Manifold/minkowskiSum(with:)``.
    /// - Parameter manifold: The first manifold.
    /// - Parameter other: The manifold to add in Minkowski space.
    /// - Returns: The Minkowski sum.
    /// - Throws: A ``ManifoldError`` if evaluation fails, or `CancellationError` if the context
    ///   is cancelled.
    func minkowskiSum(_ manifold: Manifold<Vector>, with other: Manifold<Vector>) async throws -> Manifold<Vector> {
        try await run { manifold.mesh.WithContext($0).MinkowskiSum(other.mesh) }
    }

    /// Returns the Minkowski difference of two manifolds.
    ///
    /// This is the cancellable form of ``Manifold/minkowskiDifference(with:)``.
    /// - Parameter manifold: The first manifold.
    /// - Parameter other: The manifold to subtract in Minkowski space.
    /// - Returns: The Minkowski difference.
    /// - Throws: A ``ManifoldError`` if evaluation fails, or `CancellationError` if the context
    ///   is cancelled.
    func minkowskiDifference(_ manifold: Manifold<Vector>, with other: Manifold<Vector>) async throws -> Manifold<Vector> {
        try await run { manifold.mesh.WithContext($0).MinkowskiDifference(other.mesh) }
    }
}

private extension Manifold.ExecutionContext {
    /// Runs a synchronous operation on this context off the cooperative pool, forwarding
    /// cancellation of the calling task to the context.
    func run(
        _ operation: @escaping @Sendable (CxxExecutionContext) -> CxxManifold
    ) async throws -> Manifold<Vector> {
        initializeQoS()
        let outcome: (Manifold<Vector>, ManifoldError?)? = await withTaskCancellationHandler {
            // Upstream only checks for cancellation where there's work to do, so evaluating an
            // already evaluated manifold would succeed on a cancelled context. Check up front so
            // that every operation behaves the same.
            if isCancelled { return nil }
            return await Task.detached(priority: .userInitiated) {
                let result = Manifold(operation(self.cxx))
                return (result, result.status)
            }.value
        } onCancel: {
            cancel()
        }

        guard let (result, error) = outcome else { throw CancellationError() }
        if let error {
            if error == .cancelled { throw CancellationError() }
            throw error
        }
        return result
    }
}
