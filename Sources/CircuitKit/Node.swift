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

    static var ground: Node {
        let node = Node("GND")
        node.voltage = Voltage(peak: 0.volts, phase: 0.radians, omega: 0.radiansPerSecond)
        return node
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
