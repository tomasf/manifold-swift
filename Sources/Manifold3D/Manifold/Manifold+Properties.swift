import ManifoldCPP

public extension Manifold {
    var isEmpty: Bool {
        mesh.IsEmpty()
    }

    var bounds: (min: any Vector3, max: any Vector3) {
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

    var tolerance: Double {
        mesh.GetTolerance()
    }

    var propertyCount: Int {
        mesh.NumProp()
    }

    var propertyVertexCount: Int {
        mesh.NumPropVert()
    }

    var genus: Int {
        Int(mesh.Genus())
    }
}
