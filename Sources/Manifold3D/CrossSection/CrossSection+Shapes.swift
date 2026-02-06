internal import ManifoldCPP

public extension CrossSection {
    /// An empty cross-section with no contours.
    static var empty: Self {
        Self(manifold.CrossSection())
    }

    /// Creates a rectangle with the given dimensions, with its minimum corner at the origin.
    /// - Parameter size: The width and height of the rectangle.
    static func square(size: Vector) -> Self {
        Self(manifold.CrossSection.Square(size.vec2))
    }

    /// Creates a circle centered at the origin.
    /// - Parameter radius: The radius of the circle.
    /// - Parameter segmentCount: The number of line segments used to approximate the circle.
    static func circle(radius: Double, segmentCount: Int) -> Self {
        Self(manifold.CrossSection.Circle(radius, Int32(segmentCount)))
    }
}

