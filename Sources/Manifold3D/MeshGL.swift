import Foundation
internal import ManifoldCPP
internal import ManifoldBridge

/// A mesh representation for interoperating with graphics pipelines.
///
/// `MeshGL` stores vertex positions, triangle indices, and optional per-vertex properties
/// in a flat layout suitable for GPU consumption. It also tracks original IDs for
/// mapping faces back to their source geometry after Boolean operations.
public struct MeshGL<Vector: Vector3> {
    internal let meshGL: manifold.MeshGL64

    internal init(meshGL: manifold.MeshGL64) {
        self.meshGL = meshGL
    }

    /// Creates a mesh from vertex positions and triangle indices.
    /// - Parameter vertices: The vertex positions.
    /// - Parameter triangles: The triangles, each referencing three indices into `vertices`.
    public init(vertices: [Vector], triangles: [Triangle]) {
        self.init(meshGL: Self.makeMeshGL(vertices: vertices, triangles: triangles))
    }

    /// Creates a mesh whose triangles are tagged with original IDs, so that where each face came
    /// from can be traced through Boolean operations.
    ///
    /// Consecutive triangles sharing an ID form one run (see ``runs``). Reserve the IDs with
    /// ``Manifold/reserveOriginalIDs(_:)`` so they're unique among all manifolds; a manifold built
    /// from this mesh then reports them through ``originalIDs``, as does any manifold derived from
    /// it by Boolean operations. Giving every triangle the same ID makes the mesh an original the
    /// way ``Manifold/asOriginal()`` does, but with an ID chosen in advance.
    ///
    /// - Parameters:
    ///   - vertices: The vertex positions.
    ///   - triangles: The triangles, each referencing three indices into `vertices`.
    ///   - originalIDs: The original ID of each triangle, in the same order as `triangles`.
    public init(vertices: [Vector], triangles: [Triangle], originalIDs: [Manifold.OriginalID]) {
        precondition(originalIDs.count == triangles.count, "One original ID is needed per triangle")

        var runIndex: [Int] = []
        var runOriginalID: [Manifold.OriginalID] = []
        for (index, originalID) in originalIDs.enumerated() where index == 0 || originalIDs[index - 1] != originalID {
            runIndex.append(index * 3)
            runOriginalID.append(originalID)
        }
        runIndex.append(triangles.count * 3)

        var meshGL = Self.makeMeshGL(vertices: vertices, triangles: triangles)
        meshGL.runIndex = .init(runIndex.map { .init($0) })
        meshGL.runOriginalID = .init(runOriginalID.map { .init($0) })
        self.init(meshGL: meshGL)
    }

    private static func makeMeshGL(vertices: [Vector], triangles: [Triangle]) -> manifold.MeshGL64 {
        var meshGL = manifold.MeshGL64()
        meshGL.numProp = 3
        meshGL.vertProperties = .init(vertices.flatMap { [$0.x, $0.y, $0.z] })
        meshGL.triVerts = .init(triangles.flatMap(\.indices).map { .init($0) })
        return meshGL
    }
}

public extension MeshGL {
    /// Returns a copy whose merge vectors are recomputed so that topologically identical but
    /// separated vertices are reconnected.
    ///
    /// This is a best-effort helper for the case where a manifold `MeshGL` was produced but its
    /// merge vectors were lost through a round-trip via a file format (e.g. STL) that does not
    /// preserve them. Manifoldness is judged by shared vertex *indices*, not by position, so a
    /// surface that is closed geometrically but carries split coincident vertices is reported as
    /// non-manifold — constructing a ``Manifold`` from it throws. Merging snaps those coincident
    /// vertices back together so the mesh is accepted.
    ///
    /// When nothing needs merging, the result is equivalent to the original mesh.
    ///
    /// - Returns: A merged copy of the mesh.
    func merged() -> MeshGL {
        var meshGL = self.meshGL
        _ = meshGL.Merge()
        return MeshGL(meshGL: meshGL)
    }
}

public extension MeshGL {
    /// The triangles of this mesh.
    var triangles: [Triangle] {
        let tris = Array(meshGL.triVerts)
        return stride(from: 0, to: tris.count, by: 3).map { i in
            Triangle(Int(tris[i]), Int(tris[i + 1]), Int(tris[i + 2]))
        }
    }

    /// The original face IDs for each triangle, used for tracking provenance through Boolean operations.
    var faceIDs: [Int] {
        meshGL.faceID.map { Int($0) }
    }

    /// The vertex positions of this mesh.
    var vertices: [Vector] {
        let props = vertexProperties
        let count = propertyCount
        return stride(from: 0, to: props.count, by: count).map { i in
            Vector(x: props[i], y: props[i + 1], z: props[i + 2])
        }
    }

    /// The number of properties per vertex, including the three position components.
    var propertyCount: Int {
        Int(meshGL.numProp)
    }

    /// The number of vertices in this mesh.
    var vertexCount: Int {
        Int(meshGL.vertProperties.size()) / propertyCount
    }

    /// The number of triangles in this mesh.
    var triangleCount: Int {
        Int(meshGL.triVerts.size()) / 3
    }

    /// The precision tolerance for vertex deduplication.
    var tolerance: Double {
        meshGL.tolerance
    }

    /// A flat array of all per-vertex properties, laid out as `propertyCount` values per vertex.
    var vertexProperties: [Double] {
        .init(meshGL.vertProperties)
    }

    /// Maps original IDs to the sets of triangle indices that originated from each source geometry.
    ///
    /// For the per-run backside flag, see ``runs``.
    var originalIDs: [Manifold.OriginalID: IndexSet] {
        runs.reduce(into: [:]) { result, run in
            result[run.originalID, default: IndexSet()].insert(integersIn: run.triangleRange)
        }
    }

    /// The triangle runs in this mesh, each tagged with its source ``Manifold/OriginalID``
    /// and flags describing the run.
    ///
    /// A "run" is a contiguous range of triangles that share a common origin and transform
    /// history. Boolean operations build the output as a concatenation of runs from the inputs.
    var runs: [Run] {
        let indices = meshGL.runIndex
        let count = indices.size() > 0 ? Int(indices.size()) - 1 : 0
        let flags = meshGL.runFlags
        let originals = meshGL.runOriginalID
        return (0..<count).map { i in
            let flag = i < flags.size() ? flags[i] : 0
            return Run(
                originalID: Int(originals[i]),
                triangleRange: Int(indices[i] / 3)..<Int(indices[i + 1] / 3),
                isBackside: flag & 1 != 0,
                hasNormals: flag & 2 != 0
            )
        }
    }

    /// A contiguous range of triangles in a ``MeshGL`` sharing a common source and orientation.
    struct Run: Sendable {
        /// The ``Manifold/OriginalID`` of the source geometry this run came from. May be `-1`
        /// for runs without a single original (composed geometry).
        public let originalID: Manifold.OriginalID
        /// The range of triangle indices in the mesh that belong to this run.
        public let triangleRange: Range<Int>
        /// Whether this run's orientation was inverted relative to the original geometry
        /// (e.g. from a subtraction). Informational only — the framework already orients
        /// stored normals so the standard export returns world-frame values regardless.
        public let isBackside: Bool
        /// Whether property channels `3...5` of this run hold world-frame vertex normals
        /// (set by ``Manifold/calculateNormals(channelIndex:minSharpAngle:)`` with channel
        /// index `0` and round-tripped through ``MeshGL``). Consumers should treat the slot
        /// as normals and skip re-applying ``runTransform`` to it.
        public let hasNormals: Bool
    }

    /// A reference to a specific edge within the mesh, identified by triangle and edge index.
    struct EdgeReference: Hashable, Sendable {
        /// The index of the triangle containing this edge.
        public let triangleIndex: Int
        /// The index of the edge within its triangle (0, 1, or 2).
        public let edgeIndex: Int

        /// Creates an edge reference.
        /// - Parameter triangleIndex: The index of the triangle.
        /// - Parameter edgeIndex: The index of the edge within the triangle (0, 1, or 2).
        public init(triangleIndex: Int, edgeIndex: Int) {
            self.triangleIndex = triangleIndex
            self.edgeIndex = edgeIndex
        }

        internal var index: Int {
            triangleIndex * 3 + edgeIndex
        }
    }
}

