//
//  Matrix.swift
//
//
//  Created by Riccardo Persello on 14/04/21.
//

import Foundation
import Accelerate

// MARK: - Matrix

public final class Matrix<T>: CustomStringConvertible {
    // MARK: Properties

    // Rows of columns
    public var content: [[T?]] = [[]]

    // MARK: Initializers

    public convenience init(fromArray array: () -> [[T?]]) {
        self.init()
        content = array()
    }

    public convenience init(fromMatrixOfMatrices matrix: Matrix<Matrix<T>>) {
        self.init()

        // Get sizes matrix
        let sizes: [[(Int, Int)]] = matrix.content.map({ row in
            row.map({ item in
                item?.size ?? (0, 0)
            })
        })

        // Compute maximum sizes
        let (rows, cols) = matrix.size
        var maximumRowHeights = [Int](repeating: 0, count: matrix.size.0)
        var maximumColWidths = [Int](repeating: 0, count: matrix.size.1)
        _ = sizes.enumerated().map({ row in
            row.element.enumerated().map({ item in
                maximumColWidths[item.offset] = max(maximumColWidths[item.offset], item.element.1)
                maximumRowHeights[row.offset] = max(maximumRowHeights[row.offset], item.element.0)
            })
        })

        // Copy each matrix at the right location
        for row in 0 ..< rows {
            for col in 0 ..< cols {
                let startingRow = maximumRowHeights.enumerated().reduce(0, { result, item in
                    if item.offset < row {
                        return result + maximumRowHeights[item.offset]
                    }

                    return result
                })

                let startingCol = maximumColWidths.enumerated().reduce(0, { result, item in
                    if item.offset < col {
                        return result + maximumColWidths[item.offset]
                    }

                    return result
                })

                if let submatrix = matrix[row, col] {
                    copyMatrixIntoContent(submatrix, x: startingRow, y: startingCol)
                }
            }
        }
    }

    // MARK: Private

    func copyMatrixIntoContent(_ input: Matrix<T>, x: Int, y: Int) {
        for row in 0 ..< input.size.0 {
            for col in 0 ..< input.size.1 {
                self[row + x, col + y] = input[row, col]
            }
        }
    }

    // MARK: Public

    public var transposed: Matrix<T> {
        let result = Matrix<T>()
        let (rows, cols) = self.size
        for row in 0..<rows {
            for col in 0..<cols {
                result[col, row] = self[row, col]
            }
        }
        
        return result
    }

    public var size: (Int, Int) {
        // (rows, cols)
        return (content.count, content.map({ $0.count }).max() ?? 0)
    }

    public func setItem(_ item: T, row: Int, col: Int) {
        content[row][col] = item
    }

    public var description: String {
        // Helper function for unwrapping any type, optional and not.
        func unwrap(any: Any) -> Any {
            let mi = Mirror(reflecting: any)
            if mi.displayStyle != .optional {
                return any
            }

            if mi.children.count == 0 { return NSNull() }
            let (_, some) = mi.children.first!
            return some
        }

        var maxLen = 0
        var descMatrix = [[String]](repeating: [String](repeating: "-", count: size.1), count: size.0)

        for row in 0 ..< size.0 {
            for col in 0 ..< size.1 {
                let item = self[row, col]
                descMatrix[row][col] = String(describing: unwrap(any: unwrap(any: item as Any)))
                maxLen = max(maxLen, descMatrix[row][col].count)
            }
        }

        return descMatrix.map({ row in
            row.map({ item in
                item.padding(toLength: maxLen + 1, withPad: " ", startingAt: 0)
            })
        })
            .reduce("", { res, item in
                res + item.reduce("", { res, item in
                    res + item + " "
                }) + "\n"
            })
    }

    // MARK: Subscript

    subscript(row: Int, column: Int) -> T? {
        get {
            if (0 ..< size.0).contains(row) {
                let r = content[row]
                if (0 ..< r.count).contains(column) {
                    return r[column]
                }
            }

            return nil
        }

        set {
            while row >= size.0 {
                content.append([])
            }

            while column >= content[row].count {
                content[row].append(nil)
            }

            content[row][column] = newValue
        }
    }
}

// MARK: - Equatable matrix

extension Matrix: Equatable where T: Equatable {
    public static func == (_ lhs: Matrix<T>, _ rhs: Matrix<T>) -> Bool {
        if lhs.size != rhs.size { return false }
        for row in 0 ..< lhs.size.0 {
            for col in 0 ..< lhs.size.1 {
                if lhs[row, col] != rhs[row, col] {
                    return false
                }
            }
        }

        return true
    }
}

// MARK: - Complex matrix

extension Matrix where T == Complex? {
    func getRealPart() -> Matrix<Double?> {
        let result = Matrix<Double?>()
        result.content = content.map({ row in
            row.map({ item in
                item??.real
            })
        })

        return result
    }

    func getImaginaryPart() -> Matrix<Double?> {
        let result = Matrix<Double?>()
        result.content = content.map({ row in
            row.map({ item in
                item??.imaginary
            })
        })

        return result
    }
    
    public var hermitianColumnVector: Matrix<Double?> {
        assert(size.1 == 1, "Not a column vector.")
        
        let submatrices = Matrix<Matrix<Double?>>()
        submatrices.content = [[getRealPart()], [getImaginaryPart()]]
        return Matrix<Double?>(fromMatrixOfMatrices: submatrices)
    }

    public var hermitianMatrix: Matrix<Double?> {
        let submatrices = Matrix<Matrix<Double?>>()
        submatrices.content = [[getRealPart(), -getImaginaryPart()], [getImaginaryPart(), getRealPart()]]

        return Matrix<Double?>(fromMatrixOfMatrices: submatrices)
    }

    public convenience init(fromHermitianMatrix h: Matrix<Double?>) {
        assert(h.size.0.isMultiple(of: 2), "The supplied matrix has \(h.size.0) rows, which is odd.")
        assert(h.size.1.isMultiple(of: 2), "The supplied matrix has \(h.size.1) columns, which is odd.")

        self.init()
        let finalSize = (h.size.0 / 2, h.size.1 / 2)
        for row in 0 ..< finalSize.0 {
            for col in 0 ..< finalSize.1 {
                // Check real parts are equal
                assert(h[row, col] == h[row + finalSize.0, col + finalSize.1],
                       """
                       The specified real matrix is not a valid hermitian representation for a complex matrix.
                       The upper-left part and the bottom-right part are different.
                       Please supply a block matrix in this format:

                                          |
                                    Re(C) | -Im(C)
                                   -------|--------
                                    Im(C) |  Re(C)
                                          |

                       Where C is the complex matrix you want to build.
                       """)

                // Check complex parts are opposite
                let complexPartErrorString = """
                The specified real matrix is not a valid hermitian representation for a complex matrix.
                The bottom-left part and the upper-right part are not opposite.
                Please supply a block matrix in this format:

                                   |
                             Re(C) | -Im(C)
                            -------|--------
                             Im(C) |  Re(C)
                                   |

                Where C is the complex matrix you want to build.
                """

                if h[row + finalSize.0, col] == nil || h[row, col + finalSize.1] == nil {
                    assert(h[row + finalSize.0, col] == h[row, col + finalSize.1], complexPartErrorString)
                } else {
                    assert((h[row + finalSize.0, col])! == -(h[row, col + finalSize.1]!!), complexPartErrorString)
                }

                let real: Double?? = h[row, col]
                let imaginary: Double?? = h[row + finalSize.0, col]

                if real == nil && imaginary == nil {
                    self[row, col] = nil
                } else {
                    self[row, col] = Complex(real: (real ?? 0) ?? 0, imaginary: (imaginary ?? 0) ?? 0)
                }
            }
        }
    }
}

extension Matrix where T == Optional<Double> {
    
    public var asSparseMatrix: SparseMatrix_Double {
        
        // Build the sparse matrix with coordinates
        var rows: [Int32] = []
        var columns: [Int32] = []
        var values: [Double] = []
        
        for row in 0..<size.0 {
            for col in 0..<size.1 {
                if let val = self[row, col] {
                    guard val != nil else { continue }
                    rows.append(Int32(row))
                    columns.append(Int32(col))
                    values.append(val!)
                }
            }
        }

        var attributes = SparseAttributes_t()
        attributes.kind = SparseOrdinary
        
        return SparseConvertFromCoordinate(Int32(size.0), Int32(size.1), values.count, UInt8(1), attributes, &rows, &columns, &values)
    }
    
    public var asDoubleArray: [Double] {
        var result: [Double] = []
        let (rows, cols) = self.size
        for col in 0..<cols {
            for row in 0..<rows {
                result.append((self[row, col] ?? 0) ?? 0)
            }
        }
        
        return result
    }
    
    public static prefix func - (_ rhs: Matrix<T>) -> Matrix<T> {
        let result = Matrix<T>()
        result.content = rhs.content.map({ row in
            row.map({ item in
                if let i = item {
                    guard i != nil else { return nil }
                    return 0 - i!
                } else {
                    return nil
                }
            })
        })

        return result
    }
}
