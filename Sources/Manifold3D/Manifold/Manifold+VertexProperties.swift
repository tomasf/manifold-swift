import Foundation
internal import ManifoldCPP
internal import ManifoldBridge

public extension Manifold {
    /// Creates or replaces per-vertex properties using a function evaluated at each vertex.
    ///
    /// The function receives the vertex position and the existing properties, and returns
    /// the new property values for that vertex. The number of properties per vertex is set
    /// to `channelCount` (which replaces any previous property channels).
    ///
    /// ```swift
    /// // Add UV coordinates based on position
    /// manifold.setProperties(channelCount: 5) { position, old in
    ///     [position.x, position.y, position.z, position.x, position.y]
    /// }
    /// ```
    ///
    /// - Parameter channelCount: The total number of property channels per vertex in the output (including position).
    /// - Parameter function: A closure that takes a vertex position and its existing properties, and returns the new properties.
    func setProperties(channelCount: Int, getter function: @escaping (_ position: Vector, _ oldProperties: [Double]) -> [Double]) -> Self {
        let oldCount = propertyCount
        return Self(bridge.SetProperties(mesh, .init(channelCount)) { newProps, position, oldProps in
            let props = function(.init(position), Array(UnsafeBufferPointer(start: oldProps, count: oldCount)))
            _ = UnsafeMutableBufferPointer(start: newProps, count: channelCount)
                .update(from: props)
        })
    }

    /// Calculates vertex normals and stores them in the specified property channels.
    ///
    /// Normals are area-weighted averages of adjacent face normals. Edges sharper than
    /// `minSharpAngle` create separate normals (hard edges).
    ///
    /// When `channelIndex` is `0` (the default), the standard normal slot is used: the
    /// recording is preserved as world-frame normals across subsequent transforms and
    /// Boolean operations, and ``meshGL(normalChannelIndex:)`` will auto-substitute the
    /// stored normals at output channels `3...5`. Non-zero values use a legacy deferred
    /// path and are not preserved across all operations.
    /// - Parameter channelIndex: The starting property channel index where the three normal components will be stored. Defaults to `0` (the standard slot).
    /// - Parameter minSharpAngle: The minimum angle (in degrees) between adjacent faces for a sharp edge. Defaults to `52.5`.
    func calculateNormals(channelIndex: Int = 0, minSharpAngle: Double = 52.5) -> Self {
        Self(mesh.CalculateNormals(Int32(channelIndex), minSharpAngle))
    }

    /// Calculates Gaussian and mean curvature approximations at each vertex.
    /// - Parameter gaussianChannelIndex: The property channel index for Gaussian curvature output.
    /// - Parameter meanChannelIndex: The property channel index for mean curvature output.
    func calculateCurvature(gaussianChannelIndex: Int, meanChannelIndex: Int) -> Self {
        Self(mesh.CalculateCurvature(Int32(gaussianChannelIndex), Int32(meanChannelIndex)))
    }
}
