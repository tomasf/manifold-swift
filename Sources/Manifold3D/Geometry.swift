import Foundation

public protocol Geometry<Vector>: Sendable {
    associatedtype Vector
    associatedtype Rotation
    associatedtype Transform

    static var empty: Self { get }
    init(composing: [Self])
    func decompose() -> [Self]

    var isEmpty: Bool { get }
    var bounds: (min: Vector, max: Vector) { get }
    var vertexCount: Int { get }

    func transform(_ transform: Transform) -> Self
    func translate(_ translation: Vector) -> Self
    func scale(_ scale: Vector) -> Self
    func rotate(_ rotation: Rotation) -> Self

    func boolean(_ op: BooleanOperation, with other: Self) -> Self
    static func boolean(_ op: BooleanOperation, with children: [Self]) -> Self

    func hull() -> Self
    static func hull(_ children: [Self]) -> Self
    static func hull(_ points: [Vector]) -> Self

    func warp(_ function: @escaping (Vector) -> Vector) -> Self
    func simplify(epsilon: Double) -> Self
}
