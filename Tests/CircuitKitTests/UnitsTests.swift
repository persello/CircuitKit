import XCTest
@testable import CircuitKit

final class UnitsTests: XCTestCase {
        
    func rand() -> Double {
        return Double.random(in: 0...100)
    }

    func testOperations() {
//        let x = rand()
//        let y = rand()
        let omega = rand().hertz
        
        let c: Double = rand() / 1_000_000
//        let l: Double = rand() / 1_000
        
        
//        let v0 = Voltage(rms: x.volts, phase: y.radians, omega: omega)
        let c0 = Capacitor(capacitance: c.farads)
        
        XCTAssertEqual(c0.impedance(omega).value, 1/(1.j * omega.converted(to: .radiansPerSecond).value * c.farads.value))
        
//        let i0 = v0 / c0.impedance
    }

    static var allTests = [
        ("Operations test", testOperations),
    ]
}
