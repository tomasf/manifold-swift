import Foundation
import ManifoldCPP
import ManifoldBridge

public extension Mesh {
    init(meshGL: MeshGL, smoothEdges: [MeshGL.EdgeReference: Double]) {
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

public extension Mesh {
    func refine(piecesPerEdge: Int) -> Mesh {
        Self(mesh.Refine(Int32(piecesPerEdge)))
    }

    func refine(edgeLength: Double) -> Mesh {
        Self(mesh.RefineToLength(edgeLength))
    }

    func refine(tolerance: Double) -> Mesh {
        Self(mesh.RefineToTolerance(tolerance))
    }

    func settingTolerance(_ tolerance: Double) -> Mesh {
        Self(mesh.SetTolerance(tolerance))
    }
}
