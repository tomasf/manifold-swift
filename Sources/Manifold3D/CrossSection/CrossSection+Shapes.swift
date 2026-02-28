internal import ManifoldCPP

public extension CrossSection {
    /// An empty cross-section with no contours.
    static var empty: Self {
        Self(manifold.CrossSection())
    }

    /// Creates a rectangle with the given dimensions.
    /// - Parameter size: The width and height of the rectangle.
    /// - Parameter center: If `true`, the square is centered at the origin. Defaults to `false`.
    static func square(size: Vector, center: Bool = false) -> Self {
        Self(manifold.CrossSection.Square(size.vec2, center))
    }

    /// Creates a circle centered at the origin.
    /// - Parameter radius: The radius of the circle.
    /// - Parameter segmentCount: The number of line segments used to approximate the circle.
    ///   Use `nil` to choose the count from the current ``Quality`` circular settings (default).
    static func circle(radius: Double, segmentCount: Int? = nil) -> Self {
        Self(manifold.CrossSection.Circle(radius, Int32(segmentCount ?? 0)))
    }
}
