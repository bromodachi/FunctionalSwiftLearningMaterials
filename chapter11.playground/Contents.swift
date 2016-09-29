//: Playground - noun: a place where people can play
import Foundation
import Cocoa



//Generators
protocol GeneratorType {
    associatedtype Element
    func next() -> Element?
}

class CountdownGenerator: GeneratorType {
    var element: Int
    
    init<T> (array: [T]){
        self.element = array.count
        
    }
    
    func next() -> Int? {
        if self.element <= 0 {
            return nil
        }
        else {
            self.element = self.element - 1
            return self.element
        }
    }
}

let xs = ["A", "B", "C"]
let generator = CountdownGenerator(array: xs)
while let i = generator.next() {
    print("Element \(i) of the array is \(xs[i])")
}
while let i = generator.next() {
    print("Element \(i) of the array is \(xs[i])")
}

class PowerGenerator: GeneratorType {
    typealias Element = NSDecimalNumber
    var power: NSDecimalNumber = 1
    let two: NSDecimalNumber = 2
    func next() -> NSDecimalNumber? {
        power = power.multiplying(by: 2)
        return power
    }
}

extension PowerGenerator  {
    func findPower(predicate: (NSDecimalNumber) -> Bool) -> NSDecimalNumber {
        while let x = next() {
            if predicate(x) {
                return x
            }
        }
        return 0
    }
}

print(PowerGenerator().findPower { $0.intValue > 1000 }) // I'm saying use function provided and stop until 2 to the power x is greater than 1000 (2^10



class FileLinesGenerator: GeneratorType {
    typealias Element = String
    var lines: [String] = []
    
    init(fileName: String) throws {
        let contents: String = try String(contentsOfFile: fileName)
        let newLine = NSCharacterSet.newlines
        lines = contents.components(separatedBy: newLine)
    }
    
    func next() -> String? {
        guard !lines.isEmpty else {return nil}
        let nextLine = lines.remove(at: 0)
        return nextLine
    }
    
}


extension GeneratorType {
    //The generator may be modified by the find function, resulting from the calls to next, hence we need to add the mutating annotation in the type declaration
    mutating func find(predicate: (Element) -> Bool) -> Element? {
        while let x = self.next() {
            if predicate(x) {
                return x
            }
        }
        return nil
    }
}

class PowerGenerator2: GeneratorType {
    typealias Element = NSDecimalNumber
    var power: NSDecimalNumber = 1
    var two: NSDecimalNumber = 2
    func next() -> NSDecimalNumber? {
        power = power.multiplying(by: 2)
        return power
    }
}

var power2 = PowerGenerator2()
print(power2.find(predicate: { $0.intValue > 50}))


class LimitGenerator<G: GeneratorType>: GeneratorType {
    var limit = 0
    var generator: G
    init(limit: Int, generator: G) {
        self.limit = limit
        self.generator = generator
    }
    
    func next() -> G.Element? {
        guard limit >= 0 else {
            return nil
        }
        
        limit -= 1
        return generator.next()
    }
}



extension Int {
    func countDown() -> AnyIterator<Int> {
        var i = self
        return AnyIterator.Iterator {
            if  i < 0 {
                return nil
            }
            else{
                i -= 1
                return i
            }
        }
    }
}


//The resulting generator simply reads off new elements from its  rst argument generator; once this is exhausted, it produces elements from its second generator. Once both generators have returned nil, the composite generator also returns nil.

func +<G:GeneratorType, H: GeneratorType>( first: G, second: H) -> AnyIterator<G.Element> where G.Element == H.Element, G.Element == H.Element {
    var second = second
    var first = first
    return AnyIterator.Iterator { first.next() ?? second.next() }
}



print(6.countDown().next())

//Uncomment to see how to create a custom sequence. Really was supposed to use sequence
//protocol SequenceType {
//    associatedtype Generator: GeneratorType
//    func generate() -> Generator
//    func map<T>(  transform: (Self.Generator.Element) throws -> T) rethrows -> [T]
//    func filter ( includeElement: (Self.Generator.Element) throws -> Bool) rethrows -> [Self.Generator.Element]
//    
//}


//struct ReverseSequence<T>: SequenceType {
//    func filter(includeElement: (ReverseSequence.Generator.Element) throws -> Bool) rethrows -> [ReverseSequence.Generator.Element] {
//        var result: [ReverseSequence.Generator.Element] = []
//        let generator = generate()
//        while let i = generator.next() , try includeElement(i){
//            result.append(try i )
//        }
//        return result
//    }
//    func map<T>(  transform: (ReverseSequence.Generator.Element) throws -> T) rethrows -> [T]{
//        var ts: [T] = []
//        let generator = generate()
//        while let i = generator.next(){
//            ts.append(try transform(i))
//        }
//        return ts
//    }
//    
//    var array: [T]
//    init(array: [T]) {
//        self.array = array
//    }
//    
//    func generate() -> CountdownGenerator {
//        return CountdownGenerator(array: array)
//    }
//}


/*
 
If you need to map or filter sequences that may produce either infinite results, or many results that you may not be interested in, be sure to use a LazySequence rather than a Sequence. Failing to do so could cause your program to diverge or take much longer than you might expect.
 */
extension Sequence {
    public var lazy: LazySequence<Self> {  get { return self as! LazySequence<Self> }}
}


indirect enum BinarySearchTree<Element: Comparable> {
    case Leaf
    case Node(BinarySearchTree<Element>, Element, BinarySearchTree<Element>)
}

let three: [Int] = Array(IteratorOverOne(_elements: 3))
let empty: [Int] = Array(IteratorOverOne(_elements: nil))

func one<T>(x: T?) -> AnyIterator<T> {
    return AnyIterator(IteratorOverOne(_elements: x))
}

extension BinarySearchTree {
    init () {
        self = .Leaf
    }
    init (_ value: Element) {
        self = .Node(.Leaf, value, .Leaf)
    }
    var count: Int {
        switch self { case .Leaf:
            return 0
        case let .Node(left, _, right ):
            return 1 + left . count + right.count }
    }
    var elements: [Element] {
        switch self {
        case .Leaf:
            return []
        case let .Node(left, x, right ):
            return left .elements + [x] + right.elements }
    }
    var isEmpty: Bool {
        if case .Leaf = self {
            return true
        }
        return false
    }
}

extension BinarySearchTree {
    mutating func insert(x: Element) {
        switch self {
        case .Leaf:
            self = BinarySearchTree(x)
        case .Node(var left, let y, var right):
            if x < y { left.insert(x: x) }
            if x > y { right.insert(x: x) }
            self = .Node(left, y, right)
        }
    }
}


func +<G: IteratorProtocol, H:IteratorProtocol> (first: G, second: H) -> AnyIterator<G.Element> where G.Element == H.Element  {
    var first = first
    var second = second
    return AnyIterator {first.next() ?? second.next() }
}

extension BinarySearchTree {
    var inOrder: AnyIterator<Element> {
        switch self {
        case .Leaf:
            print("getsCalledHere\(self)")
            return AnyIterator{ return nil }
        case .Node(let left, let x, let right):
            return left.inOrder + one(x: x) + right.inOrder
        }
    }
}

var copied = BinarySearchTree(5)
copied.insert(x: 10)
copied.insert(x: 7)
copied.insert(x: 9)
print("yay")
print(Array(copied.inOrder))
//let reverseSequence = ReverseSequence(array: xs)
//let reverseGenerator = reverseSequence.generate()
//while let i = reverseGenerator.next(){
//    print("Index \(i) is \(xs[i ])")
//}
//for i in ReverseSequence(array: xs) {
//    print("Index \(i) is \(xs[i ])")
//}
//let reverseElements = try ReverseSequence(array: xs).map { xs[$0] }
//for x in reverseElements {
//    print("Element is \(x)")
//}

protocol Smaller {
    func smaller() -> AnyIterator<Self>
}


extension Array {
    func generatorSmallerByOne() -> AnyIterator<[Element]> {
        var i = 0
        return AnyIterator {
            guard i < self.count else { return nil}
            
            var result = self
    
            result.remove(at: i)
            i += 1
            return result
        }
    }
}


extension Array {
    
    var decompose: (head: Element, tail: [Element])? {
        return self.count > 0 ? (self[0], Array(self[ 1..<count])) : nil
    }
    func smaller1() -> AnyIterator<[Element]> {
        guard let (head, tail) = self.decompose else {return one(x: nil)}
        let test = one(x: tail) + AnyIterator<[Element]>(tail.smaller1()).map { smallerTail in
            [head] + smallerTail
            }.makeIterator()
        return test
    }
}

print(Array([1, 2, 3].generatorSmallerByOne()))


extension Array where Element: Smaller {
    func smaller() -> AnyIterator<[Element]> {
    guard let(head, tail) = self.decompose else { return one(x: nil)}
    let gen1 = one(x: tail).makeIterator()
    let gen2 = Array<[Element]>(tail.smaller()).map { xs in
        [head] + xs
    }.makeIterator()
    let gen3 = Array<Element>(head.smaller()).map { x in
            [x] + tail
    }.makeIterator()
    return gen1 + gen2 + gen3
    }
}

func +<A>(l: AnySequence<A>, r: AnySequence<A>) -> AnySequence<A> {
    return AnySequence { l.makeIterator() + r.makeIterator() }
}
//[1, 2, 3].smaller()
/*
 struct AnySequence<Element>: SequenceType {
 init <G: GeneratorType where G.Element == Element>
 (_ makeUnderlyingGenerator: () -> G)
 func generate() -> AnyGenerator<Element> }

 
 */
let s = AnySequence([1, 2, 3]) + AnySequence([4, 5, 6])
print("First pass: ")
for x in s {
    print(x)
}
print("Second pass:")
for x in s {
    print(x)
}


extension IteratorProtocol {
    mutating func map<T>(_ transform: @escaping (Element) -> T) -> AnyIterator<T> {
        let test =  self.next().map(transform)
        return AnyIterator { test }
    }
}


public struct JoinedGenerator<Element>: IteratorProtocol {
    
    public var generator: AnyIterator<AnyIterator<Element>>
    public var current: AnyIterator<Element>?
    
    public init<
        G: IteratorProtocol>(_ g: G) where G.Element: IteratorProtocol, G.Element.Element == Element
        
    {
        var g = g
        self.generator = g.map(AnyIterator.init)
        self.current = generator.next()
    }
    
    public mutating func next() -> Element? {
        guard let c = current else { return nil }
        if let x = c.next() {
            return x
        } else {
            current = generator.next()
            return next()
        }
    }
}

extension Sequence where Iterator.Element: Sequence {
     typealias NestedElement = Iterator.Element.Iterator.Element
    func join() -> AnySequence<NestedElement> {
        return AnySequence { () -> JoinedGenerator<NestedElement> in
            var generator = self.makeIterator()
            return JoinedGenerator(generator.map { $0.makeIterator() })
        }
    }
}


extension AnySequence {
    func flatMap<T, Seq: Sequence>
        (f: (Element)->Seq)->AnySequence<T> where Seq.Iterator.Element == T {
        return AnySequence<Seq>(self.map(f)).join()
    }
}