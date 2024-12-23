import ManifoldCPP

public extension CrossSection {
    static func boolean(_ op: BooleanOperation, with children: [CrossSection]) -> Self {
        Self(manifold.CrossSection.BatchBoolean(.init(children.map(\.crossSection)), op.manifoldOp))
    }

    func boolean(_ op: BooleanOperation, with other: CrossSection) -> Self {
        Self(crossSection.Boolean(other.crossSection, op.manifoldOp))
    }

    func warp(_ function: @escaping (any Vector2) -> any Vector2) -> Self {
        Self(manifold.warp(crossSection) { function($0).vec2 })
    }

    func hull() -> Self {
        Self(crossSection.Hull())
    }

    func offset(amount: Double, joinType: JoinType, miterLimit: Double, circularSegments: Int? = nil) -> Self {
        Self(crossSection.Offset(amount, joinType.manifoldType, miterLimit, Int32(circularSegments ?? 0)))
    }
}

public extension CrossSection {
    func extrude(height: Double, divisions: Int = 0, twist twistDegrees: Double = 0, scaleTop: (any Vector2)? = nil) -> Mesh {
        .init(manifold.Manifold.Extrude(crossSection.ToPolygons(), height, Int32(divisions), twistDegrees, scaleTop?.vec2 ?? .init(1, 1)))
    }

    func revolve(degrees: Double, circularSegments: Int? = nil) -> Mesh {
        .init(manifold.Manifold.Revolve(crossSection.ToPolygons(), Int32(circularSegments ?? 0), degrees))
    }
}

public extension CrossSection {
    enum JoinType: Int {
        case miter
        case round
        case square

        internal var manifoldType: manifold.CrossSection.JoinType {
            switch self {
            case .miter: return .Miter
            case .round: return .Round
            case .square: return .Square
            }
        }
    }
}
