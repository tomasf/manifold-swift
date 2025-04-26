import Foundation
import ManifoldCPP
import ManifoldBridge

public struct Triangle: Hashable, Sendable {
    public typealias VertexIndex = Int
    public let a, b, c: VertexIndex

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
