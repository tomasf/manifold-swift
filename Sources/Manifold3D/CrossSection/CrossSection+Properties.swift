internal import ManifoldCPP

public extension CrossSection {
    /// Whether this cross-section contains no contours.
    var isEmpty: Bool {
        crossSection.IsEmpty()
    }

    /// The axis-aligned bounding box of this cross-section.
    var bounds: (min: Vector, max: Vector) {
        let box = crossSection.Bounds()
        return (.init(box.min), .init(box.max))
    }

    /// The total number of vertices across all contours.
    var vertexCount: Int {
        Int(crossSection.NumVert())
    }

    /// The number of contours (closed paths) in this cross-section.
    var contourCount: Int {
        Int(crossSection.NumContour())
    }

    /// The total area of this cross-section. Positive for counterclockwise contours.
    var area: Double {
        crossSection.Area()
    }
}
