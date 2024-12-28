import Foundation
import ManifoldCPP

public func triangulate(polygons: [Polygon], epsilon: Double) -> [Triangle] {
    manifold.Triangulate(polygons.manifoldPolygons, epsilon)
        .map { Triangle(Int($0.x), Int($0.y), Int($0.z)) }
}
