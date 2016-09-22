//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"


func intAdder(number: Int) -> Int {
    return number + 1
}

intAdder(number: 15)
//intAdder(number: 15.0)

func doubleAdder(number: Double) ->Double {
    return number + 1
}

doubleAdder(number: 15.0)

func genericAdder<T: Strideable> (number: T ) -> T { //conform to the Strideable protocol.
    return number + 1
}

genericAdder(number: 15)
genericAdder(number: 15.0)

func intMultiplier(lhs: Int, rhs: Int) -> Int {
    return lhs * rhs
}
intMultiplier(lhs: 2, rhs: 5)

func genericMultiplies(lhs: Double, rhs: Double) -> Double {
     return lhs * rhs
}

protocol Numeric {
    func *(lhs: Self, rhf: Self) -> Self
    
}

extension Double:Numeric {}
extension Float:Numeric {}
extension Int:Numeric {}
func genericMultipler<T: Numeric> (lhs: T, rhs: T) -> T {
    return lhs * rhs
}
genericMultipler(lhs: 2.4, rhs: 2.5)
genericMultipler(lhs: 2.4, rhs: 7)

genericMultipler(lhs: 1.5, rhs: 1.5)