import Cocoa

struct NSRectCorner : OptionSetType {
    let rawValue: Int
    init(rawValue: Int) { self.rawValue = rawValue }
    
    static let None = NSRectCorner(rawValue: 0)
    static let TopLeft = NSRectCorner(rawValue: 1<<0)
    static let TopRight = NSRectCorner(rawValue: 1<<1)
    static let BottomLeft = NSRectCorner(rawValue: 1<<2)
    static let BottomRight = NSRectCorner(rawValue: 1<<3)
    static let AllCorners: NSRectCorner = [TopLeft, TopRight, BottomLeft, BottomRight]
}
  
protocol NSBezierPathExtension {
    var CGPath:CGPathRef! {get set}
    func addLineToPoint(point: NSPoint)
    func addCurveToPoint(endPoint: NSPoint, controlPoint1: NSPoint, controlPoint2: NSPoint)
    func addQuadCurveToPoint(endPoint: NSPoint, controlPoint: NSPoint)
    func addArcWithCenter(center: NSPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, clockwise: Bool)
    func appendPath(path: NSBezierPath!)
}

extension NSBezierPath: NSBezierPathExtension {
    var CGPath: CGPathRef! {
        get {
            let path = CGPathCreateMutable()
            var points = Array(count: 3, repeatedValue: NSPoint())
            
            for index in 0..<self.elementCount {
                let pathType = self.elementAtIndex(index, associatedPoints: &points)
                switch pathType {
                case .MoveToBezierPathElement:
                    CGPathMoveToPoint(path, nil, points[0].x, points[0].y)
                case .LineToBezierPathElement:
                    CGPathAddLineToPoint(path, nil, points[0].x, points[0].y)
                case .CurveToBezierPathElement:
                    CGPathAddCurveToPoint(path, nil, points[0].x, points[0].y, points[1].x, points[1].y, points[2].x, points[2].y)
                case .ClosePathBezierPathElement:
                    CGPathCloseSubpath(path)
                }
            }
            return path
        }
        set {
            if let newPath = newValue {
                NSBezierHandler.bezierPathWithPath(newPath, onBezier: self)
            } else {
                NSBezierHandler.bezierPathWithPath(CGPathCreateMutable(), onBezier: self)
            }
        }
    }
    
    func addLineToPoint(point: NSPoint) {
        self.lineToPoint(point)
    }
    
    func addCurveToPoint(endPoint: NSPoint, controlPoint1: NSPoint, controlPoint2: NSPoint) {
        self.curveToPoint(endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
    }
    
    func addQuadCurveToPoint(endPoint: NSPoint, controlPoint: NSPoint) {
        let QP0 = self.currentPoint
        let CP3 = endPoint
        
        let CP1 = CGPointMake(
            QP0.x + ((2.0 / 3.0) * (controlPoint.x - QP0.x)),
            QP0.y + ((2.0 / 3.0) * (controlPoint.y - QP0.y))
        )
        let CP2 = CGPointMake(
            endPoint.x + (2.0 / 3.0) * (controlPoint.x - endPoint.x),
            endPoint.y + (2.0 / 3.0) * (controlPoint.y - endPoint.y)
        )
        self.addCurveToPoint(CP3, controlPoint1: CP1, controlPoint2: CP2)
    }
    
    func addArcWithCenter(center: NSPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, clockwise: Bool) {
        let startAngleRadian = ((startAngle) * CGFloat(180.0 / M_PI))
        let endAngleRadian = ((endAngle) * CGFloat(180.0 / M_PI))
        self.appendBezierPathWithArcWithCenter(center, radius: radius, startAngle: startAngleRadian, endAngle: endAngleRadian)
    }
    
    func appendPath(path: NSBezierPath!) {
        self.appendBezierPath(path)
    }
}

private func pathApplier(info: UnsafeMutablePointer<Void>, element: UnsafePointer<CGPathElement>) -> Void {
    let bezierPointer = unsafeBitCast(info, UnsafeMutablePointer<NSBezierPath>.self)
    let path = bezierPointer.memory
    let element = element.memory
    let points = element.points
    
    switch element.type {
    case .MoveToPoint:
        path.moveToPoint(NSMakePoint(points[0].x, points[0].y))
    case .AddLineToPoint:
        path.lineToPoint(NSMakePoint(points[0].x, points[0].y))
    case .AddQuadCurveToPoint:
        let currentPoint = path.currentPoint
        let interpolatedPoint = NSMakePoint((currentPoint.x + 2*points[0].x) / 3, (currentPoint.y + 2*points[0].y) / 3)
        path.curveToPoint(NSMakePoint(points[1].x, points[1].y), controlPoint1: interpolatedPoint, controlPoint2: interpolatedPoint)
    case .AddCurveToPoint:
        path.curveToPoint(NSMakePoint(points[2].x, points[2].y), controlPoint1: NSMakePoint(points[0].x, points[0].y), controlPoint2: NSMakePoint(points[1].x, points[1].y))
    case .CloseSubpath:
        path.closePath()
    }
}

private class NSBezierHandler {
    class func bezierPathWithPath(path: CGPathRef, onBezier bezier: NSBezierPath) {
        let info = UnsafeMutablePointer<NSBezierPath>()
        info.memory = bezier
        CGPathApply(path, info, pathApplier)
    }
}
  