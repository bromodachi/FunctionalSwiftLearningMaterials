import Foundation
import UIKit

func plusIsCommutative(x: Int, y: Int) -> Bool {
    return x + y == y+x
}
protocol Smaller {
    func smaller() -> Self?
}

protocol Arbitrary: Smaller{
    static func arbitrary() -> Self
}
func tabulate<A>(times: Int, transform: (Int) -> A) -> [A] { return (0..<times).map(transform)
}
extension Int {
    static func random(from from: Int, to: Int) -> Int {
        return from + (Int(arc4random()) % (to - from)) }
}
extension Int: Arbitrary {
    static func arbitrary() -> Int {
        return Int(arc4random())
    }
    func smaller() -> Int? {
        return self == 0 ? nil : self / 2
    }
}
Int.random(from: -200, to: 70)
extension Character: Arbitrary {
    static func arbitrary() -> Character{
        return Character(UnicodeScalar(Int.random(from: 65, to: 90))!)
    }
    func smaller() -> Character? {
        return self == nil ? nil : self
    }
}
extension String: Arbitrary {
    static func arbitrary() -> String {
        let randomLength = Int.random(from: 0, to: 40)
        let randomCharacters = tabulate(times: randomLength) { _ in
            Character.arbitrary() }
        return String(randomCharacters) }
    func smaller() -> String? {
        return isEmpty ? nil : String(characters.dropFirst()) }
}

extension CGSize {
    var area: CGFloat {
        return width * height }
}
extension CGFloat: Arbitrary {
    static func arbitrary() -> CGFloat {
        return CGFloat(Int.random(from: -200, to: 200)) }
    
    func smaller() -> CGFloat? {
        return self // implement later
    }
}



String.arbitrary ()


var numberOfIterations = 10
func check1<A:Arbitrary>(message:String,_ property: (A) -> Bool)->() {
    for _ in 0..<numberOfIterations {
        let value = A.arbitrary()
        guard property(value)
            else {
                print ( " \"\( message)\" doesn't hold: \(value)")
                return
        }
    }
    print ( " \"\( message)\" passed \(numberOfIterations) tests.")
}




/*extension CGFloat: Arbitrary {
 static func arbitrary() -> CGFloat{
 return from
 }
 }*/

extension Array: Smaller {
    func smaller() -> [Element]? {
        guard !isEmpty else{ return nil }
        return Array(dropFirst())
    }
}

extension Array where Element: Arbitrary {
    static func arbitrary() -> [Element] {
        let randomLength = Int(arc4random() % 50)
        
        return tabulate(times: randomLength) { _ in
            Element.arbitrary() } }
}
extension CGSize: Arbitrary {
    static func arbitrary() -> CGSize{
        return CGSize(width: CGFloat.arbitrary(), height: CGFloat.arbitrary())
    }
    func smaller () -> CGSize? {
        return self // implement later
    }
}

func iterateWhile<A>(condition: (A) -> Bool, initial : A, next: (A) -> A?) -> A {
    if let x = next( initial ) , condition(x) {
        return iterateWhile(condition: condition, initial : x, next: next)
    }
    return initial }


func check2<A:Arbitrary>(message:String,_property:(A)->Bool)->() { for _ in 0..<numberOfIterations {
    let value = A.arbitrary()
    guard _property(value) else {
        let smallerValue = iterateWhile(condition: { !_property($0) }, initial : value) { $0.smaller()
        }
        print ( " \"\( message)\" doesn't hold: \(smallerValue)")
        return
    }
    }
    print ( " \"\( message)\" passed \(numberOfIterations) tests.")
}
func qsort( array: [Int]) -> [Int] {
    var array = array
    if array.isEmpty { return [] }
    let middle = array.count / 2
    let pivot = array.remove(at: middle)
    let lesser = array.filter { $0 < pivot }
    print("Less than: \(lesser)")
    let greater = array.filter { $0 >= pivot }
    print(greater)
    let pivArray = [pivot]
    return qsort(array: lesser) + pivArray + qsort(array: greater)
}

qsort(array: [5,6,71,389,90,55])
[5,6,71,389,90,55].filter{ $0 >= 55
}

check1(message: "Area should be at least 0") { (size: CGSize) in size.area >= 0 } //will always work

check1(message: "Every string starts with Hello") { //stops working right away because it will not start with an h unless we can extemely lucky
    (s: String) in
    s.hasPrefix("Hello")
}


100.smaller()

struct ArbitraryInstance<T> {
    let arbitrary: () -> T
    let smaller: (T) -> T?
}

func checkHelper<A>(arbitraryInstance: ArbitraryInstance<A>, _ property: (A) -> Bool, _ message: String) -> ()
{
    for _ in 0..<numberOfIterations {
        let value = arbitraryInstance.arbitrary()
        guard property(value)
            else {
                let smallerValue = iterateWhile(condition: { !property($0) }, initial : value, next: arbitraryInstance.smaller)
                print ( " \"\( message)\" doesn't hold: \(smallerValue)")
                return
        } }
    print ( " \"\( message)\" passed \(numberOfIterations) tests.") }

func check<X: Arbitrary>(message: String, _ property: ([X]) -> Bool) -> () {
    let instance = ArbitraryInstance(arbitrary: Array.arbitrary, smaller: { (x: [X]) in x.smaller() })
    checkHelper(arbitraryInstance: instance, property, message)
}

check(message: "qsortshouldbehavelikesort"){(x: [Int]) in return qsort(array: x) == x.sorted(by: <)
}