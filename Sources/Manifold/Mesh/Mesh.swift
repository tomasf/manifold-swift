import ManifoldCPP

// Mesh corresponds to the "Manifold" type.
// A new name was chosen to prevent it from conflicting with the module name.
public struct Mesh {
    internal let mesh: manifold.Manifold

    internal init(_ mesh: manifold.Manifold) {
        self.mesh = mesh
    }

    init(_ meshGL: MeshGL) {
        self.init(manifold.Manifold(meshGL.meshGL))
    }

    func meshGL(normalIndex: Int = -1) -> MeshGL {
        MeshGL(meshGL: mesh.GetMeshGL64(Int32(normalIndex)))
    }
}
