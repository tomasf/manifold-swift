import Foundation
import ManifoldCPP

public struct Polygon {
    public let vertices: [any Vector2]

    public init(vertices: [any Vector2]) {
        self.vertices = vertices
    }
}

internal extension Polygon {
    init(_ polygon: manifold.SimplePolygon) {
        self.init(vertices: .init(polygon))
    }

    var manifoldPolygon: manifold.SimplePolygon {
        .init(vertices.map(\.vec2))
    }
}

internal extension [Polygon] {
    var manifoldPolygons: manifold.Polygons {
        .init(map(\.manifoldPolygon))
    }
}
