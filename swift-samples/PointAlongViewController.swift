//
//  PointAlongViewController.swift
//  swift-samples
//
//  Created by Jeff Jackson on 7/22/14.
//  Copyright (c) 2014 Esri. All rights reserved.
//

import ArcGIS

let topoServer = "http://services.arcgisonline.com/arcgis/rest/services/World_Topo_Map/MapServer"

class PointAlongViewController: UIViewController {

    @IBOutlet weak var mapView: AGSMapView!
    
    let routeLayer = AGSGraphicsLayer(fullEnvelope: nil, renderingMode: AGSGraphicsLayerRenderingModeDynamic)
    let markerLayer = AGSGraphicsLayer(fullEnvelope: nil, renderingMode: AGSGraphicsLayerRenderingModeDynamic)
    
    let points = [
        AGSPoint(x: -7820862.13023463, y: 5414803.92416079, spatialReference: nil),
        AGSPoint(x: -7820900.18354395, y: 5415636.25139585, spatialReference: nil),
        AGSPoint(x: -7820866.88624749, y: 5415931.20041900, spatialReference: nil),
        AGSPoint(x: -7822194.78308598, y: 5416917.91225412, spatialReference: nil),
        AGSPoint(x: -7823862.15979247, y: 5418113.37710301, spatialReference: nil),
        AGSPoint(x: -7824493.93791743, y: 5419176.56359161, spatialReference: nil),
        AGSPoint(x: -7825206.29486280, y: 5423462.06388209, spatialReference: nil),
    ]
    
    var endPointSymbol : AGSMarkerSymbol { get {
        let symbol = AGSSimpleMarkerSymbol(color: UIColor.orangeColor())
        symbol.size = CGSize(width: 25, height: 25)
        symbol.style = AGSSimpleMarkerSymbolStyleDiamond
        symbol.outline = nil
        return symbol
    }}

    init() {
        super.init(nibName: nil, bundle: nil)
        navigationItem.title = "Poing Along Polyline"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup the map layers
        //
        mapView.addMapLayer(AGSTiledMapServiceLayer(URL: NSURL(string: topoServer)))
        mapView.addMapLayer(routeLayer)
        mapView.addMapLayer(markerLayer)
        
        // create a the polyline and add it
        //
        let line = AGSMutablePolyline()
        line.addPathToPolyline()
        
        for point in points {
            line.addPointToPath(point)
        }
        
        let lineColor = UIColor(red: 0.243, green: 0.6, blue: 0.964, alpha: 0.75)
        routeLayer.addGraphic(AGSGraphic(geometry: line, symbol: AGSSimpleLineSymbol(color: lineColor, width: 8), attributes: nil))
       
        // add graphcis to show the end points
        //
        routeLayer.addGraphic(AGSGraphic(geometry: points[0], symbol: endPointSymbol, attributes: nil))
        routeLayer.addGraphic(AGSGraphic(geometry: points[points.count - 1], symbol: endPointSymbol, attributes: nil))
        
        // zoom into the area
        //
        mapView.zoomToEnvelope(line.envelope, animated: true)
    }
    

}
