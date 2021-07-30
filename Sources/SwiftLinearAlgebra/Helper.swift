//
//  File.swift
//  
//
//  Created by Jan Tomec on 28/07/2021.
//

func mod(_ a: Int, _ n: Int) -> Int {
    let r = a % n
    return r >= 0 ? r : r + n
}
