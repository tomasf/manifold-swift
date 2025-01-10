import ManifoldCPP

public extension CrossSection {
    static var empty: Self {
        Self(manifold.CrossSection())
    }

    static func square(size: any Vector2) -> Self {
        Self(manifold.CrossSection.Square(size.vec2))
    }

    static func circle(radius: Double, segmentCount: Int) -> Self {
        Self(manifold.CrossSection.Circle(radius, Int32(segmentCount)))
    }
}

