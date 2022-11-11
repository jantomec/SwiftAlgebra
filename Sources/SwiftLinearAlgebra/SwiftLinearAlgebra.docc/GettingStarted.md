# Getting Started with Matrices

See how to construct matrices and access the data.

## Overview

``Matrix`` is a basic element of Swift Linear Algebra. It represents mathematical matrices and vectors. Matrix itself is a reference type variable meaning that it is referred to by its place in the memory. Furthermore, data that a Matrix is holding is made abstract which allows very intuitive access to any submatrix where no references are lost. 

### Creating Matrices

A new matrix can be created from an existing double array using ``Matrix/init(from:)``.
```swift
let a: [[Double]] = [[ 5, 2],
                     [-1, 0]]
let A = Matrix(from: a)
```
There are also many other convenient initialization methods. For instance, a new matrix of specific shape with all elements equal can be constructed through ``Matrix/init(repeating:shape:)``.
```swift
let A = Matrix(repeating: 1, shape: (rows: 4, cols: 2))
```
A new matrix can be also constructed from a diagonal vector, defined as an array, using ``Matrix/init(diagonal:)``.
```swift
let A = Matrix(diagonal: [-1, 1, -1, 1])
```
An identity matrix is a diagonal matrix with all diagonal elements equal to 1. Such matrix can be created with ``Matrix/init(identity:)``. 
```swift
let A = Matrix(identity: 6)
```
If you want to copy existing Matrix, a special initializer ``Matrix/init(copy:)`` must be invoked. This method creates a copy of the original matrix while dropping all of the references.
```swift
let A = Matrix(identity: 6)
let B = Matrix(copy: A)
```

### Submatrices

Next let's explore slicing. Elements of Matrix are accessed through a double indexed subscript.
```swift
let A = Matrix(from: [[5, 2, 3], [-1, 0, 1]])
print(A[0,1])
// Prints "2"
```
The same syntax also allows assigning new values. Since the value `A` is just a reference to an instance of Matrix, `A` itself is not changed so it can be a `let` variable.
```swift
A[0,1] = 2.5
print(A[0,1])
// Prints "2.5"
```
Furthermore, different types of `Sequence` can be used to access submatrices. A submatrix is on its own a new instance of Matrix but preserves references to the data.
```swift
let B = A[1, [0, 2]]
print(B)
// Prints "[[-1, 1]]"

let C = A[0, 0..<2]
print(C)
// Prints "[[5, 2.5]]"

let D = A[.all, [0,2]]
print(C)
// Prints "[[5, 3], [-1, 1]]"
```
Slicing also allows assigning.
```swift
A[.all, 0] = A[.all, 1]
print(A)
// Prints "[[2.5, 2.5, 3], [0, 0, 1]]"
```

### Transpose

Transpose is an operation on a matrix which effectively substitutes rows and columns. In Swift Linear Algebra it can be accessed through a property ``Matrix/T``.
```swift
print(A.T)
// Prints "[[2.5, 0], [2.5, 0], [3, 1]]"
```
Since transpose produces a new matrix with references intact it can, like slices, also be used to assign new values.
```swift
A[.all, 2].T = A[0, [0, 2]]
print(A)
// Prints "[[2.5, 2.5, 2.5], [0, 0, 3]]"
```

### Matrix power

Square matrices can be raised to power.
```swift
print(A[.all,1...2]**2)
// Prints "[[6.25, 10.5], [0, 1]]"
```
Negative powers produce inverse of `A`.
```swift
print(A[.all,1...2]**(-1))
// Prints "[[0.4, -1.2], [0, 1]]"
```
The difference between ``Matrix/**(a:p:)`` and ``invert(_:)`` is that the latter throws an error if matrix `A` is singular while the former will force unwrap and cause runtime error. For this reason, power syntax is applicable to matrices where we are certain that the inverse exists.
