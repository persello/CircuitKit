import Foundation

// MARK: - Extend Int to have an imaginary unit generator
extension Int {
    public var j: Complex {
        return Complex(real: 0, imaginary: Double(self))
    }
}
