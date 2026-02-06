internal import ManifoldCPP
internal import ManifoldBridge

public extension Manifold {
    /// Applies a Boolean operation across multiple manifolds.
    /// - Parameter op: The Boolean operation to apply.
    /// - Parameter children: The manifolds to combine.
    /// - Returns: The result of applying the operation.
    static func boolean(_ op: BooleanOperation, with children: [Manifold]) -> Self {
        Self(manifold.Manifold.BatchBoolean(.init(children.map(\.mesh)), op.manifoldOp))
    }

    /// Applies a Boolean operation between this manifold and another.
    /// - Parameter op: The Boolean operation to apply.
    /// - Parameter other: The other manifold.
    /// - Returns: The result of applying the operation.
    func boolean(_ op: BooleanOperation, with other: Manifold) -> Self {
        Self(mesh.Boolean(other.mesh, op.manifoldOp))
    }

    /// Applies a function to each vertex position, deforming the manifold.
    ///
    /// It is the caller's responsibility to ensure the function maintains valid manifold topology
    /// (no self-intersections or flipped triangles).
    func warp(_ function: @escaping (Vector) -> Vector) -> Manifold {
        Self(bridge.Warp(mesh) {
            $0.pointee = function(.init($0.pointee)).vec3
        })
    }
}

public extension Manifold {
    /// Returns the convex hull of this manifold.
    func hull() -> Self {
        Self(mesh.Hull())
    }

    /// Returns the convex hull of multiple manifolds.
    static func hull(_ meshes: [Manifold]) -> Self {
        Self(manifold.Manifold.Hull(.init(meshes.map(\.mesh))))
    }

    /// Returns the convex hull of a set of 3D points.
    static func hull(_ points: [Vector]) -> Self {
        Self(manifold.Manifold.Hull(.init(points.map(\.vec3))))
    }
}

public extension Manifold {
    /// Splits this manifold into the intersection and difference with the given cutter.
    /// - Parameter cutter: The manifold to split by.
    /// - Returns: A tuple where the first element is the intersection and the second is the difference.
    func split(by cutter: Manifold) -> (Manifold, Manifold) {
        let results = mesh.Split(cutter.mesh)
        return (Manifold(results.first), Manifold(results.second))
    }

    /// Splits this manifold by a plane.
    /// - Parameter plane: The normal vector of the splitting plane.
    /// - Parameter originOffset: The distance from the origin to the plane along the normal.
    /// - Returns: A tuple of the geometry on each side of the plane.
    func split(by plane: Vector, originOffset: Double) -> (Manifold, Manifold) {
        let results = mesh.SplitByPlane(plane.vec3, originOffset)
        return (Manifold(results.first), Manifold(results.second))
    }

    /// Trims this manifold to the half-space on the side of the plane facing away from the normal.
    /// - Parameter plane: The normal vector of the cutting plane.
    /// - Parameter originOffset: The distance from the origin to the plane along the normal.
    func trim(by plane: Vector, originOffset: Double) -> Manifold {
        Manifold(mesh.TrimByPlane(plane.vec3, originOffset))
    }
}

public extension Manifold {
    /// Projects this manifold onto the XY plane, producing a 2D cross-section.
    func projection<V2: Vector2>() -> CrossSection<V2> {
        CrossSection(manifold.CrossSection(mesh.Project(), .Positive))
    }

    /// Slices this manifold at the given Z height, producing a 2D cross-section.
    /// - Parameter z: The Z coordinate at which to slice.
    func slice<V2: Vector2>(at z: Double) -> CrossSection<V2> {
        CrossSection(manifold.CrossSection(mesh.Slice(z), .Positive))
    }
}
