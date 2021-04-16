import Foundation

public final class Node: Identifiable {
    public init(_ name: String? = nil) {
        id = UUID()
        self.name = name
        connections = []
    }

    public var name: String?
    public var voltage: Voltage?
    public var connections: [(Bipole, Bipole.Pin)]
    public var id: UUID
    public var isGroundReference = false

    static var ground: Node {
        let node = Node("GND")
        node.voltage = Voltage(peak: 0.volts, phase: 0.radians, omega: 0.radiansPerSecond)
        node.isGroundReference = true
        return node
    }
    
    public static func + (_ lhs: Node, _ rhs: Node) -> Node {
        assert(lhs.name == rhs.name,
               "Nodes with different names can't be merged. This is a safety assertion to avoid errors. Please merge only nodes with the same names.")
        assert(lhs.voltage == rhs.voltage,
               "Nodes with different voltages can't be merged. This may mean that you are trying to modify a circuit after being solved.")
        assert(lhs.isGroundReference == rhs.isGroundReference, "Reference nodes can't be merged with other nodes.")
        
        let result = Node(lhs.name)
        result.connections.append(contentsOf: lhs.connections)
        result.connections.append(contentsOf: rhs.connections)
        result.voltage = lhs.voltage
        result.isGroundReference = lhs.isGroundReference
        
        for connection in result.connections {
            let bipole = connection.0
            if connection.1 == .pinA {
                bipole.nodeA = result
            } else {
                bipole.nodeB = result
            }
        }
            
        return result
    }
}

extension Node: Equatable {
    public static func == (_ lhs: Node, _ rhs: Node) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Node: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
