//
//  Matrix.swift
//  SwiftLinearAlgebra
//
//  Created by Jan Tomec on 09/11/2022.
//

import Foundation

private class Datum {
    var value: Double
    init(value: Double) {
        self.value = value
    }
}

enum SpecialMatrixIndex {
    case all
}

private func isMatrix(_ A: [[Double]]) -> Bool {
    let A0: Int = A[0].count
    for i in 0..<A.count {
        if A[i].count != A0 { return false }
    }
    return true
}

/// Basic class for representing matrices.
///
/// This class provides an intuitive abstract representation of a mathematical object called matrix. It references the data through pointers permitting advanced manipulation through slicing.
///
/// **Getting started with Matrices:**
///
/// Create a new matrix from existing double array:
/// ```swift
/// let a: [[Double]] = [[ 5, 2],
///                      [-1, 0]]
/// let A = Matrix(from: a)
/// ```
/// There are also many other convenient initialization methods. Next let's explore slicing:
/// ```swift
/// let b = A[.all, 0]  // [[5], [-1]]
/// let c = A[1, 0...1] + b.T  // [[4, -1]]
/// ```
/// Slicing also allows assigning. See this:
/// ```swift
/// A[.all, 0].T = c  // [[4, 2], [-1, 0]]
/// ```
class Matrix {
    private var data: [Datum]
    
    /// Shape of the matrix.
    ///
    /// - Important: The shape can be changed directly by manipulating this property. Changing the shape essentially restructures the matrix. The order of the data follows `C`-ordering style.
    ///
    /// - Precondition: When changing the shape, the dimensions must match the number of element in the matrix.
    var shape: (rows: Int, cols: Int) {
        willSet(newShape) {
            precondition(newShape.rows * newShape.cols == self.data.count, "The shape is incompatible with this matrix.")
        }
    }
    
    private init(dataPtr: [Datum], shape: (rows: Int, cols: Int)) {
        self.data = dataPtr
        self.shape = shape
    }
    
    /// Create an instance of this class from an array of arrays of doubles.
    ///
    /// - Precondition: The input must represent a matrix (all rows should have equal length).
    convenience init(from values: [[Double]]) {
        precondition(isMatrix(values), "Input argument is not a matrix.")
        let shape = (values.count, values[0].count)
        let data = Array(values.joined())
        var dataPtr = [Datum]()
        for i in 0..<data.count {
            dataPtr.append(Datum(value: data[i]))
        }
        self.init(dataPtr: dataPtr, shape: shape)
    }
    
    /// Create an instance of this class by repeating the same value.
    convenience init(repeating value: Double, shape: (rows: Int, cols: Int)) {
        self.init(from: Array(repeating: Array(repeating: value, count: shape.cols), count: shape.rows))
    }
    
    /// Create an instance of this class from a diagonal vector, represented as an array of doubles.
    convenience init(diagonal: [Double]) {
        self.init(repeating: 0, shape: (diagonal.count, diagonal.count))
        for i in 0..<diagonal.count {
            self[i,i] = diagonal[i]
        }
    }
    
    /// Create an instance of this class representing an identity matrix of order `n`.
    convenience init(identity n: Int) {
        let diagonal = Array(repeating: 1.0, count: n)
        self.init(repeating: 0, shape: (diagonal.count, diagonal.count))
        for i in 0..<diagonal.count {
            self[i,i] = diagonal[i]
        }
    }
    
    /// Create a copy of the input matrix.
    convenience init(copy matrix: Matrix) {
        var c: [[Double]] = Array(repeating: Array(repeating: 0, count: matrix.shape.cols), count: matrix.shape.rows)
        for row in 0..<matrix.shape.rows {
            for col in 0..<matrix.shape.cols {
                c[row][col] = matrix[row,col]
            }
        }
        self.init(from: c)
    }
    
    subscript(row: Int, col: Int) -> Double {
        get {
            return self.data[row*self.shape.cols + col].value
        }
        set(newValue) {
            self.data[row*self.shape.cols + col].value = newValue
        }
    }
    
    subscript<C: Sequence<Int>>(row: Int, cols: C) -> Matrix {
        get {
            var subptr = [Datum]()
            for col in cols {
                subptr.append(self.data[row*self.shape.cols + col])
            }
            let subshape = (1, subptr.count)
            let submatrix = Matrix(dataPtr: subptr, shape: subshape)
            return submatrix
        }
        set(newValue) {
            let i = 0
            var j = 0
            for col in cols {
                self.data[row*self.shape.cols + col] = newValue.data[i*newValue.shape.cols + j]
                j += 1
            }
        }
    }
    
    subscript<R: Sequence<Int>>(rows: R, col: Int) -> Matrix {
        get {
            var subptr = [Datum]()
            for row in rows {
                subptr.append(self.data[row*self.shape.cols + col])
            }
            let subshape = (subptr.count, 1)
            let submatrix = Matrix(dataPtr: subptr, shape: subshape)
            return submatrix
        }
        set(newValue) {
            var i = 0
            let j = 0
            for row in rows {
                self.data[row*self.shape.cols + col] = newValue.data[i*newValue.shape.cols + j]
                i += 1
            }
        }
    }
    
    subscript<R: Sequence<Int>, C: Sequence<Int>>(rows: R, cols: C) -> Matrix {
        get {
            var subptr = [Datum]()
            var subshape = (rows: 0, cols: 0)
            for row in rows {
                subshape.rows += 1
                subshape.cols = 0
                for col in cols {
                    subshape.cols += 1
                    subptr.append(self.data[row*self.shape.cols + col])
                }
            }
            let submatrix = Matrix(dataPtr: subptr, shape: subshape)
            return submatrix
        }
        set(newValue) {
            var i = 0
            for row in rows {
                var j = 0
                for col in cols {
                    self.data[row*self.shape.cols + col] = newValue.data[i*newValue.shape.cols + j]
                    j += 1
                }
                i += 1
            }
        }
    }
    
    subscript(row: Int, cols: SpecialMatrixIndex) -> Matrix {
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
    subscript<R: Sequence<Int>>(rows: R, cols: SpecialMatrixIndex) -> Matrix {
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
    subscript(rows: SpecialMatrixIndex, col: Int) -> Matrix {
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
    subscript<C: Sequence<Int>>(rows: SpecialMatrixIndex, cols: C) -> Matrix {
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
    subscript(rows: SpecialMatrixIndex, cols: SpecialMatrixIndex) -> Matrix {
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
    var description: String {
        var d: String = "["
        for i in 0..<self.shape.rows {
            d += "["
            for j in 0..<self.shape.cols {
                d += String(format: "%10.5f", self.data[i*self.shape.cols + j].value)
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

infix operator ∙: MultiplicationPrecedence
extension Matrix {
    static func +(a: Matrix, b: Matrix) -> Matrix {
        precondition(a.shape == b.shape, "The shape of both matrices should be the same.")
        let c = Matrix(repeating: 0, shape: a.shape)
        for row in 0..<c.shape.rows {
            for col in 0..<c.shape.cols {
                c[row,col] = a[row,col] + b[row,col]
            }
        }
        return c
    }
    static func +=(a: inout Matrix, b: Matrix) {
        precondition(a.shape == b.shape, "The shape of both matrices should be the same.")
        for row in 0..<a.shape.rows {
            for col in 0..<a.shape.cols {
                a[row,col] += b[row,col]
            }
        }
    }
    static func -(a: Matrix, b: Matrix) -> Matrix {
        precondition(a.shape == b.shape, "The shape of both matrices should be the same.")
        let c = Matrix(repeating: 0, shape: a.shape)
        for row in 0..<c.shape.rows {
            for col in 0..<c.shape.cols {
                c[row,col] = a[row,col] - b[row,col]
            }
        }
        return c
    }
    static func -=(a: inout Matrix, b: Matrix) {
        precondition(a.shape == b.shape, "The shape of both matrices should be the same.")
        for row in 0..<a.shape.rows {
            for col in 0..<a.shape.cols {
                a[row,col] -= b[row,col]
            }
        }
    }
    static func *(a: Double, b: Matrix) -> Matrix {
        let c = Matrix(copy: b)
        for row in 0..<c.shape.rows {
            for col in 0..<c.shape.cols {
                c[row,col] *= a
            }
        }
        return c
    }
    static func *(b: Matrix, a: Double) -> Matrix {
        let c = Matrix(copy: b)
        for row in 0..<c.shape.rows {
            for col in 0..<c.shape.cols {
                c[row,col] *= a
            }
        }
        return c
    }
    static func *=(a: inout Matrix, b: Double) {
        for row in 0..<a.shape.rows {
            for col in 0..<a.shape.cols {
                a[row,col] *= b
            }
        }
    }
    static func ∙(a: Matrix, b: Matrix) -> Matrix {
        precondition(a.shape.cols == b.shape.rows, "The number of columns in the first matrix should equal the number of rows in the second.")
        let c = Matrix(repeating: 0, shape: (a.shape.rows, b.shape.cols))
        for i in 0..<a.shape.rows {
            for j in 0..<b.shape.cols {
                for k in 0..<a.shape.cols {
                    c[i,j] += a[i,k] * b[k,j]
                }
            }
        }
        return c
    }
    static func ==(a: Matrix, b: Matrix) -> Bool {
        precondition(a.shape == b.shape, "The matrices must have the same shape.")
        let tolerance = 1e-12
        for row in 0..<a.shape.rows {
            for col in 0..<a.shape.cols {
                if abs(a[row,col] - b[row,col]) > tolerance { return false }
            }
        }
        return true
    }
}

extension Matrix {
    var T: Matrix {
        get {
            let c = Matrix(repeating: 0, shape: (rows: self.shape.cols, cols: self.shape.rows))
            for row in 0..<self.shape.rows {
                for col in 0..<self.shape.cols {
                    c[col,row] = self[row,col]
                }
            }
            return c
        }
    }
}

extension Matrix {
    /// Extract the standard Swift double array representation of this matrix.
    func toArray() -> [[Double]] {
        var a: [[Double]] = Array(repeating: Array(repeating: 0, count: self.shape.cols), count: self.shape.rows)
        for row in 0..<self.shape.rows {
            for col in 0..<self.shape.cols {
                a[row][col] = self[row,col]
            }
        }
        return a
    }
}
