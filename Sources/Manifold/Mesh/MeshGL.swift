import Foundation
import ManifoldCPP
import ManifoldBridge

public struct MeshGL {
    internal let meshGL: manifold.MeshGL64

    internal init(meshGL: manifold.MeshGL64) {
        self.meshGL = meshGL
    }
}

public extension MeshGL {
    init(vertices: [any Vector3], triangles: [Triangle]) {
        var meshGL = manifold.MeshGL64()
        meshGL.numProp = 3
        meshGL.vertProperties = .init(vertices.flatMap { [$0.x, $0.y, $0.z] })
        meshGL.triVerts = .init(triangles.flatMap(\.indices).map { .init($0) })
        self.meshGL = meshGL
    }

    var triangles: [Triangle] {
        let meshGL = self.meshGL
        return (0..<meshGL.NumTri()).map {
            let verts = meshGL.GetTriVerts(Int($0))
            return Triangle(Int(verts[0]), Int(verts[1]), Int(verts[2]))
        }
    }

    var faceIDs: [Int] {
        meshGL.faceID.map { Int($0) }
    }

    var vertices: [any Vector3] {
        (0..<Int(meshGL.NumVert())).map(meshGL.GetVertPos)
    }

    var propertyCount: Int {
        Int(meshGL.numProp)
    }

    var vertexCount: Int {
        Int(meshGL.NumVert())
    }

    var triangleCount: Int {
        Int(meshGL.NumVert())
    }

    var tolerance: Double {
        meshGL.tolerance
    }

    var vertexProperties: [Double] {
        .init(meshGL.vertProperties)
    }

    // Maps original IDs to sets of triangle indices
    var originalIDs: [Mesh.OriginalID: IndexSet] {
        let ranges = meshGL.runIndex.paired().map { Int($0 / 3)..<Int($1 / 3) }
        return ranges.enumerated().reduce(into: [:]) { result, item in
            let originalID = Int(meshGL.runOriginalID[item.offset])
            result[originalID, default: IndexSet()].insert(integersIn: item.element)
        }
    }

    struct EdgeReference: Hashable {
        public let triangleIndex: Int
        public let edgeIndex: Int

        public init(triangleIndex: Int, edgeIndex: Int) {
            self.triangleIndex = triangleIndex
            self.edgeIndex = edgeIndex
        }

        internal var index: Int {
            triangleIndex * 3 + edgeIndex
        }
    }
}

