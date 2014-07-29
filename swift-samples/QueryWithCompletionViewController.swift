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
        query.`where` = "NAME like '%California%'"
        query.outFields = ["*"]
        query.returnGeometry = true
        query.maxAllowableOffset = 100
        self.queryTask.executeQuery(query){ (featureSet, error) in
            if let e = error {
                println("error: \(e)")
            } else if let fs = featureSet {
                println("found: \(fs.features.count) results")
                for feature in fs.features {
                    if let g = feature as? AGSGraphic {
                        g.symbol = AGSSimpleFillSymbol(color: UIColor.blueColor(), outlineColor: UIColor.whiteColor())
                        self.graphicsLayer.addGraphic(g)
                    }
                }
            } else {
                println("AHHHH! We shouldn't be here")
            }
        }
        
    }
}