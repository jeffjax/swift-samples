//
//  QueryWithCompletionViewController.swift
//  swift-samples
//
//  Created by Eric Ito on 7/29/14.
//  Copyright (c) 2014 Esri. All rights reserved.
//

import UIKit
import ArcGIS

class QueryWithCompletionViewController: UIViewController {
    
    @IBOutlet weak var mapView: AGSMapView! = nil
    
    var queryTask = AGSQueryTask(URL: NSURL(string: "http://services.arcgisonline.com/arcgis/rest/services/Demographics/USA_2000-2010_Population_Change/MapServer/4"))
    
    var graphicsLayer = AGSGraphicsLayer(fullEnvelope: nil, renderingMode: AGSGraphicsLayerRenderingModeDynamic)
    
    override func viewDidLoad() {
        
        self.mapView.addMapLayer(AGSOpenStreetMapLayer())
        self.mapView.addMapLayer(self.graphicsLayer)
        
        var query = AGSQuery()
        
        // NOTE: if a property is also a keyword, you need to wrap it in backticks (`)
        query.`where` = "NAME like '%California%'"
        query.outFields = ["*"]
        query.returnGeometry = true
        query.maxAllowableOffset = 100
        
        // query features
        self.queryTask.executeQuery(query){ (featureSet, error) in
            if let e = error {
                println("error: \(e)")
            } else if let fs = featureSet {
                println("found \(fs.features.count) results -- (1 expected)")
                for feature in fs.features {
                    if let g = feature as? AGSGraphic {
                        g.symbol = AGSSimpleFillSymbol(color: UIColor.blueColor(), outlineColor: UIColor.whiteColor())
                        self.graphicsLayer.addGraphic(g)
                    }
                }
                self.mapView.zoomToExpandedEnvelope(self.graphicsLayer.fullEnvelope, factor: 1.1)
            } else {
                println("AHHHH! We shouldn't be here")
            }
        }
        
        // query objectIDs
        self.queryTask.executeForIDsWithQuery(query) { (objectIDs, error) in
            if let e = error {
                println("error: \(e)")
            } else if let objectIDs = objectIDs {
                println("found \(objectIDs.count) objectID(s) -- (1 expected)")
            } else {
                println("AHHHH! We shouldn't be here")
            }
        }
        
        // query count
        self.queryTask.executeFeatureCountWithQuery(query) { (count, error) in
            if let e = error {
                println("error: \(error)")
            } else if let count = count {
                println("found \(count) state for query -- (1 expected)")
            } else {
                println("AHH! shouldn't be here")
            }
        }
        
    }
}