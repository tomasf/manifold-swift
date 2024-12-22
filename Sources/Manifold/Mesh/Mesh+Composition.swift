import ManifoldCPP

public extension Mesh {
    static func compose(meshes: [Mesh]) -> Mesh {
        Self(manifold.Manifold.Compose(.init(meshes.map(\.mesh))))
    }

    func decompose() -> [Mesh] {
        mesh.Decompose().map(Mesh.init)
    }
}

public extension Mesh {
    typealias OriginalID = Int
    
    var originalID: OriginalID? {
        let id = mesh.OriginalID()
        return id == -1 ? nil : Int(id)
    }
    
    func asOriginal() -> Mesh {
        Mesh(mesh.AsOriginal())
    }
}
