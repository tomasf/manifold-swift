import ManifoldCPP

public extension Manifold {
    init(composing meshes: [Manifold]) {
        self = Self(manifold.Manifold.Compose(.init(meshes.map(\.mesh))))
    }

    func decompose() -> [Manifold] {
        mesh.Decompose().map(Manifold.init)
    }
}

public extension Manifold {
    typealias OriginalID = Int
    
    var originalID: OriginalID? {
        let id = mesh.OriginalID()
        return id == -1 ? nil : Int(id)
    }
    
    func asOriginal() -> Manifold {
        Manifold(mesh.AsOriginal())
    }

    static func reserveOriginalIDs(_ count: Int) -> Int {
        Int(manifold.Manifold.ReserveIDs(.init(count)))
    }
}
