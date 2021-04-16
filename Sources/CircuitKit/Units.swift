import Foundation

// MARK: - Extension for existing frequency unit
extension UnitFrequency {
    public static var radiansPerSecond = UnitFrequency(symbol: "rad/s", converter: UnitConverterLinear(coefficient: 2 * .pi))
}

// MARK: - Inductance and capacitance

public final class UnitInductance: Dimension {
    public static let henry = UnitInductance(symbol: "H", converter: UnitConverterLinear(coefficient: 1.0))
    public static let milliHenry = UnitInductance(symbol: "mH", converter: UnitConverterLinear(coefficient: 1.0e-3))
    public static let microHenry = UnitInductance(symbol: "µH", converter: UnitConverterLinear(coefficient: 1.0e-6))
    public static let nanoHenry = UnitInductance(symbol: "nH", converter: UnitConverterLinear(coefficient: 1.0e-9))

    public override class func baseUnit() -> UnitInductance {
        return UnitInductance.henry
    }
}

public final class UnitCapacitance: Dimension {
    public static let farad = UnitCapacitance(symbol: "F", converter: UnitConverterLinear(coefficient: 1.0))
    public static let milliFarad = UnitCapacitance(symbol: "mF", converter: UnitConverterLinear(coefficient: 1.0e-3))
    public static let microFarad = UnitCapacitance(symbol: "µF", converter: UnitConverterLinear(coefficient: 1.0e-6))
    public static let nanoFarad = UnitCapacitance(symbol: "nF", converter: UnitConverterLinear(coefficient: 1.0e-9))
    public static let picoFarad = UnitCapacitance(symbol: "pF", converter: UnitConverterLinear(coefficient: 1.0e-12))

    public override class func baseUnit() -> UnitCapacitance {
        return UnitCapacitance.farad
    }
}

// MARK: - Voltage and current

protocol Sinusoidal: CustomStringConvertible, Equatable {
    var omega: Measurement<UnitFrequency> { get set }
    var value: Complex { get set }

    associatedtype AssociatedUnit: Dimension
    static var displayUnit: AssociatedUnit { get set }
}

extension Sinusoidal {
    public static func - (_ lhs: Self, _ rhs: Self) -> Self {
        var result = lhs
        result.value = lhs.value - rhs.value
        return result
    }
    
    public static func + (_ lhs: Self, _ rhs: Self) -> Self {
        var result = lhs
        result.value = lhs.value + rhs.value
        return result
    }
    
    public static prefix func -(_ lhs: Self) -> Self {
        var result = lhs
        result.value = -lhs.value
        return result
    }
    
    public static func == (_ lhs: Self, _ rhs: Self) -> Bool {
        return (lhs.value == rhs.value && lhs.omega == rhs.omega)
    }

    var phase: Measurement<UnitAngle> {
        return Measurement<UnitAngle>(value: value.argument, unit: .radians)
    }

    var peak: Measurement<AssociatedUnit> {
        return Measurement<AssociatedUnit>(value: value.modulus, unit: Self.displayUnit)
    }

    var rms: Measurement<AssociatedUnit> {
        return Measurement<AssociatedUnit>(value: value.modulus / 2.squareRoot(), unit: Self.displayUnit)
    }
}

// CustomStringConvertible conformance
extension Sinusoidal {
    public var description: String {
        return "\(peak) peak @ \(omega.converted(to: .hertz)) with \(phase.converted(to: .degrees)) phase"
    }
}

public struct Voltage: Sinusoidal {
    public var omega: Measurement<UnitFrequency>
    public var value: Complex

    static var displayUnit: UnitElectricPotentialDifference = .volts
    public typealias AssociatedUnit = UnitElectricPotentialDifference

    public init(peak: Measurement<AssociatedUnit>, phase: Measurement<UnitAngle>, omega: Measurement<UnitFrequency>) {
        self.omega = omega
        value = Complex(modulus: peak.converted(to: Self.displayUnit).value, argument: phase.converted(to: .radians).value)
    }

    public init(rms: Measurement<AssociatedUnit>, phase: Measurement<UnitAngle>, omega: Measurement<UnitFrequency>) {
        self.omega = omega
        value = Complex(modulus: rms.converted(to: Self.displayUnit).value * 2.squareRoot(), argument: phase.converted(to: .radians).value)
    }

    public init(omega: Measurement<UnitFrequency>, value: Complex) {
        self.omega = omega
        self.value = value
    }
}

public struct Current: Sinusoidal {
    public var omega: Measurement<UnitFrequency>
    public var value: Complex

    static var displayUnit: UnitElectricCurrent = .amperes
    public typealias AssociatedUnit = UnitElectricCurrent

    public init(peak: Measurement<AssociatedUnit>, phase: Measurement<UnitAngle>, omega: Measurement<UnitFrequency>) {
        self.omega = omega
        value = Complex(modulus: peak.converted(to: Self.displayUnit).value, argument: phase.converted(to: .radians).value)
    }

    public init(rms: Measurement<AssociatedUnit>, phase: Measurement<UnitAngle>, omega: Measurement<UnitFrequency>) {
        self.omega = omega
        value = Complex(modulus: rms.converted(to: Self.displayUnit).value * 2.squareRoot(), argument: phase.converted(to: .radians).value)
    }

    public init(omega: Measurement<UnitFrequency>, value: Complex) {
        self.omega = omega
        self.value = value
    }
}

// MARK: -  Impedance and admittance

public protocol SupportsSeriesAndParallels {
    var value: Complex { get }
    static func fromSeries(of items: [SupportsSeriesAndParallels]) -> Self
    static func fromParallel(of items: [SupportsSeriesAndParallels]) -> Self
}

public struct Impedance: SupportsSeriesAndParallels, CustomStringConvertible {
    public init(value: Complex) {
        self.value = value
    }

    public var value: Complex

    public static func fromSeries(of items: [SupportsSeriesAndParallels]) -> Impedance {
        let totalImpedanceValue: Complex = items.map({ item -> Complex in
            if let admittance = item as? Admittance {
                return admittance.asImpedance().value
            } else if let impedance = item as? Impedance {
                return impedance.value
            } else {
                print("You have defined a new serial/parallel unit without implementing its conversion!")
                return .zero
            }
        })
            .reduce(.zero, { x, y in
                x + y
            })

        return Impedance(value: totalImpedanceValue)
    }

    public static func fromParallel(of items: [SupportsSeriesAndParallels]) -> Impedance {
        let totalImpedanceValueInverse: Complex = items.map({ item -> Complex in
            if let admittance = item as? Admittance {
                return admittance.asImpedance().value
            } else if let impedance = item as? Impedance {
                return impedance.value
            } else {
                print("You have defined a new serial/parallel unit without implementing its conversion!")
                return .zero
            }
        })
            .reduce(.zero, { x, y in
                if x == 0 {
                    return y
                } else if y == 0 {
                    return x
                } else {
                    return (1 / x) + (1 / y)
                }
            })

        return Impedance(value: 1 / totalImpedanceValueInverse)
    }

    public func asAdmittance() -> Admittance {
        return Admittance(value: 1 / value)
    }

    // CustomStringConvertible conformance
    public var description: String {
        return "\(value.description)Ω"
    }
}

public struct Admittance: SupportsSeriesAndParallels, CustomStringConvertible {
    public init(value: Complex) {
        self.value = value
    }

    public var value: Complex

    public static func fromSeries(of items: [SupportsSeriesAndParallels]) -> Admittance {
        Impedance.fromSeries(of: items).asAdmittance()
    }

    public static func fromParallel(of items: [SupportsSeriesAndParallels]) -> Admittance {
        Impedance.fromParallel(of: items).asAdmittance()
    }

    public func asImpedance() -> Impedance {
        return Impedance(value: 1 / value)
    }

    // CustomStringConvertible conformance
    public var description: String {
        return "\(value.description)S"
    }
}

// MARK: - Operations between units

// V = I * Z
// V = Z * I

// Y = I / V
// V = I / Y
extension Current {
    public static func * (_ lhs: Current, _ rhs: Impedance) -> Voltage {
        return Voltage(omega: lhs.omega, value: lhs.value * rhs.value)
    }

    public static func * (_ lhs: Impedance, _ rhs: Current) -> Voltage {
        return rhs * lhs
    }

    public static func / (_ lhs: Current, _ rhs: Voltage) -> Admittance {
        return Admittance(value: lhs.value / rhs.value)
    }

    public static func / (_ lhs: Current, _ rhs: Admittance) -> Voltage {
        return Voltage(omega: lhs.omega, value: lhs.value / rhs.value)
    }
}

// I = V * Y
// I = Y * V

// Z = V / I
// I = V / Z
extension Voltage {
    public static func * (_ lhs: Voltage, _ rhs: Admittance) -> Current {
        return Current(omega: lhs.omega, value: lhs.value * rhs.value)
    }

    public static func * (_ lhs: Admittance, _ rhs: Voltage) -> Current {
        return rhs * lhs
    }

    public static func / (_ lhs: Voltage, _ rhs: Current) -> Impedance {
        return Impedance(value: lhs.value / rhs.value)
    }

    public static func / (_ lhs: Voltage, _ rhs: Impedance) -> Current {
        return Current(omega: lhs.omega, value: lhs.value / rhs.value)
    }
}

// MARK: - Units initializer from Double
extension Double {
    public var radians: Measurement<UnitAngle> {
        return Measurement<UnitAngle>(value: self, unit: .radians)
    }
    
    public var degrees: Measurement<UnitAngle> {
        return Measurement<UnitAngle>(value: self, unit: .degrees)
    }
    
    public var volts: Measurement<UnitElectricPotentialDifference> {
        return Measurement<UnitElectricPotentialDifference>(value: self, unit: .volts)
    }
    
    public var amperes: Measurement<UnitElectricCurrent> {
        return Measurement<UnitElectricCurrent>(value: self, unit: .amperes)
    }
    
    public var ohms: Measurement<UnitElectricResistance> {
        return Measurement<UnitElectricResistance>(value: self, unit: .ohms)
    }
    
    public var henry: Measurement<UnitInductance> {
        return Measurement<UnitInductance>(value: self, unit: .henry)
    }
    
    public var farads: Measurement<UnitCapacitance> {
        return Measurement<UnitCapacitance>(value: self, unit: .farad)
    }
    
    public var hertz: Measurement<UnitFrequency> {
        return Measurement<UnitFrequency>(value: self, unit: .hertz)
    }
    
    public var radiansPerSecond: Measurement<UnitFrequency> {
        return Measurement<UnitFrequency>(value: self, unit: .radiansPerSecond)
    }
}
