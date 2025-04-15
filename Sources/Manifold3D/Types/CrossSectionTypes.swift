import Foundation
import ManifoldCPP

public extension CrossSection {
    enum FillRule: Hashable, Sendable {
        case evenOdd
        case nonZero
        case positive
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

    enum JoinType: Int, Hashable, Sendable {
        case miter
        case round
        case square

        internal var manifoldType: manifold.CrossSection.JoinType {
            switch self {
            case .miter: return .Miter
            case .round: return .Round
            case .square: return .Square
            }
        }
    }
}
