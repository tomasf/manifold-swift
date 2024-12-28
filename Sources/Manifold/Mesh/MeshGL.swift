import Foundation
import ManifoldCPP
import ManifoldBridge

public struct MeshGL {
    internal let meshGL: manifold.MeshGL64

    internal init(meshGL: manifold.MeshGL64) {
        self.meshGL = meshGL
    }

    public init(vertices: [any Vector3], triangles: [Triangle]) {
        var meshGL = manifold.MeshGL64()
        meshGL.numProp = 3
        meshGL.vertProperties = .init(vertices.flatMap(\.values))
        meshGL.triVerts = .init(triangles.flatMap(\.indices).map { .init($0) })
        self.meshGL = meshGL
    }

    public var triangles: [Triangle] {
        let meshGL = self.meshGL
        return (0..<meshGL.NumTri()).map {
            let verts = meshGL.GetTriVerts(Int($0))
            return Triangle(Int(verts[0]), Int(verts[1]), Int(verts[2]))
        }
    }

    public var faceIDs: [UInt64] {
        .init(meshGL.faceID)
    }

    public var vertices: [any Vector3] {
        (0..<Int(meshGL.NumVert())).map(meshGL.GetVertPos)
    }

    // Maps original IDs to sets of triangle indices
    public var originalIDs: [Mesh.OriginalID: IndexSet] {
        let ranges = meshGL.runIndex.paired().map { Int($0 / 3)..<Int($1 / 3) }
        return ranges.enumerated().reduce(into: [:]) { result, item in
            let originalID = Int(meshGL.runOriginalID[item.offset])
            result[originalID, default: IndexSet()].insert(integersIn: item.element)
        }
    }
}

