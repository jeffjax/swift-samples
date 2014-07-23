//
//  AGSPolyline.swift
//  swift-samples
//
//  Created by Jeff Jackson on 7/23/14.
//  Copyright (c) 2014 Esri. All rights reserved.
//

import ArcGIS

extension AGSPolyline {
    
    // Calculate a point along the polyline.
    //
    func pointAlong(distance: Double) -> AGSPoint? {
        
        let engine = AGSGeometryEngine.defaultGeometryEngine()
        
        // iterate over eacah segment of the polyline
        //
        var total : Double = 0
        for var i = 1; i < numPointsInPath(0); ++i {
            let p0 = pointOnPath(0, atIndex: i - 1)
            let p1 = pointOnPath(0, atIndex: i)
            
            // calculate the length of the segment
            //
            let segLength = engine.geodesicDistanceBetweenPoint1(p0, point2: p1, inUnit: spatialReference.unit())
            
            // if adding the entire segment brings us over the required distance then 
            // we've done - just need to calculate the last point and return it
            //
            if total + segLength.distance >=  distance {
                let points = engine.geodesicMovePoints([p0], byDistance: distance - total, inUnit: spatialReference.unit(), azimuth: segLength.azimuth1) as Array<AGSPoint>
                return points[0]
                
            } else {
                total += segLength.distance
            }
        }
        
        return nil
    }
    
    func reverseDirection() -> AGSPolyline {
        let result = AGSMutablePolyline(spatialReference: spatialReference)
        
        for i in reverse(0..<numPaths) {
            result.addPathToPolyline()
            
            for j in reverse(0..<numPointsInPath(i)) {
                result.addPointToPath(pointOnPath(i, atIndex: j))
            }
        }
        return result
    }
}