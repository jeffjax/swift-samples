//
//  SearchViewController.swift
//  swift-samples
//
//  Created by Jeff Jackson on 7/23/14.
//  Copyright (c) 2014 Esri. All rights reserved.
//

import ArcGIS

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, AGSLocatorDelegate {

    @IBOutlet weak var searchBar: UISearchBar! = nil
    @IBOutlet weak var tableView: UITableView! = nil
    
    var mapView : AGSMapView
    var graphicsLayer : AGSGraphicsLayer // graphics layer for feedback on the map
    var completion : () -> Void   // completion block for the iPhone
    
    let locator = AGSLocator(URL: NSURL(string: "http://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer"))
    var lastSearch : String?
    var isSearching = false

    var suggestions : [AGSLocatorSuggestion]?
    var findResults : [AGSLocatorFindResult]?
    
    init(mapView: AGSMapView, completion : () -> Void) {
        self.mapView = mapView
        self.graphicsLayer = mapView.mapLayerForName("Graphics") as AGSGraphicsLayer
        self.completion = completion
        
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = .None;

        navigationItem.title = "Search"
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "CONTENT")
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: Selector("done:"))
        }
    }

    func done(sender: AnyObject) {
        completion()
    }
    
    // MARK: UITableViewDataSource
    //
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        if let suggestions = suggestions {
            return suggestions.count
        }
        if let findResults = findResults {
            return findResults.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier("CONTENT", forIndexPath: indexPath) as UITableViewCell
        if let suggestions = suggestions {
            cell.textLabel.text = suggestions[indexPath.row].text
        } else if let findResults = findResults {
            cell.textLabel.text = findResults[indexPath.row].name
        }
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let suggestions = suggestions {
            searchSuggestion(suggestions[indexPath.row])
        } else if let findResults = findResults {
            showFindResult(findResults[indexPath.row])
        }
    }
    
    // MARK: UISearchBarDelegate
    //
    func searchBar(searchBar: UISearchBar!, textDidChange searchText: String!) {
        NSObject.cancelPreviousPerformRequestsWithTarget(self)
        
        if !searchBar.text.isEmpty {
            dispatch_after_delay(0.25) {
                self.findSuggestions(searchBar.text)
            }
        } else {
            suggestions = nil
            findResults = nil
            tableView.reloadData()
            graphicsLayer.removeAllGraphics()
        }
    }
    
    // MARK: Search methods
    
    // Find the suggestions for a string.
    //
    func findSuggestions(searchText: String) {
        let params = AGSLocatorFindParameters()
        params.text = searchText
        params.maxLocations = 5
        params.outFields = ["*"]
        params.location = mapView.visibleAreaEnvelope.center
        params.distance = 5000
        
        lastSearch = searchText
        
        locator.suggestionsForParameters(params, { (results: [AGSLocatorSuggestion]?, error: NSError?) -> Void in
            if self.lastSearch != searchText || self.isSearching {
                return
            }
            
            self.suggestions = results
            self.tableView.reloadData()
        })
    }
    
    // Given a suggestion, perform a search and get back a place.
    //
    func searchSuggestion(suggestion: AGSLocatorSuggestion) {
        isSearching = true
        findResults = nil
        
        if suggestion.isCollection {
            suggestions = nil
            tableView.reloadData()
        }
        
        let params = AGSLocatorMagicFindParameters()
        params.magicKey = suggestion.magicKey
        params.text = suggestion.text
        params.outSpatialReference = mapView.spatialReference
        params.maxLocations = suggestion.isCollection ? 5 : 1
        
        locator.delegate = self
        locator.findWithParameters(params)
    }
    
    // Show the find results on the map.
    //
    func showFindResult(result: AGSLocatorFindResult) {
        
        // on the phone, close this view controller so we can see the result on
        // the map
        //
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            completion()
        }
        
        graphicsLayer.removeAllGraphics()
        graphicsLayer.addGraphic(result.graphic)
        
        let extent = result.extent
        if extent.width > 0 && extent.height > 0 {
            mapView.zoomToExpandedEnvelope(extent, factor: 1.5)
            
        } else {
            mapView.centerAtPoint(extent.center, animated: true)
        }
    }

    // MARK: AGSLocatorDelegate
    //
    func locator(locator: AGSLocator!, operation op: NSOperation!, didFailToFindWithError error: NSError!) {
        self.isSearching = false
    }
    
    func locator(locator: AGSLocator!, operation op: NSOperation!, didFind results: [AnyObject]!) {
        self.isSearching = false
        
        if let results = results as? [AGSLocatorFindResult] {
            if results.count > 1 {
                findResults = results
                self.tableView.reloadData()
            } else {
                self.showFindResult(results[0])
            }
        }
       
    }
    
 }

