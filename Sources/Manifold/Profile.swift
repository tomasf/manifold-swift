import ManifoldCPP

public struct Profile {
    internal let profile: manifold.CrossSection

    internal init(_ profile: manifold.CrossSection) {
        self.profile = profile
    }
}

public extension Profile {
    var isEmpty: Bool {
        profile.IsEmpty()
    }

    var boundingBox: (any Vector2, any Vector2) {
        let box = profile.Bounds()
        return (box.min, box.max)
    }

    var vertexCount: Int {
        Int(profile.NumVert())
    }

    var area: Double {
        profile.Area()
    }
}

public extension Profile {
    static var empty: Self {
        Self(manifold.CrossSection())
    }

    static func rectangle(size: any Vector2) -> Self {
        Self(manifold.CrossSection.Square(size.vec2))
    }

    static func circle(radius: Double, segmentCount: Int) -> Self {
        Self(manifold.CrossSection.Circle(radius, Int32(segmentCount)))
    }
}

public extension Profile {
    func applyOperation(_ op: BooleanOperation, with other: Profile) -> Self {
        Self(profile.Boolean(other.profile, op.manifoldOp))
    }

    func translate(_ translation: any Vector2) -> Self {
        Self(profile.Translate(translation.vec2))
    }

    func scale(_ scale: any Vector2) -> Self {
        Self(profile.Scale(scale.vec2))
    }

    func rotate(_ degrees: Double) -> Self {
        Self(profile.Rotate(degrees))
    }

    func convexHull() -> Self {
        Self(profile.Hull())
    }
}

public extension Profile {
    func extrude(height: Double, divisions: Int, twist twistDegrees: Double, scaleTop: any Vector2) -> Mesh {
        .init(manifold.Manifold.Extrude(profile.ToPolygons(), height, Int32(divisions), twistDegrees, scaleTop.vec2))
    }

    func revolve(degrees: Double, circularSegments: Int) -> Mesh {
        .init(manifold.Manifold.Revolve(profile.ToPolygons(), Int32(circularSegments), degrees))
    }
}
