import Foundation
internal import ManifoldCPP
internal import ManifoldBridge

/// A triangle defined by three vertex indices into a vertex array.
public struct Triangle: Hashable, Sendable {
    /// An index into a vertex array.
    public typealias VertexIndex = Int

    /// The index of the first vertex.
    public let a: VertexIndex
    /// The index of the second vertex.
    public let b: VertexIndex
    /// The index of the third vertex.
    public let c: VertexIndex

    /// Creates a triangle from three vertex indices.
    public init(_ a: VertexIndex, _ b: VertexIndex, _ c: VertexIndex) {
        self.a = a
        self.b = b
        self.c = c
    }

    internal var indices: [VertexIndex] {
        [a, b, c]
    }

    internal init(_ ivec: manifold.ivec3) {
        self.init(Int(ivec.x), Int(ivec.y), Int(ivec.z))
    }

    internal init(_ ivec: bridge.ivec64) {
        self.init(Int(ivec.x), Int(ivec.y), Int(ivec.z))
    }
}
