//
//  File.swift
//
//
//  Created by Jan Tomec on 28/07/2021.
//

struct Matrix: Equatable {
    
    private var value: [[Double]]
    private let nRows: Int
    private let nCols: Int
    
    init(_ values: [[Double]]) throws {
        self.nRows = values.count
        self.nCols = values.first?.count ?? 0
        for i in 0..<self.nRows {
            if values[i].count != self.nCols {
                throw LinearAlgebraError.inputNotMatrixLike
            }
        }
        self.value = values
    }
    
    init(_ values: [[Int]]) throws {
        let doubles = values.map {
            (row) in
            row.map {
                (element) in
                Double(element)
            }
        }
        try self.init(doubles)
    }
    
    init(_ values: [[Float]]) throws {
        let doubles = values.map {
            (row) in
            row.map {
                (element) in
                Double(element)
            }
        }
        try self.init(doubles)
    }
}
