import Foundation

public class Bipole: Identifiable {
    static var globalID: Int = 0
    
    public enum Pin {
        case pinA
        case pinB
    }

    public init(nodeA: Node? = nil, nodeB: Node? = nil) {
        
        self.id = Bipole.globalID
        Bipole.globalID += 1
        
        self.nodeA = nodeA ?? Node()
        self.nodeB = nodeB ?? Node()
        
        // willSet first init fix
        self.nodeA.connections.append((self, .pinA))
        self.nodeB.connections.append((self, .pinB))
    }

    public var nodeA: Node {
        willSet {
            // Remove old
            nodeA.connections.removeAll(where: { $0 == (self, .pinA) })

            // Add new
            newValue.connections.append((self, .pinA))
        }
    }

    public var nodeB: Node {
        willSet {
            // Remove old
            nodeB.connections.removeAll(where: { $0 == (self, .pinB) })

            // Add new
            newValue.connections.append((self, .pinB))
        }
    }
    
    public var current: Current?
    public var voltage: Voltage? {
        if let vA = nodeA.voltage,
           let vB = nodeB.voltage {
            return vA - vB
        }
        
        return nil
    }

    public var id: Int

    deinit {
        self.nodeA.connections.removeAll(where: { $0.0 == self })
        self.nodeB.connections.removeAll(where: { $0.0 == self })
        
        // Do not delete ID, no need to do it
    }
}

extension Bipole: Equatable {
    public static func == (_ lhs: Bipole, _ rhs: Bipole) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Bipole: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
