//
//  LinearAlgebra.swift
//  SwiftLinearAlgebra
//
//  Created by Jan Tomec on 09/11/2022.
//

import Foundation

public enum LinearAlgebraError: Error {
    case degenerateMatrix
    case singularMatrix
}

private func LUDecompositionDoolittle(_ A: Matrix, tolerance: Double = 1e-10) throws -> (LU: Matrix, P: [Int]) {
    precondition(A.shape.rows == A.shape.cols, "LU decomposition requires a square matrix.")
    let LU = Matrix(copy: A)
    let n = LU.shape.rows
    var P: [Int] = Array(0...n)
    var maxA: Double
    var imax: Int
    for i in 0..<n {
        maxA = 0.0
        imax = i
        for k in i..<n {
            let absA = abs(A[k,i])
            if absA > maxA {
                maxA = absA
                imax = k
            }
        }
        if maxA < tolerance {
            throw LinearAlgebraError.degenerateMatrix
        }
        if imax != i {
            // pivoting P
            let j = P[i]
            P[i] = P[imax]
            P[imax] = j
            // pivoting rows of LU
            let ptr = Matrix(copy: LU[i, .all])
            LU[i, .all] = LU[imax, .all]
            LU[imax, .all] = ptr
            // counting pivots starting from N (for determinant)
            P[n] += 1
        }
        for j in i+1..<n {
            LU[j,i] /= LU[i,i];
            for k in i+1..<n {
                LU[j,k] -= LU[j,i] * LU[i,k];
            }
        }
    }
    for i in 0..<n {
        if LU[i,i] == 0 { throw LinearAlgebraError.singularMatrix }
    }
    return (LU, P)
}

private func LUSolve(LU: Matrix, P: [Int], b: Matrix) -> Matrix {
    let x = Matrix(copy: b)
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
    let IA = Matrix(copy: LU)
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
