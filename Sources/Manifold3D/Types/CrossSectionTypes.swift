import Foundation
internal import ManifoldCPP

public extension CrossSection {
    /// A rule that determines which areas are considered "inside" when constructing a cross-section from polygons.
    enum FillRule: Hashable, Sendable {
        /// A point is inside if the winding number is odd.
        case evenOdd
        /// A point is inside if the winding number is nonzero.
        case nonZero
        /// A point is inside if the winding number is positive.
        case positive
        /// A point is inside if the winding number is negative.
        case negative

        var manifoldFillRule: manifold.CrossSection.FillRule {
            switch self {
            case .evenOdd: return .EvenOdd
            case .nonZero: return .NonZero
            case .positive: return .Positive
            case .negative: return .Negative
            }
        }
    }

    /// The method used to join path segments when offsetting a cross-section.
    enum JoinType: Int, Hashable, Sendable {
        /// Sharp corners, extended to the miter limit.
        case miter
        /// Rounded corners using circular arcs.
        case round
        /// Squared-off corners, extending half the offset distance.
        case square
        /// Beveled (flat) corners.
        case bevel

        internal var manifoldType: manifold.CrossSection.JoinType {
            switch self {
            case .miter: return .Miter
            case .round: return .Round
            case .square: return .Square
            case .bevel: return .Bevel
            }
        }
    }
}
