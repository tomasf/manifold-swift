import ManifoldCPP

public struct Mesh {
    internal let mesh: manifold.Manifold

    fileprivate init(_ mesh: manifold.Manifold) {
        self.mesh = mesh
    }
}

public extension Mesh {
    static var empty: Self {
        Self(manifold.Manifold())
    }

    static func sphere(radius: Double, segmentCount: Int) -> Self {
        Self(manifold.Manifold.Sphere(radius, Int32(segmentCount)))
    }

    static func box(size: any Vector3) -> Self {
        Self(manifold.Manifold.Cube(size.vec3))
    }
}

public extension Mesh {
    enum BooleanOperation {
        case union
        case difference
        case intersection

        internal var manifoldOp: manifold.OpType {
            switch self {
            case .union: .Add
            case .difference: .Subtract
            case .intersection: .Intersect
            }
        }
    }

    func applyOperation(_ op: BooleanOperation, with other: Mesh) -> Self {
        Self(mesh.Boolean(other.mesh, op.manifoldOp))
    }
}
