internal import ManifoldCPP

public extension Manifold {
    /// Whether this manifold contains no geometry.
    var isEmpty: Bool {
        mesh.IsEmpty()
    }

    /// The axis-aligned bounding box of this manifold.
    var bounds: (min: Vector, max: Vector) {
        let box = mesh.BoundingBox()
        return (.init(box.min), .init(box.max))
    }

    /// The number of vertices in the underlying mesh.
    var vertexCount: Int {
        mesh.NumVert()
    }

    /// The number of edges in the underlying mesh.
    var edgeCount: Int {
        mesh.NumEdge()
    }

    /// The number of triangles in the underlying mesh.
    var triangleCount: Int {
        mesh.NumTri()
    }

    /// The total surface area of this manifold.
    var surfaceArea: Double {
        mesh.SurfaceArea()
    }

    /// The volume enclosed by this manifold.
    var volume: Double {
        mesh.Volume()
    }

    /// The precision tolerance of this manifold, used for vertex deduplication and edge collapsing.
    var tolerance: Double {
        mesh.GetTolerance()
    }

    /// The number of per-vertex property channels, including the three position components.
    var propertyCount: Int {
        mesh.NumProp()
    }

    /// The number of property vertices, which may differ from ``vertexCount`` when properties are not shared across faces.
    var propertyVertexCount: Int {
        mesh.NumPropVert()
    }

    /// The topological genus of this manifold (0 for a sphere, 1 for a torus, etc.).
    var genus: Int {
        Int(mesh.Genus())
    }

    /// Casts a ray segment against this manifold and returns every intersection.
    ///
    /// The ray is treated as a segment from `origin` to `endpoint`, inclusive of both
    /// endpoints. Hits are ordered by increasing parametric distance.
    ///
    /// - Parameters:
    ///   - origin: The start of the ray segment.
    ///   - endpoint: The end of the ray segment.
    /// - Returns: All hits along the segment, or an empty array if the ray misses.
    func rayCast(from origin: Vector, to endpoint: Vector) -> [RayHit<Vector>] {
        let hits = mesh.RayCast(origin.vec3, endpoint.vec3)
        return hits.map { RayHit($0) }
    }
}
