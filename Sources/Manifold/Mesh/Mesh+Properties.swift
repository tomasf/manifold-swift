import ManifoldCPP

public extension Mesh {
    var isEmpty: Bool {
        mesh.IsEmpty()
    }

    var boundingBox: (any Vector3, any Vector3) {
        let box = mesh.BoundingBox()
        return (box.min, box.max)
    }

    var vertexCount: Int {
        mesh.NumVert()
    }

    var edgeCount: Int {
        mesh.NumEdge()
    }

    var triangleCount: Int {
        mesh.NumTri()
    }

    var surfaceArea: Double {
        mesh.SurfaceArea()
    }

    var volume: Double {
        mesh.Volume()
    }
}
