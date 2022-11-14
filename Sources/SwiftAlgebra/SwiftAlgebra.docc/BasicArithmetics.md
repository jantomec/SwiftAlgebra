# Basic Arithmetics

Basic arithmetic operations with Swift Algebra.

## Overview

``Matrix`` allows all basic arithmetic operations to be performed intuitively using operators.

### Addition and subtraction

```swift
let A = Matrix(from: [[5, 2], [-1, 0]])
print(A + A)
// Prints "[[10, 4], [-2, 0]]"

A[.all, 1] -= A[.all, 0]
print(A)
// Prints "[[5, -3], [-1, 1]]"
```

### Multiplication with a scalar

```swift
let B = 0.5 * (A + A.T)
print(B)
// Prints "[[5, 0.5], [0.5, 0]]"
```

### Matrix multiplication

```swift
print(B∙A)
// Prints "[[24.5, 10], [2.5, 1]]"
```

### Matrix power

```swift
print(B**3)
// Prints "[[127.5, 12.625], [12.625, 1.25]]"
```
