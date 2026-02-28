import Foundation
internal import ManifoldCPP
internal import ManifoldBridge

public extension Manifold {
    /// Creates a smooth manifold from a mesh with per-edge smoothness values.
    ///
    /// Edges with smoothness `0` are sharp and edges with smoothness `1` are fully smooth.
    /// The mesh is refined into a smooth surface when ``refine(piecesPerEdge:)`` or similar is called.
    /// - Parameter meshGL: The input mesh.
    /// - Parameter smoothEdges: A dictionary mapping edge references to smoothness values (0 to 1). Defaults to an empty dictionary.
    init(meshGL: MeshGL<Vector>, smoothEdges: [MeshGL<Vector>.EdgeReference: Double] = [:]) {
        initializeQoS()
        self = Self(manifold.Manifold.Smooth(meshGL.meshGL, .init(smoothEdges.map {
            manifold.Smoothness(halfedge: $0.key.index, smoothness: $0.value)
        })))
    }

    /// Sets smoothing based on vertex normals stored in the given property channels.
    /// - Parameter index: The starting property channel index where normals are stored.
    func smoothByNormals(index: Int) -> Self {
        Self(mesh.SmoothByNormals(Int32(index)))
    }

    /// Automatically smooths edges that are less sharp than the given angle.
    /// - Parameter minSharpAngle: Edges with dihedral angles less than this (in degrees) will be smoothed. Defaults to `60`.
    /// - Parameter minSmoothness: The minimum smoothness value to assign to smoothed edges. Defaults to `0`.
    func smoothOut(minSharpAngle: Double = 60, minSmoothness: Double = 0) -> Self {
        Self(mesh.SmoothOut(minSharpAngle, minSmoothness))
    }
}

public extension Manifold {
    /// Subdivides each edge into the given number of pieces, applying smoothing if set.
    /// - Parameter piecesPerEdge: The number of pieces to split each edge into.
    func refine(piecesPerEdge: Int) -> Manifold {
        Self(mesh.Refine(Int32(piecesPerEdge)))
    }

    /// Subdivides edges to achieve a target edge length, applying smoothing if set.
    /// - Parameter edgeLength: The target maximum edge length.
    func refine(edgeLength: Double) -> Manifold {
        Self(mesh.RefineToLength(edgeLength))
    }

    /// Subdivides edges to achieve a target surface tolerance, applying smoothing if set.
    /// - Parameter tolerance: The maximum distance the refined surface may deviate from the smooth ideal.
    func refine(tolerance: Double) -> Manifold {
        Self(mesh.RefineToTolerance(tolerance))
    }

    /// Returns a copy of this manifold with an updated precision tolerance.
    /// - Parameter tolerance: The new tolerance value for vertex deduplication and edge collapsing.
    func settingTolerance(_ tolerance: Double) -> Manifold {
        Self(mesh.SetTolerance(tolerance))
    }

    /// Simplifies the mesh by removing vertices that are within the given tolerance.
    /// - Parameter epsilon: The maximum distance a vertex may be removed from its original position. Defaults to `0`.
    func simplify(epsilon: Double = 0) -> Self {
        Self(mesh.Simplify(epsilon))
    }
}
