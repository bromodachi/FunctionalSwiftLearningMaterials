import Foundation

func computeIntArray<T, U>(xs:[T], f: (T)-> U) ->[U] {
    var result: [U] = []
    for x in xs {
        result.append(f(x))
    }
    return result
}
func doubleArray(xs: [Int]) -> [Int] {
    return computeIntArray(xs: xs, f: {x in x * 2})
}
func stringadd(xs: [String]) -> [String] {
    return computeIntArray(xs: xs, f: {x in x + x})
}

func reduce <A,R> (arr: [A], initialValue: R, combine: (R,A) -> R) -> R{
    var result = initialValue
    for x in arr {
        result = combine(result, x)
    }
    return result
}
func sumReduce(xs: [Int]) -> Int {
    return reduce(arr: xs, initialValue: 0) {result, x in result + x}
}
sumReduce(xs: [1,2,3])
func stringReduce(xs: [String]) -> String {
    return reduce(arr: xs, initialValue: "", combine: {result, x in result + x})
}


stringReduce(xs: ["test", "blah", "dog"])