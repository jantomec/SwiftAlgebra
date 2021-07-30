    import XCTest
    @testable import SwiftLinearAlgebra

    final class SwiftLinearAlgebraMatrixTests: XCTestCase {
        func testMatrixInitFromArray() {
            // This function tests if matrix is successfully constructed.
            let input: [[Int]] = [[1,2,3]]
            let output = Matrix(input)
            let referenceInput: [[Double]] = [[1,2,3]]
            let expectedOutput = Matrix(referenceInput)
            XCTAssertEqual(output, expectedOutput)
        }
        func testMatrixInitFromValueSuccessful() {
            // This function tests if matrix is successfully constructed.
            let output = Matrix(value: 1, shape: (3, 1))
            let referenceInput: [[Double]] = [[1],
                                              [1],
                                              [1]]
            let expectedOutput = Matrix(referenceInput)
            XCTAssertEqual(output, expectedOutput)
        }
        func testMatrixSubscriptSingleElement() {
            let matrix = Matrix([[1,2,3],
                                 [2,3,4]])
            XCTAssertEqual(matrix[1, 0], 2)
        }
        func testMatrixSafeSubscriptSingleElementSuccessful() {
            let matrix = Matrix([[1,2,3],
                                 [2,3,4]])
            XCTAssertEqual(matrix[safe: 1, 0], 2)
        }
        func testMatrixSafeSubscriptSingleElementUnsuccessful() {
            let matrix = Matrix([[1,2,3],
                                 [2,3,4]])
            XCTAssertEqual(matrix[safe: 2, 0], nil)
        }
        func testMatrixCyclicSubscriptSingleElement() {
            let matrix = Matrix([[1,2,3],
                                 [2,3,4]])
            XCTAssertEqual(matrix[cyclic: 2, 0], 1)
        }
        func testMatrixSubscriptRow() {
            let matrix = Matrix([[1,2,3],
                                 [2,3,4]])
            let expectedResult = Matrix(vector: [2,3,4], type: .row)
            XCTAssertEqual(matrix[1, .all], expectedResult)
        }
        func testMatrixSubscriptColumn() {
            let matrix = Matrix([[1,2,3],
                                 [2,3,4]])
            let expectedResult = Matrix(vector: [2,3], type: .column)
            XCTAssertEqual(matrix[.all, 1], expectedResult)
        }
        func testMatrixSafeSubscriptColumnSuccessful() {
            let matrix = Matrix([[1,2,3],
                                 [2,3,4]])
            let expectedResult = Matrix(vector: [2,3], type: .column)
            XCTAssertEqual(matrix[safe: .all, 1], expectedResult)
        }
        func testMatrixSafeSubscriptColumnUnsuccessful() {
            let matrix = Matrix([[1,2,3],
                                 [2,3,4]])
            XCTAssertEqual(matrix[safe: .all, 3], nil)
        }
        func testMatrixCyclicSubscriptRow() {
            let matrix = Matrix([[1,2,3],
                                 [2,3,4]])
            let expectedResult = Matrix(vector: [2,3,4], type: .row)
            XCTAssertEqual(matrix[cyclic: -1, .all], expectedResult)
        }
        func testMatrixCyclicSubscriptColumn() {
            let matrix = Matrix([[1,2,3],
                                 [2,3,4]])
            let expectedResult = Matrix(vector: [2,3], type: .column)
            XCTAssertEqual(matrix[cyclic: .all, -2], expectedResult)
        }
        func testMatrixSubscriptListRow() {
            let matrix = Matrix([[1,2,3],
                                 [4,5,6]])
            let expectedResult = Matrix(vector: [2,3], type: .row)
            XCTAssertEqual(matrix[0, [1,2]], expectedResult)
        }
        func testMatrixSubscriptListColumn() {
            let matrix = Matrix([[1,2,3],
                                 [4,5,6]])
            let expectedResult = Matrix(vector: [2,5], type: .column)
            XCTAssertEqual(matrix[[0,1], 1], expectedResult)
        }
        func testMatrixSubscriptListMatrix() {
            let matrix = Matrix([[1,2,3],
                                 [4,5,6]])
            let expectedResult = Matrix([[2,3],
                                         [5,6]])
            XCTAssertEqual(matrix[[0,1],
                                  [1,2]], expectedResult)
        }
        func testMatrixSubscriptAddListMatrix() {
            var matrix = Matrix([[1,2,3],
                                 [4,5,6]])
            matrix[[0,1], [0,1]] += Matrix([[2,3],
                                            [5,6]])
            let expectedResult = Matrix([[3,5,3],
                                         [9,11,6]])
            XCTAssertEqual(matrix, expectedResult)
        }
        func testMatrixSubscriptRange() {
            let matrix = Matrix([[1,2,3],
                                 [4,5,6]])
            let expectedResult = Matrix([[2,3]])
            XCTAssertEqual(matrix[0, 1..<3], expectedResult)
        }
        func testMatrixSubscriptAddRangeList() {
            var matrix = Matrix(value: 0, shape: (4, 5))
            matrix[1..<3, [0,3]] = Matrix([[1,2],
                                           [3,4]])
            let expectedResult = Matrix([[0,0,0,0,0],
                                         [1,0,0,2,0],
                                         [3,0,0,4,0],
                                         [0,0,0,0,0]])
            XCTAssertEqual(matrix, expectedResult)
        }
        func testMatrixVectorSubscript() {
            let matrix = Matrix(vector: [1,2,3], type: .column)
            XCTAssertEqual(matrix[1], 2)
        }
        func testMatrixVectorSafeSubscript() {
            let matrix = Matrix(vector: [1,2,3], type: .column)
            XCTAssertEqual(matrix[safe: 3], nil)
        }
        func testMatrixVectorCyclicSubscript() {
            let matrix = Matrix(vector: [1,2,3], type: .row)
            XCTAssertEqual(matrix[cyclic: 3], 1)
        }
        func testMatrixVectorCyclicRangeSubscript() {
            let matrix = Matrix(vector: [1,2,3], type: .column)
            let expectedResult = Matrix(vector: [2,3,1], type: .column)
            XCTAssertEqual(matrix[cyclic: [1,2,3]], expectedResult)
        }
        func testMatrixAddition() {
            let A = Matrix([[1,2,3],
                            [2,3,4]])
            let B = Matrix([[0,4,7],
                            [5,9,2.5]])
            let C = Matrix([[1,6,10],
                            [7,12,6.5]])
            XCTAssertEqual(A + B, C)
        }
        func testMatrixSelfAddition() {
            var A = Matrix([[1,2,3],
                            [2,3,4]])
            let B = Matrix([[0,4,7],
                            [5,9,2.5]])
            A += B
            let C = Matrix([[1,6,10],
                            [7,12,6.5]])
            XCTAssertEqual(A, C)
        }
        func testMatrixSubstraction() {
            let A = Matrix([[1,2,3],
                            [2,3,4]])
            let B = Matrix([[1,6,10],
                            [7,12,6.5]])
            let C = Matrix([[0,4,7],
                            [5,9,2.5]])
            XCTAssertEqual(B - A, C)
        }
        func testMatrixElementwiseMultiplication() {
            let A = Matrix([[1,2,3],
                            [2,3,4]])
            let B = Matrix([[1,6,10],
                            [7,12,6.5]])
            let C = Matrix([[1,12,30],
                            [14,36,26]])
            XCTAssertEqual(A * B, C)
        }
        func testMatrixMatrixMultiplication() {
            let A = Matrix([[1,2,3],
                            [2,3,4]])
            let B = Matrix([[1,6],
                            [7,12.6],
                            [2.4,5]])
            let C = Matrix([[22.2, 46.2],
                            [32.6, 69.8]])
            XCTAssertEqual(A ∙ B, C)
        }
        func testMatrixVectorMultiplication() {
            let A = Matrix([[1,2,3],
                            [2,3,4]])
            let B = Matrix(vector: [1, 7, 2.4], type: .column)
            let C = Matrix([[22.2],
                            [32.6]])
            XCTAssertEqual(A ∙ B, C)
        }
        func testVectorMatrixMultiplication() {
            let A = Matrix(vector: [1, 7, 2.4], type: .row)
            let B = Matrix([[1,2],
                            [2,3],
                            [3,4]])
            let C = Matrix([[22.2, 32.6]])
            XCTAssertEqual(A ∙ B, C)
        }
        func testMatrixTransposed() {
            let A = Matrix([[1,2,3],
                            [2,3,4]])
            let expectedResult = Matrix([[1,2],
                                         [2,3],
                                         [3,4]])
            XCTAssertEqual(A.transposed, expectedResult)
        }
        func testMatrixOuterProduct() {
            let A = Matrix(vector: [1,2,3], type: .column)
            let B = Matrix(vector: [2,3,4], type: .column)
            let expectedResult = Matrix([[2,3,4],
                                         [4,6,8],
                                         [6,9,12]])
            XCTAssertEqual(A ⊙ B, expectedResult)
        }
        func testMatrixCrossProduct() {
            let A = Matrix(vector: [1,2,3], type: .column)
            let B = Matrix(vector: [-2,3,4], type: .column)
            let expectedResult = Matrix(vector: [-1,-10,7], type: .column)
            XCTAssertEqual(A ⨯ B, expectedResult)
        }
        func testMatrixIdentity() {
            let A = identity(2)
            let expectedResult = Matrix([[1,0],
                                         [0,1]])
            XCTAssertEqual(A, expectedResult)
        }
        func testMatrixExponent() {
            let A = Matrix([[1,2],
                            [3,4]])
            let expectedResult = Matrix([[7,10],
                                         [15,22]])
            XCTAssertEqual(A**2, expectedResult)
        }
        func testMatrixNorm() {
            let A = Matrix(vector: [1,2,3], type: .column)
            let expectedResult = 3.7416573867739413
            XCTAssertEqual(norm(vector: A), expectedResult, accuracy: 1e-12)
        }
        func testMatrixLUDecomposition() {
            let A = Matrix([[0, 2, 4],
                            [4, 2, 1],
                            [-1, 0, -1]])
            let decomposed = try! LUDecompositionDoolittle(A)
            let expectedResult = Matrix([[4, 2, 1],
                                         [0, 2, 4],
                                         [-0.25, 0.25, -1.75]])
            XCTAssertEqual(decomposed.LU, expectedResult)
        }
        func testMatrixLUSolve() {
            let A = Matrix([[0, 2, 4],
                            [4, 2, 1],
                            [-1, 0, -1]])
            let b = Matrix(vector: [-1, 1, 3], type: .column)
            let result = try! solve(A: A, b: b)
            let expectedResult = Matrix(vector: [-1, 3.5, -2], type: .column)
            XCTAssertEqual(result, expectedResult)
        }
        func testMatrixLUSolveUnsuccessful() {
            let A = Matrix([[0, 2, 4],
                            [0, 4, 8],
                            [-1, 0, -1]])
            let b = Matrix(vector: [-1, 1, 3], type: .column)
            let check: Bool
            do {
                _ = try solve(A: A, b: b)
                check = false
            } catch LinearAlgebraError.singularMatrix {
                check = true
            } catch {
                check = false
            }
            XCTAssertTrue(check)
        }
        func testMatrixLUInvert() {
            let A = Matrix([[1, 2, 3],
                            [3, 2, 1],
                            [-1, 0, -1]])
            let result = try! invert(A: A)
            let expectedResult = Matrix([[-0.25, 0.25, -0.5], [0.25, 0.25, 1], [0.25, -0.25, -0.5]])
            let tolerance = 1e-12
            var correct = true
            for i in 0..<result.shape.nRows {
                for j in 0..<result.shape.nCols {
                    if abs(result[i,j] - expectedResult[i,j]) > tolerance {
                        correct = false
                    }
                }
            }
            XCTAssertTrue(correct)
        }
    }

    final class SwiftLinearAlgebraLieGroupTests: XCTestCase {
        func testLieGroupSO3SkewSymmetricMatrix() {
            let a = Matrix(vector: [1,2,3], type: .column)
            let S = skewSymmetric(vector: a)
            let expectedResult = Matrix([[0,-3,2],
                                         [3,0,-1],
                                         [-2,1,0]])
            XCTAssertEqual(S, expectedResult)
        }
        func testLieGroupSO3MatrixExponential() {
            let t = 0.3
            var o = Matrix(vector: [3,4,5], type: .column)
            o /= norm(vector: o)
            let result = matrixExp(matrix: skewSymmetric(vector: t*o))
            let expectedResult = Matrix([[0.963375921082997, -0.19824509949802857, 0.1805705269486247],
                                         [0.21968358471773775, 0.969628812605412, -0.1075132009149723],
                                         [-0.15377242042398837, 0.14324400961448747, 0.9776682445628029]])
            let tolerance = 1e-12
            var correct = true
            for i in 0..<result.shape.nRows {
                for j in 0..<result.shape.nCols {
                    if abs(result[i,j] - expectedResult[i,j]) > tolerance {
                        correct = false
                    }
                }
            }
            XCTAssertTrue(correct)
        }
        func testLieGroupSO3MatrixLogartihm() {
            let t = 0.3
            var o = Matrix(vector: [3,4,5], type: .column)
            o /= norm(vector: o)
            let expectedResult = t * o
            let exp = matrixExp(matrix: skewSymmetric(vector: expectedResult))
            let log = matrixLog(matrix: exp)
            let result = rotationVector(from: log)
            let tolerance = 1e-12
            var correct = true
            for i in 0..<result.shape.nRows {
                for j in 0..<result.shape.nCols {
                    if abs(result[i,j] - expectedResult[i,j]) > tolerance {
                        correct = false
                    }
                }
            }
            XCTAssertTrue(correct)
        }
    }
