import ManifoldCPP

// Mesh corresponds to the "Manifold" type.
// A new name was chosen to prevent it from conflicting with the module name.
public struct Mesh {
    internal let mesh: manifold.Manifold

    internal init(_ mesh: manifold.Manifold) {
        self.mesh = mesh
    }

    func meshGL() -> any MeshGL {
        mesh.GetMeshGL64()
    }
}
