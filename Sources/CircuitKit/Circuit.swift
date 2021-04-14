import Foundation
import simd

public class Circuit<Component: Bipole> {
    var nodes = Set<Node>()
    var components = Set<Component>()
    // var voltagesources = ...
        
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
    }
    
    func buildGMatrix() {
        
    }
    
    func findComponentsBetween(_ a: Node, _ b: Node) -> [Component] {
        return a.connections.filter({ connection in
            let otherSide: Node = (connection.1 == .pinA) ? connection.0.nodeB : connection.0.nodeA
            return otherSide == b
        })
        .map({$0.0 as! Component})
    }
    
    func addComponent(_ component: Component) {
        components.insert(component)
    }
    
    func addNode(_ node: Node) {
        nodes.insert(node)
    }
}
