internal import ManifoldCPP
internal import ManifoldBridge

public extension Manifold {
    /// An empty manifold with no geometry.
    static var empty: Self {
        initializeQoS()
        return Self(manifold.Manifold())
    }

    /// Creates a regular tetrahedron centered at the origin with unit edge length.
    static func tetrahedron() -> Self {
        initializeQoS()
        return Self(manifold.Manifold.Tetrahedron())
    }

    /// Creates a sphere centered at the origin.
    /// - Parameter radius: The radius of the sphere.
    /// - Parameter segmentCount: The number of segments used to approximate the sphere.
    ///   Use `0` to choose the count from the current ``Quality`` circular settings (default).
    static func sphere(radius: Double, segmentCount: Int = 0) -> Self {
        initializeQoS()
        return Self(manifold.Manifold.Sphere(radius, Int32(segmentCount)))
    }

    /// Creates a cylinder centered on the Z axis.
    /// - Parameter height: The height of the cylinder along the Z axis.
    /// - Parameter bottomRadius: The radius at the bottom (Z = 0 or Z = -height/2).
    /// - Parameter topRadius: The radius at the top. Defaults to `-1` (same as `bottomRadius`).
    /// - Parameter segmentCount: The number of segments used to approximate the circular cross-section.
    ///   Use `0` to choose the count from the current ``Quality`` circular settings (default).
    /// - Parameter center: If `true`, the cylinder is centered at the origin; otherwise the bottom is at Z = 0. Defaults to `false`.
    static func cylinder(
        height: Double,
        bottomRadius: Double,
        topRadius: Double = -1,
        segmentCount: Int = 0,
        center: Bool = false
    ) -> Self {
        initializeQoS()
        return Self(manifold.Manifold.Cylinder(height, bottomRadius, topRadius, Int32(segmentCount), center))
    }

    /// Creates an axis-aligned box.
    /// - Parameter size: The dimensions of the box along each axis. Defaults to `(1, 1, 1)`.
    /// - Parameter center: If `true`, the box is centered at the origin; otherwise the minimum corner is at the origin. Defaults to `false`.
    static func cube(size: any Vector3 = Vector(x: 1, y: 1, z: 1), center: Bool = false) -> Self {
        initializeQoS()
        return Self(manifold.Manifold.Cube(size.vec3, center))
    }

    /// Creates a manifold from an implicit function (level set / signed distance function).
    ///
    /// The function is evaluated on a grid within the given bounds, and the surface is
    /// extracted where the function equals `level` using marching tetrahedra.
    ///
    /// - Parameter bounds: The bounding box to evaluate the function within.
    /// - Parameter edgeLength: The grid cell size. Smaller values produce finer detail.
    /// - Parameter level: The iso-value at which to extract the surface. Defaults to `0`.
    /// - Parameter tolerance: The precision for surface location. Use `-1` for automatic.
    /// - Parameter functor: A function returning the signed distance at each point.
    ///   Negative values are inside the surface.
    static func levelSet(
        bounds: (Vector, Vector),
        edgeLength: Double,
        level: Double = 0,
        tolerance: Double = -1,
        functor: @escaping (Vector) -> Double
    ) -> Self {
        initializeQoS()
        return Self(bridge.LevelSet({ functor(.init($0)) }, .init(bounds.0.vec3, bounds.1.vec3), edgeLength, level, tolerance, true))
    }
}
