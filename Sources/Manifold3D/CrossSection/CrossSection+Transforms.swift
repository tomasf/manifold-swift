internal import ManifoldCPP

public extension CrossSection {
    /// Applies a 2x3 affine transform matrix to this cross-section.
    func transform(_ transform: any Matrix2x3) -> Self {
        Self(crossSection.Transform(transform.mat2x3))
    }

    /// Translates this cross-section by the given offset.
    func translate(_ translation: Vector) -> Self {
        Self(crossSection.Translate(translation.vec2))
    }

    /// Scales this cross-section by the given factors along each axis.
    func scale(_ scale: Vector) -> Self {
        Self(crossSection.Scale(scale.vec2))
    }

    /// Rotates this cross-section by the given angle in degrees.
    func rotate(_ degrees: Double) -> Self {
        Self(crossSection.Rotate(degrees))
    }

    /// Mirrors this cross-section across the axis defined by the given vector through the origin.
    func mirror(_ axis: Vector) -> Self {
        Self(crossSection.Mirror(axis.vec2))
    }
}
