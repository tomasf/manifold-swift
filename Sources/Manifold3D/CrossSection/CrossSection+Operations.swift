import Foundation
import ManifoldCPP
import ManifoldBridge

public extension CrossSection {
    static func boolean(_ op: BooleanOperation, with children: [CrossSection]) -> Self {
        Self(manifold.CrossSection.BatchBoolean(.init(children.map(\.crossSection)), op.manifoldOp))
    }

    func boolean(_ op: BooleanOperation, with other: CrossSection) -> Self {
        Self(crossSection.Boolean(other.crossSection, op.manifoldOp))
    }

    func warp(_ function: @escaping (any Vector2) -> any Vector2) -> Self {
        Self(bridge.Warp(crossSection) {
            $0.pointee = function($0.pointee).vec2
        })
    }

    func offset(amount: Double, joinType: JoinType, miterLimit: Double, circularSegments: Int? = nil) -> Self {
        Self(crossSection.Offset(amount, joinType.manifoldType, miterLimit, Int32(circularSegments ?? 0)))
    }

    func simplify(epsilon: Double = 1e-6) -> CrossSection {
        Self(crossSection.Simplify(epsilon))
    }
}

public extension CrossSection {
    func hull() -> Self {
        Self(crossSection.Hull())
    }

    static func hull(_ crossSections: [CrossSection]) -> Self {
        Self(manifold.CrossSection.Hull(.init(crossSections.map(\.crossSection))))
    }

    static func hull(_ points: [any Vector2]) -> Self {
        Self(manifold.CrossSection.Hull(.init(points.map(\.vec2))))
    }
}

public extension CrossSection {
    func extrude(height: Double, divisions: Int = 0, twist twistDegrees: Double = 0, scaleTop: (any Vector2)? = nil) -> Manifold {
        .init(manifold.Manifold.Extrude(crossSection.ToPolygons(), height, Int32(divisions), twistDegrees, scaleTop?.vec2 ?? .init(1, 1)))
    }

    func revolve(degrees: Double, circularSegments: Int) -> Manifold {
        .init(manifold.Manifold.Revolve(crossSection.ToPolygons(), Int32(circularSegments), degrees))
    }
}
