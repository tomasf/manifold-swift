import ManifoldCPP
import Cxx

public struct CrossSection {
    internal let crossSection: manifold.CrossSection

    internal init(_ crossSection: manifold.CrossSection) {
        self.crossSection = crossSection
    }
}

public extension CrossSection {
    var isEmpty: Bool {
        crossSection.IsEmpty()
    }

    var boundingBox: (any Vector2, any Vector2) {
        let box = crossSection.Bounds()
        return (box.min, box.max)
    }

    var vertexCount: Int {
        Int(crossSection.NumVert())
    }

    var area: Double {
        crossSection.Area()
    }
}

public extension CrossSection {
    static var empty: Self {
        Self(manifold.CrossSection())
    }

    static func square(size: any Vector2) -> Self {
        Self(manifold.CrossSection.Square(size.vec2))
    }

    static func circle(radius: Double, segmentCount: Int) -> Self {
        Self(manifold.CrossSection.Circle(radius, Int32(segmentCount)))
    }

    static func polygon(_ polygon: [any Vector2]) -> Self {
        Self(manifold.CrossSection(.init(polygon.map(\.vec2)), .NonZero))
    }

    static func boolean(_ op: BooleanOperation, with children: [CrossSection]) -> Self {
        Self(manifold.CrossSection.BatchBoolean(.init(children.map(\.crossSection)), op.manifoldOp))
    }
}

// SimplePolygon is already CxxVector
// Not sure why, but this makes SimplePolygon work with the CxxVector initializer
extension manifold.SimplePolygon: CxxVector {}

public extension CrossSection {
    func boolean(_ op: BooleanOperation, with other: CrossSection) -> Self {
        Self(crossSection.Boolean(other.crossSection, op.manifoldOp))
    }

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

    func hull() -> Self {
        Self(crossSection.Hull())
    }

    func offset(amount: Double, joinType: JoinType, miterLimit: Double, circularSegments: Int? = nil) -> Self {
        Self(crossSection.Offset(amount, joinType.manifoldType, miterLimit, Int32(circularSegments ?? 0)))
    }
}

public extension CrossSection {
    enum JoinType: Int {
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

public extension CrossSection {
    func extrude(height: Double, divisions: Int = 0, twist twistDegrees: Double = 0, scaleTop: (any Vector2)? = nil) -> Mesh {
        .init(manifold.Manifold.Extrude(crossSection.ToPolygons(), height, Int32(divisions), twistDegrees, scaleTop?.vec2 ?? .init(1, 1)))
    }

    func revolve(degrees: Double, circularSegments: Int) -> Mesh {
        .init(manifold.Manifold.Revolve(crossSection.ToPolygons(), Int32(circularSegments), degrees))
    }
}
