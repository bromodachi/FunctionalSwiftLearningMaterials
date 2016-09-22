//: Playground - noun: a place where people can play

import UIKit

typealias Position = CGPoint
typealias Distance = CGFloat

let minimumDistance: Distance = 2



typealias Region = (Position) -> Bool


func circle(radius:Distance) -> Region {
    return { point in
        return sqrt(point.x * point.x + point.y * point.y) <= radius
        
    }
}

func shift(offset: Position, region: @escaping Region) -> Region {
    return {
        point in
        let shiftedPoint = Position(x: point.x - offset.x , y: point.y - offset.y)
        return region(shiftedPoint)
    }
}


func difference(region: @escaping Region, minusRegion: @escaping Region) -> Region{
    return intersection(region1: region, region2: invert(region: minusRegion))
}
func invert(region: @escaping Region) -> Region {
    return  { point in
        !region(point)
    }
}

func union(region1: @escaping Region, region2: @escaping Region) -> Region {
    return { point in
        region1(point) && region2(point)
    }
}
func intersection(region1: @escaping Region, region2: @escaping Region) -> Region {
    return {
        point in region1(point) && region2(point)
    }
}


func inRange(ownPosition: Position, target: Position, friendly: Position, range: Distance) -> Bool {
    let rangeRegion = difference(region: circle(radius:range), minusRegion: circle(radius: minimumDistance))
    let targetRegion = shift(offset: ownPosition, region: rangeRegion)
    let friendlyRegion = shift(offset: friendly, region: circle(radius: minimumDistance))
    let resultRegion = difference(region: targetRegion, minusRegion: friendlyRegion)
    return resultRegion(target)
    
}

let position = Position(x: 2, y: 2)
let target = Position(x: 3, y: 3)
let friendly = Position(x: 0, y: 0)
let range: Distance = 5
let circlePosition = Position(x: 0, y: 0)
inRange(ownPosition: position, target: target, friendly: friendly, range: range)
//let circleVar = circle(radius: 5, center: circlePosition)
//print(shift(offset: position, region: circleVar))
