import ManifoldCPP
import ManifoldBridge

public extension Mesh {
    static func boolean(_ op: BooleanOperation, with children: [Mesh]) -> Self {
        Self(manifold.Manifold.BatchBoolean(.init(children.map(\.mesh)), op.manifoldOp))
    }

    func boolean(_ op: BooleanOperation, with other: Mesh) -> Self {
        Self(mesh.Boolean(other.mesh, op.manifoldOp))
    }

    func warp(_ function: @escaping (any Vector3) -> any Vector3) -> Mesh {
        Self(bridge.Warp(mesh) {
            $0.pointee = function($0.pointee).vec3
        })
    }
}

public extension Mesh {
    func hull() -> Self {
        Self(mesh.Hull())
    }

    static func hull(_ meshes: [Mesh]) -> Self {
        Self(manifold.Manifold.Hull(.init(meshes.map(\.mesh))))
    }

    static func hull(_ points: [any Vector3]) -> Self {
        Self(manifold.Manifold.Hull(.init(points.map(\.vec3))))
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
