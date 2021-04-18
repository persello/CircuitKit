import Foundation

public class Circuit {
    var nodes = Set<Node>()
    var groundNode: Node?
    var components = Set<Bipole>()
    
    public init(autoDiscoverFromNode node: Node) {
        autoDiscover(startingNode: node)
    }

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
            if !components.contains(connection.0) {
                addNode(otherSide)
                addComponent(connection.0)
                autoDiscover(startingNode: otherSide)
            }
        }

        assert(groundNode != nil, "The specified circuit does not have a reference ground node. A ground node is necessary.")
    }

    internal func buildGMatrix(omega: Measurement<UnitFrequency>) -> Matrix<Complex?> {
        let g = Matrix<Complex?>()

        for node1 in nodes.sorted(by: { $0.id > $1.id }).enumerated() {
            for node2 in nodes.sorted(by: { $0.id > $1.id }).enumerated() {
                g[node1.offset, node2.offset] = findComponentsBetween(node1.element, node2.element).reduce(Complex.zero, { result, component in

                    if let component = component as? ComponentWithComputableImpedance {
                        return result + component.impedance(omega).asAdmittance().value
                    }

                    return result
                })

                // Invert everything outside diagonal
                g[node1.offset, node2.offset] = ((g[node1.offset, node2.offset] ?? 0) ?? 0) * Double((node1.offset == node2.offset) ? 1 : -1)
            }
        }

        return g
    }

    internal func buildBMatrix() -> Matrix<Complex?> {
        let b = Matrix<Complex?>()

        for node in nodes.sorted(by: { $0.id > $1.id }).enumerated() {
            for generator in voltageSources.sorted(by: { $0.id > $1.id }).enumerated() {
                let value: Double!
                if node.element.connections.contains(where: { $0.0 == generator.element && $0.1 == .pinA }) {
                    value = 1.0
                } else if node.element.connections.contains(where: { $0.0 == generator.element && $0.1 == .pinB }) {
                    value = -1.0
                } else {
                    value = 0.0
                }

                b[node.offset, generator.offset] = Optional(Complex(real: value, imaginary: 0))
            }
        }

        return b
    }

    internal func buildCMatrix(fromBMatrix b: Matrix<Complex?>? = nil) -> Matrix<Complex?> {
        if let b = b {
            return b.transposed
        }

        return buildBMatrix().transposed
    }

    internal func buildDMatrix() -> Matrix<Complex?> {
        return Matrix<Complex?>()
    }

    internal func buildAMatrix(omega: Measurement<UnitFrequency>) -> Matrix<Complex?> {
        let g = buildGMatrix(omega: omega)
        let b = buildBMatrix()
        let c = buildCMatrix(fromBMatrix: b)
        let d = buildDMatrix()
        let submatrices = Matrix<Matrix<Complex?>>() {
            [[g, b],
             [c, d]]
        }

        return Matrix<Complex?>(fromMatrixOfMatrices: submatrices)
    }

    internal func buildZVector() -> Matrix<Complex?> {
        let z = Matrix<Complex?>()

        for node in nodes.sorted(by: { $0.id > $1.id }).enumerated() {
            z[node.offset, 0] = node.element.connections.filter({ $0.0 is IdealCurrentGenerator }).reduce(Complex.zero, { result, item in
                result + (item.0 as! IdealCurrentGenerator).fixedCurrent.value
            })
        }

        for generator in voltageSources.sorted(by: { $0.id > $1.id }).enumerated() {
            z[nodes.count + generator.offset, 0] = generator.element.fixedVoltage.value
        }

        return z
    }

    public func solve() {
        assert(voltageSources.count + currentSources.count > 0,
               "You need at least one voltage or current generator in the circuit.")
        let omega: Measurement<UnitFrequency> = voltageSources.first?.fixedVoltage.omega ?? (currentSources.first?.fixedCurrent.omega)!
        assert(voltageSources.allSatisfy({ $0.fixedVoltage.omega == omega }),
               "All voltage and current sources must have the same frequency!")
        assert(currentSources.allSatisfy({ $0.fixedCurrent.omega == omega }),
               "All voltage and surrent sources must have the same frequency!")

        let a = buildAMatrix(omega: omega)
        let z = buildZVector()

        let solutionArray = Solver.solveSystem(coefficientMatrix: a, constantsVector: z)
        assert(solutionArray.count.isMultiple(of: 2), "The solution does not represent a complex array")

        var solution = [Complex](repeating: .zero, count: solutionArray.count / 2)
        for index in 0 ..< solution.count {
            solution[index] = Complex(real: solutionArray[index], imaginary: solutionArray[index + solution.count])
        }

        for node in nodes.sorted(by: { $0.id > $1.id }).enumerated() {
            node.element.voltage = Voltage(omega: omega, value: solution[node.offset])
        }

        for generator in voltageSources.sorted(by: { $0.id > $1.id }).enumerated() {
            generator.element.current = Current(omega: omega, value: solution[nodes.count + generator.offset])
        }

        for component in components.filter({ $0 is ComponentWithComputableImpedance }) {
            let impedance = (component as! ComponentWithComputableImpedance).impedance(omega)
            if let voltage = component.voltage {
                component.current = voltage / impedance
            }
        }
    }

    internal func findComponentsBetween(_ a: Node, _ b: Node) -> [Bipole] {
        if a == b {
            return a.connections.map({ $0.0 })
        } else {
            return a.connections.filter({ connection in
                let otherSide: Node = (connection.1 == .pinA) ? connection.0.nodeB : connection.0.nodeA
                return otherSide == b
            })
                .map({ $0.0 })
        }
    }

    internal func addComponent(_ component: Bipole) {
        components.insert(component)
    }

    internal func addNode(_ node: Node) {
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
