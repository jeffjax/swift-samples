//
//  SearchViewController.swift
//  swift-samples
//
//  Created by Jeff Jackson on 7/23/14.
//  Copyright (c) 2014 Esri. All rights reserved.
//

import ArcGIS

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var searchBar: UISearchBar! = nil
    @IBOutlet weak var tableView: UITableView! = nil
    var mapView : AGSMapView
    var graphicsLayer : AGSGraphicsLayer
    var completion : () -> Void
    
    let locator = AGSLocator(URL: NSURL(string: "http://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer"))
    var lastSearch : String?
    var isSearching = false

    var suggestions : [AGSLocatorSuggestion]?
    var findResults : [AGSLocatorSuggestionFindResult]?
    
    init(mapView: AGSMapView, completion : () -> Void) {
        self.mapView = mapView
        self.graphicsLayer = mapView.mapLayerForName("Graphics") as AGSGraphicsLayer
        self.completion = completion
        
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

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
            graphicsLayer.removeAllGraphics()
            graphicsLayer.addGraphic(findResults[indexPath.row].graphic)
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
            tableView.reloadData()
        }
    }
    
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
        suggestions = nil
        findResults = nil
        tableView.reloadData()
        
        let params = AGSLocatorFindParameters()
        params.text = suggestion.text
        params.maxLocations = suggestion.isCollection ? 5 : 1
        
        locator.findSuggestion(suggestion, params: params, { (results: [AGSLocatorSuggestionFindResult]?, error: NSError?) -> Void in
            self.isSearching = false
            self.findResults = results
            self.tableView.reloadData()
        })
    }
}

