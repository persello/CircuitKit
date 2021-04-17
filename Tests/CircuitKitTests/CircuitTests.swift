import XCTest
@testable import CircuitKit

final class CircuitTests: XCTestCase {
    
    func testCircuit() {
        let a = Node("A")
        let b = Node("B")
        let g = Node.ground
        
        let r1 = Resistor(resistance: 10.ohms, between: a, and: b)
        let r2 = Resistor(resistance: 10.ohms, between: b, and: g)
        
        let e0 = IdealVoltageGenerator(voltage: Voltage(peak: 50.volts, phase: 0.degrees, omega: 0.hertz),
                                       between: a, and: g)
        
        let circuit = Circuit()
        circuit.autoDiscover(startingNode: g)
        circuit.solve()
        
        XCTAssertEqual(g.voltage?.value, .zero)
        XCTAssertEqual(b.voltage?.value, e0.fixedVoltage.value/2)
        
        print(r1.voltage)
        
    }

    static var allTests = [
        ("Circuit test", testCircuit),
    ]
}
