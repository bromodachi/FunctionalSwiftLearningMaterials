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

protocol SequenceType {
    associatedtype Generator: GeneratorType
    func generate() -> Generator
    func map<T>(  transform: (Self.Generator.Element) throws -> T) rethrows -> [T]
    func filter ( includeElement: (Self.Generator.Element) throws -> Bool) rethrows -> [Self.Generator.Element]
    
}


struct ReverseSequence<T>: SequenceType {
    func filter(includeElement: (ReverseSequence.Generator.Element) throws -> Bool) rethrows -> [ReverseSequence.Generator.Element] {
        var result: [ReverseSequence.Generator.Element] = []
        let generator = generate()
        while let i = generator.next() , try includeElement(i){
            result.append(try i )
        }
        return result
    }
    func map<T>(  transform: (ReverseSequence.Generator.Element) throws -> T) rethrows -> [T]{
        var ts: [T] = []
        let generator = generate()
        while let i = generator.next(){
            ts.append(try transform(i))
        }
        return ts
    }
    
    var array: [T]
    init(array: [T]) {
        self.array = array
    }
    
    func generate() -> CountdownGenerator {
        return CountdownGenerator(array: array)
    }
}




let reverseSequence = ReverseSequence(array: xs)
let reverseGenerator = reverseSequence.generate()
while let i = reverseGenerator.next(){
    print("Index \(i) is \(xs[i ])")
}
//for i in ReverseSequence(array: xs) {
//    print("Index \(i) is \(xs[i ])")
//}
let reverseElements = try ReverseSequence(array: xs).map { xs[$0] }
for x in reverseElements {
    print("Element is \(x)")
}
