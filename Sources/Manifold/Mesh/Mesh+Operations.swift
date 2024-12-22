import ManifoldCPP
import ManifoldExtras

public extension Mesh {
    static func boolean(_ op: BooleanOperation, with children: [Mesh]) -> Self {
        Self(manifold.Manifold.BatchBoolean(.init(children.map(\.mesh)), op.manifoldOp))
    }

    func boolean(_ op: BooleanOperation, with other: Mesh) -> Self {
        Self(mesh.Boolean(other.mesh, op.manifoldOp))
    }

    func hull() -> Self {
        Self(mesh.Hull())
    }

    func warp(_ function: @escaping (any Vector3) -> any Vector3) -> Mesh {
        Self(manifold.warp(mesh) { function($0).vec3 })
    }

    func refine(piecesPerEdge: Int) -> Mesh {
        Self(mesh.Refine(Int32(piecesPerEdge)))
    }

    func refine(edgeLength: Double) -> Mesh {
        Self(mesh.RefineToLength(edgeLength))
    }
}

public extension Mesh {
    func split(by cutter: Mesh) -> (Mesh, Mesh) {
        let results = mesh.Split(cutter.mesh)
        return (Mesh(results.first), Mesh(results.second))
    }

    func split(by plane: Vector3, originOffset: Double) -> (Mesh, Mesh) {
        let results = mesh.SplitByPlane(plane.vec3, originOffset)
        return (Mesh(results.first), Mesh(results.second))
    }

    func trim(by plane: Vector3, originOffset: Double) -> Mesh {
        Mesh(mesh.TrimByPlane(plane.vec3, originOffset))
    }
}

public extension Mesh {
    func projection() -> CrossSection {
        CrossSection(manifold.CrossSection(mesh.Project(), .Positive))
    }

    func slice(at z: Double) -> CrossSection {
        CrossSection(manifold.CrossSection(mesh.Slice(z), .Positive))
    }
}

