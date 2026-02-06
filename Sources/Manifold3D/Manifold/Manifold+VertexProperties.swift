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
    /// - Parameter channelIndex: The starting property channel index where the three normal components will be stored.
    /// - Parameter minSharpAngle: The minimum angle (in degrees) between adjacent faces for a sharp edge. Defaults to `60`.
    func calculateNormals(channelIndex: Int, minSharpAngle: Double = 60) -> Self {
        Self(mesh.CalculateNormals(Int32(channelIndex), minSharpAngle))
    }

    /// Calculates Gaussian and mean curvature approximations at each vertex.
    /// - Parameter gaussianChannelIndex: The property channel index for Gaussian curvature output.
    /// - Parameter meanChannelIndex: The property channel index for mean curvature output.
    func calculateCurvature(gaussianChannelIndex: Int, meanChannelIndex: Int) -> Self {
        Self(mesh.CalculateCurvature(Int32(gaussianChannelIndex), Int32(meanChannelIndex)))
    }
}
