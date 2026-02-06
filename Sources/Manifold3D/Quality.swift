internal import ManifoldCPP

/// Controls the quantization of circular shapes into line segments.
///
/// Use this type to configure how many segments are used when creating circles,
/// spheres, cylinders, and other shapes derived from circles.
public struct Quality {
    private init() {}
}

public extension Quality {
    private typealias Q = manifold.Quality

    /// Specifies how circular segments are determined.
    enum CircularSegments {
        /// Resets to the default segment calculation.
        case defaults
        /// Uses a fixed number of segments for all circles regardless of radius.
        case fixed (count: Int)
        /// Determines segment count dynamically based on minimum angle and edge length constraints.
        case dynamic (minAngle: Double, minEdgeLength: Double)
    }

    /// Sets the global quality for circular shape quantization.
    ///
    /// When using ``CircularSegments/fixed(count:)``, the given count is used for all circles.
    /// When using ``CircularSegments/dynamic(minAngle:minEdgeLength:)``, the segment count is
    /// calculated per circle to satisfy both the minimum angle and minimum edge length constraints.
    /// - Parameter segments: The segment calculation method to use.
    static func setCircleQuality(_ segments: CircularSegments) {
        switch segments {
        case .defaults:
            Q.ResetToDefaults()

        case .fixed(count: let count):
            Q.SetCircularSegments(Int32(count))

        case .dynamic(minAngle: let minAngle, minEdgeLength: let minEdgeLength):
            Q.SetCircularSegments(0)
            Q.SetMinCircularAngle(minAngle)
            Q.SetMinCircularEdgeLength(minEdgeLength)
        }
    }

    /// Returns the number of circular segments that would be used for a circle with the given radius.
    /// - Parameter radius: The radius of the circle.
    /// - Returns: The number of segments based on the current quality settings.
    static func circularSegmentCount(for radius: Double) -> Int {
        Int(Q.GetCircularSegments(radius))
    }
}
