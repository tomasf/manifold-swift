import ManifoldCPP

public protocol Matrix3x4 {
    subscript(_ row: Int, _ column: Int) -> Double { get }
}

public protocol Matrix2x3 {
    subscript(_ row: Int, _ column: Int) -> Double { get }
}

internal extension Matrix3x4 {
    var mat3x4: manifold.mat3x4 {
        (0..<4).flatMap { column in
            (0..<3).map { row in self[row, column] }
        }.withUnsafeBufferPointer {
            manifold.mat3x4($0.baseAddress)
        }
    }
}

internal extension Matrix2x3 {
    var mat2x3: manifold.mat2x3 {
        (0..<3).flatMap { column in
            (0..<2).map { row in self[row, column] }
        }.withUnsafeBufferPointer {
            manifold.mat2x3($0.baseAddress)
        }
    }
}
