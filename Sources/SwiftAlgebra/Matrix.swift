//
//  Matrix.swift
//  SwiftAlgebra
//
//  Created by Jan Tomec on 09/11/2022.
//

import Foundation

//private class Datum {
//    var value: Double
//    init(value: Double) {
//        self.value = value
//    }
//}

/// Special index which can be used to access all elements of a Matrix in a particular direction.
public enum SpecialMatrixIndex {
    case all
}

private func isMatrix(_ A: [[Double]]) -> Bool {
    for i in 1..<A.count {
        if A[i].count != A[0].count { return false }
    }
    return true
}

private func isCoherent(_ A: [[Matrix]]) -> Bool {
    let cumcols: ([Matrix]) -> Int = { matrixRow in
        return matrixRow.reduce(0) { partialResult, block in
            partialResult + block.shape.cols
        }
    }
    for i in 1..<A.count {
        if cumcols(A[i]) != cumcols(A[0]) { return false }
    }
    return true
}

/// Basic class for representing matrices.
///
/// This class provides an intuitive abstract representation of a mathematical object called matrix. It references the data through pointers permitting advanced manipulation through slicing.
public struct Matrix {
    private var data: [Double]
    
    /// Shape of the matrix.
    ///
    /// - Important: The shape can be changed directly by manipulating this property. Changing the shape essentially restructures the matrix. The order of the data follows `C`-ordering style.
    ///
    /// - Precondition: When changing the shape, the dimensions must match the number of element in the matrix.
    public var shape: (rows: Int, cols: Int) {
        willSet(newShape) {
            precondition(newShape.rows * newShape.cols == self.data.count, "The shape is incompatible with this matrix.")
        }
    }
    
    private init(data: [Double], shape: (rows: Int, cols: Int)) {
        self.data = data
        self.shape = shape
    }
    
    /// Create an instance of this class from an array of arrays of doubles.
    ///
    /// Example:
    /// ```swift
    /// let A = Matrix(from: [[5, 2], [-1, 0]])
    /// ```
    ///
    /// - Precondition: The input must represent a matrix (all rows should have equal length).
    /// - Parameter values: Double array of data.
    public init(from values: [[Double]]) {
        precondition(isMatrix(values), "Input argument is not a matrix.")
        let shape = (values.count, values[0].count)
        let data = Array(values.joined())
        self.init(data: data, shape: shape)
    }
    
    /// Create an instance of this class by repeating the same value.
    ///
    /// Example:
    /// ```swift
    /// let A = Matrix(repeating: 0, shape: (3,3))
    /// ```
    /// - Parameters:
    ///   - value: Value to be repeated.
    ///   - shape: Desired shape of the matrix.
    public init(repeating value: Double, shape: (rows: Int, cols: Int)) {
        self.init(from: Array(repeating: Array(repeating: value, count: shape.cols), count: shape.rows))
    }
    
    /// Create an instance of this class from a diagonal vector, represented as an array of doubles.
    ///
    /// Example:
    /// ```swift
    /// let A = Matrix(diagonal: [5, 2, -1, 0])
    /// ```
    /// - Parameter diagonal: Array of diagonal elements.
    public init(diagonal: [Double]) {
        self.init(repeating: 0, shape: (diagonal.count, diagonal.count))
        for i in 0..<diagonal.count {
            self[i,i] = diagonal[i]
        }
    }
    
    /// Create an instance of this class representing an identity matrix of order `n`.
    ///
    /// Example:
    /// ```swift
    /// let A = Matrix(identity: 3)
    /// ```
    ///
    /// - Parameter n: Dimension of the matrix.
    public init(identity n: Int) {
        let diagonal = Array(repeating: 1.0, count: n)
        self.init(repeating: 0, shape: (diagonal.count, diagonal.count))
        for i in 0..<diagonal.count {
            self[i,i] = diagonal[i]
        }
    }
    
    /// Create a copy of the input matrix.
    ///
    /// Example:
    /// ```swift
    /// let A = Matrix(from: [[5, 2], [-1, 0]])
    /// let B = Matrix(copy: A)
    /// ```
    ///
    /// - Parameter matrix: A Matrix to be copied.
    public init(copy matrix: Matrix) {
        var c: [[Double]] = Array(repeating: Array(repeating: 0, count: matrix.shape.cols), count: matrix.shape.rows)
        for row in 0..<matrix.shape.rows {
            for col in 0..<matrix.shape.cols {
                c[row][col] = matrix[row,col]
            }
        }
        self.init(from: c)
    }
    
    /// Create a matrix from coherent blocks. Coherency can be visualized as drawing only straight division lines across the entire matrix.
    ///
    /// Example:
    /// ```swift
    /// let I = Matrix(identity: 3)
    /// let O = Matrix(repeating: 0, shape: (3,1))
    /// let A = Matrix(blocks: [[I, O],
    ///                         [O.T, Matrix(from: [[2]])]])
    /// ```
    /// - Parameter blocks: Blocks of coherent submatrices
    /// - Parameter copy: Whether the data should be copied or should the references remain. They are copied by default.
    public init(blocks: [[Matrix]], copy: Bool = true) {
        precondition(isCoherent(blocks), "Blocks are not coherent.")
        let cumrows = blocks.reduce(0) { partialResult, subrow in
            partialResult + subrow[0].shape.rows
        }
        let cumcols = blocks[0].reduce(0) { partialResult, block in
            partialResult + block.shape.cols
        }
        self.init(repeating: 0, shape: (cumrows, cumcols))
        var cumrow = 0
        for row in 0..<blocks.count {
            var cumcol = 0
            for col in 0..<blocks[0].count {
                if copy {
                    self[cumrow..<cumrow+blocks[row][col].shape.rows, cumcol..<cumcol+blocks[row][col].shape.cols] = Matrix(copy: blocks[row][col])
                } else {
                    self[cumrow..<cumrow+blocks[row][col].shape.rows, cumcol..<cumcol+blocks[row][col].shape.cols] = blocks[row][col]
                }
                cumcol += blocks[row][col].shape.cols
            }
            cumrow += blocks[row][0].shape.rows
        }
    }
    
    public subscript(row: Int, col: Int) -> Double {
        get {
            return self.data[row*self.shape.cols + col]
        }
        set(newValue) {
            self.data[row*self.shape.cols + col] = newValue
        }
    }
    
    public subscript<C: Sequence<Int>>(row: Int, cols: C) -> Matrix {
        get {
            let subptr = cols.map { self.data[row*self.shape.cols + $0] }
            return Matrix(data: subptr, shape: (1, subptr.count))
        }
        set(newValue) {
            let i = 0
            var j = 0
            for col in cols {
                self.data[row*self.shape.cols + col] = newValue.data[i*newValue.shape.cols + j]
                j += 1
            }
            precondition(j == newValue.shape.cols, "Matrices' shapes do not match: trying to overwrite selected shape \((1,cols)) with \(newValue.shape).")
        }
    }
    
    public subscript<R: Sequence<Int>>(rows: R, col: Int) -> Matrix {
        get {
            let subptr = rows.map { self.data[$0*self.shape.cols + col] }
            return Matrix(data: subptr, shape: (subptr.count, 1))
        }
        set(newValue) {
            var i = 0
            let j = 0
            for row in rows {
                self.data[row*self.shape.cols + col] = newValue.data[i*newValue.shape.cols + j]
                i += 1
            }
            precondition(i == newValue.shape.rows, "Matrices' shapes do not match: trying to overwrite selected shape \((rows,1)) with \(newValue.shape).")
        }
    }
    
    public subscript<R: Sequence<Int>, C: Sequence<Int>>(rows: R, cols: C) -> Matrix {
        get {
            var subptr = [Double]()
            var subshape = (rows: 0, cols: 0)
            for row in rows {
                subshape.rows += 1
                subshape.cols = 0
                for col in cols {
                    subshape.cols += 1
                    subptr.append(self.data[row*self.shape.cols + col])
                }
            }
            let submatrix = Matrix(data: subptr, shape: subshape)
            return submatrix
        }
        set(newValue) {
            var i = 0
            var j = 0
            for row in rows {
                j = 0
                for col in cols {
                    self.data[row*self.shape.cols + col] = newValue.data[i*newValue.shape.cols + j]
                    j += 1
                }
                i += 1
            }
            precondition((i,j) == newValue.shape, "Matrices' shapes do not match: trying to overwrite selected shape \((rows,cols)) with \(newValue.shape).")
        }
    }
    
    public subscript(row: Int, cols: SpecialMatrixIndex) -> Matrix {
        get {
            switch cols {
            case .all:
                return self[row,0..<self.shape.cols]
            }
        }
        set(newValue) {
            switch cols {
            case .all:
                self[row,0..<self.shape.cols] = newValue
            }
        }
    }
    
    public subscript<R: Sequence<Int>>(rows: R, cols: SpecialMatrixIndex) -> Matrix {
        get {
            switch cols {
            case .all:
                return self[rows,0..<self.shape.cols]
            }
        }
        set(newValue) {
            switch cols {
            case .all:
                self[rows,0..<self.shape.cols] = newValue
            }
        }
    }
    
    public subscript(rows: SpecialMatrixIndex, col: Int) -> Matrix {
        get {
            switch rows {
            case .all:
                return self[0..<self.shape.rows,col]
            }
        }
        set(newValue) {
            switch rows {
            case .all:
                self[0..<self.shape.rows,col] = newValue
            }
        }
    }
    
    public subscript<C: Sequence<Int>>(rows: SpecialMatrixIndex, cols: C) -> Matrix {
        get {
            switch rows {
            case .all:
                return self[0..<self.shape.rows,cols]
            }
        }
        set(newValue) {
            switch rows {
            case .all:
                self[0..<self.shape.rows,cols] = newValue
            }
        }
    }
    
    public subscript(rows: SpecialMatrixIndex, cols: SpecialMatrixIndex) -> Matrix {
        get {
            switch rows {
            case .all:
                switch cols {
                case .all:
                    return self
                }
            }
        }
        set(newValue) {
            switch rows {
            case .all:
                switch cols {
                case .all:
                    self[0..<self.shape.rows,0..<self.shape.cols] = newValue
                }
            }
        }
    }
}

extension Matrix: CustomStringConvertible {
    public var description: String {
        var d: String = "["
        for i in 0..<self.shape.rows {
            d += "["
            for j in 0..<self.shape.cols {
                d += String(format: "%10.5f", self.data[i*self.shape.cols + j])
                if j < self.shape.cols - 1 {
                    d += ", "
                } else {
                    d += "]"
                }
            }
            if i < self.shape.rows - 1 {
                d += ",\n "
            } else {
                d += "]"
            }
        }
        return d
    }
}

precedencegroup ExponentiativePrecedence {
    associativity: right
    higherThan: MultiplicationPrecedence
}
infix operator **: ExponentiativePrecedence
infix operator ∙: MultiplicationPrecedence
infix operator ≈: ComparisonPrecedence
extension Matrix {
    public static func +(a: Matrix, b: Matrix) -> Matrix {
        precondition(a.shape == b.shape, "The shape of both matrices should be the same.")
        var c = Matrix(repeating: 0, shape: a.shape)
        for row in 0..<c.shape.rows {
            for col in 0..<c.shape.cols {
                c[row,col] = a[row,col] + b[row,col]
            }
        }
        return c
    }
    
    public static func +=(a: inout Matrix, b: Matrix) {
        precondition(a.shape == b.shape, "The shape of both matrices should be the same.")
        for row in 0..<a.shape.rows {
            for col in 0..<a.shape.cols {
                a[row,col] += b[row,col]
            }
        }
    }
    
    public static func -(a: Matrix, b: Matrix) -> Matrix {
        precondition(a.shape == b.shape, "The shape of both matrices should be the same.")
        var c = Matrix(repeating: 0, shape: a.shape)
        for row in 0..<c.shape.rows {
            for col in 0..<c.shape.cols {
                c[row,col] = a[row,col] - b[row,col]
            }
        }
        return c
    }
    
    public static func -=(a: inout Matrix, b: Matrix) {
        precondition(a.shape == b.shape, "The shape of both matrices should be the same.")
        for row in 0..<a.shape.rows {
            for col in 0..<a.shape.cols {
                a[row,col] -= b[row,col]
            }
        }
    }
    
    public static func *(a: Double, b: Matrix) -> Matrix {
        var c = Matrix(copy: b)
        for row in 0..<c.shape.rows {
            for col in 0..<c.shape.cols {
                c[row,col] *= a
            }
        }
        return c
    }
    
    public static func *(b: Matrix, a: Double) -> Matrix {
        var c = Matrix(copy: b)
        for row in 0..<c.shape.rows {
            for col in 0..<c.shape.cols {
                c[row,col] *= a
            }
        }
        return c
    }
    
    public static func *=(a: inout Matrix, b: Double) {
        for row in 0..<a.shape.rows {
            for col in 0..<a.shape.cols {
                a[row,col] *= b
            }
        }
    }
    
    public static func /(b: Matrix, a: Double) -> Matrix {
        var c = Matrix(copy: b)
        for row in 0..<c.shape.rows {
            for col in 0..<c.shape.cols {
                c[row,col] /= a
            }
        }
        return c
    }
    
    public static func ∙(a: Matrix, b: Matrix) -> Matrix {
        precondition(a.shape.cols == b.shape.rows, "The number of columns in the first matrix should equal the number of rows in the second.")
        var c = Matrix(repeating: 0, shape: (a.shape.rows, b.shape.cols))
        for i in 0..<a.shape.rows {
            for j in 0..<b.shape.cols {
                for k in 0..<a.shape.cols {
                    c[i,j] += a[i,k] * b[k,j]
                }
            }
        }
        return c
    }
    
    public static func ≈(a: Matrix, b: Matrix) -> Bool {
        if a.shape != b.shape { return false }
        let tolerance = 1e-12
        for row in 0..<a.shape.rows {
            for col in 0..<a.shape.cols {
                if abs(a[row,col] - b[row,col]) > tolerance { return false }
            }
        }
        return true
    }
    
    public static func **(a: Matrix, p: Int) -> Matrix {
        precondition(a.shape.rows == a.shape.cols, "Only square matrices can be raised to power.")
        let c: Matrix
        if p < 0 {
            c = try! invert(a)
        } else {
            c = Matrix(copy: a)
        }
        var e = Matrix(identity: a.shape.cols)
        for _ in 0..<abs(p) {
            e = e∙c
        }
        return e
    }
    
    public static prefix func - (a: Matrix) -> Matrix {
        return -1 * a
    }
}

extension Matrix {
    /// Transpose of a matrix
    public var T: Matrix {
        get {
            var c = Matrix(repeating: 0, shape: (rows: self.shape.cols, cols: self.shape.rows))
            for row in 0..<self.shape.rows {
                for col in 0..<self.shape.cols {
                    c[col,row] = self[row,col]
                }
            }
            return c
        }
        set(newValue) {
            precondition(self.shape.cols == newValue.shape.rows && self.shape.rows == newValue.shape.cols)
            for row in 0..<newValue.shape.rows {
                for col in 0..<newValue.shape.cols {
                    self[col,row] = newValue[row,col]
                }
            }
        }
    }
}

extension Matrix {
    /// Extract the standard Swift double array representation of this matrix.
    public func toArray() -> [[Double]] {
        var a: [[Double]] = Array(repeating: Array(repeating: 0, count: self.shape.cols), count: self.shape.rows)
        for row in 0..<self.shape.rows {
            for col in 0..<self.shape.cols {
                a[row][col] = self[row,col]
            }
        }
        return a
    }
    
    /// Extract the flattened standard Swift array representation of this matrix.
    public func toFlatArray() -> [Double] {
        var a: [Double] = Array(repeating: 0, count: self.shape.rows*self.shape.cols)
        for row in 0..<self.shape.rows {
            for col in 0..<self.shape.cols {
                a[row+col] = self[row,col]
            }
        }
        return a
    }
}

extension Matrix {
    /// Copy matrix, breaking the link to original matrix.
    ///
    /// Alias to `Matrix(copy: self)`
    /// Explicit version of the same as doing
    /// `A = Matrix(identity: 3)`
    /// `B = Matrix(copy: A) // B = A.copy()` 
    /// - Returns: Copy of a matrix
    public func copy() -> Matrix { return Matrix(copy: self) }
    
    /// Create a new mirror to matrix, keeping the link to original matrix
    ///
    /// Alias to `self`.
    /// Explicit version of the same as doing
    /// `A = Matrix(identity: 3)`
    /// `B = A // B = A.mirror()`
    /// - Returns: Mirror of a matrix
    public func mirror() -> Matrix { return self }
}
