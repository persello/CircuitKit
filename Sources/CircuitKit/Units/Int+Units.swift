import Foundation

// MARK: - Units initializer from Int
extension Int {
    public var radians: Measurement<UnitAngle> {
        return Double(self).radians
    }
    
    public var degrees: Measurement<UnitAngle> {
        return Double(self).degrees
    }
    
    public var volts: Measurement<UnitElectricPotentialDifference> {
        return Double(self).volts
    }
    
    public var amperes: Measurement<UnitElectricCurrent> {
        return Double(self).amperes
    }
    
    public var ohms: Measurement<UnitElectricResistance> {
        return Double(self).ohms
    }
    
    public var henry: Measurement<UnitInductance> {
        return Double(self).henry
    }
    
    public var farads: Measurement<UnitCapacitance> {
        return Double(self).farads
    }
    
    public var hertz: Measurement<UnitFrequency> {
        return Double(self).hertz
    }
    
    public var radiansPerSecond: Measurement<UnitFrequency> {
        return Double(self).radiansPerSecond
    }
}
