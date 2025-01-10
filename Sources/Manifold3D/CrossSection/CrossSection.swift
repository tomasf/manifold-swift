import ManifoldCPP
import Cxx

public struct CrossSection {
    internal let crossSection: manifold.CrossSection

    internal init(_ crossSection: manifold.CrossSection) {
        self.crossSection = crossSection
    }
}

public extension CrossSection {
    init(polygons: [Polygon], fillRule: FillRule) {
        self.init(manifold.CrossSection(polygons.manifoldPolygons, fillRule.manifoldFillRule))
    }

    func polygons() -> [Polygon] {
        crossSection.ToPolygons().map { Polygon($0) }
    }

    init(composing crossSections: [CrossSection]) {
        self = Self(manifold.CrossSection.Compose(.init(crossSections.map(\.crossSection))))
    }

    func decompose() -> [Self] {
        crossSection.Decompose().map(CrossSection.init)
    }
}

// SimplePolygon is already CxxVector
// Not sure why, but this makes SimplePolygon work with the CxxVector initializer
extension manifold.SimplePolygon: CxxVector, CxxRandomAccessCollection {}
