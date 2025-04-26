import Foundation
import ManifoldCPP
import ManifoldBridge

public extension CrossSection {
    static func boolean(_ op: BooleanOperation, with children: [Self]) -> Self {
        Self(manifold.CrossSection.BatchBoolean(.init(children.map(\.crossSection)), op.manifoldOp))
    }

    func boolean(_ op: BooleanOperation, with other: Self) -> Self {
        Self(crossSection.Boolean(other.crossSection, op.manifoldOp))
    }

    func warp(_ function: @escaping (V) -> V) -> Self {
        Self(bridge.Warp(crossSection) {
            $0.pointee = function(.init($0.pointee)).vec2
        })
    }

    func offset(amount: Double, joinType: JoinType, miterLimit: Double, circularSegments: Int? = nil) -> Self {
        Self(crossSection.Offset(amount, joinType.manifoldType, miterLimit, Int32(circularSegments ?? 0)))
    }

    func simplify(epsilon: Double = 1e-6) -> Self {
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

    static func hull(_ points: [V]) -> Self {
        Self(manifold.CrossSection.Hull(.init(points.map(\.vec2))))
    }
}

public extension CrossSection {
    func extrude<V3: Vector3>(
        height: Double,
        divisions: Int = 0,
        twist twistDegrees: Double = 0,
        scaleTop: V? = nil
    ) -> Manifold<V3> {
        Manifold(manifold.Manifold.Extrude(
            crossSection.ToPolygons(), height, Int32(divisions), twistDegrees, scaleTop?.vec2 ?? .init(1, 1))
        )
    }

    func revolve<V3: Vector3>(degrees: Double, circularSegments: Int) -> Manifold<V3> {
        Manifold(manifold.Manifold.Revolve(crossSection.ToPolygons(), Int32(circularSegments), degrees))
    }
}
