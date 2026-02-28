import Foundation

/// A protocol providing the shared interface for 2D and 3D geometry types.
///
/// Both ``Manifold`` and ``CrossSection`` conform to this protocol, giving them a
/// common set of operations including Boolean operations, transforms, convex hulls, and warping.
public protocol Geometry<Vector>: Sendable {
    /// The vector type used for positions.
    associatedtype Vector
    /// The type used to specify rotations.
    associatedtype Rotation
    /// The type used to specify affine transforms.
    associatedtype Transform

    /// An empty geometry with no vertices or faces.
    static var empty: Self { get }
    /// Separates this geometry into its disconnected components.
    func decompose() -> [Self]

    /// Whether this geometry contains no vertices.
    var isEmpty: Bool { get }
    /// The axis-aligned bounding box of this geometry.
    var bounds: (min: Vector, max: Vector) { get }
    /// The number of vertices in this geometry.
    var vertexCount: Int { get }

    /// Applies an affine transform to this geometry.
    func transform(_ transform: Transform) -> Self
    /// Translates this geometry by the given offset.
    func translate(_ translation: Vector) -> Self
    /// Scales this geometry by the given factors along each axis.
    func scale(_ scale: Vector) -> Self
    /// Rotates this geometry by the given rotation.
    func rotate(_ rotation: Rotation) -> Self

    /// Applies a Boolean operation between this geometry and another.
    func boolean(_ op: BooleanOperation, with other: Self) -> Self
    /// Applies a Boolean operation across multiple geometries.
    static func boolean(_ op: BooleanOperation, with children: [Self]) -> Self

    /// Returns the convex hull of this geometry.
    func hull() -> Self
    /// Returns the convex hull of multiple geometries.
    static func hull(_ children: [Self]) -> Self
    /// Returns the convex hull of a set of points.
    static func hull(_ points: [Vector]) -> Self

    /// Applies a function to each vertex position, deforming the geometry.
    func warp(_ function: @escaping (Vector) -> Vector) -> Self
    /// Simplifies the geometry, removing vertices within the given tolerance.
    func simplify(epsilon: Double) -> Self
}
