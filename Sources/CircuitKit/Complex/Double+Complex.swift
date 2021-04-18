import Foundation

// MARK: - Double extension for approximation and imaginary unit generation
infix operator ≈≈: ComparisonPrecedence

extension Double {
    
    // (Empyrically found): Best achievable precision in Complex operations
    static let approximationPrecision = 0.00000000001
    
    public var j: Complex {
        return Complex(real: 0, imaginary: self)
    }
    
    public static func ≈≈ (_ lhs: Double, _ rhs: Double) -> Bool {
        return abs(lhs - rhs) < approximationPrecision
    }
}
