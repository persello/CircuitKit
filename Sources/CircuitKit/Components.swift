import Foundation

// TODO: Implement multiplication and division with this type with automatic frequency capture.
public typealias ComputableImpedance = (Measurement<UnitFrequency>) -> Impedance

// MARK: - Protocol

protocol LinearComponent {
    var impedance: ComputableImpedance { get }
}

// MARK: - Passive components

public final class Resistor: Bipole, LinearComponent {
    
    public init(resistance: Measurement<UnitElectricResistance>, between nodeA: Node? = nil, and nodeB: Node? = nil) {
        self.resistance = resistance
        self.impedance = { _ in
            Impedance(value: Complex(real: resistance.converted(to: .ohms).value, imaginary: 0))
        }
        
        super.init(nodeA: nodeA, nodeB: nodeB)
    }
    
    public var resistance: Measurement<UnitElectricResistance>
    public var impedance: (Measurement<UnitFrequency>) -> Impedance
}

public final class Capacitor: Bipole, LinearComponent {
    public init(capacitance: Measurement<UnitCapacitance>, between nodeA: Node? = nil, and nodeB: Node? = nil) {
        self.capacitance = capacitance
        self.impedance = { omega in
            let value = 1 / (1.0.j * omega.converted(to: .radiansPerSecond).value * capacitance.converted(to: .farad).value)
            return Impedance(value: value)
        }
        
        super.init(nodeA: nodeA, nodeB: nodeB)
    }

    public var capacitance: Measurement<UnitCapacitance>
    public var impedance: (Measurement<UnitFrequency>) -> Impedance
}

public final class Inductor: Bipole, LinearComponent {
    public init(inductance: Measurement<UnitInductance>, between nodeA: Node? = nil, and nodeB: Node? = nil) {
        self.inductance = inductance

        self.impedance = { omega in
            let value = (1.0.j * omega.converted(to: .radiansPerSecond).value * inductance.converted(to: .henry).value)
            return Impedance(value: value)
        }
        
        super.init(nodeA: nodeA, nodeB: nodeB)
    }

    public var inductance: Measurement<UnitInductance>
    public var impedance: (Measurement<UnitFrequency>) -> Impedance
}

// MARK: - Operations with computable impedance
// V = I * Z
// V = Z * I
extension Current {
    public static func * (_ lhs: Current, _ rhs: ComputableImpedance) -> Voltage {
        return lhs * rhs(lhs.omega)
    }

    public static func * (_ lhs: ComputableImpedance, _ rhs: Current) -> Voltage {
        return rhs * lhs
    }
}

// I = V / Z
extension Voltage {
    public static func / (_ lhs: Voltage, _ rhs: ComputableImpedance) -> Current {
        lhs / rhs(lhs.omega)
    }
}
