//
//  LinearAlgebraTests.swift
//  LinearAlgebraTests
//
//  Created by Jan Tomec on 10/11/2022.
//

import XCTest
@testable import SwiftLinearAlgebra

final class LinearAlgebraTests: XCTestCase {

    func testEquality() throws {
        let a = Matrix(from: [[3.5, 0.9, 6.3], [8.2, -0.7, -6.5], [-4.6, 9.3, -8.9], [0.4,
            4.3, -9.4]])
        let b = Matrix(from: [[3.5, 0.9, 6.3], [8.2, -0.7, -6.5], [-4.6, 9.3, -8.9], [0.4,
                                                                                      4.3, -9.4]])
        XCTAssert(a == b)
    }
    
    func testReferencing() throws {
        let a = Matrix(from: [[3.5, 0.9, 6.3], [8.2, -0.7, -6.5], [-4.6, 9.3, -8.9], [0.4,
            4.3, -9.4]])
        let b = a[.all, 0...2]
        a[0,0] = 100
        let c = Matrix(from: [[100.0, 0.9, 6.3], [8.2, -0.7, -6.5], [-4.6, 9.3, -8.9], [0.4,
            4.3, -9.4]])
        XCTAssert(b == c)
    }
    
    func testCopying() throws {
        let a = Matrix(from: [[3.5, 0.9, 6.3], [8.2, -0.7, -6.5], [-4.6, 9.3, -8.9], [0.4,
            4.3, -9.4]])
        let b = Matrix(copy: a[.all, 0...2])
        a[0,0] = 100
        let c = Matrix(from: [[3.5, 0.9, 6.3], [8.2, -0.7, -6.5], [-4.6, 9.3, -8.9], [0.4,
            4.3, -9.4]])
        XCTAssert(b == c)
    }
    
    func testArithmetics() throws {
        let a = Matrix(from: [[3.5, 0.9, 6.3], [8.2, -0.7, -6.5], [-4.6, 9.3, -8.9], [0.4,
            4.3, -9.4]])
        let b = Matrix(from: [[-6.1, 1.0, 9.3, -3.9], [-5.1, -6.3, 1.7, 6.2], [-0.6, 0.3,
            4.3, -3.4]])
        let c = Matrix(from: [[-11.3,   1.1, -11.0],
                              [  4.8, -20.3,  19.5],
                              [ 40.5,  -7.9,  -4.9]])
        a[0..<3,0..<3] += b[0..<3,0..<3]
        XCTAssert(2*a[0..<3,0..<3].T + b.T[0..<3,0..<3] == c)
    }
    
    func testMatrixMultiplication() throws {
        let a = Matrix(from: [[3.5, 0.9, 6.3], [8.2, -0.7, -6.5], [-4.6, 9.3, -8.9], [0.4,
            4.3, -9.4]])
        let b = Matrix(from: [[-6.1, 1.0, 9.3, -3.9], [-5.1, -6.3, 1.7, 6.2], [-0.6, 0.3,
            4.3, -3.4]])
        let c = Matrix(from: [[-57.49, 63.53, -91.04],
                              [-74.85, 42.29, -64.59],
                              [-20.78, 24.62, -12.04]])
        XCTAssert(b∙a == c)
    }
    
    func testInverting() throws {
        let a = Matrix(from: [[-57.49, 63.53, -91.04],
                              [-74.85, 42.29, -64.59],
                              [-20.78, 24.62, -12.04]])
        let b = Matrix(from: [[ 0.020156646023028360, -0.027530452243719080, -0.004723350790256376],
                              [ 0.008222499098030746, -0.022367978292674870,  0.057821544853750080],
                              [-0.017974848551911330,  0.001776010968341117,  0.043332031870502870]])
        XCTAssert(try invert(a) == b)
    }
    
    func testSolving() throws {
        let a = Matrix(from: [[3.5, 0.9, 6.3], [8.2, -0.7, -6.5], [-4.6, 9.3, -8.9], [0.4,
            4.3, -9.4]])
        let b = Matrix(from: [[-6.1, 1.0, 9.3, -3.9], [-5.1, -6.3, 1.7, 6.2], [-0.6, 0.3,
            4.3, -3.4]])
        let x = Matrix(from: [[-0.4494608992983296, 0.1766566088810417, 0.3831939999287645]])
        XCTAssert(try solve(A: a[0...2,0...2], b: b[.all,1]) == x.T)
    }

}
