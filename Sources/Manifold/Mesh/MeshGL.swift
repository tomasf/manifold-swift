import Foundation
import ManifoldCPP

public struct MeshGL {
    internal let meshGL: manifold.MeshGL64

    internal init(meshGL: manifold.MeshGL64) {
        self.meshGL = meshGL
    }

    public init(vertices: [any Vector3], triangles: [Triangle]) {
        var meshGL = manifold.MeshGL64()
        meshGL.numProp = 3
        meshGL.vertProperties = .init(vertices.flatMap(\.values))
        meshGL.triVerts = .init(triangles.flatMap(\.indices))
        self.meshGL = meshGL
    }

    public var triangles: [Triangle] {
        (0..<meshGL.NumTri()).map { Triangle(meshGL: self, index: Int($0)) }
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

public struct Triangle {
    public typealias VertexIndex = UInt64

    public let a: VertexIndex
    public let b: VertexIndex
    public let c: VertexIndex
    public let faceID: UInt64

    public init(a: VertexIndex, b: VertexIndex, c: VertexIndex) {
        self.a = a
        self.b = b
        self.c = c
        faceID = 0
    }

    internal init(meshGL: MeshGL, index: Int) {
        let verts = meshGL.meshGL.GetTriVerts(index)
        a = .init(verts[0])
        b = .init(verts[1])
        c = .init(verts[2])
        faceID = .init(meshGL.meshGL.faceID[index])
    }

    internal var indices: [VertexIndex] {
        [a, b, c]
    }
}
