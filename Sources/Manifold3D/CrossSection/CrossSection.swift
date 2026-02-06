internal import ManifoldCPP
internal import ManifoldBridge
import Cxx

public struct CrossSection<Vector: Vector2>: Geometry, @unchecked Sendable {
    public let crossSection: manifold.CrossSection

    internal init(_ crossSection: manifold.CrossSection) {
        initializeQoS()
        self.crossSection = crossSection
    }
}

public extension CrossSection {
    init(polygons: [Polygon<Vector>], fillRule: FillRule) {
        self.init(manifold.CrossSection(Polygon.manifoldPolygons(polygons), fillRule.manifoldFillRule))
    }

    func polygons() -> [Polygon<Vector>] {
        crossSection.ToPolygons().map { Polygon($0) }
    }

    func decompose() -> [Self] {
        crossSection.Decompose().map(CrossSection.init)
    }
}

// SimplePolygon is already CxxVector
// Not sure why, but this makes SimplePolygon work with the CxxVector initializer
extension manifold.SimplePolygon: CxxVector, CxxRandomAccessCollection {}
