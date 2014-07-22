//
//  PointAlongViewController.swift
//  swift-samples
//
//  Created by Jeff Jackson on 7/22/14.
//  Copyright (c) 2014 Esri. All rights reserved.
//

import ArcGIS

class PointAlongViewController: UIViewController {

    @IBOutlet weak var mapView: AGSMapView!
    
    let graphicsLayer = AGSGraphicsLayer(fullEnvelope: nil, renderingMode: AGSGraphicsLayerRenderingModeDynamic)
    
    var markerSymbol : AGSMarkerSymbol { get {
        let symbol = AGSSimpleMarkerSymbol(color: UIColor.orangeColor())
        symbol.size = CGSize(width: 30, height: 30)
        symbol.style = AGSSimpleMarkerSymbolStyleDiamond
        symbol.outline = nil
        return symbol
    }}

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // add a basemap layer to the map
        //
        let layer = AGSTiledMapServiceLayer(URL: NSURL(string: "http://services.arcgisonline.com/arcgis/rest/services/World_Topo_Map/MapServer"))
        mapView.addMapLayer(layer)
        
        // setup the start and end points for our route
        //
        graphicsLayer.addGraphic(AGSGraphic(geometry: AGSPoint(x: -7819521.53924862, y: 5414305.58847304, spatialReference: nil), symbol: markerSymbol, attributes: nil))
        graphicsLayer.addGraphic(AGSGraphic(geometry: AGSPoint(x: -7825281.34279851, y: 5412808.28979497, spatialReference: nil), symbol: markerSymbol, attributes: nil))
        
        mapView.addMapLayer(graphicsLayer)
        
        // zoom into the area
        //
        let center = AGSPoint.pointWithX(-7822565.384422094, y: 5413016.324809469, spatialReference: nil)
        mapView.zoomToScale(36111.909643, withCenterPoint:center, animated: true)
    }

}
