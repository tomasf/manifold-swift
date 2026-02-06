internal import ManifoldCPP

/// A Boolean operation to apply between two geometries.
public enum BooleanOperation: Hashable, Sendable {
    /// Combines both geometries into one.
    case union
    /// Subtracts the second geometry from the first.
    case difference
    /// Keeps only the overlapping region.
    case intersection

    internal var manifoldOp: manifold.OpType {
        switch self {
        case .union: .Add
        case .difference: .Subtract
        case .intersection: .Intersect
        }
    }
}

