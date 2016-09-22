import UIKit

protocol Type {
    func printInformation()
}
struct PointStruct:Type {
    var x: Int
    var y: Int
    let type = "Struct"
    func printInformation() {
        print("\(type) value is \(x)")
    }
}

class PointClass: Type {
    var x:Int
    var y:Int
    let type = "Class"
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    func printInformation() {
        print("\(type) value is \(x)")
    }
}


func setStructToOrigin(point: PointStruct) -> PointStruct {
    var point = point
    point.x = 0
    point.y = 0
    return point
}

func setClassToOrigin(point: PointClass) -> PointClass {
    point.x = 0
    point.y = 0
    return point
}


func printPoint <T: Type>( point : T ){
    point.printInformation()
}

//using structs
var structPoint = PointStruct(x: 1, y: 2)
var sameStructPoint = structPoint
sameStructPoint.x = 3

printPoint(point: structPoint)
printPoint(point: sameStructPoint)

//using classes
var classPoint = PointClass(x: 1, y: 2)
var someClassPoint = classPoint
someClassPoint.x = 3

var structOrigin: PointStruct = setStructToOrigin(point: structPoint)s

var classOrigin = setClassToOrigin(point: classPoint)
printPoint(point: classPoint)
printPoint(point: classOrigin)


let immutablePoint = PointStruct(x: 0, y: 0)
//immutablePoint = PointStruct(x: 2, y: 2) <- not acceptable because we use let

/*
 If we declare the x and y properties within the struct using the let keyword, then we can’t ever change them after initialization, no matter whether the variable holding the point instance is mutable or immutable:
 struct ImmutablePointStruct { let x: Int
 let y: Int }
 
 
 var immutablePoint2 = ImmutablePointStruct(x: 1, y: 1) immutablePoint2.x = 3 // Rejected!
 Of course, we can still assign a new value to immutablePoint2: immutablePoint2 = ImmutablePointStruct(x: 2, y: 2)
 
 */





