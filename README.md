# SwiftAlgebra

A small standalone package for linear algebra and Lie groups.

## Features

Currenlty supported features:
- Vectors are treated as one-dimensional matrices
- Advanced slicing
- Arithmetic operations on matrices
- Linear algebra (inverse and solve using LU decomposition)
- Lie groups and operations on them

## Installation

https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app

## Requirements

_SwiftAlgebra_ includes only pure Swift code making this package cross-platform. The latest version of Swift is recommended, while Swift 5.5 is the minimum requirement.

## Usage

The following code snippets should help you getting the gist of it.

Construct an identity matrix
```swift
var I = Matrix(identity: 4)
```
or a general matrix from a double array
```swift
let A = Matrix(from: [[1,2,3],[4,5,6],[7,8,9]])
```
We can then do arithmetic operations
```swift
I[1...3,0...2] += 0.5 * (A + A.T)
```
or even matrix multiplication
```swift
let B = I[0...1,1...3]∙A[.all, 1...2]
```
We can also invert the matrix or solve a system of equations
```swift
B[.all, .all] = I[0...1,0...1]
print(try invert(B))
print(try solve(A: B, b: I[0...1,0]))
```
We can also extract submatrices while keeping the reference alive
```swift
var C = I[0...2,0]
print(I)
C *= 2
print(I)
```
Note that we marked matrix `C` as `var` while `I` and `B` were also manipulated under `let`. This is because in the last example we replaced the reference of the `Matrix` instance, not individual values. Individual values can be changed through the subscript `[.all, .all]`.

## Contribution

Contact me personally.

## License

[<img src="https://github.com/tomecj/SwiftLinearAlgebra/blob/master/Resources/1280px-MIT_logo.png" alt="drawing" height="20"/>](https://github.com/tomecj/SwiftLinearAlgebra/blob/master/LICENSE)

## Resources

- [Swift](https://developer.apple.com/documentation/swift)
- [Swift Package](https://developer.apple.com/documentation/xcode/creating_a_standalone_swift_package_with_xcode)
- [Semantic Versioning](https://stackoverflow.com/questions/37814286/how-to-manage-the-version-number-in-git)
