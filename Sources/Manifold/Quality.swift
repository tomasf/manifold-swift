import ManifoldCPP

public struct Quality {
    private init() {}
}

public extension Quality {
    private typealias Q = manifold.Quality

    enum CircularSegments {
        case defaults
        case fixed (count: Int)
        case dynamic (minAngle: Double, minEdgeLength: Double)
    }

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

    static func circularSegmentCount(for radius: Double) -> Int {
        Int(Q.GetCircularSegments(radius))
    }
}
