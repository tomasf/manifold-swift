import ManifoldCPP

public enum BooleanOperation {
    case union
    case difference
    case intersection

    internal var manifoldOp: manifold.OpType {
        switch self {
        case .union: .Add
        case .difference: .Subtract
        case .intersection: .Intersect
        }
    }
}

