import ManifoldCPP

public extension CrossSection {
    var isEmpty: Bool {
        crossSection.IsEmpty()
    }

    var bounds: (min: V, max: V) {
        let box = crossSection.Bounds()
        return (.init(box.min), .init(box.max))
    }

    var vertexCount: Int {
        Int(crossSection.NumVert())
    }

    var contourCount: Int {
        Int(crossSection.NumContour())
    }

    var area: Double {
        crossSection.Area()
    }
}
