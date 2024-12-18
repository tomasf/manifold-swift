import Foundation
import ManifoldCPP

public protocol Triangle {
    var a: UInt64 { get }
    var b: UInt64 { get }
    var c: UInt64 { get }
    var faceID: UInt64 { get }
}

public protocol MeshData {
    var triangles: [Triangle] { get }
    var vertices: [Vector3] { get }

    // Maps original IDs to sets of triangle indices
    var originalIDs: [Int: IndexSet] { get }
}

extension manifold.MeshGL64: MeshData {
    public var triangles: [any Triangle] {
        (0..<NumTri()).map {
            let tri = GetTriVerts(Int($0))
            return VertexIndices(a: tri[0], b: tri[1], c: tri[2], faceID: faceID[Int($0)])
        }
    }
    
    public var vertices: [any Vector3] {
        (0..<NumVert()).map {
            GetVertPos(Int($0))
        }
    }

    public var originalIDs: [Int: IndexSet] {
        let ranges = (runIndex + [NumTri()]).paired().map { Int($0)..<Int($1) }
        return ranges.enumerated().reduce(into: [:]) { result, item in
            let originalID = Int(runOriginalID[item.offset])
            result[originalID, default: IndexSet()].insert(integersIn: item.element)
        }
    }
}

struct VertexIndices: Triangle {
    let a: UInt64
    let b: UInt64
    let c: UInt64
    let faceID: UInt64
}
