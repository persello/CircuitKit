import Accelerate
import Foundation

public class Solver {
    public static func solveSystem(coefficientMatrix a: Matrix<Complex?>, constantsVector b: Matrix<Complex?>) -> [Double] {
        let matrixSize = a.size
        let vectorSize = b.size

        assert(matrixSize.0 == vectorSize.0, "Coefficient matrix and constants vector must have the same number of rows.")
        assert(vectorSize.1 == 1, "The constants vector should be a vector, that is a matrix with only one column.")

        let aSparseMatrix = a.hermitianMatrix.asSparseMatrix
        let factorization = SparseFactor(SparseFactorizationQR, aSparseMatrix)

        var bArray = b.hermitianColumnVector.asDoubleArray
        let bCount = bArray.count

        let nrhs = Int(aSparseMatrix.structure.columnCount)
        let byteCount = factorization.solveWorkspaceRequiredStatic + nrhs * factorization.solveWorkspaceRequiredPerRHS
        let workspace = UnsafeMutableRawPointer.allocate(byteCount: byteCount, alignment: MemoryLayout<Double>.alignment)

        /// Solve the system.
        let xValues = [Double](unsafeUninitializedCapacity: bCount) {
            buffer, count in
            bArray.withUnsafeMutableBufferPointer { bPtr in
                let B = DenseMatrix_Double(rowCount: Int32(bCount),
                                           columnCount: 1,
                                           columnStride: Int32(bCount),
                                           attributes: SparseAttributes_t(),
                                           data: bPtr.baseAddress!)

                let X = DenseMatrix_Double(rowCount: Int32(bCount),
                                           columnCount: 1,
                                           columnStride: Int32(bCount),
                                           attributes: SparseAttributes_t(),
                                           data: buffer.baseAddress!)

                SparseSolve(factorization, B, X,
                            workspace)

                count = bCount
            }
        }
        
        let result = xValues
        workspace.deallocate()
        return result
    }
}
