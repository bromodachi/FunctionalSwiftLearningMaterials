

import UIKit
import CoreGraphics

/*
 Come back to this chapter and maybe implement it for iOS. I skimmed through this since it was for Mac.
 */


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

extension Diagram {
    var size: CGSize {
        switch self {
        
        case .Prim(let size, _):
            return size
        case .Attributed(_, let x):
            return x.size
        case .Beside(let l, let r):
            let sizeLeft = l.size
            let sizeRight = r.size
            return CGSize(width: sizeLeft.width + sizeRight.width , height: max(sizeLeft.height , sizeRight.height))
        case .Below(let l, let r ):
            let sizeLeft = l.size
            let sizeRight = r.size
            return CGSize(width: max(sizeLeft.width, sizeRight.width), height: sizeLeft.height + sizeRight.height)
        case .Align(_, let r):
            return r.size
        }
    }
    
}

//extension CGContext {
//    func draw(bounds: CGRect, _ diagram: Diagram) {
//        switch diagram {
//        case .Prim(let size, .Ellipse):
//            let frame = size.fit(vector: CGVector(dx: 0.5, dy: 0.5), rect: bounds)
//            self.fillEllipse(in: frame)
//        case .Prim(let size, .Rectangle):
//            let frame = size.fit(vector: CGVector(dx: 0.5, dy: 0.5), rect: bounds)
//            self.fill(frame)
//            // <</drawRectangle>>
//        // <<drawText>>
//        case .Prim(let size, .Text(let text)):
//            let frame = size.fit(vector: CGVector(dx: 0.5, dy: 0.5), rect: bounds)
//            let font = UIFont.systemFont(ofSize: 12)
//            let attributes = [NSFontAttributeName: font]
//            let attributedText = NSAttributedString(string: text, attributes: attributes)
//            attributedText.draw(in: frame)
//        case .Attributed(.FillColor(let color), let d):
//            self.saveGState()
//            color.set()
//            draw(bounds, d)
//            self.restoreGState()
//        case .Beside(let left, let right):
//            let (lFrame, rFrame) = bounds.split(
//                left.size.width/diagram.size.width, edge: .MinXEdge)
//            draw(lFrame, left)
//            draw(rFrame, right)
//        case .Below(let top, let bottom):
//            let (lFrame, rFrame) = bounds.split(
//                bottom.size.height/diagram.size.height, edge: .MinYEdge)
//            draw(lFrame, bottom)
//            draw(rFrame, top)
//
//        case .Align(let vec, let diagram):
//            let frame = diagram.size.fit(vec, bounds)
//            draw(frame, diagram)
//        }
//    }
//}

extension Sequence where Iterator.Element ==  CGFloat {
    func normalize() -> [CGFloat] {
        let maxVal = self.reduce(0){ Swift.max($0,  $1)}
        return self.map {$0 / maxVal}
    }
}

func*(l: CGFloat,r: CGSize)->CGSize{
    return CGSize(width: l * r.width, height: l * r.height)
}
func /( l : CGSize, r: CGSize) -> CGSize {
    return CGSize(width: l.width/r.width, height: l.height / r.height) }
func*(l: CGSize,r: CGSize)->CGSize{
    return CGSize(width: l.width * r.width, height: l.height * r.height)
}
func -( l : CGSize, r: CGSize) -> CGSize {
    return CGSize(width:l.width-r.width,height: l.height - r.height) }
func -( l : CGPoint, r: CGPoint) -> CGPoint { return CGPoint(x: l.x - r.x, y: l.y - r.y)
}


extension CGSize {
    var point: CGPoint {
        return CGPoint(x: self.width, y: self.height)
    }
}
extension CGVector {
    var point: CGPoint { return CGPoint(x: dx, y: dy) }
    var size: CGSize { return CGSize(width: dx, height: dy) }
}

extension CGSize {
    func fit(vector: CGVector, rect: CGRect ) -> CGRect {
        let scaleSize = rect.size / self
        let scale = min(scaleSize.width, scaleSize.height)
        let size = scale * self
        let space = vector.size * (size - rect.size)
        return CGRect(origin: rect.origin - rect.origin , size: size)
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

let empty: Diagram = rect(width: 0, height: 0)

func hcat(diagrams: [Diagram]) -> Diagram {
    return diagrams.reduce(empty, |||)
}

precedencegroup threeBars {
    associativity: left
}
infix operator ||| : threeBars
func ||| (l: Diagram, r: Diagram) -> Diagram {
    return Diagram.Beside(l, r)
}

infix operator --- : threeBars
func --- (l: Diagram, r: Diagram) -> Diagram {
    return Diagram.Below(l, r)
}

let blueSquare = square(side: 1).fill(color: UIColor.blue.cgColor)
let redSquare = square(side: 2).fill(color: UIColor.red.cgColor)
let greenCircle = circle(diameter: 1).fill(color: UIColor.green.cgColor)

let cyanCircle = circle(diameter: 1).fill(color: UIColor.cyan.cgColor)
let example1 = blueSquare ||| redSquare ||| greenCircle
let example2 = blueSquare ||| cyanCircle ||| redSquare ||| greenCircle


func barGraph(input: [(String, Double)]) -> Diagram {
    let values: [CGFloat] = input.map { CGFloat($0.1)}
    let nValues = values.normalize()
    let bars = hcat(diagrams: nValues.map { (x: CGFloat) -> Diagram in
        return rect(width: 1, height: 3*x).fill(color: UIColor.black.cgColor).alignBottom()
    })
    let labels = hcat(diagrams: input.map{ x in
        return text(theText: x.0, width: 1, height: 0.3).alignTop()
    })
    return bars --- labels
    
}
let cities = [ "Shanghai": 14.01, "Istanbul": 13.3, "Moscow": 10.56, "New York": 8.33, "Berlin": 3.43]
let example3 = barGraph(input: Array(cities))

CGSize(width: 1, height: 1).fit (
    vector: CGVector(dx: 0.5, dy: 0.5), rect: CGRect(x: 0, y: 0, width: 200, height: 100))

CGSize(width: 1, height: 1).fit(
    vector: CGVector(dx: 0, dy: 0.5), rect: CGRect(x: 0, y: 0, width: 200, height: 100))


