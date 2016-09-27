

import UIKit
import CoreGraphics


enum Primitive {
    case Ellipse
    case Rectangle
    case Text(String)
}
enum Attribute {
    case FillColor(CGColor)
}

indirect enum Diagram {
    case Prim(CGSize, Primitive)
    case Beside(Diagram, Diagram)
    case Below(Diagram, Diagram)
    case Attributed(Attribute, Diagram)
    case Align(CGVector, Diagram)
}

extension Diagram {
    func fill(color: CGColor) -> Diagram {
        return .Attributed(.FillColor(color), self)
    }
    
    func alignTop() -> Diagram {
        return .Align(CGVector(dx: 0.5, dy: 1), self)
    }
    
    func alignBottom() -> Diagram {
        return .Align(CGVector(dx: 0.5, dy: 0), self)
    }
}


func rect(width: CGFloat, height: CGFloat) -> Diagram {
    return .Prim(CGSize(width: width, height: height), .Rectangle)
}


func square(side: CGFloat) -> Diagram {
    return rect(width: side, height: side)
}

func circle(diameter: CGFloat) -> Diagram {
    return .Prim(CGSize(width:diameter, height: diameter), .Ellipse)
}

func text(theText: String, width: CGFloat, height: CGFloat) -> Diagram {
    return .Prim(CGSize(width: width, height: height), .Text(theText))
}

infix operator ||| { associativity left }
func ||| (l: Diagram, r: Diagram) -> Diagram {
    return Diagram.Beside(l, r)
}

infix operator --- { associativity left }
func --- (l: Diagram, r: Diagram) -> Diagram {
    return Diagram.Below(l, r)
}

let blueSquare = square(side: 1).fill(color: UIColor.blue.cgColor)
let redSquare = square(side: 2).fill(color: UIColor.red.cgColor)
let greenCircle = circle(diameter: 1).fill(color: UIColor.green.cgColor)

let cyanCircle = circle(diameter: 1).fill(color: UIColor.cyan.cgColor)
let example1 = blueSquare ||| redSquare ||| greenCircle

