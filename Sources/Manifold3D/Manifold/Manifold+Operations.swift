import ManifoldCPP
import ManifoldBridge

public extension Manifold {
    static func boolean(_ op: BooleanOperation, with children: [Manifold]) -> Self {
        Self(manifold.Manifold.BatchBoolean(.init(children.map(\.mesh)), op.manifoldOp))
    }

    func boolean(_ op: BooleanOperation, with other: Manifold) -> Self {
        Self(mesh.Boolean(other.mesh, op.manifoldOp))
    }

    func warp(_ function: @escaping (Vector) -> Vector) -> Manifold {
        Self(bridge.Warp(mesh) {
            $0.pointee = function(.init($0.pointee)).vec3
        })
    }
}

public extension Manifold {
    func hull() -> Self {
        Self(mesh.Hull())
    }

    static func hull(_ meshes: [Manifold]) -> Self {
        Self(manifold.Manifold.Hull(.init(meshes.map(\.mesh))))
    }

    static func hull(_ points: [Vector]) -> Self {
        Self(manifold.Manifold.Hull(.init(points.map(\.vec3))))
    }
}

public extension Manifold {
    func split(by cutter: Manifold) -> (Manifold, Manifold) {
        let results = mesh.Split(cutter.mesh)
        return (Manifold(results.first), Manifold(results.second))
    }

    func split(by plane: Vector, originOffset: Double) -> (Manifold, Manifold) {
        let results = mesh.SplitByPlane(plane.vec3, originOffset)
        return (Manifold(results.first), Manifold(results.second))
    }

    func trim(by plane: Vector, originOffset: Double) -> Manifold {
        Manifold(mesh.TrimByPlane(plane.vec3, originOffset))
    }
}

public extension Manifold {
    func projection<V2: Vector2>() -> CrossSection<V2> {
        CrossSection(manifold.CrossSection(mesh.Project(), .Positive))
    }

    func slice<V2: Vector2>(at z: Double) -> CrossSection<V2> {
        CrossSection(manifold.CrossSection(mesh.Slice(z), .Positive))
    }
}
