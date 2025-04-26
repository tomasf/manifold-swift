import Foundation
import ManifoldCPP

public struct Polygon<V: Vector2> {
    public let vertices: [V]

    public init(vertices: [V]) {
        self.vertices = vertices
    }
}

public extension Polygon {
    static func triangulate(_ polygons: [Polygon], epsilon: Double) -> [Triangle] {
        manifold.Triangulate(Polygon.manifoldPolygons(polygons), epsilon).map(Triangle.init)
    }

    func triangulate(epsilon: Double) -> [Triangle] {
        Self.triangulate([self], epsilon: epsilon)
    }
}

internal extension Polygon {
    init(_ polygon: manifold.SimplePolygon) {
        self.init(vertices: polygon.map { .init($0) })
    }

    var manifoldPolygon: manifold.SimplePolygon {
        .init(vertices.map(\.vec2))
    }

    static func manifoldPolygons(_ polygons: [Self]) -> manifold.Polygons {
        .init(polygons.map(\.manifoldPolygon))
    }
}
