internal import ManifoldCPP

/// A two-dimensional vector type.
///
/// Conform your own 2D vector type to this protocol to use it with ``CrossSection`` and ``Polygon``.
public protocol Vector2: Sendable {
    /// The x component.
    var x: Double { get }
    /// The y component.
    var y: Double { get }

    /// Creates a vector with the given components.
    init(x: Double, y: Double)
}

/// A three-dimensional vector type.
///
/// Conform your own 3D vector type to this protocol to use it with ``Manifold`` and ``MeshGL``.
public protocol Vector3: Sendable {
    /// The x component.
    var x: Double { get }
    /// The y component.
    var y: Double { get }
    /// The z component.
    var z: Double { get }

    /// Creates a vector with the given components.
    init(x: Double, y: Double, z: Double)
}


internal extension Vector2 {
    init(_ manifoldVector: manifold.vec2) {
        self.init(x: manifoldVector.x, y: manifoldVector.y)
    }

    var vec2: manifold.vec2 { .init(x, y) }
}

internal extension Vector3 {
    init(_ manifoldVector: manifold.vec3) {
        self.init(x: manifoldVector.x, y: manifoldVector.y, z: manifoldVector.z)
    }

    var vec3: manifold.vec3 { .init(x, y, z) }
}
