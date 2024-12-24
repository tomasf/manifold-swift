import ManifoldCPP

public extension CrossSection {
    var isEmpty: Bool {
        crossSection.IsEmpty()
    }

    var bounds: (any Vector2, any Vector2) {
        let box = crossSection.Bounds()
        return (box.min, box.max)
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
