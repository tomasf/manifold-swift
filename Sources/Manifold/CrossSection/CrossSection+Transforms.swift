import ManifoldCPP

public extension CrossSection {
    func transform(_ transform: any Matrix2x3) -> Self {
        Self(crossSection.Transform(transform.mat2x3))
    }

    func translate(_ translation: any Vector2) -> Self {
        Self(crossSection.Translate(translation.vec2))
    }

    func scale(_ scale: any Vector2) -> Self {
        Self(crossSection.Scale(scale.vec2))
    }

    func rotate(_ degrees: Double) -> Self {
        Self(crossSection.Rotate(degrees))
    }
}
