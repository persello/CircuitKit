//
//  Matrix.swift
//  
//
//  Created by Riccardo Persello on 14/04/21.
//

import Foundation

// MARK: - Matrix
public final class Matrix<T>: CustomStringConvertible {
    
    // MARK: Properties
    // Rows of columns
    public var content: [[T?]] = [[]]
    
    // MARK:  Initializers
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
        for row in 0..<rows {
            for col in 0..<cols {
                let startingRow = maximumRowHeights.enumerated().reduce(0, { result, item in
                    if item.offset < row {
                        return result + (maximumRowHeights[item.offset])
                    }
                    
                    return result
                })
                
                let startingCol = maximumColWidths.enumerated().reduce(0, { result, item in
                    if item.offset < col {
                        return result + (maximumColWidths[item.offset])
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
        for row in 0..<input.size.0 {
            for col in 0..<input.size.1 {
                self[row + x, col + y] = input[row, col]
            }
        }
    }
    
    // MARK: Public
    public var size: (Int, Int) {
        // (rows, cols)
        return (content.count, content.map({$0.count}).max() ?? 0)
    }
    
    public func setItem(_ item: T, row: Int, col: Int) {
        content[row][col] = item
    }
    
    public var description: String {
        
        // Helper function for unwrapping any type, optional and not.
        func unwrap(any:Any) -> Any {
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
        
        for row in 0..<size.0 {
            for col in 0..<size.1 {
                let item = self[row, col]
                descMatrix[row][col] = String(describing: unwrap(any: item as Any))
                maxLen = max(maxLen, descMatrix[row][col].count)
            }
        }
        
        return descMatrix.map({ row in
            row.map({ item in
                return item.padding(toLength: maxLen, withPad: " ", startingAt: 0)
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
            if (0..<self.size.0).contains(row) {
                let r = content[row]
                if (0..<r.count).contains(column) {
                    return r[column]
                }
            }
            
            return nil
        }
        
        set {
            while row >= self.size.0 {
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
        for row in 0..<lhs.size.0 {
            for col in 0..<lhs.size.1 {
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
    
    public var realMatrixRepresentation: Matrix<Double?> {
        let submatrices = Matrix<Matrix<Double?>>()
        submatrices.content = [[getRealPart(), -getImaginaryPart()], [getImaginaryPart(), getRealPart()]]
        
        return Matrix<Double?>(fromMatrixOfMatrices: submatrices)
    }
    
    public convenience init(fromRealMatrixRepresentation realMatrix: Matrix<Double?>) {
        assert(realMatrix.size.0.isMultiple(of: 2))
        assert(realMatrix.size.1.isMultiple(of: 2))
        
        self.init()
        let finalSize = (realMatrix.size.0 / 2, realMatrix.size.1 / 2)
        for row in 0..<finalSize.0 {
            for col in 0..<finalSize.1 {
                // Check real parts are equal
                assert(realMatrix[row, col] == realMatrix[row + finalSize.0, col + finalSize.1])
                
                // Check complex parts are opposite
                if realMatrix[row + finalSize.0, col] == nil || realMatrix[row, col + finalSize.1] == nil{
                    assert(realMatrix[row + finalSize.0, col] == realMatrix[row, col + finalSize.1])
                } else {
                    assert((realMatrix[row + finalSize.0, col])! == -(realMatrix[row, col + finalSize.1]!!))
                }
                
                let real: Double?? = realMatrix[row, col]
                let imaginary: Double?? = realMatrix[row + finalSize.0, col]

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
    public static prefix func - (_ rhs: Matrix<T>) -> Matrix<T> {
        let result = Matrix<T>()
        result.content = rhs.content.map({row in
            row.map({item in
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
