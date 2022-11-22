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
var B = I[0...1,1...3]∙A[.all, 1...2]
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

## Extra Tips & Tricks

I know, symbols '∙' and '≈' are a bit tedious to type, but! Many editors including _Xcode_ allow snippets which can make the coding very simple while the beautiful syntax remains. [Here](https://sarunw.com/posts/how-to-create-code-snippets-in-xcode/) is a link on how to do it in Xcode.

All code is documented using [DocC](https://developer.apple.com/documentation/docc). The code to the documentation is also available so that if you make any changes, you can simply adopt the docs as well. Since all code is open-source, the documentation on this repository is not yet compiled.

### Running examples

_Swift Package Manager_ allows you to include this package in executables or in other packages like this one.
Assuming you have _Swift_ and _Swift Package Manager_ installed, follow these steps to create an example command line app:

1. In _Terminal_, go to your working directory and create a new folder.

```shell
mkdir SomeCalculations
cd SomeCalculations
```

2. Create a new package there.

```shell
swift package init --type executable --name SomeCalculations
```

3. Add dependency on _Fiber_ by editing `SomeCalculations/Package.swift`.

```swift
// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SomeCalculations",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/tomecj/SwiftAlgebra", from: "2.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "SomeCalculations",
            dependencies: ["SwiftAlgebra"]),
        .testTarget(
            name: "SomeCalculationsTests",
            dependencies: ["SomeCalculations"]),
    ]
)
```

4. Edit source code in `SomeCalculations/Sources/SomeCalculations/SomeCalculations.swift`

```swift
import SwiftAlgebra

@main
public struct SomeCalculations {
    public private(set) var text = "Hello, World!"

    public static func main() {
        print(SomeCalculations().text)
        let A = Matrix(identity: 3)
        let B = Matrix(from: [[1, 2, 3]]).T
        print (A ∙ B)
    }
}
```

<!--Find some examples [here](abc.com)!-->

## Contribution

Contact me personally.

## License

[<img src="https://github.com/tomecj/SwiftAlgebra/blob/master/Resources/1280px-MIT_logo.png" alt="drawing" height="20"/>](https://github.com/tomecj/SwiftAlgebra/blob/master/LICENSE)

## Resources

- [Swift](https://developer.apple.com/documentation/swift)
- [Swift Package](https://developer.apple.com/documentation/xcode/creating_a_standalone_swift_package_with_xcode)
- [Semantic Versioning](https://stackoverflow.com/questions/37814286/how-to-manage-the-version-number-in-git)
