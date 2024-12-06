import ManifoldCPP

public protocol Matrix3x4 {
    subscript(_ row: Int, _ column: Int) -> Double { get }
}

public protocol Matrix2x3 {
    subscript(_ row: Int, _ column: Int) -> Double { get }
}

internal extension Matrix3x4 {
    var mat3x4: manifold.mat3x4 {
        let values = (0..<3).flatMap { row in
            (0..<4).map { column in self[row, column] }
        }
        return values.withUnsafeBufferPointer { .init($0.baseAddress) }
    }
}

internal extension Matrix2x3 {
    var mat2x3: manifold.mat2x3 {
        let values = (0..<2).flatMap { row in
            (0..<3).map { column in self[row, column] }
        }
        return values.withUnsafeBufferPointer { .init($0.baseAddress) }
    }
}
