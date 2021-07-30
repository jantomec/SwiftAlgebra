//
//  File.swift
//  
//
//  Created by Jan Tomec on 29/07/2021.
//

import Foundation

enum LieGroup {
    case R3
    case SO3
    case SE3
}

func skewSymmetric(vector: Matrix) -> Matrix {
    switch vector.shape.nRows {
    case 3:
        let check = vector.shape.nCols == 1
        precondition(check, "Skewsymmetric in SO(3) requires a column vector with 3 components.")
        var s = Matrix(value: 0, shape: Shape(nRows: vector.shape.nRows, nCols: vector.shape.nRows))
        s[0,1] = -vector[2,0]
        s[1,0] = vector[2,0]
        s[0,2] = vector[1,0]
        s[2,0] = -vector[1,0]
        s[1,2] = -vector[0,0]
        s[2,1] = vector[0,0]
        return s
    default:
        let s = Matrix(value: 0, shape: Shape(nRows: vector.shape.nRows, nCols: vector.shape.nRows))
        return s
    }
}

func rotationVector(from skewSymmetric: Matrix) -> Matrix {
    switch skewSymmetric.shape.nRows {
    case 3:
        var rv = Matrix(value: 0, shape: (3,1))
        rv[0,0] = skewSymmetric[2,1]
        rv[1,0] = skewSymmetric[0,2]
        rv[2,0] = skewSymmetric[1,0]
        return rv
    default:
        return skewSymmetric
    }
}

func matrixExp(matrix: Matrix) -> Matrix {
    switch matrix.shape {
    case Shape(nRows: 3, nCols: 3):
        let theta = (matrix[2,1]*matrix[2,1] + matrix[0,2]*matrix[0,2] + matrix[1,0]*matrix[1,0]).squareRoot()
        return identity(3) + sin(theta) / theta * matrix + (1 - cos(theta)) / (theta**2) * matrix**2
    default:
        return matrix
    }
}

func matrixLog(matrix: Matrix) -> Matrix {
    switch matrix.shape {
    case Shape(nRows: 3, nCols: 3):
        // Matrix is rotation matrix in SO(3)
        let R = matrix
        // Extraction of quaternion from rotation matrix
        let tr = R[0,0] + R[1,1] + R[2,2]
          
        let M = max(tr, R[0,0], R[1,1], R[2,2])
        var q = Matrix(value: 0, shape: (4, 1))
        if M == tr {
            q[3,0] = 0.5 * sqrt(1 + tr)
            q[0,0] = 0.25 * (R[2,1] - R[1,2]) / q[3,0]
            q[1,0] = 0.25 * (R[0,2] - R[2,0]) / q[3,0]
            q[2,0] = 0.25 * (R[1,0] - R[0,1]) / q[3,0]
        } else if M == R[0,0] {
            q[0,0] = sqrt(0.5 * R[0,0] + 0.25 * (1 - tr))
            q[3,0] = 0.25 * (R[2,1] - R[1,2]) / q[0,0]
            q[1,0] = 0.25 * (R[1,0] + R[0,1]) / q[0,0]
            q[2,0] = 0.25 * (R[2,0] + R[0,2]) / q[0,0]
        } else if M == R[1,1] {
            q[1,0] = sqrt(0.5 * R[1,1] + 0.25 * (1 - tr))
            q[3,0] = 0.25 * (R[0,2] - R[2,0]) / q[1,0]
            q[2,0] = 0.25 * (R[2,1] + R[1,2]) / q[1,0]
            q[0,0] = 0.25 * (R[0,1] + R[1,0]) / q[1,0]
        } else if M == R[2,2] {
            q[2,0] = sqrt(0.5 * R[2,2] + 0.25 * (1 - tr))
            q[3,0] = 0.25 * (R[1,0] - R[0,1]) / q[2,0]
            q[0,0] = 0.25 * (R[0,2] + R[2,0]) / q[2,0]
            q[1,0] = 0.25 * (R[1,2] + R[2,1]) / q[2,0]
        }
        q /= norm(vector: q)
        let qv = q[0..<3,0]
        let n = norm(vector: qv)
        if n != 0 {
            let angle = 2 * atan2(n, q[3, 0])
            return skewSymmetric(vector: angle / n * qv)
        } else {
            return skewSymmetric(vector: Matrix(value: 0, shape: (3,1)))
        }
    default:
        return matrix
    }
}
