internal import ManifoldCPP

/// A single intersection between a ray segment and a ``Manifold``.
///
/// Returned by ``Manifold/rayCast(from:to:)``. Hits are ordered by increasing
/// ``parametricDistance``.
public struct RayHit<Vector: Vector3>: Sendable {
    /// The index of the hit triangle in the manifold's triangle list.
    public let triangleIndex: Int

    /// The parametric position along the ray segment in the closed interval `0...1`,
    /// where `0` is the origin and `1` is the endpoint. Hits exactly at the origin
    /// or endpoint are included.
    public let parametricDistance: Double

    /// The 3D position of the hit point.
    public let position: Vector

    /// The geometric face normal at the hit.
    public let normal: Vector

    internal init(_ hit: manifold.RayHit) {
        self.triangleIndex = Int(hit.faceID)
        self.parametricDistance = hit.distance
        self.position = Vector(hit.position)
        self.normal = Vector(hit.normal)
    }
}
