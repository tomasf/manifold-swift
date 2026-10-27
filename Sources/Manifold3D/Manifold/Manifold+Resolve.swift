import Foundation

public extension Manifold {
    /// Forces evaluation of any deferred CSG operations, returning the resolved manifold.
    ///
    /// Manifold builds up a deferred tree for Boolean operations, transforms, warps, and other
    /// non-eager operations. Queries that need concrete vertex data — such as
    /// ``meshGL(normalChannelIndex:)``, ``volume``, ``status``, or ``vertexCount`` — implicitly
    /// force evaluation. `resolve()` does so explicitly, off the calling task, and is cancellable:
    ///
    /// ```swift
    /// let result = try await (a + b - c).resolve()
    /// ```
    ///
    /// Cancellation of the enclosing `Task` is forwarded to the underlying evaluation. The
    /// granularity is per-Boolean-operation, so a single large Boolean may run to completion
    /// before cancellation is observed; the next operation in the tree will short-circuit.
    ///
    /// Once `resolve()` returns, subsequent queries on the result (``meshGL(normalChannelIndex:)``,
    /// ``volume``, etc.) read from the already-evaluated leaf and are inexpensive.
    ///
    /// - Parameters:
    ///   - progressInterval: How often `onProgress` is invoked while evaluation is in flight,
    ///     in seconds. Defaults to 0.1. Ignored if `onProgress` is `nil`.
    ///   - onProgress: An optional closure invoked with normalized evaluation progress in the
    ///     range `0...1`. May be called from a background thread. Not guaranteed to be called
    ///     with `1.0` on completion.
    /// - Returns: A manifold with its CSG tree fully evaluated.
    /// - Throws: ``ManifoldError`` if evaluation fails. Throws `CancellationError` if the
    ///   enclosing task is cancelled before evaluation completes.
    func resolve(
        progressInterval: TimeInterval = 0.1,
        onProgress: (@Sendable (Double) -> Void)? = nil
    ) async throws -> Manifold {
        let context = ExecutionContext()

        return try await withThrowingTaskGroup(of: Manifold?.self) { group in
            // Cancelling the calling task cancels this child, which cancels the context.
            group.addTask {
                try await context.resolve(self)
            }

            if let onProgress {
                let sleepNanos = UInt64(max(0, progressInterval) * 1_000_000_000)
                group.addTask {
                    while !Task.isCancelled {
                        try? await Task.sleep(nanoseconds: sleepNanos)
                        if Task.isCancelled { break }
                        onProgress(context.progress)
                    }
                    return nil
                }
            }

            for try await result in group {
                if let resolved = result {
                    group.cancelAll()
                    return resolved
                }
            }
            throw CancellationError()
        }
    }
}
