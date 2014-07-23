//
//  SimpleMapViewController.swift
//  swift-samples
//
//  Created by Jeff Jackson on 7/22/14.
//  Copyright (c) 2014 Esri. All rights reserved.
//

import ArcGIS

class SimpleMapViewController: UIViewController {

    @IBOutlet weak var mapView: AGSMapView!
    
    init() {
        super.init(nibName: nil, bundle: nil)
        navigationItem.title = "Simple Map"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let layer = AGSTiledMapServiceLayer(URL: NSURL(string: "http://services.arcgisonline.com/arcgis/rest/services/World_Topo_Map/MapServer"))
        mapView.addMapLayer(layer)
        
        let center = AGSPoint.pointWithX(-7822565, y: 5413016, spatialReference: nil)
        mapView.zoomToScale(72112, withCenterPoint:center, animated: true)
    }

}
