import Foundation

public final class Complex: AdditiveArithmetic, CustomStringConvertible, Equatable, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {
    
    // MARK: - Internal representation

    private var _real: Double?
    private var _imaginary: Double?
    private var _modulus: Double?
    private var _argument: Double?

    private func updateRectangularCoordinates() {
        if let mod = _modulus,
           let arg = _argument {
            _real = mod * cos(arg)
            _imaginary = mod * sin(arg)
        } else {
            _real = 0
            _imaginary = 0
        }
    }

    private func updatePolarCoordinates() {
        if let real = _real,
           let imag = _imaginary {
            _modulus = sqrt(real * real + imag * imag)
            _argument = atan2(imag, real)
        } else {
            _modulus = 0
            _argument = 0
        }
    }

    // MARK: - Public properties

    // Rectangular coordinates
    public var real: Double {
        if let real = _real {
            return real
        } else {
            updateRectangularCoordinates()
            return self.real
        }
    }

    public var imaginary: Double {
        if let imaginary = _imaginary {
            return imaginary
        } else {
            updateRectangularCoordinates()
            return self.imaginary
        }
    }

    // Polar coordinates
    public var modulus: Double {
        if let modulus = _modulus {
            return modulus
        } else {
            updatePolarCoordinates()
            return self.modulus
        }
    }

    public var argument: Double {
        if let argument = _argument {
            return argument
        } else {
            updatePolarCoordinates()
            return self.argument
        }
    }

    // MARK: - Initializers

    public init(real: Double, imaginary: Double) {
        _real = real
        _imaginary = imaginary
    }

    public init(modulus: Double, argument: Double) {
        var _mod = modulus
        var _arg = argument

        if modulus < 0 {
            _mod = -modulus
            _arg = argument + .pi
        }

        if abs(_arg) > .pi {
            _arg = fmod(_arg + .pi, 2 * .pi)

            if _arg < 0 {
                _arg += 2 * .pi
            }

            _arg = _arg - .pi
        }

        _modulus = _mod
        _argument = _arg
    }

    // MARK: - Operations

    // Addition
    public static func + (_ lhs: Complex, _ rhs: Complex) -> Complex {
        return Complex(real: lhs.real + rhs.real, imaginary: lhs.imaginary + rhs.imaginary)
    }

    public static func + (_ lhs: Double, _ rhs: Complex) -> Complex {
        return Complex(real: lhs, imaginary: 0) + rhs
    }

    public static func + (_ lhs: Complex, _ rhs: Double) -> Complex {
        return rhs + lhs
    }

    // Inversion
    public static prefix func - (_ c: Complex) -> Complex {
        // Do not change representation type.
        if let mod = c._modulus,
           let arg = c._argument {
            return Complex(modulus: -mod, argument: arg)
        } else if let real = c._real,
                  let imag = c._imaginary {
            return Complex(real: -real, imaginary: -imag)
        } else {
            return Complex(real: 0, imaginary: 0)
        }
    }

    // Subtraction
    public static func - (_ lhs: Complex, _ rhs: Complex) -> Complex {
        return lhs + (-rhs)
    }

    public static func - (_ lhs: Double, _ rhs: Complex) -> Complex {
        return lhs + (-rhs)
    }

    public static func - (_ lhs: Complex, _ rhs: Double) -> Complex {
        return lhs + (-rhs)
    }

    // Multiplication
    public static func * (_ lhs: Complex, _ rhs: Complex) -> Complex {
        return Complex(modulus: lhs.modulus * rhs.modulus, argument: lhs.argument + rhs.argument)
    }

    public static func * (_ lhs: Double, _ rhs: Complex) -> Complex {
        return Complex(modulus: lhs * rhs.modulus, argument: rhs.argument)
    }

    public static func * (_ lhs: Complex, _ rhs: Double) -> Complex {
        return Complex(modulus: lhs.modulus * rhs, argument: lhs.argument)
    }

    // Division
    public static func / (_ lhs: Complex, _ rhs: Complex) -> Complex {
        return Complex(modulus: lhs.modulus / rhs.modulus, argument: lhs.argument - rhs.argument)
    }

    public static func / (_ lhs: Double, _ rhs: Complex) -> Complex {
        return Complex(modulus: lhs / rhs.modulus, argument: -rhs.argument)
    }

    public static func / (_ lhs: Complex, _ rhs: Double) -> Complex {
        return Complex(modulus: lhs.modulus / rhs, argument: lhs.argument)
    }

    // Power with real exponent
    public static func ^ (_ lhs: Complex, _ rhs: Double) -> Complex {
        return Complex(modulus: pow(lhs.modulus, rhs), argument: lhs.argument * rhs)
    }

    // Conjugate
    public var conjugate: Complex {
        return Complex(real: real, imaginary: -imaginary)
    }

    // MARK: - Protocol conformance

    // Equatable
    public static func == (_ lhs: Complex, _ rhs: Complex) -> Bool {
        return (lhs.real ≈≈ rhs.real && lhs.imaginary ≈≈ rhs.imaginary) || (lhs.modulus ≈≈ rhs.modulus && lhs.argument ≈≈ rhs.argument)
    }

    public static func == (_ lhs: Double, _ rhs: Complex) -> Bool {
        return Complex(real: lhs, imaginary: 0) == rhs
    }

    public static func == (_ lhs: Complex, _ rhs: Double) -> Bool {
        return lhs == Complex(real: rhs, imaginary: 0)
    }

    // CustomStringConvertible
    public var description: String {
        return "\(String(format: "%.4f", real))\(imaginary >= 0 ? "+" : "-")\(String(format: "%.4f", abs(imaginary)))j"
    }

    // MARK: - Constants

    public static let j = Complex(real: 0, imaginary: 1)
    public static let zero = Complex(real: 0, imaginary: 0)
    
    // MARK: - Expressible by literal conformance
    public convenience init(integerLiteral value: Int) {
        self.init(real: Double(value), imaginary: 0)
    }
    
    public convenience init(floatLiteral value: Double) {
        self.init(real: value, imaginary: 0)
    }
}


// MARK: - Other types extensions
infix operator ≈≈: ComparisonPrecedence

extension Double {
    static let approximationPrecision = 0.00000000001
    
    public var j: Complex {
        return Complex(real: 0, imaginary: self)
    }
    
    public static func ≈≈ (_ lhs: Double, _ rhs: Double) -> Bool {
        return abs(lhs - rhs) < approximationPrecision
    }
}

extension Int {
    public var j: Complex {
        return Complex(real: 0, imaginary: Double(self))
    }
}
