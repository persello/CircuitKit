import XCTest

import CircuitKitTests

var tests = [XCTestCaseEntry]()
tests += CircuitTests.allTests()
tests += ComplexTests.allTests()
tests += MatrixTests.allTests()
tests += UnitsTests.allTests()
XCTMain(tests)
