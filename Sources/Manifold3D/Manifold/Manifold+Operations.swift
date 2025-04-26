import ManifoldCPP
import ManifoldBridge

public extension Manifold {
    static func boolean(_ op: BooleanOperation, with children: [Manifold]) -> Self {
        Self(manifold.Manifold.BatchBoolean(.init(children.map(\.mesh)), op.manifoldOp))
    }

    func boolean(_ op: BooleanOperation, with other: Manifold) -> Self {
        Self(mesh.Boolean(other.mesh, op.manifoldOp))
    }

    func simplify(epsilon: Double) -> Self {
        Self(mesh.Simplify(epsilon))
    }

    func warp(_ function: @escaping (any Vector3) -> any Vector3) -> Manifold {
        Self(bridge.Warp(mesh) {
            $0.pointee = function($0.pointee).vec3
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

    static func hull(_ points: [any Vector3]) -> Self {
        Self(manifold.Manifold.Hull(.init(points.map(\.vec3))))
    }
}

public extension Manifold {
    func split(by cutter: Manifold) -> (Manifold, Manifold) {
        let results = mesh.Split(cutter.mesh)
        return (Manifold(results.first), Manifold(results.second))
    }

    func split(by plane: Vector3, originOffset: Double) -> (Manifold, Manifold) {
        let results = mesh.SplitByPlane(plane.vec3, originOffset)
        return (Manifold(results.first), Manifold(results.second))
    }

    func trim(by plane: Vector3, originOffset: Double) -> Manifold {
        Manifold(mesh.TrimByPlane(plane.vec3, originOffset))
    }
}

public extension Manifold {
    func projection() -> CrossSection {
        CrossSection(manifold.CrossSection(mesh.Project(), .Positive))
    }

    func slice(at z: Double) -> CrossSection {
        CrossSection(manifold.CrossSection(mesh.Slice(z), .Positive))
    }
}
