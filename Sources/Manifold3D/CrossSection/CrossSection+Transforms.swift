import ManifoldCPP

public extension CrossSection {
    func transform<M: Matrix2x3>(_ transform: M) -> Self {
        Self(crossSection.Transform(transform.mat2x3))
    }

    func translate(_ translation: V) -> Self {
        Self(crossSection.Translate(translation.vec2))
    }

    func scale(_ scale: V) -> Self {
        Self(crossSection.Scale(scale.vec2))
    }

    func rotate(_ degrees: Double) -> Self {
        Self(crossSection.Rotate(degrees))
    }

    func mirror(_ axis: V) -> Self {
        Self(crossSection.Mirror(axis.vec2))
    }
}
