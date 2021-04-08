import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(CircuitKitTests.allTests),
        testCase(ComplexTests.allTests)
    ]
}
#endif
