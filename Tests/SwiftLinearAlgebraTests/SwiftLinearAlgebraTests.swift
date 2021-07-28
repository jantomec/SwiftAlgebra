    import XCTest
    @testable import SwiftLinearAlgebra

    final class SwiftLinearAlgebraTests: XCTestCase {
        func testMatrixInitSuccessful() {
            // This function tests if matrix is successfully constructed.
            let input: [[Int]] = [[1,2,3]]
            let output = try? Matrix(input)
            let referenceInput: [[Double]] = [[1,2,3]]
            let expectedOutput = try? Matrix(referenceInput)
            XCTAssertEqual(output, expectedOutput)
        }
        func testMatrixInitUnsuccessful() {
            // This function tests if matrix is successfully constructed.
            let input: [[Int]] = [[1,2,3], [1,2]]
            let output = try? Matrix(input)
            XCTAssertEqual(output, nil)
        }
    }
