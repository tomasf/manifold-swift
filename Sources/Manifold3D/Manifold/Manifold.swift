internal import ManifoldCPP
internal import ManifoldBridge

/// A 3D manifold solid, representing a closed, watertight triangle mesh.
///
/// `Manifold` supports Boolean operations, transformations, convex hulls, smoothing, and
/// vertex property channels. It tracks the provenance of faces through original IDs,
/// allowing you to map materials or other attributes back to source geometry after operations.
///
/// Create manifolds from primitives like ``sphere(radius:segmentCount:)`` and
/// ``cube(size:center:)``, or from a ``MeshGL`` mesh.
public struct Manifold<Vector: Vector3>: Geometry, @unchecked Sendable {
    internal let mesh: manifold.Manifold

    internal init(_ mesh: manifold.Manifold) {
        initializeQoS()
        self.mesh = mesh
    }
}

public extension Manifold {
    /// Creates a manifold from a mesh, validating that it is closed and manifold.
    /// - Parameter meshGL: The mesh to construct from.
    /// - Throws: A ``ManifoldError`` if the mesh is not valid.
    init(_ meshGL: MeshGL<Vector>) throws(Error) {
        self.init(manifold.Manifold(meshGL.meshGL))
        if isEmpty, let error = self.status {
            throw error
        }
    }

    /// Exports the manifold as a ``MeshGL`` mesh.
    /// - Parameter normalChannelIndex: If non-negative, the vertex property channel index where
    ///   normals will be recalculated and stored. Defaults to `-1` (no normal update).
    /// - Returns: The mesh representation of this manifold.
    func meshGL(normalChannelIndex: Int = -1) -> MeshGL<Vector> {
        MeshGL(meshGL: mesh.GetMeshGL64(Int32(normalChannelIndex)))
    }

    /// The error status of this manifold, or `nil` if no error has occurred.
    var status: ManifoldError? {
        ManifoldError(mesh.Status())
    }

    /// Returns the minimum gap between this manifold and another within the given search range.
    /// - Parameter other: The other manifold to measure the gap to.
    /// - Parameter searchLength: The maximum distance to search.
    /// - Returns: The minimum distance found, or `searchLength` if no closer gap exists.
    func minimumGap(to other: Manifold, searchLength: Double) -> Double {
        mesh.MinGap(other.mesh, searchLength)
    }
}

/// An error that occurs when constructing or operating on a ``Manifold``.
public enum ManifoldError: Swift.Error {
    /// A vertex contains a non-finite (NaN or infinite) coordinate.
    case nonFiniteVertex
    /// The mesh is not edge-manifold or not oriented.
    case notManifold
    /// A triangle references a vertex index outside the vertex array.
    case vertexOutOfBounds
    /// The vertex properties array has an incorrect length.
    case propertiesWrongLength
    /// The required position properties (x, y, z) are missing.
    case missingPositionProperties
    /// The merge vectors have different lengths.
    case mergeVectorsDifferentLengths
    /// A merge index is out of bounds.
    case mergeIndexOutOfBounds
    /// The transform array has an incorrect length.
    case transformWrongLength
    /// The run index array has an incorrect length.
    case runIndexWrongLength
    /// The face ID array has an incorrect length.
    case faceIDWrongLength
    /// The construction parameters are invalid.
    case invalidConstruction
    /// The result mesh is too large.
    case resultTooLarge

    internal init?(_ error: manifold.Manifold.Error) {
        switch error {
        case .NoError: return nil
        case .NonFiniteVertex: self = .nonFiniteVertex
        case .NotManifold: self = .notManifold
        case .VertexOutOfBounds: self = .vertexOutOfBounds
        case .PropertiesWrongLength: self = .propertiesWrongLength
        case .MissingPositionProperties: self = .missingPositionProperties
        case .MergeVectorsDifferentLengths: self = .mergeVectorsDifferentLengths
        case .MergeIndexOutOfBounds: self = .mergeIndexOutOfBounds
        case .TransformWrongLength: self = .transformWrongLength
        case .RunIndexWrongLength: self = .runIndexWrongLength
        case .FaceIDWrongLength: self = .faceIDWrongLength
        case .InvalidConstruction: self = .invalidConstruction
        case .ResultTooLarge: self = .resultTooLarge
        @unknown default:
            assertionFailure("Unknown error")
            return nil
        }
    }
}
