import Foundation
import simd

public class Circuit<Component: Bipole> {
    var nodes = Set<Node>()
    var components = Set<Component>()
}
