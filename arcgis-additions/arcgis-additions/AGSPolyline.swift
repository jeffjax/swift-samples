//
//  AGSPolyline.swift
//  arcgis-additions
//
//  Created by Jeff Jackson on 7/22/14.
//  Copyright (c) 2014 Esri. All rights reserved.
//

import ArcGIS

extension AGSPolyline {
    func pointAlong(distance: Double) -> AGSPoint? {
        
        let engine = AGSGeometryEngine.defaultGeometryEngine()
        
        var total : Double = 0
        for var i = 1; i < numPointsInPath(0); ++i {
            let p0 = pointOnPath(0, atIndex: i - 1)
            let p1 = pointOnPath(0, atIndex: i)
            
            let segLength = engine.geodesicDistanceBetweenPoint1(p0, point2: p1, inUnit: spatialReference.unit())
            
            if total + segLength.distance >=  distance {
                let points = engine.geodesicMovePoints([p0], byDistance: distance - total, inUnit: spatialReference.unit(), azimuth: segLength.azimuth1) as Array<AGSPoint>
                return points[0]
                
            } else {
                total += segLength.distance
            }
        }
        
        return nil
    }
    
    func distanceFromStart(toPoint: AGSPoint) -> Double {
        let engine = AGSGeometryEngine.defaultGeometryEngine()
        let proximity2 = engine.nearestCoordinateInGeometry(self, toPoint: toPoint)
        let cutter = AGSMutablePolyline(spatialReference: spatialReference)
        cutter.addPathToPolyline()
        cutter.addPointToPath(AGSPoint(x: proximity2.point.x, y: proximity2.point.y - 10, spatialReference: proximity2.point.spatialReference))
        cutter.addPointToPath(AGSPoint(x: proximity2.point.x, y: proximity2.point.y + 10, spatialReference: proximity2.point.spatialReference))
        
        if let result = engine.cutGeometry(self, withCutter: cutter) as [AGSPolyline]! {
            if result.count == 0 {
                return 0
            } else if result.count == 1 {
                if result[0].pointOnPath(0, atIndex: 0).isEqualToPoint(self.pointOnPath(0, atIndex: 0)) {
                    return engine.geodesicLengthOfGeometry(result[0], inUnit: spatialReference.unit())
                } else {
                    return 0
                }
           } else {
                if result[0].pointOnPath(0, atIndex: 0).isEqualToPoint(self.pointOnPath(0, atIndex: 0)) {
                    return engine.geodesicLengthOfGeometry(result[0], inUnit: spatialReference.unit())
                } else {
                    return engine.geodesicLengthOfGeometry(result[1], inUnit: spatialReference.unit())
                }
            }
        }
        return 0
    }

    func distanceFromEnd(toPoint: AGSPoint) -> Double {
        let engine = AGSGeometryEngine.defaultGeometryEngine()
        return engine.geodesicLengthOfGeometry(self, inUnit: spatialReference.unit()) - distanceFromStart(toPoint)
     }
}
