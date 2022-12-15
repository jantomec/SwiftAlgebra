//
//  LieGroups.swift
//  SwiftAlgebra
//
//  Created by Jan Tomec on 10/11/2022.
//

import Foundation

private enum VectorSpace {
    case so3, SO3, se3, SE3, adse3, coadse3, AdSE3, linear
}

precedencegroup ExponentiativePrecedence {
    associativity: right
    higherThan: MultiplicationPrecedence
}
infix operator **: ExponentiativePrecedence
extension Double {
    fileprivate static func **(a: Double, b: Int) -> Double {
        var r: Double = 1
        for _ in 0..<b {
            r *= a
        }
        return r
    }
}

/// Check whether a matrix is skew-symmetric
/// - Parameter x: Any matrix
/// - Returns: True or false
private func isSkewsymmetric(_ x: Matrix) -> Bool {
    return x ≈ -x.T
}

/// Check whether a matrix is orthogonal
/// - Parameter x: Any matrix
/// - Returns: True or false
private func isOrthogonal(_ x: Matrix) -> Bool {
    if x.shape.rows == x.shape.cols {
        return x∙x.T ≈ Matrix(identity: x.shape.cols)
    } else {
        return false
    }
}

/// Check if matrix is in so(3) Lie algebra
/// - Parameter x: Any matrix
/// - Returns: True or false
private func isInso3(_ x: Matrix) -> Bool {
    return isSkewsymmetric(x) && x.shape == (3,3)
}

/// Check if matrix is in se(3) Lie algebra
/// - Parameter x: Any matrix
/// - Returns: True or false
private func isInse3(_ x: Matrix) -> Bool {
    if x.shape == (4,4) {
        return isSkewsymmetric(x[0...2,0...2]) && x[3, .all] ≈ Matrix(repeating: 0, shape: (rows: 1, cols: 4))
    } else {
        return false
    }
}

/// Check if matrix is in adjoint of se(3) Lie algebra
/// - Parameter x: Any matrix
/// - Returns: True or false
private func isInadse3(_ x: Matrix) -> Bool {
    if x.shape == (6,6) {
        return isSkewsymmetric(x[0...2,0...2]) && isSkewsymmetric(x[0...2,3...5]) && x[0...2,0...2] ≈ x[3...5,3...5] && x[3...5, 0...2] ≈ Matrix(repeating: 0, shape: (rows: 3, cols: 3))
    } else {
        return false
    }
}

/// Check if matrix is in adjoint* of se(3) Lie algebra
/// - Parameter x: Any matrix
/// - Returns: True or false
private func isIncoadse3(_ x: Matrix) -> Bool {
    if x.shape == (6,6) {
        return isSkewsymmetric(x[3...5, 0...2]) && x[3...5, 0...2] ≈ x[0...2,3...5] && isSkewsymmetric(x[3...5,3...5]) && x[0...2,0...2] ≈ Matrix(repeating: 0, shape: (rows: 3, cols: 3))
    } else {
        return false
    }
}

/// Check if matrix is in SO(3) Lie group
/// - Parameter x: Any matrix
/// - Returns: True or false
private func isInSO3(_ x: Matrix) -> Bool {
    return isOrthogonal(x) && x.shape == (3,3)
}

/// Check if matrix is in SE(3) Lie group
/// - Parameter x: Any matrix
/// - Returns: True or false
private func isInSE3(_ x: Matrix) -> Bool {
    if x.shape == (4,4) {
        return isOrthogonal(x[0...2,0...2]) && x[3, .all] ≈ Matrix(from: [[0, 0, 0, 1]])
    } else {
        return false
    }
}

/// Check if matrix is in adjoint of SE(3) Lie group
/// - Parameter x: Any matrix
/// - Returns: True or false
private func isInAdSE3(_ x: Matrix) -> Bool {
    if x.shape == (6,6) {
        return isOrthogonal(x[0...2,0...2]) && x[0...2,0...2] ≈ x[3...5,3...5] && x[3...5,0...2] ≈ Matrix(repeating: 0, shape: (rows: 3, cols: 3))
    } else {
        return false
    }
}

/// Return vector space of matrix `X`
/// - Parameter X: Any matrix
/// - Returns: Vector space
private func vectorSpace(of x: Matrix) -> VectorSpace {
    if isInso3(x) { return .so3 }
    if isInSO3(x) { return .SO3 }
    if isInse3(x) { return .se3 }
    if isInadse3(x) { return .adse3 }
    if isIncoadse3(x) { return .coadse3 }
    if isInSE3(x) { return .SE3 }
    if isInAdSE3(x) { return .AdSE3 }
    return .linear
}

/// Hat map for so(3) Lie algebra
/// - Parameter x: Vector from R^3
/// - Returns: Matrix in so(3)
private func hatso3(_ x: Matrix) -> Matrix {
    var hatX = Matrix(repeating: 0, shape: (rows: 3, cols: 3))
    hatX[2,1] = x[0,0]
    hatX[1,2] = -x[0,0]
    hatX[0,2] = x[1,0]
    hatX[2,0] = -x[1,0]
    hatX[1,0] = x[2,0]
    hatX[0,1] = -x[2,0]
    return hatX
}

/// Reverse from the hat map for so(3) Lie algebra
/// - Parameter x: Matrix from so(3)
/// - Returns: Vector in R^3
private func antihatso3(_ x: Matrix) -> Matrix {
    var vecX = Matrix(repeating: 0, shape: (rows: 3, cols: 1))
    vecX[0,0] = x[2,1]
    vecX[1,0] = x[0,2]
    vecX[2,0] = x[1,0]
    return vecX
}

/// Hat map for se(3) Lie algebra
/// - Parameter x: Vector from R^6
/// - Returns: Matrix in se(3)
private func hatse3(_ x: Matrix) -> Matrix {
    var hatX = Matrix(repeating: 0, shape: (rows: 4, cols: 4))
    hatX[0...2,0...2] = hatso3(x[3...5,0])
    hatX[0...2,3] = Matrix(copy: x[0...2,0])
    return hatX
}

/// Reverse from the hat map for se(3) Lie algebra
/// - Parameter x: Matrix from se(3)
/// - Returns: Vector in R^6
private func antihatse3(_ x: Matrix) -> Matrix {
    var vecX = Matrix(repeating: 0, shape: (rows: 6, cols: 1))
    vecX[3...5,0] = antihatso3(x[0...2,0...2])
    vecX[0...2,0] = Matrix(copy: x[0...2,3])
    return vecX
}

/// Maps a vector from linear space to Lie algebra.
///
/// This function is specifically applicable to three- and six-dimensional linear spaces.
/// ![s o 3 and s e 3 map](hatso3)
/// ![s o 3 and s e 3 map](hatse3)
///
/// - Precondition: Shape of matrix `x` must be either `(3,1)` or `(6,1)`.
///
/// - Remark: A new matrix is created by copying existing data. Changes in values of the original object **do not** affect the created matrix.
///
/// - Parameter x: Column matrix, element of linear space.
///
/// - Returns: A new matrix, member of Lie algebra.
public func hat(_ x: Matrix) -> Matrix {
    switch x.shape {
    case (3,1): return hatso3(x)
    case (6,1): return hatse3(x)
    default: fatalError("Shape of matrix `x` must be either `(3,1)` or `(6,1)`.")
    }
}

/// Maps a matrix from Lie algebra to  linear space.
///
/// This function does the reverse of the ``hat(_:)``.
///
/// - Precondition: Matrix `x` must be a member of either so(3) or se(3) Lie algebra.
///
/// - Remark: A new matrix is created by copying existing data. Changes in values of the original object **do not** affect the created matrix.
///
/// - Parameter x: Matrix, element of Lie algebra.
///
/// - Returns: A new matrix, member of linear space.
public func antihat(_ x: Matrix) -> Matrix {
    switch vectorSpace(of: x) {
    case .so3: return antihatso3(x)
    case .se3: return antihatse3(x)
    default: fatalError("Matrix `x` must be a member of either so(3) or se(3) Lie algebra.")
    }
}

/// Maps a matrix from Lie algebra or Lie group to its adjoint representation.
///
/// This function is specifically applicable to so(3), se(3)  SO(3) and SE(3).
/// ![s o 3 and s e 3 map](adjointalgebraso3)
/// ![s o 3 and s e 3 map](adjointalgebrase3)
/// ![Adjoint](adjointgroupSO3)
/// ![Adjoint](adjointgroupSE3)
///
/// - Precondition: Matrix `x` must be a member of either so(3) or se(3) Lie algebra.
///
/// - Remark: A new matrix is created by copying existing data. Changes in values of the original object **do not** affect the created matrix.
///
/// - Parameter x: Matrix, element of Lie algebra or Lie group.
///
/// - Returns: A new matrix, member of adjoint of Lie algebra.
public func adjoint(_ x: Matrix) -> Matrix {
    switch vectorSpace(of: x) {
    case .so3:
        return Matrix(copy: x)
    case .se3:
        var a = Matrix(repeating: 0, shape: (rows: 6, cols: 6))
        a[0...2,0...2] = Matrix(copy: x[0...2,0...2])
        a[3...5,3...5] = Matrix(copy: x[0...2,0...2])
        a[0...2,3...5] = hat(x[0...2,3])
        return a
    case .SO3:
        return Matrix(copy: x)
    case .SE3:
        var a = Matrix(repeating: 0, shape: (rows: 6, cols: 6))
        a[0...2,0...2] = Matrix(copy: x[0...2,0...2])
        a[3...5,3...5] = Matrix(copy: x[0...2,0...2])
        a[0...2,3...5] = hat(x[0...2,3])∙x[0...2,0...2]
        return a
    default:
        fatalError("Matrix `x` must be a member of either so(3) or se(3) Lie algebra or SO(3) or SE(3) Lie group.")
    }
}

/// Maps a matrix from adjoint of Lie algebra or adjoint of Lie group to  Lie algebra or Lie group.
///
/// This function does the reverse of the ``adjoint(_:)``.
///
/// - Precondition: Matrix `x` must be a member of adjoint of either so(3) or se(3) Lie algebra or SO(3) or SE(3) Lie group.
///
/// - Remark: A new matrix is created by copying existing data. Changes in values of the original object **do not** affect the created matrix.
///
/// - Parameter x: Matrix, element of adjoint of Lie algebra or Lie group.
///
/// - Returns: A new matrix, member of Lie algebra or Lie group.
public func antiadjoint(_ x: Matrix) -> Matrix {
    switch vectorSpace(of: x) {
    case .so3:
        return Matrix(copy: x)
    case .adse3:
        var a = Matrix(repeating: 0, shape: (rows: 4, cols: 4))
        a[0...2,0...2] = Matrix(copy: x[0...2,0...2])
        a[0...2,3] = antihat(x[0...2,3...5])
        return a
    case .SO3:
        return Matrix(copy: x)
    case .AdSE3:
        var a = Matrix(identity: 4)
        a[0...2,0...2] = Matrix(copy: x[0...2,0...2])
        a[0...2,3] = antihat(x[0...2,3...5]∙x[0...2,0...2].T)
        return a
    default:
        fatalError("Matrix `x` must be a member of adjoint of either so(3) or se(3) Lie algebra or SO(3) or SE(3) Lie group.")
    }
}

/// Maps a vector from linear space to adjoint representation of Lie algebra.
///
/// This function is specifically applicable to three- and six-dimensional linear spaces. It is a convenience function which acts as a convolution of ``hat(_:)`` and ``adjoint(_:)``.
///
/// - Precondition: Shape of matrix `x` must be either `(3,1)` or `(6,1)`.
///
/// - Remark: A new matrix is created by copying existing data. Changes in values of the original object **do not** affect the created matrix.
///
/// - Parameter x: Column matrix, element of linear space.
///
/// - Returns: A new matrix, member of the adjoint of Lie algebra.
public func tilde(_ x: Matrix) -> Matrix {
    return adjoint(hat(x))
}

/// Maps a matrix from adjoint of Lie algebra to  linear space.
///
/// This function does the reverse of the ``tilde(_:)``.
///
/// - Precondition: Matrix `x` must be a member of either adjoint of so(3) or se(3) Lie algebra.
///
/// - Remark: A new matrix is created by copying existing data. Changes in values of the original object **do not** affect the created matrix.
///
/// - Parameter x: Matrix, element of adjoint of Lie algebra.
///
/// - Returns: A new matrix, member of linear space.
public func antitilde(_ x: Matrix) -> Matrix {
    return antihat(antiadjoint(x))
}

/// Maps a matrix from Lie algebra to its coadjoint representation.
///
/// This function is specifically applicable to so(3) and se(3).
/// ![s o 3 and s e 3 map](coadjointalgebraso3)
/// ![s o 3 and s e 3 map](coadjointalgebrase3)
///
/// - Precondition: Matrix `x` must be a member of either so(3) or se(3) Lie algebra.
///
/// - Remark: A new matrix is created by copying existing data. Changes in values of the original object **do not** affect the created matrix.
///
/// - Parameter x: Matrix, element of Lie algebra.
///
/// - Returns: A new matrix, member of coadjoint of Lie algebra.
public func coadjoint(_ x: Matrix) -> Matrix {
    switch vectorSpace(of: x) {
    case .so3:
        return Matrix(copy: x)
    case .se3:
        var a = Matrix(repeating: 0, shape: (rows: 6, cols: 6))
        a[0...2,3...5] = hat(x[0...2,3])
        a[3...5,0...2] = hat(x[0...2,3])
        a[3...5,3...5] = Matrix(copy: x[0...2,0...2])
        return a
    default:
        fatalError("Matrix `x` must be a member of either so(3) or se(3) Lie algebra.")
    }
}

/// Maps a matrix from coadjoint of Lie algebra to  Lie algebra.
///
/// This function does the reverse of the ``coadjoint(_:)``.
///
/// - Precondition: Matrix `x` must be a member of coadjoint of either so(3) or se(3) Lie algebra.
///
/// - Remark: A new matrix is created by copying existing data. Changes in values of the original object **do not** affect the created matrix.
///
/// - Parameter x: Matrix, element of coadjoint of Lie algebra.
///
/// - Returns: A new matrix, member of Lie algebra.
public func anticoadjoint(_ x: Matrix) -> Matrix {
    switch vectorSpace(of: x) {
    case .so3:
        return Matrix(copy: x)
    case .coadse3:
        var a = Matrix(repeating: 0, shape: (rows: 4, cols: 4))
        a[0...2,0...2] = Matrix(copy: x[3...5,3...5])
        a[0...2,3] = antihat(x[0...2,3...5])
        return a
    default:
        fatalError("Matrix `x` must be a member of adjoint of either so(3) or se(3) Lie algebra or SO(3) or SE(3) Lie group.")
    }
}

/// Maps a vector from linear space to coadjoint representation of Lie algebra.
///
/// This function is specifically applicable to three- and six-dimensional linear spaces. It is a convenience function which acts as a convolution of ``hat(_:)`` and ``coadjoint(_:)``.
///
/// - Precondition: Shape of matrix `x` must be either `(3,1)` or `(6,1)`.
///
/// - Remark: A new matrix is created by copying existing data. Changes in values of the original object **do not** affect the created matrix.
///
/// - Parameter x: Column matrix, element of linear space.
///
/// - Returns: A new matrix, member of the coadjoint of the Lie algebra.
public func check(_ x: Matrix) -> Matrix {
    return coadjoint(hat(x))
}

/// Maps a matrix from coadjoint of Lie algebra to  linear space.
///
/// This function does the reverse of the ``check(_:)``.
///
/// - Precondition: Matrix `x` must be a member of either coadjoint of so(3) or se(3) Lie algebra.
///
/// - Remark: A new matrix is created by copying existing data. Changes in values of the original object **do not** affect the created matrix.
///
/// - Parameter x: Matrix, element of coadjoint of Lie algebra.
///
/// - Returns: A new matrix, member of linear space.
public func anticheck(_ x: Matrix) -> Matrix {
    antihat(anticoadjoint(x))
}

private func factorial(_ N: Int) -> Double {
    var mult = N
    var retVal: Double = 1.0
    while mult > 0 {
        retVal *= Double(mult)
        mult -= 1
    }
    return retVal
}

/// Matrix exponential - series
/// - Parameter x: Square matrix
/// - Returns: Linear space
private func expseries(_ x: Matrix) -> Matrix {
    var m = Matrix(identity: x.shape.rows)
    let itermax = 15
    let tolerance = 1e-12
    for i in 1..<itermax {
        let c = x**i / factorial(i)
        m += c
        if sqrt(trace(c∙c.T)) < tolerance { break }
    }
    return m
}

/// Tangent application - series
/// - Parameter x: Square matrix
/// - Returns: Linear space
private func tangseries(_ x: Matrix) -> Matrix {
    var m = Matrix(identity: x.shape.rows)
    let itermax = 15
    let tolerance = 1e-12
    for i in 1..<itermax {
        let c = (-x)**i / factorial(i+1)
        m += c
        if sqrt(trace(c∙c.T)) < tolerance { break }
    }
    return m
}

/// Matrix logarithm - series
/// - Parameter x: Square matrix
/// - Returns: Linear space
private func logseries(_ x: Matrix) -> Matrix {
    print("LOGARITHM SERIES EXPANSION")
    var m = Matrix(repeating: 0, shape: x.shape)
    let I = Matrix(identity: x.shape.rows)
    let itermax = 15
    let tolerance = 1e-12
    for i in 1..<itermax {
        let c = (-1)**(i+1) * (x - I)**i / Double(i)
        m += c
        if sqrt(trace(c∙c.T)) < tolerance { break }
    }
    return m
}

/// Matrix exponential so(3)
/// - Parameter x: so(3)
/// - Returns: SO(3)
private func expso3(_ x: Matrix) -> Matrix {
    let tolerance = 1e-3
    let n = sqrt(-0.5*trace(x**2))
    if n < tolerance { return expseries(x) }
    let a = sin(n) / n
    let b = (1 - cos(n)) / n**2
    return Matrix(identity: 3) + a * x + b * x**2
}

/// Tangent application so(3)
/// - Parameter x: ad(so(3)) = so(3)
/// - Returns: R^3x3
private func tangso3(_ x: Matrix) -> Matrix {
    let tolerance = 1e-3
    let n = sqrt(-0.5*trace(x**2))
    if n < tolerance { return tangseries(x) }
    let a = sin(n) / n
    let b = (1 - cos(n)) / n**2
    return Matrix(identity: 3) - b * x + (1 - a)/n**2 * x**2
}

/// Extract quaternion from a rotation matrix.
/// - Parameter x: Matrix from SO(3)
/// - Returns: Matrix in su(2) = quaternion. The scalar part is in the first position before the vector part.
private func spurrier_quaternion_extraction(_ x: Matrix) -> Matrix {
    let tr = trace(x)
    let m = max(tr, x[0,0], x[1,1], x[2,2])
    var q = Matrix(repeating: 0, shape: (rows: 4, cols: 1))
    switch m {
    case tr:
        q[0,0] = sqrt(1.0 + tr) / 2
        for i in 1...3 {
            let j = i % 3 + 1, k = (i+1) % 3 + 1  // cyclic permutations
            q[i,0] = (x[k-1,j-1] - x[j-1,k-1]) / (4 * q[0,0])
        }
    default:
        let i = [x[0,0], x[1,1], x[2,2]].enumerated().max(by: { (a, b) in
            a.element < b.element
        })!.offset + 1
        let j = i % 3 + 1, k = (i+1) % 3 + 1  // cyclic permutations
        q[i,0] = sqrt(x[i-1,i-1] / 2 + (1 - tr) / 4)
        q[0,0] = (x[k-1,j-1] - x[j-1,k-1]) / (4*q[i,0])
        for l in [j, k] {
            q[l,0] = (x[l-1,i-1] + x[i-1,l-1]) / (4*q[i,0])
        }
    }
    return q
}

/// Matrix logarithm SO(3)
/// - Parameter x: SO(3)
/// - Returns: so(3) with angle of rotation normalized between -π and π
private func logSO3(_ x: Matrix) -> Matrix {
    let q = spurrier_quaternion_extraction(x)
    let n = sqrt((q[1...3,0].T ∙ q[1...3,0])[0,0])
    if n == 0 { return hat(q[1...3,0]) }
    var angle = 2 * atan2(n, q[0,0])
    // normalize angle to be within (-π, π)
    angle = angle.truncatingRemainder(dividingBy: 2*Double.pi)
    if angle > Double.pi {
        angle -= 2 * Double.pi
    } else if angle < -Double.pi {
        angle += 2 * Double.pi
    }
    return angle * hat(q[1...3,0]) / n
}

/// Matrix exponential se(3)
/// - Parameter x: se(3)
/// - Returns: SE(3)
private func expse3(_ x: Matrix) -> Matrix {
    var e = Matrix(identity: 4)
    e[0...2,0...2] = expso3(x[0...2,0...2])
    e[0...2,3] = tangso3(x[0...2,0...2]).T ∙ x[0...2,3]
    return e
}

/// Tangent application se(3)
/// - Parameter x: adjoint se(3)
/// - Returns: R^6x6
private func tangse3(_ x: Matrix) -> Matrix {
    let tolerance = 1e-3
    let b = sqrt(-0.25*trace(x**2))
    if b < tolerance { return tangseries(x) }
    var e = Matrix(identity: 6)
    e[0...2,0...2] = tangso3(x[0...2,0...2])
    e[3...5,3...5] = tangso3(x[3...5,3...5])
    let c = -1/2 * trace(x[0...2,0...2] ∙ x[0...2,3...5])
    let a1 = (cos(b) - 1) / b**2
    let a2 = (b - sin(b)) / b**3
    let a3 = c * (2 - 2 * cos(b) - b * sin(b)) / b**4
    let a4 = -c * (2 + cos(b) - 3 * sin(b) / b) / b**4
    e[0...2,3...5] = (
        a1 * x[0...2,3...5]
        + a2 * (x[0...2,0...2] ∙ x[0...2,3...5] + x[0...2,3...5] ∙ x[0...2,0...2])
        + a3 * x[0...2,0...2]
        + a4 * x[0...2,0...2]**2
    )
    return e
}

/// Matrix logarithm SE(3)
/// - Parameter x: SE(3)
/// - Returns: se(3)
private func logSE3(_ x: Matrix) -> Matrix {
    var m = Matrix(repeating: 0, shape: (rows: 4, cols: 4))
    m[0...2,0...2] = logSO3(x[0...2,0...2])
    m[0...2,3] = tangso3(m[0...2,0...2]).T**(-1) ∙ x[0...2,3]
    return m
}

/// Compute matrix exponential.
///
/// Compute the generalized exponential map on matrices by evaluating the series.
/// ![series](exp)
/// The number of terms used to compute the result varies as it is determined by convergence rate. Convergence is determined by observing the norm change between iterations. The iteration process breaks when the desired tolerance `1e-12` is achieved or the total number of terms exceedes 15.
///
/// - Remark: No warning is given if the series did not converge successfully.
///
/// Checks are performed to see whether the input matrix conforms to Lie algebra with a closed form solution in which case the closed form solution is used instead of the series.
/// ![expSO3](expSO3)
/// ![expSE3](expSE3)
/// For convenience, vectors from linear space can also be inputs as they are isomorphic to Lie algebra.
/// | SO(3)     | so(3), R^3 |
/// |-----------|------------|
/// | SE(3)     | se(3), R^6 |
/// | Ad(SE(3)) | ad(se(3))  |
///
/// - Precondition: Exponential function is defined only on square matrices.
///
/// - Parameter x: Matrix.
///
/// - Returns: Matrix exponential.
public func exp(_ x: Matrix) -> Matrix {
    switch vectorSpace(of: x) {
    case .so3:
        return expso3(x)
    case .se3:
        return expse3(x)
    case .adse3:
        return adjoint(expse3(hat(antitilde(x))))
    case .linear:
        if x.shape == (3,1) {
            return expso3(hat(x))
        } else if x.shape == (6,1) {
            return expse3(hat(x))
        } else if x.shape.rows == x.shape.cols {
            return expseries(x)
        } else {
            fatalError("Exponential function is defined only on square matrices.")
        }
    default:
        fatalError("Exponential function is defined only on square matrices representing Lie algebra.")
    }
}

/// Compute tangent application of exponential map.
///
/// Derivative of matrix exponential can be expressed through the exponential itself and tangent application.
/// ![dexp](dexp)
/// Tangent application can be computed by evaluating series expansion.
/// ![series](tang)
/// The number of terms used to compute the result varies as it is determined by convergence rate. Convergence is determined by observing the norm change between iterations. The iteration process breaks when the desired tolerance `1e-12` is achieved or the total number of terms exceedes 15.
///
/// - Remark: No warning is given if the series did not converge successfully.
///
/// Checks are performed to see whether the input matrix conforms to Lie algebra with a closed form solution in which case the closed form solution is used instead of the series.
/// ![tangSO3](tangSO3)
/// ![tangSE3](tangSE3)
/// ![tanguomega](tanguomega)
///
/// - Note: For small norms, the analytical expressions for tangent application can accumulate significant numerical error. In this cases series expansion is still prefered.
///
/// For convenience, vectors from linear space can also be inputs as they are isomorphic to Lie algebra.
/// | R^3x3     | so(3), R^3 |
/// |------------|------------|
/// | R^6x6     | se(3), ad(se(3)) , R^6 |
///
/// - Precondition: Tangent application is defined only on square matrices.
///
/// - Parameter x: Matrix.
///
/// - Returns: Tangent application.
public func tang(_ x: Matrix) -> Matrix {
    switch vectorSpace(of: x) {
    case .so3:
        return tangso3(x)
    case .adse3:
        return tangse3(x)
    case .se3:
        return tangse3(adjoint(x))
    case .linear:
        if x.shape == (3,1) {
            return tangso3(hat(x))
        } else if x.shape == (6,1) {
            return tangse3(tilde(x))
        } else if x.shape.rows == x.shape.cols {
            return tangseries(x)
        } else {
            fatalError("Tangent application is defined only on square matrices representing adjoint of Lie algebra.")
        }
    default:
        fatalError("Tangent application is defined only on square matrices representing adjoint of Lie algebra.")
    }
}

/// Compute matrix logartihm.
///
/// Compute the generalized logarithmic map on matrices by evaluating the series.
/// ![series](log)
/// The number of terms used to compute the result varies as it is determined by convergence rate. Convergence is determined by observing the norm change between iterations. The iteration process breaks when the desired tolerance `1e-12` is achieved or the total number of terms exceedes 15.
///
/// - Remark: No warning is given if the series did not converge successfully.
///
/// Checks are performed to see whether the input matrix conforms to Lie algebra with a closed form solution in which case the closed form solution is used instead of the series.
/// ![logSO3](logSO3)
/// ![logSE3](logSE3)
/// Although the analytical solution for SO(3) has a concise form, it is not the most appropriate in the numerical sense. Therefore we use the purposfully developed algorithm by [Spurrier (1978)](https://arc.aiaa.org/doi/10.2514/3.57311).
///
/// - Precondition: Logarithmic function is defined only on square matrices.
///
/// - Parameter x: Matrix.
///
/// - Returns: Matrix logartihm.
public func log(_ x: Matrix) -> Matrix {
    switch vectorSpace(of: x) {
    case .SO3:
        return logSO3(x)
    case .SE3:
        return logSE3(x)
    case .AdSE3:
        return adjoint(logSE3(antiadjoint(x)))
    case .linear:
        if x.shape.rows == x.shape.cols {
            return logseries(x)
        } else {
            fatalError("Exponential function is defined only on square matrices.")
        }
    default:
        fatalError("Exponential function is defined only on square matrices.")
    }
}
