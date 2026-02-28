internal import ManifoldCPP

/// A matrix type that provides element access by row and column.
public protocol Matrix {
    /// Accesses the element at the given row and column.
    subscript(_ row: Int, _ column: Int) -> Double { get }
}

/// A 3-row, 4-column matrix representing a 3D affine transform.
///
/// Conform your own matrix type to this protocol to use it with ``Manifold/transform(_:)``.
public protocol Matrix3x4: Matrix {}

/// A 2-row, 3-column matrix representing a 2D affine transform.
///
/// Conform your own matrix type to this protocol to use it with ``CrossSection/transform(_:)``.
public protocol Matrix2x3: Matrix {}

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
