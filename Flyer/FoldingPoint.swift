//
//  FoldedPoint.swift
//  
//
//  Created by David Williams on 11/27/19.
//

import Cocoa

class FoldingPoint: NSObject {
    private var value: CGPoint
    private let bounds: CGSize
    
    static private func foldedValue( value: CGFloat, span: CGFloat ) -> CGFloat {
        let halfSpan = span/2;
        if value > halfSpan {
            return (value + halfSpan).truncatingRemainder(dividingBy: span) - halfSpan
        }
        else if value < -halfSpan {
            return (value - halfSpan).truncatingRemainder(dividingBy: span) + halfSpan
        }
        return value
    }
    
    init( value: CGPoint, bounds: CGSize ) {
        self.value = CGPoint(
            x: FoldingPoint.foldedValue(value: value.x, span: bounds.width),
            y: FoldingPoint.foldedValue(value: value.y, span: bounds.height)
        )
        self.bounds = bounds
    }
    
    func push( direction: CGPoint, magnitude: CGFloat ) {
        value.x = FoldingPoint.foldedValue(value: value.x + direction.x*magnitude, span: bounds.width)
        value.y = FoldingPoint.foldedValue(value: value.y + direction.y*magnitude, span: bounds.height)
    }
    
    var position : CGPoint {
        set {
            self.value = CGPoint(
                x: FoldingPoint.foldedValue(value: newValue.x, span: bounds.width),
                y: FoldingPoint.foldedValue(value: newValue.y, span: bounds.height)
            )
        }
        get {
            self.value
        }
    }
    
    func closestLine( target: CGPoint ) -> CGPoint {
        var dx = target.x - value.x
        var dy = target.y - value.y
        
        let halfWidth = bounds.width/2
        if dx > halfWidth {
            dx -= bounds.width
        }
        else if dx < -halfWidth {
            dx += bounds.width
        }

        let halfHeight = bounds.height/2
        if dy > halfHeight {
            dy -= bounds.height
        }
        else if dy < -halfHeight {
            dy += bounds.height
        }
        
        return CGPoint(x:dx, y:dy)
    }
    
    func smallestSquareDistance( target: CGPoint ) -> CGFloat {
        let xbound = bounds.width/2
        let ybound = bounds.height/2

        var dx = value.x - target.x
        var dy = value.y - target.y
        
        if dx > xbound {
            dx -= 2*xbound
        } else if dx < -xbound {
            dx += 2*xbound
        }
        
        if dy > ybound {
            dy -= 2*ybound
        } else if dx < -ybound {
            dy += 2*ybound
        }
        
        return dx*dx + dy*dy
    }
}
