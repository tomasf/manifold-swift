import ManifoldCPP

public extension Mesh {
    func transform(_ transform: any Matrix3x4) -> Self {
        Self(mesh.Transform(transform.mat3x4))
    }

    func translate(_ translation: any Vector3) -> Self {
        Self(mesh.Translate(translation.vec3))
    }

    func scale(_ scale: any Vector3) -> Self {
        Self(mesh.Scale(scale.vec3))
    }

    func rotate(_ rotation: any Vector3) -> Self {
        Self(mesh.Rotate(rotation.x, rotation.y, rotation.z))
    }
}
