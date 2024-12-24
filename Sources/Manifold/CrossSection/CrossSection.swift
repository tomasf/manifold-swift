import ManifoldCPP
import Cxx

public struct CrossSection {
    internal let crossSection: manifold.CrossSection

    internal init(_ crossSection: manifold.CrossSection) {
        self.crossSection = crossSection
    }

    public func decompose() -> [Self] {
        crossSection.Decompose().map(CrossSection.init)
    }
}

// SimplePolygon is already CxxVector
// Not sure why, but this makes SimplePolygon work with the CxxVector initializer
extension manifold.SimplePolygon: CxxVector {}
