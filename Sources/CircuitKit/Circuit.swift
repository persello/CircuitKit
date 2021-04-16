import Foundation
import simd

public class Circuit<Component: Bipole> {
    var nodes = Set<Node>()
    var groundNode: Node?
    var components = Set<Component>()

    var voltageSources: [IdealVoltageGenerator] {
        return components.filter({ $0 is IdealVoltageGenerator }).map({ $0 as! IdealVoltageGenerator })
    }

    var currentSources: [IdealCurrentGenerator] {
        return components.filter({ $0 is IdealCurrentGenerator }).map({ $0 as! IdealCurrentGenerator })
    }

    public func autoDiscover(startingNode: Node) {
        addNode(startingNode)
        for connection in startingNode.connections {
            let otherSide: Node = (connection.1 == .pinA) ? connection.0.nodeB : connection.0.nodeA
            if !components.contains(connection.0 as! Component) {
                addNode(otherSide)
                addComponent(connection.0 as! Component)
                autoDiscover(startingNode: otherSide)
            }
        }
        
        assert(groundNode != nil, "The specified circuit does not have a reference ground node. A ground node is necessary.")
    }

    internal func buildGMatrix(omega: Measurement<UnitFrequency>) -> Matrix<Complex?> {
        let g = Matrix<Complex?>()

        for node1 in nodes.sorted(by: { $0.id.uuidString > $1.id.uuidString }).enumerated() {
            for node2 in nodes.sorted(by: { $0.id.uuidString > $1.id.uuidString }).enumerated() {
                g[node1.offset, node2.offset] = findComponentsBetween(node1.element, node2.element).reduce(Complex.zero, { result, component in
                    if let component = component as? ComponentWithComputableImpedance {
                        return result + component.impedance(omega).asAdmittance().value
                    }

                    return result
                })
            }
        }

        return g
    }

//    internal func buildBMatrix() -> Matrix<Complex?> {
//        for 
//    }
//
//    internal func buildCMatrix() -> Matrix<Complex?> {
//        // Transpose the B matrix since we have only independent voltage sources
//    }
//
//    internal func buildDMatrix() -> Matrix<Complex?> {
//        // All zeros, since we have only independent voltage sources
//    }
//
//    internal func buildAMatrix(omega: Measurement<UnitFrequency>) -> Matrix<Complex?> {
//
//    }
//
//    internal func buildZVector() -> Matrix<Complex?> {
//
//    }
//
//    internal func buildXVector() -> Matrix<Complex?> {
//
//    }

    func findComponentsBetween(_ a: Node, _ b: Node) -> [Component] {
        if a == b {
            return a.connections.map({ $0.0 as! Component })
        } else {
            return a.connections.filter({ connection in
                let otherSide: Node = (connection.1 == .pinA) ? connection.0.nodeB : connection.0.nodeA
                return otherSide == b
            })
                .map({ $0.0 as! Component })
        }
    }

    func addComponent(_ component: Component) {
        components.insert(component)
    }

    func addNode(_ node: Node) {
        // Set as reference node if ground
        if node.isGroundReference {
            // Merge all the ground nodes if necessary
            if groundNode != nil {
                groundNode = node + groundNode!
            } else {
                groundNode = node
            }
        } else {
            nodes.insert(node)
        }
    }
}
