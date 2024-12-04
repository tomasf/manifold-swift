import ManifoldCPP
import Foundation

// This is temporary cursed code. We shouldn't even use STL because it sucks

public extension Mesh {
    var stl: Data {
        let normalIndex = Int32(0)
        let meshGL = mesh.CalculateNormals(normalIndex).GetMeshGL(normalIndex)

        var stl = "solid foo\n"
        for t in 0..<Int(meshGL.NumTri()) {
            let indices = meshGL.GetTriVerts(t)

            let a = Int(meshGL.numProp) * Int(indices[0])

            stl += "facet normal \(meshGL.vertProperties[a + 3]) \(meshGL.vertProperties[a + 4]) \(meshGL.vertProperties[a + 5]) \n"
            stl += "    outer loop\n"

            let vertices = (0..<3).map {
                meshGL.GetVertPos(Int(indices[Int32($0)]))
            }
            for v in vertices {
                stl += "        vertex \(v.x) \(v.y) \(v.z)\n"
            }
            stl += "    endloop\n"
            stl += "endfacet\n"
        }
        stl += "endsolid foo"

        return Data(stl.utf8)
    }
}
