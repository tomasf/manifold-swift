import Foundation

public struct Triangle: Hashable, Sendable {
    public typealias VertexIndex = Int

    public let a: VertexIndex
    public let b: VertexIndex
    public let c: VertexIndex

    public init(_ a: VertexIndex, _ b: VertexIndex, _ c: VertexIndex) {
        self.a = a
        self.b = b
        self.c = c
    }

    internal var indices: [VertexIndex] {
        [a, b, c]
    }
}
