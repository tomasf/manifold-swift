import Foundation
internal import ManifoldCPP

/// A simple polygon defined by an ordered list of 2D vertices.
public struct Polygon<V: Vector2> {
    /// The ordered vertices of this polygon.
    public let vertices: [V]

    /// Creates a polygon from an ordered list of vertices.
    public init(vertices: [V]) {
        self.vertices = vertices
    }
}

public extension Polygon {
    /// Triangulates multiple polygons into a list of triangles.
    /// - Parameter polygons: The polygons to triangulate.
    /// - Parameter epsilon: The precision tolerance for degenerate-edge removal.
    /// - Returns: An array of triangles with indices into the combined vertex array.
    static func triangulate(_ polygons: [Polygon], epsilon: Double) -> [Triangle] {
        manifold.Triangulate(Polygon.manifoldPolygons(polygons), epsilon).map(Triangle.init)
    }

    /// Triangulates this polygon into a list of triangles.
    /// - Parameter epsilon: The precision tolerance for degenerate-edge removal.
    /// - Returns: An array of triangles with indices into this polygon's vertex array.
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
