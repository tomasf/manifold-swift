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
}

public extension MeshGL {
    /// Creates a mesh from vertex positions and triangle indices.
    /// - Parameter vertices: The vertex positions.
    /// - Parameter triangles: The triangles, each referencing three indices into `vertices`.
    init(vertices: [Vector], triangles: [Triangle]) {
        var meshGL = manifold.MeshGL64()
        meshGL.numProp = 3
        meshGL.vertProperties = .init(vertices.flatMap { [$0.x, $0.y, $0.z] })
        meshGL.triVerts = .init(triangles.flatMap(\.indices).map { .init($0) })
        self.meshGL = meshGL
    }

    /// The triangles of this mesh.
    var triangles: [Triangle] {
        let meshGL = self.meshGL
        return (0..<meshGL.NumTri()).map {
            Triangle(meshGL.GetTriVerts(Int($0)))
        }
    }

    /// The original face IDs for each triangle, used for tracking provenance through Boolean operations.
    var faceIDs: [Int] {
        meshGL.faceID.map { Int($0) }
    }

    /// The vertex positions of this mesh.
    var vertices: [Vector] {
        (0..<Int(meshGL.NumVert())).map {
            Vector(meshGL.GetVertPos($0))
        }
    }

    /// The number of properties per vertex, including the three position components.
    var propertyCount: Int {
        Int(meshGL.numProp)
    }

    /// The number of vertices in this mesh.
    var vertexCount: Int {
        Int(meshGL.NumVert())
    }

    /// The number of triangles in this mesh.
    var triangleCount: Int {
        Int(meshGL.NumTri())
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
    var originalIDs: [Manifold.OriginalID: IndexSet] {
        let ranges = meshGL.runIndex.paired().map { Int($0 / 3)..<Int($1 / 3) }
        return ranges.enumerated().reduce(into: [:]) { result, item in
            let originalID = Int(meshGL.runOriginalID[item.offset])
            result[originalID, default: IndexSet()].insert(integersIn: item.element)
        }
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

