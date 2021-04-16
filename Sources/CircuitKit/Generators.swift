import Foundation

protocol Generator {
    
}

class IdealVoltageGenerator: Bipole, Generator {
    var fixedVoltage: Voltage
    
    init(voltage: Voltage, positiveTerminal: Pin = .pinA, nodeA: Node? = nil, nodeB: Node? = nil) {
        self.fixedVoltage = (positiveTerminal == .pinA) ? voltage : -voltage
        super.init(nodeA: nodeA, nodeB: nodeB)
    }
}

class IdealCurrentGenerator: Bipole, Generator {
    var fixedCurrent: Current
    
    init(current: Current, positiveTerminal: Pin = .pinA, nodeA: Node? = nil, nodeB: Node? = nil) {
        self.fixedCurrent = (positiveTerminal == .pinA) ? current : -current
        super.init(nodeA: nodeA, nodeB: nodeB)
    }
}
