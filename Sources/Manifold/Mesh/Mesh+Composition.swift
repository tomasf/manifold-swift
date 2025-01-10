import ManifoldCPP

public extension Mesh {
    init(composing meshes: [Mesh]) {
        self = Self(manifold.Manifold.Compose(.init(meshes.map(\.mesh))))
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

    static func reserveOriginalIDs(_ count: Int) -> Int {
        Int(manifold.Manifold.ReserveIDs(.init(count)))
    }
}
