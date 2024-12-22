import ManifoldCPP

public extension Mesh {
    static var empty: Self {
        Self(manifold.Manifold())
    }

    static func tetrahedron() -> Self {
        Self(manifold.Manifold.Tetrahedron())
    }

    static func sphere(radius: Double, segmentCount: Int) -> Self {
        Self(manifold.Manifold.Sphere(radius, Int32(segmentCount)))
    }

    static func cylinder(height: Double, bottomRadius: Double, topRadius: Double, segmentCount: Int) -> Self {
        Self(manifold.Manifold.Cylinder(height, bottomRadius, topRadius, Int32(segmentCount)))
    }

    static func cube(size: any Vector3) -> Self {
        Self(manifold.Manifold.Cube(size.vec3))
    }
}
