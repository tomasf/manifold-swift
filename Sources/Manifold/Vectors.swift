import ManifoldCPP

public protocol Vector3 {
    var x: Double { get }
    var y: Double { get }
    var z: Double { get }
}

public protocol Vector2 {
    var x: Double { get }
    var y: Double { get }
}

internal extension Vector3 {
    var vec3: manifold.vec3 { .init(x, y, z) }
}
