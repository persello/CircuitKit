import XCTest
@testable import CircuitKit

final class MatrixTests: XCTestCase {
        
    func rand() -> Double {
        return Double.random(in: 0...100)
    }

    func testComposition() {
        
        /*
         Compose  X = A | B
                      -----
                      C | D
         */
        
        let a = Matrix<Double?>()
        
        // Try to get a nonexistent item
        XCTAssertNil(a[3, 1] as Any?)
        
        // Set a nonexistent item
        a[3, 1] = 2
        XCTAssertEqual(a[3, 1], 2)
        
        let b = Matrix<Double?>() {
            [[1, 4, 5],
             [2, 1, 3],
             [4, 0, 4]]
        }
        
        let c = Matrix<Double?>()
        c[2, 1] = 4
        c[1, 1] = 3
        c[3, 2] = 6.3
        
        // Not setting D on purpose
        let submatrices = Matrix<Matrix<Double?>>()
        submatrices.content = [[a, b], [c]]
        
        let x = Matrix<Double?>(fromMatrixOfMatrices: submatrices)
    
        let solution = Matrix<Double?>() {
            [
                [nil, nil, nil, 1, 4, 5],
                [nil, nil, nil, 2, 1, 3],
                [nil, nil, nil, 4, 0, 4],
                [nil, 2, nil, nil, nil, nil],
                [nil, nil, nil, nil, nil, nil],
                [nil, 3, nil, nil, nil, nil],
                [nil, 4, nil, nil, nil, nil],
                [nil, nil, 6.3, nil, nil, nil]
            ]
        }
        
        XCTAssertEqual(x, solution)
    }
    
    func testComplexToReal() {
        let c = Matrix<Complex?>() {
            [
                [2.j + 4, 3.j, nil],
                [2.j, 6, -1.j - 3],
                [0, nil, 0]
            ]
        }
        
//        c.realMatrixRepresentation
    
    }

    static var allTests = [
        ("Matrix composition", testComposition),
        ("Complex to real matrix conversion", testComplexToReal)
    ]
}
