//
//  PointAlongViewController.swift
//  swift-samples
//
//  Created by Jeff Jackson on 7/22/14.
//  Copyright (c) 2014 Esri. All rights reserved.
//  
//  This sample uses the AGSPolyline.pointAlong() method to display mile markers along a route on the map.
//

import ArcGIS

let topoServer = "http://services.arcgisonline.com/arcgis/rest/services/World_Topo_Map/MapServer"

class PointAlongViewController: UIViewController {

    @IBOutlet weak var mapView: AGSMapView! = nil
    
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
        symbol.size = CGSize(width: 18, height: 18)
        symbol.style = AGSSimpleMarkerSymbolStyleDiamond
        symbol.outline.color = UIColor.whiteColor()
        return symbol
    }}

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup our UI
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reverse", style: .Plain, target: self, action: Selector("reverseDirection:"))

        // setup the map layers
        //
        mapView.addMapLayer(AGSTiledMapServiceLayer(URL: NSURL(string: topoServer)))
        mapView.addMapLayer(routeLayer)
        mapView.addMapLayer(markerLayer)
        
        // setup the polyline
        //
        let polyline = AGSMutablePolyline(spatialReference: AGSSpatialReference(WKID: 102100))
        polyline.addPathToPolyline()
        
        for point in points {
            polyline.addPointToPath(point)
        }
        
        let lineColor = UIColor(red: 0.243, green: 0.6, blue: 0.964, alpha: 0.75)
        routeLayer.addGraphic(AGSGraphic(geometry: polyline, symbol: AGSSimpleLineSymbol(color: lineColor, width: 8), attributes: nil))
       
        // add graphcis to show the end points
        //
        routeLayer.addGraphic(AGSGraphic(geometry: points[0], symbol: endPointSymbol, attributes: nil))
        routeLayer.addGraphic(AGSGraphic(geometry: points[points.count - 1], symbol: endPointSymbol, attributes: nil))
        
        generateMileMarkers()
        
        // zoom into the area
        //
        mapView.zoomToExpandedEnvelope(polyline.envelope, factor: 1.5)
    }
    
    // generates points along the route at every mile
    //
    func generateMileMarkers() {
        markerLayer.removeAllGraphics()
        
        if let polyline = routeLayer.graphics[0].geometry as? AGSPolyline {
            
            let length = AGSGeometryEngine.defaultGeometryEngine().lengthOfGeometry(polyline)
            var distance : Double = AGSUnitsToUnits(1, AGSUnitsMiles, AGSUnitsMeters)
            
            for var mile = 1; distance < length; mile++ {
                if let point = polyline.pointAlong(distance) {
                    let graphic = AGSGraphic(geometry: point, symbol: mileMarkerSymbol(mile), attributes: nil)
                    markerLayer.addGraphic(graphic)
                } else {
                    break
                }
                distance += AGSUnitsToUnits(1, AGSUnitsMiles, AGSUnitsMeters)
            }
        }
    }
    
    // creates a multi-layer point symbol that shows the mile number
    //
    func mileMarkerSymbol(mile: Int) -> AGSSymbol {
        
        let bg = AGSSimpleMarkerSymbol(color: UIColor.orangeColor())
        bg.size = CGSize(width: 20, height: 20)
        bg.style = AGSSimpleMarkerSymbolStyleCircle
        bg.outline = nil
        
        let ts = AGSTextSymbol(text: NSString(format: "%d", mile), color: UIColor.whiteColor() )
        
        let cs = AGSCompositeSymbol()
        cs.addSymbol(bg)
        cs.addSymbol(ts)
        
        return cs
    }

    // reverses the direction of the polyline that represents the route
    //
    func reverseDirection(sender: AnyObject) {
        let graphic = routeLayer.graphics[0] as AGSGraphic
        if let polyline = graphic.geometry as? AGSPolyline {
            graphic.geometry = polyline.reverseDirection()
            generateMileMarkers()
        }
    }

}
