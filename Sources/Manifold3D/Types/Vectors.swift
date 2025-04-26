import ManifoldCPP

public protocol Vector2 {
    var x: Double { get }
    var y: Double { get }

    init(x: Double, y: Double)
}

public protocol Vector3 {
    var x: Double { get }
    var y: Double { get }
    var z: Double { get }

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
