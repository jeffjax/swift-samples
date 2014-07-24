//
//  SuggestViewController.swift
//  swift-samples
//
//  Created by Jeff Jackson on 7/23/14.
//  Copyright (c) 2014 Esri. All rights reserved.
//

import ArcGIS

class SuggestViewController: UIViewController {

    @IBOutlet weak var mapView: AGSMapView! = nil
    
    var searchVC : SearchViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: Selector("showSearch:"))

        let layer = AGSTiledMapServiceLayer(URL: NSURL(string: "http://services.arcgisonline.com/arcgis/rest/services/World_Topo_Map/MapServer"))
        mapView.addMapLayer(layer)
        
        let graphicsLayer = AGSGraphicsLayer(fullEnvelope: nil, renderingMode: AGSGraphicsLayerRenderingModeDynamic)
        graphicsLayer.renderer = AGSSimpleRenderer(symbol: markerSymbol)
        mapView.addMapLayer(graphicsLayer, withName: "Graphics")
        
        let center = AGSPoint.pointWithX(-7822565, y: 5413016, spatialReference: nil)
        mapView.zoomToScale(72112, withCenterPoint:center, animated: true)
    }
    
    var markerSymbol : AGSMarkerSymbol { get {
        let symbol = AGSSimpleMarkerSymbol(color: UIColor.orangeColor())
        symbol.size = CGSize(width: 24, height: 24)
        symbol.style = AGSSimpleMarkerSymbolStyleDiamond
        symbol.outline.color = UIColor.whiteColor()
        return symbol
    }}

    
    func showSearch(sender: AnyObject) {
        if searchVC == nil {
            searchVC = SearchViewController(mapView: mapView) { self.dismissPopover() }
        }
        presentPopoverForController(searchVC!, barButtonItem: sender as UIBarButtonItem, size: CGSize(width: 300, height: 550))
    }
}
