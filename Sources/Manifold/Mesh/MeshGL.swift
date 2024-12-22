import Foundation
import ManifoldCPP

public protocol MeshGL {
    var triangles: [Triangle] { get }
    var vertices: [Vector3] { get }

    // Maps original IDs to sets of triangle indices
    var originalIDs: [Mesh.OriginalID: IndexSet] { get }
}

extension manifold.MeshGL64: MeshGL {
    public var triangles: [Triangle] {
        (0..<NumTri()).map { Triangle(meshGL: self, index: Int($0)) }
    }
    
    public var vertices: [any Vector3] {
        (0..<Int(NumVert())).map(GetVertPos)
    }

    public var originalIDs: [Mesh.OriginalID: IndexSet] {
        let ranges = runIndex.paired().map { Int($0 / 3)..<Int($1 / 3) }
        return ranges.enumerated().reduce(into: [:]) { result, item in
            let originalID = Int(runOriginalID[item.offset])
            result[originalID, default: IndexSet()].insert(integersIn: item.element)
        }
    }
}

public struct Triangle {
    typealias VertexIndex = UInt64

    let a: VertexIndex
    let b: VertexIndex
    let c: VertexIndex
    let faceID: UInt64

    internal init(meshGL: manifold.MeshGL64, index: Int) {
        let verts = meshGL.GetTriVerts(index)
        a = .init(verts[0])
        b = .init(verts[1])
        c = .init(verts[2])
        faceID = .init(meshGL.faceID[index])
    }
}
