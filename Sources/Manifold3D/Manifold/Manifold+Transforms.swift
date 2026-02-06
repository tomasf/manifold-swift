internal import ManifoldCPP

public extension Manifold {
    /// Applies a 3x4 affine transform matrix to this manifold.
    func transform(_ transform: any Matrix3x4) -> Self {
        Self(mesh.Transform(transform.mat3x4))
    }

    /// Translates this manifold by the given offset.
    func translate(_ translation: Vector) -> Self {
        Self(mesh.Translate(translation.vec3))
    }

    /// Scales this manifold by the given factors along each axis.
    func scale(_ scale: Vector) -> Self {
        Self(mesh.Scale(scale.vec3))
    }

    /// Rotates this manifold by the given angles in degrees, applied in X, then Y, then Z order.
    func rotate(_ rotation: Vector) -> Self {
        Self(mesh.Rotate(rotation.x, rotation.y, rotation.z))
    }

    /// Mirrors this manifold across the plane defined by the given normal vector through the origin.
    func mirror(_ normal: Vector) -> Self {
        Self(mesh.Mirror(normal.vec3))
    }
}
