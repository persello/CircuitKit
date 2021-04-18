import XCTest
@testable import CircuitKit

final class CircuitTests: XCTestCase {
    
    func testCircuit1() {
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
    }
    
    func testCircuit2() {
        let a = Node("A")
        let b = Node("B")
        let g = Node.ground
        
        let r1 = Resistor(resistance: 1000.ohms, between: a, and: g)
        let c = Capacitor(capacitance: 1e-6.farads, between: b, and: a)
        
        let e = IdealVoltageGenerator(voltage: Voltage(peak: 5.volts, phase: 0.degrees, omega: 1000.hertz), between: b, and: g)
        
        let circuit = Circuit()
        circuit.autoDiscover(startingNode: g)
        circuit.solve()
        
        XCTAssertEqual(r1.voltage?.value, e.fixedVoltage.value / (c.impedance(1000.hertz).value + r1.impedance(1000.hertz).value) * r1.impedance(1000.hertz).value)
    }

    func testCircuit3() {
        let a = Node("A")
        let g = Node.ground
        
        let c1 = Capacitor(capacitance: 0.1e-6.farads, between: a)
        let e = IdealVoltageGenerator(voltage: Voltage(rms: 12.volts, phase: 0.degrees, omega: 15000.hertz), between: c1.nodeB, and: g)
        
        let c2 = Capacitor(capacitance: 0.05e-6.farads, between: a, and: g)
        let c3 = Capacitor(capacitance: 0.22e-6.farads, between: a, and: g)
        
        let r1 = Resistor(resistance: 330.ohms, between: a)
        let r2 = Resistor(resistance: 180.ohms, between: r1.nodeB, and: g)

        let circuit = Circuit()
        circuit.autoDiscover(startingNode: g)
        circuit.solve()
        
        XCTAssertEqual((e.current?.rms.converted(to: .milliamperes).value)!, 82.7, accuracy: 0.1)
        XCTAssertEqual((c2.current?.rms.converted(to: .milliamperes).value)!, 15.3, accuracy: 0.1)
        XCTAssertEqual((c3.current?.rms.converted(to: .milliamperes).value)!, 67.3, accuracy: 0.1)
        XCTAssertEqual((r1.current?.rms.converted(to: .milliamperes).value)!, 6.37, accuracy: 0.01)
    }
    
    static var allTests = [
        ("Circuit test 1", testCircuit1),
        ("Circuit test 2", testCircuit2),
        ("Circuit test 3", testCircuit3)
    ]
}
