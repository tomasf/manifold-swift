import Foundation
internal import ManifoldCPP
internal import ManifoldBridge

public extension CrossSection {
    /// Applies a Boolean operation across multiple cross-sections.
    /// - Parameter op: The Boolean operation to apply.
    /// - Parameter children: The cross-sections to combine.
    static func boolean(_ op: BooleanOperation, with children: [Self]) -> Self {
        Self(manifold.CrossSection.BatchBoolean(.init(children.map(\.crossSection)), op.manifoldOp))
    }

    /// Applies a Boolean operation between this cross-section and another.
    /// - Parameter op: The Boolean operation to apply.
    /// - Parameter other: The other cross-section.
    func boolean(_ op: BooleanOperation, with other: Self) -> Self {
        Self(crossSection.Boolean(other.crossSection, op.manifoldOp))
    }

    /// Applies a function to each vertex position, deforming the cross-section.
    func warp(_ function: @escaping (Vector) -> Vector) -> Self {
        Self(bridge.Warp(crossSection) {
            $0.pointee = function(.init($0.pointee)).vec2
        })
    }

    /// Offsets the contours of this cross-section by the given amount.
    /// - Parameter amount: The offset distance. Positive values expand, negative values shrink.
    /// - Parameter joinType: The method used to join path segments at corners.
    /// - Parameter miterLimit: The maximum extension for miter joins, as a multiple of the offset.
    /// - Parameter circularSegments: The number of segments for round joins. If `nil`, uses the global quality setting.
    func offset(amount: Double, joinType: JoinType, miterLimit: Double, circularSegments: Int? = nil) -> Self {
        Self(crossSection.Offset(amount, joinType.manifoldType, miterLimit, Int32(circularSegments ?? 0)))
    }

    /// Simplifies the contours by removing vertices within the given tolerance.
    /// - Parameter epsilon: The maximum distance a vertex may deviate from the simplified path.
    func simplify(epsilon: Double = 1e-6) -> Self {
        Self(crossSection.Simplify(epsilon))
    }
}

public extension CrossSection {
    /// Returns the convex hull of this cross-section.
    func hull() -> Self {
        Self(crossSection.Hull())
    }

    /// Returns the convex hull of multiple cross-sections.
    static func hull(_ crossSections: [CrossSection]) -> Self {
        Self(manifold.CrossSection.Hull(.init(crossSections.map(\.crossSection))))
    }

    /// Returns the convex hull of a set of 2D points.
    static func hull(_ points: [Vector]) -> Self {
        Self(manifold.CrossSection.Hull(.init(points.map(\.vec2))))
    }
}

public extension CrossSection {
    /// Extrudes this cross-section along the Z axis to create a 3D manifold.
    /// - Parameter height: The height of the extrusion.
    /// - Parameter divisions: The number of intermediate layers for twist and scale interpolation. Defaults to `0`.
    /// - Parameter twistDegrees: The total rotation applied over the height, in degrees. Defaults to `0`.
    /// - Parameter scaleTop: The scale factor applied to the top cross-section. Defaults to uniform scale (1, 1).
    func extrude<V3: Vector3>(
        height: Double,
        divisions: Int = 0,
        twist twistDegrees: Double = 0,
        scaleTop: Vector? = nil
    ) -> Manifold<V3> {
        Manifold(manifold.Manifold.Extrude(
            crossSection.ToPolygons(), height, Int32(divisions), twistDegrees, scaleTop?.vec2 ?? .init(1, 1))
        )
    }

    /// Revolves this cross-section around the Y axis to create a 3D manifold.
    /// - Parameter degrees: The angle of revolution in degrees.
    /// - Parameter circularSegments: The number of segments used to approximate the revolution.
    func revolve<V3: Vector3>(degrees: Double, circularSegments: Int) -> Manifold<V3> {
        Manifold(manifold.Manifold.Revolve(crossSection.ToPolygons(), Int32(circularSegments), degrees))
    }
}
