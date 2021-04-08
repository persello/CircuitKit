import XCTest
@testable import CircuitKit

final class ComplexTests: XCTestCase {
    
    func rand() -> Double {
        return Double.random(in: 0...100)
    }
    
    func testCoordinates() {
        measure {
            let x = rand()
            let y = rand()
            
            let a = Complex(real: x, imaginary: y)
            
            XCTAssertEqual(a.real , x)
            XCTAssertEqual(a.imaginary , y)
            XCTAssertEqual(a.modulus , (x * x + y * y).squareRoot())
            XCTAssertEqual(a.argument , atan2(y, x))
            XCTAssertEqual(a.conjugate.modulus , a.modulus)
            XCTAssertEqual(a.conjugate.argument , -(a.argument))
            XCTAssertEqual(a.conjugate.real , a.real)
            XCTAssertEqual(a.conjugate.imaginary , -(a.imaginary))
            XCTAssertEqual(a.conjugate.conjugate , a)
            
            let b = Complex(modulus: (x * x + y * y).squareRoot(), argument: atan2(y, x))
            XCTAssertEqual(b.real , x, accuracy: Double.approximationPrecision)
            XCTAssertEqual(b.imaginary , y, accuracy: Double.approximationPrecision)
        }
    }
    
    func testOperations() {
        measure {
            let x = Complex(real: rand(), imaginary: rand())
            let y = Complex(modulus: rand(), argument: rand())
            
            let k = rand()
            
            XCTAssertEqual(-x , .complexZero - x)
            
            XCTAssertEqual(x + y , Complex(real: x.real + y.real, imaginary: x.imaginary + y.imaginary))
            XCTAssertEqual(x - y , Complex(real: x.real - y.real, imaginary: x.imaginary - y.imaginary))
            XCTAssertEqual(x * y , Complex(modulus: x.modulus * y.modulus, argument: x.argument + y.argument))
            XCTAssertEqual(x / y , Complex(modulus: x.modulus / y.modulus, argument: x.argument - y.argument))
            XCTAssertEqual(x * k , Complex(modulus: x.modulus * k, argument: x.argument))
            XCTAssertEqual(x / k , Complex(modulus: x.modulus / k, argument: x.argument))
            
            XCTAssertEqual(x + y , y + x)
            XCTAssertEqual(x - y , -(y - x))
            XCTAssertEqual(x * y , y * x)
            XCTAssertEqual(x / y , 1 / (y / x))
            XCTAssertEqual(x * k , k * x)
            XCTAssertEqual(x / k , 1 / k * x)
            
            XCTAssertEqual(x + k, k + x)
            XCTAssertEqual(x - k, -(k - x))
        }
    }
    
    func testFromReal() {
        measure {
            let x = rand()
            let y = Int(rand())
            
            XCTAssertEqual(x.j, Complex(real: 0, imaginary: x))
            XCTAssertEqual(y.j, Complex(real: 0, imaginary: Double(y)))
        }
    }
    
    func testEqualToReal() {
        measure {
            let x = rand()
            XCTAssert(x == Complex(real: x, imaginary: 0))
            XCTAssert(Complex(real: x, imaginary: 0) == x)
        }
    }
    
    func testPower() {
        measure {
            let x = rand()
            let y = rand()
            let z = Int(rand()) % 10 + 1
            
            let c = Complex(real: x, imaginary: y)
            var res = c
            for _ in 0..<(z - 1) {
                res = res * c
            }
            
            XCTAssert((c^(Double(z)) - res).modulus / (c^Double(z)).modulus < 0.00000000000001)
        }
    }
    
    static var allTests = [
        ("Coordinate test", testCoordinates),
        ("Operations test", testOperations),
        ("Real to complex conversion test", testFromReal),
        ("Complex and real equality test", testEqualToReal),
        ("Power test", testPower)
    ]
}
