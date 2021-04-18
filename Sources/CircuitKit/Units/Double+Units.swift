import Foundation

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
