import Foundation
import ManifoldCPP

public protocol Triangle {
    typealias VertexIndex = UInt64
    var a: VertexIndex { get }
    var b: VertexIndex { get }
    var c: VertexIndex { get }
    var faceID: UInt64 { get }
}

public protocol MeshData {
    var triangles: [Triangle] { get }
    var vertices: [Vector3] { get }

    // Maps original IDs to sets of triangle indices
    var originalIDs: [Mesh.OriginalID: IndexSet] { get }
}

extension manifold.MeshGL64: MeshData {
    public var triangles: [any Triangle] {
        (0..<NumTri()).map {
            let tri = GetTriVerts(Int($0))
            return VertexIndices(a: .init(tri[0]), b: .init(tri[1]), c: .init(tri[2]), faceID: .init(faceID[Int($0)]))
        }
    }
    
    public var vertices: [any Vector3] {
        (0..<NumVert()).map {
            GetVertPos(Int($0))
        }
    }

    public var originalIDs: [Mesh.OriginalID: IndexSet] {
        let ranges = runIndex.paired().map { Int($0 / 3)..<Int($1 / 3) }
        return ranges.enumerated().reduce(into: [:]) { result, item in
            let originalID = Int(runOriginalID[item.offset])
            result[originalID, default: IndexSet()].insert(integersIn: item.element)
        }
    }
}

struct VertexIndices: Triangle {
    let a: VertexIndex
    let b: VertexIndex
    let c: VertexIndex
    let faceID: UInt64
}
