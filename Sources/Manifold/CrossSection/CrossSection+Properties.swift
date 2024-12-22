import ManifoldCPP

public extension CrossSection {
    var isEmpty: Bool {
        crossSection.IsEmpty()
    }

    var boundingBox: (any Vector2, any Vector2) {
        let box = crossSection.Bounds()
        return (box.min, box.max)
    }

    var vertexCount: Int {
        Int(crossSection.NumVert())
    }

    var area: Double {
        crossSection.Area()
    }
}
