internal import ManifoldCPP

public extension Manifold {
    /// Separates this manifold into its disconnected components.
    /// - Returns: An array of manifolds, one for each connected component.
    func decompose() -> [Manifold] {
        mesh.Decompose().map(Manifold.init)
    }
}

public extension Manifold {
    /// An identifier that tracks the provenance of faces through Boolean operations.
    typealias OriginalID = Int

    /// The original ID of this manifold, or `nil` if it was produced by a Boolean operation rather than created as an original.
    var originalID: OriginalID? {
        let id = mesh.OriginalID()
        return id == -1 ? nil : Int(id)
    }

    /// Returns a copy of this manifold marked as an original, assigning it a new unique original ID and updating all face IDs.
    func asOriginal() -> Manifold {
        Manifold(mesh.AsOriginal())
    }

    /// Reserves a block of original IDs for external use.
    /// - Parameter count: The number of IDs to reserve.
    /// - Returns: The first ID in the reserved block.
    static func reserveOriginalIDs(_ count: Int) -> Int {
        Int(manifold.Manifold.ReserveIDs(.init(count)))
    }
}
