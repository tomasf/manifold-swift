import ManifoldCPP

public protocol Vector3 {
    var x: Double { get }
    var y: Double { get }
    var z: Double { get }
}

extension manifold.vec2: Vector2 {}

public protocol Vector2 {
    var x: Double { get }
    var y: Double { get }
}

extension manifold.vec3: Vector3 {}

internal extension Vector3 {
    var vec3: manifold.vec3 { .init(x, y, z) }
}

internal extension Vector2 {
    var vec2: manifold.vec2 { .init(x, y) }
}
