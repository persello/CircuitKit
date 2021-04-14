import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(CircuitKitTests.allTests),
        testCase(UnitsTests.allTests),
        testCase(ComplexTests.allTests),
        testCase(CircuitTests.allTests)
    ]
}
#endif
