import ManifoldCPP

public extension Manifold {
    func transform<T: Matrix3x4>(_ transform: T) -> Self {
        Self(mesh.Transform(transform.mat3x4))
    }

    func translate(_ translation: V) -> Self {
        Self(mesh.Translate(translation.vec3))
    }

    func scale(_ scale: V) -> Self {
        Self(mesh.Scale(scale.vec3))
    }

    func rotate(_ rotation: V) -> Self {
        Self(mesh.Rotate(rotation.x, rotation.y, rotation.z))
    }

    func mirror(_ normal: V) -> Self {
        Self(mesh.Mirror(normal.vec3))
    }
}
