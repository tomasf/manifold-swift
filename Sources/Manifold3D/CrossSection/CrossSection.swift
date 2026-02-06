internal import ManifoldCPP
internal import ManifoldBridge
import Cxx

/// A 2D cross-section representing one or more closed, non-self-intersecting contours.
///
/// Cross-sections are built from polygons or primitive shapes and support Boolean operations,
/// transformations, offsetting, and convex hulls. They can be extruded or revolved into 3D ``Manifold`` geometry.
///
/// Internally backed by the Clipper2 polygon clipping library.
public struct CrossSection<Vector: Vector2>: Geometry, @unchecked Sendable {
    public let crossSection: manifold.CrossSection

    internal init(_ crossSection: manifold.CrossSection) {
        initializeQoS()
        self.crossSection = crossSection
    }
}

public extension CrossSection {
    /// Creates a cross-section from polygons using the specified fill rule.
    /// - Parameter polygons: The input polygons.
    /// - Parameter fillRule: The rule used to determine which areas are considered inside.
    init(polygons: [Polygon<Vector>], fillRule: FillRule) {
        self.init(manifold.CrossSection(Polygon.manifoldPolygons(polygons), fillRule.manifoldFillRule))
    }

    /// Exports this cross-section as an array of polygons.
    func polygons() -> [Polygon<Vector>] {
        crossSection.ToPolygons().map { Polygon($0) }
    }

    /// Separates this cross-section into its disconnected components.
    func decompose() -> [Self] {
        crossSection.Decompose().map(CrossSection.init)
    }
}

// SimplePolygon is already CxxVector
// Not sure why, but this makes SimplePolygon work with the CxxVector initializer
extension manifold.SimplePolygon: CxxVector, CxxRandomAccessCollection {}
