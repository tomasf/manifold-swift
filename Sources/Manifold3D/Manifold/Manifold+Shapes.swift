import ManifoldCPP
import ManifoldBridge

public extension Manifold {
    static var empty: Self {
        Self(manifold.Manifold())
    }

    static func tetrahedron() -> Self {
        Self(manifold.Manifold.Tetrahedron())
    }

    static func sphere(radius: Double, segmentCount: Int) -> Self {
        Self(manifold.Manifold.Sphere(radius, Int32(segmentCount)))
    }

    static func cylinder(height: Double, bottomRadius: Double, topRadius: Double, segmentCount: Int, center: Bool = false) -> Self {
        Self(manifold.Manifold.Cylinder(height, bottomRadius, topRadius, Int32(segmentCount), center))
    }

    static func cube(size: any Vector3, center: Bool = false) -> Self {
        Self(manifold.Manifold.Cube(size.vec3, center))
    }

    static func levelSet(
        bounds: (V, V),
        edgeLength: Double,
        level: Double = 0,
        tolerance: Double = -1,
        functor: @escaping (V) -> Double
    ) -> Self {
        Self(bridge.LevelSet({ functor(.init($0)) }, .init(bounds.0.vec3, bounds.1.vec3), edgeLength, level, tolerance, true))
    }
}
