//
//  LinearAlgebra.swift
//  SwiftAlgebra
//
//  Created by Jan Tomec on 09/11/2022.
//

import Foundation

public enum LinearAlgebraError: Error {
    case degenerateMatrix
    case singularMatrix
}

/// Compute trace of matrix.
///
/// - Precondition: "Trace is defined only on square matrices."
///
/// - Parameter A: Square matrix
/// - Returns: Trace of matrix
public func trace(_ A: Matrix) -> Double {
    precondition(A.shape.rows == A.shape.cols, "Trace is defined only on square matrices.")
    var tr: Double = 0
    for row in 0..<A.shape.rows {
        tr += A[row,row]
    }
    return tr
}

/// Compute determinant of matrix
///
/// - Precondition: "Determinant is defined only on square matrices."
///
/// - Parameter A: Square matrix
/// - Returns: Determinant of matrix
public func det(_ A: Matrix) -> Double {
    precondition(A.shape.rows == A.shape.cols, "Determinant is defined only on square matrices.")
    if A.shape == (1,1) {
        return A[0,0]
    } else {
        var d: Double = 0
        for col in 0..<A.shape.cols {
            var indices = Array(0..<A.shape.cols)
            indices.remove(at: col)
            d += pow(-1.0, Double(col)) * A[0,col] * det(A[1..<A.shape.rows,indices])
        }
        return d
    }
}

private func LUDecompositionDoolittle(_ A: Matrix, tolerance: Double = 1e-10) throws -> (LU: Matrix, P: [Int]) {
    precondition(A.shape.rows == A.shape.cols, "LU decomposition requires a square matrix.")
    var LU = Matrix(copy: A)
    let n = LU.shape.rows
    var P: [Int] = Array(0..<n)
    // Set up scale factors
    var s = Array(repeating: 0.0, count: n)
    for i in 0..<n {
        s[i] = LU[i,.all].toArray()[0].map({ abs($0) }).max()!
    }
    for k in 0..<n-1 {
        // Row interchange, if needed
        let scaledColumn = LU[k..<n, k].toFlatArray().enumerated().map { abs($0.element) / s[$0.offset+k] }
        let p = scaledColumn.enumerated().max { $0.element < $1.element }!.offset + k
        print(LU, p, k)
        if abs(LU[p,k]) < tolerance {
            throw LinearAlgebraError.singularMatrix
        }
        if p != k {
            s.swapAt(k, p)
            let LUk = Matrix(copy: LU[k,.all])
            LU[k,.all] = LU[p,.all]
            LU[p,.all] = LUk
            P.swapAt(k, p)
        }
        // Elimination
        for i in k+1..<n {
            if LU[i,k] != 0.0 {
                let lam = LU[i,k] / LU[k,k]
                LU[i,k+1..<n] = LU[i,k+1..<n] - lam * LU[k,k+1..<n]
                LU[i,k] = lam
            }
        }
    }
    return (LU, P)
}

private func LUSolve(LU: Matrix, P: [Int], b: Matrix) -> Matrix {
    var x = Matrix(copy: b)
    let n = LU.shape.rows
    precondition(n == LU.shape.cols, "LU decomposition requires a square matrix.")
    for i in 0..<n {
        x[i,0] = b[P[i],0]
        for k in 0..<i {
            x[i,0] -= LU[i,k] * x[k,0]
        }
    }
    for i in 1...n {
        let j = n-i
        for k in j+1..<n {
            x[j,0] -= LU[j,k] * x[k,0]
        }
        x[j,0] /= LU[j,j];
    }
    return x
}

/// Solve a linear system of equations.
///
/// Solve a system of equations defined by the matrix of coefficients `A` and the right-hand-side vector `b`, i. e. A.x = b. Vector x represents the unknowns.
///
/// - Precondition: Only square matrices are allowed.
///
/// - Parameters:
///   - A: Matrix of coefficients
///   - b: Right-hand-side vector
///
/// - Returns: Vector of unknowns.
public func solve(A: Matrix, b: Matrix) throws -> Matrix {
    let decomposition = try LUDecompositionDoolittle(A)
    return LUSolve(LU: decomposition.LU, P: decomposition.P, b: b)
}

private func LUInvert(LU: Matrix, P: [Int]) -> Matrix {
    var IA = Matrix(copy: LU)
    let n = LU.shape.rows
    precondition(n == LU.shape.cols, "LU decomposition requires a square matrix.")
    for j in 0..<n {
        for i in 0..<n {
            IA[i,j] = P[i] == j ? 1 : 0
            for k in 0..<i {
                IA[i,j] -= LU[i,k] * IA[k,j]
            }
        }
        for l in 1...n {
            let i = n - l
            for k in i+1..<n {
                IA[i,j] -= LU[i,k] * IA[k,j]
            }
            IA[i,j] /= LU[i,i]
        }
    }
    return IA
}

/// Compute the inverse of a matrix.
///
/// - Precondition: Only square matrices can be inverted.
///
/// - Parameter A: Matrix to be inverted.
///
/// - Returns: A new matrix, inverse of the input.
public func invert(_ A: Matrix) throws -> Matrix {
    let decomposition = try LUDecompositionDoolittle(A)
    return LUInvert(LU: decomposition.LU, P: decomposition.P)
}
