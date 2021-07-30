//
//  File.swift
//
//
//  Created by Jan Tomec on 28/07/2021.
//

import Foundation

enum MatrixIndex {
    case all
}

enum MatrixType {
    case row
    case column
    case diagonal
}

struct Shape: Equatable {
    var nRows: Int
    var nCols: Int
}

struct Matrix: Equatable {
    
    private var value: [[Double]]
    var shape: Shape {
        return Shape(nRows: self.value.count, nCols: self.value.first?.count ?? 0)
    }
    var description: String {
        var printString: String = "Matrix(["
        for i in 0..<self.shape.nRows {
            if i != 0 { printString += "        " }
            printString += "["
            for j in 0..<self.shape.nCols {
                if j == 0 {
                    printString += "\(self[i, j])"
                } else {
                    printString += ", \(self[i, j])"
                }
            }
            printString += "]"
            if i < self.shape.nRows-1 { printString += "\n" }
        }
        printString += "])"
        return printString
    }
    
    init(_ values: [[Double]]) {
        let s = Shape(nRows: values.count, nCols: values.first?.count ?? 0)
        var check = true
        for i in 0..<s.nRows {
            if values[i].count != s.nCols {
                check = false
            }
        }
        precondition(check, "All rows should be of equal length.")
        self.value = values
    }
    
    init(_ values: [[Int]]) {
        let doubles = values.map {
            (row) in
            row.map {
                (element) in
                Double(element)
            }
        }
        self.init(doubles)
    }
    
    init(_ values: [[Float]]) {
        let doubles = values.map {
            (row) in
            row.map {
                (element) in
                Double(element)
            }
        }
        self.init(doubles)
    }
    
    init(value: Double, shape: (nRows: Int, nCols: Int)) {
        self.value = Array(repeating: Array(repeating: value, count: shape.nCols), count: shape.nRows)
    }
    
    init(value: Double, shape: Shape) {
        self.init(value: value, shape: (shape.nRows, shape.nCols))
    }
    
    init(value: Float, shape: (nRows: Int, nCols: Int)) {
        self.init(value: Double(value), shape: shape)
    }
    
    init(value: Float, shape: Shape) {
        self.init(value: value, shape: (shape.nRows, shape.nCols))
    }
    
    init(value: Int, shape: (nRows: Int, nCols: Int)) {
        self.init(value: Double(value), shape: shape)
    }
    
    init(value: Int, shape: Shape) {
        self.init(value: value, shape: (shape.nRows, shape.nCols))
    }
    
    init(vector: [Double], type: MatrixType) {
        switch type {
        case .row:
            let rowVector = [vector]
            self.init(rowVector)
        case .column:
            let columnVector = vector.map { [$0] }
            self.init(columnVector)
        case .diagonal:
            self.init(value: 0, shape: Shape(nRows: vector.count, nCols: vector.count))
            for i in 0..<vector.count {
                self[i,i] = vector[i]
            }
        }
    }
    
    init(vector: [Float], type: MatrixType) {
        let doubles = vector.map { Double($0) }
        self.init(vector: doubles, type: type)
    }
    
    init(vector: [Int], type: MatrixType) {
        let doubles = vector.map { Double($0) }
        self.init(vector: doubles, type: type)
    }
    
    private func checkBounds(row: Int) -> Bool {
        return (0 <= row && row < self.shape.nRows)
    }
    
    private func checkBounds(col: Int) -> Bool {
        return (0 <= col && col < self.shape.nCols)
    }
}

extension Matrix {
    subscript(row: Int, col: Int) -> Double {
        get {
            return self.value[row][col]
        }
        set(newValue) {
            self.value[row][col] = newValue
        }
    }
    
    subscript(safe row: Int, col: Int) -> Double? {
        get {
            if self.checkBounds(row: row) && self.checkBounds(col: col) {
                return self[row, col]
            } else {
                return nil
            }
        }
        set(newValue) {
            if self.checkBounds(row: row) && self.checkBounds(col: col) {
                self[row, col] = newValue ?? self[row, col]
            }
        }
    }
    
    subscript(cyclic row: Int, col: Int) -> Double {
        get {
            let r = mod(row, self.shape.nRows)
            let c = mod(col, self.shape.nCols)
            return self[r, c]
        }
        set(newValue) {
            let r = mod(row, self.shape.nRows)
            let c = mod(col, self.shape.nCols)
            self[r, c] = newValue
        }
    }
    
    subscript<T: RandomAccessCollection>(row: T, col: Int) -> Matrix where T.Element == Int, T.Index == Int {
        get {
            var submatrix = Matrix(value: 0, shape: (row.count, 1))
            var iIndex: Int = 0
            for iElement in row.indices {
                submatrix[iIndex, 0] = self[iElement, col]
                iIndex += 1
            }
            return submatrix
        }
        set(newValue) {
            var iIndex: Int = 0
            for iElement in row.indices {
                self[iElement, col] = newValue[iIndex, 0]
                iIndex += 1
            }
        }
    }
    
    subscript<T: RandomAccessCollection>(safe row: T, col: Int) -> Matrix where T.Element == Int, T.Index == Int {
        get {
            var submatrix = Matrix(value: 0, shape: (row.count, 1))
            var iIndex: Int = 0
            for iElement in row.indices {
                submatrix[safe: iIndex, 0] = self[safe: iElement, col]
                iIndex += 1
            }
            return submatrix
        }
        set(newValue) {
            var iIndex: Int = 0
            for iElement in row.indices {
                self[safe: iElement, col] = newValue[safe: iIndex, 0]
                iIndex += 1
            }
        }
    }
    
    subscript<T: RandomAccessCollection>(cyclic row: T, col: Int) -> Matrix where T.Element == Int, T.Index == Int {
        get {
            var submatrix = Matrix(value: 0, shape: (row.count, 1))
            var iIndex: Int = 0
            for iElement in row.indices {
                submatrix[cyclic: iIndex, 0] = self[cyclic: iElement, col]
                iIndex += 1
            }
            return submatrix
        }
        set(newValue) {
            var iIndex: Int = 0
            for iElement in row.indices {
                self[cyclic: iElement, col] = newValue[cyclic: iIndex, 0]
                iIndex += 1
            }
        }
    }
    
    subscript<T: RandomAccessCollection>(row: Int, col: T) -> Matrix where T.Element == Int, T.Index == Int {
        get {
            var submatrix = Matrix(value: 0, shape: (1, col.count))
            var jIndex: Int = 0
            for jElement in col {
                submatrix[0, jIndex] = self[row, jElement]
                jIndex += 1
            }
            return submatrix
        }
        set(newValue) {
            var jIndex: Int = 0
            for jElement in col {
                self[row, jElement] = newValue[0, jIndex]
                jIndex += 1
            }
        }
    }
    
    subscript<T: RandomAccessCollection>(safe row: Int, col: T) -> Matrix where T.Element == Int, T.Index == Int {
        get {
            var submatrix = Matrix(value: 0, shape: (1, col.count))
            var jIndex: Int = 0
            for jElement in col {
                submatrix[safe: 0, jIndex] = self[safe: row, jElement]
                jIndex += 1
            }
            return submatrix
        }
        set(newValue) {
            var jIndex: Int = 0
            for jElement in col {
                self[safe: row, jElement] = newValue[safe: 0, jIndex]
                jIndex += 1
            }
        }
    }
    
    subscript<T: RandomAccessCollection>(cyclic row: Int, col: T) -> Matrix where T.Element == Int, T.Index == Int {
        get {
            var submatrix = Matrix(value: 0, shape: (1, col.count))
            var jIndex: Int = 0
            for jElement in col {
                submatrix[cyclic: 0, jIndex] = self[cyclic: row, jElement]
                jIndex += 1
            }
            return submatrix
        }
        set(newValue) {
            var jIndex: Int = 0
            for jElement in col {
                self[cyclic: row, jElement] = newValue[cyclic: 0, jIndex]
                jIndex += 1
            }
        }
    }
    
    subscript<T: RandomAccessCollection, U: RandomAccessCollection>(row: T, col: U) -> Matrix where
        T.Element == Int, T.Index == Int, U.Element == Int, U.Index == Int {
        get {
            var submatrix = Matrix(value: 0, shape: (row.count, col.count))
            var iIndex: Int = 0
            var jIndex: Int
            for iElement in row {
                jIndex = 0
                for jElement in col {
                    submatrix[iIndex, jIndex] = self[iElement, jElement]
                    jIndex += 1
                }
                iIndex += 1
            }
            return submatrix
        }
        set(newValue) {
            var iIndex: Int = 0
            var jIndex: Int
            for iElement in row {
                jIndex = 0
                for jElement in col {
                    self[iElement, jElement] = newValue[iIndex, jIndex]
                    jIndex += 1
                }
                iIndex += 1
            }
        }
    }
    
    subscript<T: RandomAccessCollection, U: RandomAccessCollection>(safe row: T, col: U) -> Matrix where
        T.Element == Int, T.Index == Int, U.Element == Int, U.Index == Int {
        get {
            var submatrix = Matrix(value: 0, shape: (row.count, col.count))
            var iIndex: Int = 0
            var jIndex: Int
            for iElement in row {
                jIndex = 0
                for jElement in col {
                    submatrix[safe: iIndex, jIndex] = self[safe: iElement, jElement]
                    jIndex += 1
                }
                iIndex += 1
            }
            return submatrix
        }
        set(newValue) {
            var iIndex: Int = 0
            var jIndex: Int
            for iElement in row {
                jIndex = 0
                for jElement in col {
                    self[safe: iElement, jElement] = newValue[safe: iIndex, jIndex]
                    jIndex += 1
                }
                iIndex += 1
            }
        }
    }
    
    subscript<T: RandomAccessCollection, U: RandomAccessCollection>(cyclic row: T, col: U) -> Matrix where
        T.Element == Int, T.Index == Int, U.Element == Int, U.Index == Int {
        get {
            var submatrix = Matrix(value: 0, shape: (row.count, col.count))
            var iIndex: Int = 0
            var jIndex: Int
            for iElement in row {
                jIndex = 0
                for jElement in col {
                    submatrix[iIndex, jIndex] = self[cyclic: iElement, jElement]
                    jIndex += 1
                }
                iIndex += 1
            }
            return submatrix
        }
        set(newValue) {
            var iIndex: Int = 0
            var jIndex: Int
            for iElement in row {
                jIndex = 0
                for jElement in col {
                    self[cyclic: iElement, jElement] = newValue[iIndex, jIndex]
                    jIndex += 1
                }
                iIndex += 1
            }
        }
    }

    subscript(row: Int, col: MatrixIndex) -> Matrix {
        get {
            return Matrix(vector: self.value[row], type: .row)
        }
        set(newValue) {
            for i in 0..<self.shape.nCols {
                self[row, i] = newValue[0, i]
            }
        }
    }
    
    subscript(safe row: Int, col: MatrixIndex) -> Matrix? {
        get {
            if self.checkBounds(row: row) {
                return self[row, col]
            } else {
                return nil
            }
        }
        set(newValue) {
            if let newValue = newValue {
                if self.checkBounds(row: row) && newValue.checkBounds(row: 0) {
                    self[row, col] = newValue
                }
            }
        }
    }
    
    subscript(cyclic row: Int, col: MatrixIndex) -> Matrix {
        get {
            let r = mod(row, self.shape.nRows)
            return self[r, col]
        }
        set(newValue) {
            let r = mod(row, self.shape.nRows)
            self[r, col] = newValue
        }
    }

    subscript(row: MatrixIndex, col: Int) -> Matrix {
        get {
            return Matrix(vector: self.value.map { $0[col] }, type: .column)
        }
        set(newValue) {
            for i in 0..<self.shape.nRows {
                self[i,col] = newValue[i,0]
            }
        }
    }
    
    subscript(safe row: MatrixIndex, col: Int) -> Matrix? {
        get {
            if self.checkBounds(col: col) {
                return self[row, col]
            } else {
                return nil
            }
        }
        
        set(newValue) {
            if let newValue = newValue {
                if self.checkBounds(col: col) && newValue.checkBounds(col: 0) {
                    self[row, col] = newValue
                }
            }
        }
    }
    
    subscript(cyclic row: MatrixIndex, col: Int) -> Matrix {
        get {
            let c = mod(col, self.shape.nCols)
            return self[row, c]
        }
        set(newValue) {
            let c = mod(col, self.shape.nCols)
            self[row, c] = newValue
        }
    }
    
    subscript(row: MatrixIndex, col: MatrixIndex) -> Matrix {
        get {
            return Matrix(self.value)
        }
        set(newValue) {
            for i in 0..<self.shape.nRows {
                for j in 0..<self.shape.nRows {
                    self[i,j] = newValue[i,j]
                }
            }
        }
    }
    
    subscript(safe row: MatrixIndex, col: MatrixIndex) -> Matrix {
        get {
            return Matrix(self.value)
        }
        set(newValue) {
            for i in 0..<self.shape.nRows {
                for j in 0..<self.shape.nRows {
                    self[i,j] = newValue[i,j]
                }
            }
        }
    }
    
    subscript(cyclic row: MatrixIndex, col: MatrixIndex) -> Matrix {
        get {
            return Matrix(self.value)
        }
        set(newValue) {
            for i in 0..<self.shape.nRows {
                for j in 0..<self.shape.nRows {
                    self[i,j] = newValue[i,j]
                }
            }
        }
    }
    
    subscript(index: Int) -> Double {
        get {
            let check = self.shape.nRows == 1 || self.shape.nCols == 1
            precondition(check, "Single subscript is only allowed on vectors")
            if self.shape.nRows == 1 {
                return self[0, index]
            } else {
                return self[index, 0]
            }
        }
        set(newValue) {
            let check = self.shape.nRows == 1 || self.shape.nCols == 1
            precondition(check, "Single subscript is only allowed on vectors")
            if self.shape.nRows == 1 {
                self[0, index] = newValue
            } else {
                self[index, 0] = newValue
            }
        }
    }
    
    subscript(safe index: Int) -> Double? {
        get {
            let check = self.shape.nRows == 1 || self.shape.nCols == 1
            precondition(check, "Single subscript is only allowed on vectors")
            if self.shape.nRows == 1 {
                return self[safe: 0, index]
            } else {
                return self[safe: index, 0]
            }
        }
        set(newValue) {
            let check = self.shape.nRows == 1 || self.shape.nCols == 1
            precondition(check, "Single subscript is only allowed on vectors")
            if self.shape.nRows == 1 {
                self[safe: 0, index] = newValue
            } else {
                self[safe: index, 0] = newValue
            }
        }
    }
    
    subscript(cyclic index: Int) -> Double {
        get {
            let check = self.shape.nRows == 1 || self.shape.nCols == 1
            precondition(check, "Single subscript is only allowed on vectors")
            if self.shape.nRows == 1 {
                return self[cyclic: 0, index]
            } else {
                return self[cyclic: index, 0]
            }
        }
        set(newValue) {
            let check = self.shape.nRows == 1 || self.shape.nCols == 1
            precondition(check, "Single subscript is only allowed on vectors")
            if self.shape.nRows == 1 {
                self[cyclic: 0, index] = newValue
            } else {
                self[cyclic: index, 0] = newValue
            }
        }
    }
    
    subscript<T: RandomAccessCollection>(indexList: T) -> Matrix where
        T.Element == Int, T.Index == Int {
        get {
            let check = self.shape.nRows == 1 || self.shape.nCols == 1
            precondition(check, "Single subscript is only allowed on vectors")
            if self.shape.nRows == 1 {
                var submatrix = Matrix(value: 0, shape: (1, indexList.count))
                var jIndex: Int = 0
                for jElement in indexList {
                    submatrix[0, jIndex] = self[0, jElement]
                    jIndex += 1
                }
                return submatrix
            } else {
                var submatrix = Matrix(value: 0, shape: (indexList.count, 1))
                var iIndex: Int = 0
                for iElement in indexList {
                    submatrix[iIndex, 0] = self[iElement, 0]
                    iIndex += 1
                }
                return submatrix
            }
        }
        set(newValue) {
            let check = self.shape.nRows == 1 || self.shape.nCols == 1
            precondition(check, "Single subscript is only allowed on vectors")
            if self.shape.nRows == 1 {
                var jIndex: Int = 0
                for jElement in indexList {
                    self[0, jElement] = newValue[0, jIndex]
                    jIndex += 1
                }
            } else {
                var iIndex: Int = 0
                for iElement in indexList {
                    self[iElement, 0] = newValue[iIndex, 0]
                    iIndex += 1
                }
            }
        }
    }
    
    subscript<T: RandomAccessCollection>(safe indexList: T) -> Matrix where
        T.Element == Int, T.Index == Int {
        get {
            let check = self.shape.nRows == 1 || self.shape.nCols == 1
            precondition(check, "Single subscript is only allowed on vectors")
            if self.shape.nRows == 1 {
                var submatrix = Matrix(value: 0, shape: (1, indexList.count))
                var jIndex: Int = 0
                for jElement in indexList {
                    submatrix[safe: 0, jIndex] = self[safe: 0, jElement]
                    jIndex += 1
                }
                return submatrix
            } else {
                var submatrix = Matrix(value: 0, shape: (indexList.count, 1))
                var iIndex: Int = 0
                for iElement in indexList {
                    submatrix[safe: iIndex, 0] = self[safe: iElement, 0]
                    iIndex += 1
                }
                return submatrix
            }
        }
        set(newValue) {
            let check = self.shape.nRows == 1 || self.shape.nCols == 1
            precondition(check, "Single subscript is only allowed on vectors")
            if self.shape.nRows == 1 {
                var jIndex: Int = 0
                for jElement in indexList {
                    self[safe: 0, jElement] = newValue[safe: 0, jIndex]
                    jIndex += 1
                }
            } else {
                var iIndex: Int = 0
                for iElement in indexList {
                    self[safe: iElement, 0] = newValue[safe: iIndex, 0]
                    iIndex += 1
                }
            }
        }
    }
    
    subscript<T: RandomAccessCollection>(cyclic indexList: T) -> Matrix where
        T.Element == Int, T.Index == Int {
        get {
            let check = self.shape.nRows == 1 || self.shape.nCols == 1
            precondition(check, "Single subscript is only allowed on vectors")
            if self.shape.nRows == 1 {
                var submatrix = Matrix(value: 0, shape: (1, indexList.count))
                var jIndex: Int = 0
                for jElement in indexList {
                    submatrix[cyclic: 0, jIndex] = self[cyclic: 0, jElement]
                    jIndex += 1
                }
                return submatrix
            } else {
                var submatrix = Matrix(value: 0, shape: (indexList.count, 1))
                var iIndex: Int = 0
                for iElement in indexList {
                    submatrix[cyclic: iIndex, 0] = self[cyclic: iElement, 0]
                    iIndex += 1
                }
                return submatrix
            }
        }
        set(newValue) {
            let check = self.shape.nRows == 1 || self.shape.nCols == 1
            precondition(check, "Single subscript is only allowed on vectors")
            if self.shape.nRows == 1 {
                var jIndex: Int = 0
                for jElement in indexList {
                    self[cyclic: 0, jElement] = newValue[cyclic: 0, jIndex]
                    jIndex += 1
                }
            } else {
                var iIndex: Int = 0
                for iElement in indexList {
                    self[cyclic: iElement, 0] = newValue[cyclic: iIndex, 0]
                    iIndex += 1
                }
            }
        }
    }
}

extension Matrix {
    var transposed: Matrix {
        var transposedMatrix = Matrix(value: 0, shape: (self.shape.nCols, self.shape.nRows))
        for i in 0..<self.shape.nRows {
            for j in 0..<self.shape.nCols {
                transposedMatrix[j,i] = self[i,j]
            }
        }
        return transposedMatrix
    }
}

precedencegroup CrossPrecedence { higherThan: MultiplicationPrecedence }
precedencegroup PowerPrecedence { higherThan: CrossPrecedence }
infix operator **: PowerPrecedence
infix operator ∙: MultiplicationPrecedence
infix operator ⊙: CrossPrecedence
infix operator ⨯: CrossPrecedence

func **(radix: Double, power: Double) -> Double {
    return pow(radix, power)
}

func **(radix: Double, power: Int) -> Double {
    return radix ** Double(power)
}

extension Matrix {
    static func +(lhs: Matrix, rhs: Matrix) -> Matrix {
        let check = lhs.shape.nRows == rhs.shape.nRows && lhs.shape.nCols == rhs.shape.nCols
        precondition(check, "Matrices should have equal shape.")
        var result = Matrix(value: 0, shape: lhs.shape)
        for i in 0..<lhs.shape.nRows {
            for j in 0..<rhs.shape.nCols {
                result[i,j] = lhs[i,j] + rhs[i,j]
            }
        }
        return result
    }
    
    static func +=(lhs: inout Matrix, rhs: Matrix) {
        lhs = lhs + rhs
    }
    
    static func -(lhs: Matrix, rhs: Matrix) -> Matrix {
        let check = lhs.shape.nRows == rhs.shape.nRows && lhs.shape.nCols == rhs.shape.nCols
        precondition(check, "Matrices should have equal shape.")
        var result = Matrix(value: 0, shape: lhs.shape)
        for i in 0..<lhs.shape.nRows {
            for j in 0..<rhs.shape.nCols {
                result[i,j] = lhs[i,j] - rhs[i,j]
            }
        }
        return result
    }
    
    static func -=(lhs: inout Matrix, rhs: Matrix) {
        lhs = lhs - rhs
    }
    
    static func *(lhs: Matrix, rhs: Matrix) -> Matrix {
        let check = lhs.shape.nRows == rhs.shape.nRows && lhs.shape.nCols == rhs.shape.nCols
        precondition(check, "Matrices should have equal shape.")
        var result = Matrix(value: 0, shape: lhs.shape)
        for i in 0..<lhs.shape.nRows {
            for j in 0..<rhs.shape.nCols {
                result[i,j] = lhs[i,j] * rhs[i,j]
            }
        }
        return result
    }
    
    static func *(lhs: Double, rhs: Matrix) -> Matrix {
        var result = Matrix(value: 0, shape: rhs.shape)
        for i in 0..<rhs.shape.nRows {
            for j in 0..<rhs.shape.nCols {
                result[i,j] = lhs * rhs[i,j]
            }
        }
        return result
    }
    
    static func *(lhs: Matrix, rhs: Double) -> Matrix {
        var result = Matrix(value: 0, shape: lhs.shape)
        for i in 0..<lhs.shape.nRows {
            for j in 0..<lhs.shape.nCols {
                result[i,j] = rhs * lhs[i,j]
            }
        }
        return result
    }
    
    static func *=(lhs: inout Matrix, rhs: Double) {
        lhs = lhs * rhs
    }
    
    static func /(lhs: Matrix, rhs: Double) -> Matrix {
        var result = Matrix(value: 0, shape: lhs.shape)
        for i in 0..<lhs.shape.nRows {
            for j in 0..<lhs.shape.nCols {
                result[i,j] = lhs[i,j] / rhs
            }
        }
        return result
    }
    
    static func /=(lhs: inout Matrix, rhs: Double) {
        lhs = lhs / rhs
    }
    
    static func ∙(lhs: Matrix, rhs: Matrix) -> Matrix {
        let check = lhs.shape.nCols == rhs.shape.nRows
        precondition(check, "Noumber of columns in first matrix should equal the noumber of rows in the second.")
        var result = Matrix(value: 0, shape: Shape(nRows: lhs.shape.nRows, nCols: rhs.shape.nCols))
        for i in 0..<lhs.shape.nRows {
            for j in 0..<rhs.shape.nCols {
                for k in 0..<lhs.shape.nCols {
                    result[i,j] += lhs[i,k] * rhs[k,j]
                }
            }
        }
        return result
    }
    
    static func ⊙(lhs: Matrix, rhs: Matrix) -> Matrix {
        let check = lhs.shape.nRows == rhs.shape.nRows && lhs.shape.nCols == 1 && rhs.shape.nCols == 1
        precondition(check, "Both sides should be column vectors.")
        var result = Matrix(value: 0, shape: Shape(nRows: lhs.shape.nRows, nCols: rhs.shape.nRows))
        for i in 0..<lhs.shape.nRows {
            for j in 0..<rhs.shape.nRows {
                result[i,j] += lhs[i,0] * rhs[j,0]
            }
        }
        return result
    }
    
    static func ⨯(lhs: Matrix, rhs: Matrix) -> Matrix {
        let check = lhs.shape.nRows == 3 && rhs.shape.nRows == 3 && lhs.shape.nCols == 1 && rhs.shape.nCols == 1
        precondition(check, "Both sides should be column vectors.")
        var result = Matrix(value: 0, shape: lhs.shape)
        result[0,0] = lhs[1,0] * rhs[2,0] - lhs[2,0] * rhs[1,0]
        result[1,0] = lhs[2,0] * rhs[0,0] - lhs[0,0] * rhs[2,0]
        result[2,0] = lhs[0,0] * rhs[1,0] - lhs[1,0] * rhs[0,0]
        return result
    }
    
    static func **(lhs: Matrix, rhs: Int) -> Matrix {
        let check = lhs.shape.nRows == lhs.shape.nCols
        precondition(check, "Matrix should be square.")
        var result = identity(lhs.shape.nRows)
        for _ in 0..<rhs {
            result = result ∙ lhs
        }
        return result
    }
}

func identity(_ dimensions: Int) -> Matrix {
    return Matrix(vector: Array(repeating: 1, count: dimensions), type: .diagonal)
}

func norm(vector: Matrix) -> Double {
    var square: Double = 0
    let check = vector.shape.nCols == 1
    precondition(check, "Column vector is required.")
    for i in 0..<vector.shape.nRows {
        square += vector[i,0]**2
    }
    return square.squareRoot()
}
