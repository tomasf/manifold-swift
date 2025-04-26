import ManifoldCPP
import Cxx

public struct CrossSection<V: Vector2>: @unchecked Sendable {
    internal let crossSection: manifold.CrossSection

    internal init(_ crossSection: manifold.CrossSection) {
        self.crossSection = crossSection
    }
}

public extension CrossSection {
    init(polygons: [Polygon<V>], fillRule: FillRule) {
        self.init(manifold.CrossSection(Polygon.manifoldPolygons(polygons), fillRule.manifoldFillRule))
    }

    func polygons() -> [Polygon<V>] {
        crossSection.ToPolygons().map { Polygon($0) }
    }

    init(composing crossSections: [Self]) {
        self = Self(manifold.CrossSection.Compose(.init(crossSections.map(\.crossSection))))
    }

    func decompose() -> [Self] {
        crossSection.Decompose().map(CrossSection.init)
    }
}

// SimplePolygon is already CxxVector
// Not sure why, but this makes SimplePolygon work with the CxxVector initializer
extension manifold.SimplePolygon: CxxVector, CxxRandomAccessCollection {}
