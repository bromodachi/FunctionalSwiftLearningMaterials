import Cocoa

//extension NSGraphicsContext {
//    var cgContext: CGContext {
//        let opaqueContext = OpaquePointer(self.graphicsPort)
//        return Unmanaged<CGContext>.fromOpaque(opaqueContext)
//            .takeUnretainedValue()
//    }
//}
//
//extension Sequence where Iterator.Element == CGFloat {
//    func normalize() -> [CGFloat] {
//        let maxVal = self.reduce(0) { max($0, $1) }
//        return self.map { $0 / maxVal }
//    }
//}


extension CGRect {
    func split(_ ratio: CGFloat, edge: CGRectEdge) -> (CGRect, CGRect) {
        let length = edge.isHorizontal ? width : height
        return divided(atDistance: length * ratio, from: edge)
    }
}

extension CGRectEdge {
    var isHorizontal: Bool {
        return self == .maxXEdge || self == .minXEdge;
    }
}


func *(l: CGFloat, r: CGSize) -> CGSize {
    return CGSize(width: l * r.width, height: l * r.height)
}
func /(l: CGSize, r: CGSize) -> CGSize {
    return CGSize(width: l.width / r.width, height: l.height / r.height)
}
func *(l: CGSize, r: CGSize) -> CGSize {
    return CGSize(width: l.width * r.width, height: l.height * r.height)
}
func -(l: CGSize, r: CGSize) -> CGSize {
    return CGSize(width: l.width - r.width, height: l.height - r.height)
}
func -(l: CGPoint, r: CGPoint) -> CGPoint {
    return CGPoint(x: l.x - r.x, y: l.y - r.y)
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


enum Primitive {
    case ellipse
    case rectangle
    case text(String)
}

indirect enum Diagram {
    case prim(CGSize, Primitive)
    case beside(Diagram, Diagram)
    case below(Diagram, Diagram)
    case attributed(Attribute, Diagram)
    case align(CGVector, Diagram)
}

enum Attribute {
    case fillColor(NSColor)
}

extension Diagram {
    var size: CGSize {
        switch self {
        case .prim(let size, _):
            return size
        case .attributed(_, let x):
            return x.size
        case .beside(let l, let r):
            let sizeL = l.size
            let sizeR = r.size
            return CGSize(width: sizeL.width + sizeR.width,
                          height: max(sizeL.height, sizeR.height))
        case .below(let l, let r):
            return CGSize(width: max(l.size.width, r.size.width),
                          height: l.size.height + r.size.height)
        case .align(_, let r):
            return r.size
        }
    }
}


extension CGSize {
    func fit(_ vector: CGVector, _ rect: CGRect) -> CGRect {
        let scaleSize = rect.size / self
        let scale = min(scaleSize.width, scaleSize.height)
        let size = scale * self
        let space = vector.size * (size - rect.size)
        return CGRect(origin: rect.origin - space.point, size: size)
    }
    
}


extension CGContext {
    func draw(_ bounds: CGRect, _ diagram: Diagram) {
        switch diagram {
        case .prim(let size, .ellipse):
            let frame = size.fit(CGVector(dx: 0.5, dy: 0.5), bounds)
            self.fillEllipse(in: frame)
            // <</drawEllipse>>
        // <<drawRectangle>>
        case .prim(let size, .rectangle):
            let frame = size.fit(CGVector(dx: 0.5, dy: 0.5), bounds)
            self.fill(frame)
            // <</drawRectangle>>
        // <<drawText>>
        case .prim(let size, .text(let text)):
            let frame = size.fit(CGVector(dx: 0.5, dy: 0.5), bounds)
            let font = NSFont.systemFont(ofSize: 12)
            let attributes = [NSFontAttributeName: font]
            let attributedText = NSAttributedString(string: text, attributes: attributes)
            attributedText.draw(in: frame)
            // <</drawText>>
        // <<drawFill>>
        case .attributed(.fillColor(let color), let d):
            self.saveGState()
            color.set()
            draw(bounds, d)
            self.restoreGState()
            // <</drawFill>>
        // <<drawBeside>>
        case .beside(let left, let right):
            let (lFrame, rFrame) = bounds.split(
                left.size.width/diagram.size.width, edge: .minXEdge)
            draw(lFrame, left)
            draw(rFrame, right)
            // <</drawBeside>>
        // <<drawBelow>>
        case .below(let top, let bottom):
            let (lFrame, rFrame) = bounds.split(
                bottom.size.height/diagram.size.height, edge: .minYEdge)
            draw(lFrame, bottom)
            draw(rFrame, top)
            // <</drawBelow>>
        // <<drawAlign>>
        case .align(let vec, let diagram):
            let frame = diagram.size.fit(vec, bounds)
            draw(frame, diagram)
        }
    }
}


class Draw: NSView {
    let diagram: Diagram
    
    init(frame frameRect: NSRect, diagram: Diagram) {
        self.diagram = diagram
        super.init(frame:frameRect)
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current() else { return }
        context.cgContext.draw(self.bounds, diagram)
    }
}


extension Diagram {
    func pdf(_ width: CGFloat) -> Data {
        let height = width * (size.height / size.width)
        let v = Draw(frame: NSMakeRect(0, 0, width, height), diagram: self)
        return v.dataWithPDF(inside: v.bounds)
    }
}


func rect(width: CGFloat, height: CGFloat) -> Diagram {
    return .prim(CGSize(width: width, height: height), .rectangle)
}

func circle(diameter: CGFloat) -> Diagram {
    return .prim(CGSize(width: diameter, height: diameter), .ellipse)
}

func text(_ theText: String, width: CGFloat, height: CGFloat) -> Diagram {
    return .prim(CGSize(width: width, height: height), .text(theText))
}

func square(side: CGFloat) -> Diagram {
    return rect(width: side, height: side)
}

infix operator ||| { associativity left }
func ||| (l: Diagram, r: Diagram) -> Diagram {
    return Diagram.beside(l, r)
}

infix operator --- { associativity left }
func --- (l: Diagram, r: Diagram) -> Diagram {
    return Diagram.below(l, r)
}

extension Diagram {
    func fill(_ color: NSColor) -> Diagram {
        return .attributed(.fillColor(color), self)
    }
    
    func alignTop() -> Diagram {
        return .align(CGVector(dx: 0.5, dy: 1), self)
    }
    
    func alignBottom() -> Diagram {
        return .align(CGVector(dx: 0.5, dy: 0), self)
    }
}

let empty: Diagram = rect(width: 0, height: 0)

func hcat(_ diagrams: [Diagram]) -> Diagram {
    return diagrams.reduce(empty, |||)
}



let blueSquare = square(side: 1).fill(.blue())
let redSquare = square(side: 2).fill(.red())
let greenCircle = circle(diameter: 1).fill(.green())
let example1 = blueSquare ||| redSquare ||| greenCircle


let cyanCircle = circle(diameter: 1).fill(.cyan())
let example2 = blueSquare ||| cyanCircle ||| redSquare ||| greenCircle
