import Foundation
import ManifoldCPP
import ManifoldBridge

public extension Manifold {
    init(meshGL: MeshGL<V>, smoothEdges: [MeshGL<V>.EdgeReference: Double]) {
        self = Self(manifold.Manifold.Smooth(meshGL.meshGL, .init(smoothEdges.map {
            manifold.Smoothness(halfedge: $0.key.index, smoothness: $0.value)
        })))
    }

    func smoothByNormals(index: Int) -> Self {
        Self(mesh.SmoothByNormals(Int32(index)))
    }

    func smoothOut(minSharpAngle: Double, minSmoothness: Double) -> Self {
        Self(mesh.SmoothOut(minSharpAngle, minSmoothness))
    }
}

public extension Manifold {
    func refine(piecesPerEdge: Int) -> Manifold {
        Self(mesh.Refine(Int32(piecesPerEdge)))
    }

    func refine(edgeLength: Double) -> Manifold {
        Self(mesh.RefineToLength(edgeLength))
    }

    func refine(tolerance: Double) -> Manifold {
        Self(mesh.RefineToTolerance(tolerance))
    }

    func settingTolerance(_ tolerance: Double) -> Manifold {
        Self(mesh.SetTolerance(tolerance))
    }

    func simplify(epsilon: Double) -> Self {
        Self(mesh.Simplify(epsilon))
    }
}
