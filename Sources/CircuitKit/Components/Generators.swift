import Foundation

protocol Generator {
    
}

public class IdealVoltageGenerator: Bipole, Generator {
    public var fixedVoltage: Voltage
    
    public init(voltage: Voltage, positiveTerminal: Pin = .pinA, between nodeA: Node? = nil, and nodeB: Node? = nil) {
        self.fixedVoltage = (positiveTerminal == .pinA) ? voltage : -voltage
        super.init(nodeA: nodeA, nodeB: nodeB)
    }
}

public class IdealCurrentGenerator: Bipole, Generator {
    public var fixedCurrent: Current
    
    public init(current: Current, positiveTerminal: Pin = .pinA, between nodeA: Node? = nil, and nodeB: Node? = nil) {
        self.fixedCurrent = (positiveTerminal == .pinA) ? current : -current
        super.init(nodeA: nodeA, nodeB: nodeB)
    }
}
