import ManifoldCPP

public extension Manifold {
    func transform(_ transform: any Matrix3x4) -> Self {
        Self(mesh.Transform(transform.mat3x4))
    }

    func translate(_ translation: Vector) -> Self {
        Self(mesh.Translate(translation.vec3))
    }

    func scale(_ scale: Vector) -> Self {
        Self(mesh.Scale(scale.vec3))
    }

    func rotate(_ rotation: Vector) -> Self {
        Self(mesh.Rotate(rotation.x, rotation.y, rotation.z))
    }

    func mirror(_ normal: Vector) -> Self {
        Self(mesh.Mirror(normal.vec3))
    }
}
