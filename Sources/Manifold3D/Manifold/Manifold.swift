import ManifoldCPP

public struct Manifold<Vector: Vector3>: Geometry, @unchecked Sendable {    
    public let mesh: manifold.Manifold

    internal init(_ mesh: manifold.Manifold) {
        self.mesh = mesh
    }
}

public extension Manifold {
    init(_ meshGL: MeshGL<Vector>) throws(Error) {
        self.init(manifold.Manifold(meshGL.meshGL))
        if isEmpty, let error = self.status {
            throw error
        }
    }

    func meshGL(normalChannelIndex: Int = -1) -> MeshGL<Vector> {
        MeshGL(meshGL: mesh.GetMeshGL64(Int32(normalChannelIndex)))
    }

    var status: ManifoldError? {
        ManifoldError(mesh.Status())
    }

    func minimumGap(to other: Manifold, searchLength: Double) -> Double {
        mesh.MinGap(other.mesh, searchLength)
    }
}

public enum ManifoldError: Swift.Error {
    case nonFiniteVertex
    case notManifold
    case vertexOutOfBounds
    case propertiesWrongLength
    case missingPositionProperties
    case mergeVectorsDifferentLengths
    case mergeIndexOutOfBounds
    case transformWrongLength
    case runIndexWrongLength
    case faceIDWrongLength
    case invalidConstruction
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
