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

    static func polygon(_ polygon: [any Vector2], fillRule: FillRule) -> Self {
        Self(manifold.CrossSection(.init(polygon.map(\.vec2)), fillRule.primitive))
    }

    static func polygons(_ polygons: [[any Vector2]], fillRule: FillRule) -> Self {
        Self(manifold.CrossSection(.init(polygons.map { .init($0.map(\.vec2)) }), fillRule.primitive))
    }
}

public extension CrossSection {
    enum FillRule {
        case evenOdd
        case nonZero
        case positive
        case negative

        internal init(_ primitive: manifold.CrossSection.FillRule) {
            switch primitive {
            case .EvenOdd: self = .evenOdd
            case .NonZero: self = .nonZero
            case .Positive: self = .positive
            case .Negative: self = .negative
            @unknown default:
                assertionFailure("Unknown fill rule")
                self = .nonZero
            }
        }

        var primitive: manifold.CrossSection.FillRule {
            switch self {
            case .evenOdd: return .EvenOdd
            case .nonZero: return .NonZero
            case .positive: return .Positive
            case .negative: return .Negative
            }
        }
    }
}
