import XCTest
@testable import CircuitKit

final class CircuitTests: XCTestCase {
    
    func testCircuit() {
        let a = Node("A")
        let b = Node("B")
        let c = Node("C")
        let d = Node.ground
        
        let c0 = Capacitor(capacitance: 0.0001.farads, between: a, and: b)
        let r0 = Resistor(resistance: 10.ohms, between: a, and: c)
        let l0 = Inductor(inductance: 0.1.henry, between: c, and: d)
        let r1 = Resistor(resistance: 12.ohms, between: b, and: d)
        
        let r2 = Resistor(resistance: 15.ohms, between: a, and: d)
        let r3 = Resistor(resistance: 15.ohms, between: b, and: c)
        
        let r4 = Resistor(resistance: 15.ohms, between: a, and: b)
        let r5 = Resistor(resistance: 15.ohms, between: a, and: c)
        
        let circuit = Circuit()
        circuit.autoDiscover(startingNode: d)
        
        XCTAssertEqual(circuit.nodes.count, 4)
        XCTAssertEqual(circuit.components.count, 8)
        
        print(circuit.buildGMatrix(omega: 0.hertz))
    }

    static var allTests = [
        ("Circuit test", testCircuit),
    ]
}
