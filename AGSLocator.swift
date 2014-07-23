//
//  AGSLocator.swift
//  swift-samples
//
//  Created by Jeff Jackson on 7/23/14.
//  Copyright (c) 2014 Esri. All rights reserved.
//

import ArcGIS

class AGSLocatorSuggestion : NSObject, AGSCoding {
    
    var text: String!
    var magicKey: String!
    var isCollection : Bool = false
    
    init(JSON json: [NSObject : AnyObject]!) {
        super.init()
        self.decodeWithJSON(json)
    }
    
    func decodeWithJSON(json: [NSObject : AnyObject]!) {
        if let json = json {
            magicKey = json["magicKey"]! as String
            text = json["text"]! as String
            isCollection = (json["isCollection"] as NSNumber).boolValue
        }
    }
    
    func encodeToJSON() -> [NSObject : AnyObject]! {
        var json = [NSObject : AnyObject]()
        json["magicKey"] = magicKey
        json["text"] = text
        json["isCollection"] = NSNumber(bool: isCollection)
        return json
    }
}

class AGSLocatorSuggestionFindResult : NSObject, AGSCoding {

    var graphic: AGSGraphic!
    var extent: AGSEnvelope!
    var name : String!
    
    init(JSON json: [NSObject : AnyObject]!) {
        super.init()
        self.decodeWithJSON(json)
    }
    
    func decodeWithJSON(json: [NSObject : AnyObject]!) {
        if let json = json {
            graphic = AGSGraphic(JSON: json["feature"]! as [NSObject : AnyObject])
            extent = AGSEnvelope(JSON: json["extent"]! as [NSObject : AnyObject])
            name = json["name"]! as String
        }
    }
    
    func encodeToJSON() -> [NSObject : AnyObject]! {
        var json = [NSObject : AnyObject]()
        json["feature"] = graphic.encodeToJSON()
        json["extent"] = extent.encodeToJSON()
        json["name"] = name
        return json
    }

}

extension AGSLocator {
    
    // Returns suggestions for the specified find parameters.
    //
    func suggestionsForParameters(params: AGSLocatorFindParameters, completion: (results: [AGSLocatorSuggestion]?, error: NSError?) -> Void) {
        
        let paramsDictionary = NSMutableDictionary(objectsAndKeys: "json", "f")
        paramsDictionary.addEntriesFromDictionary(params.encodeToJSON())
        
        let op = AGSJSONRequestOperation(URL: self.URL, resource: "suggest", queryParameters: paramsDictionary)
        op.securedResource = self
        op.requestCachePolicy = self.requestCachePolicy
        op.timeoutInterval = self.timeoutInterval
        
        op.completionHandler = { (obj: AnyObject!) -> Void in

            var suggestions = [AGSLocatorSuggestion]()
            if let json = obj as? NSDictionary {
                if let array = json["suggestions"] as? [NSDictionary] {
                    for suggestionJson in array {
                        suggestions.append(AGSLocatorSuggestion(JSON: suggestionJson))
                    }
                }
            }
            completion(results: suggestions, error: nil)
        }
        
        op.errorHandler = { (err: NSError!) -> Void in
            completion(results: nil, error: err)
        }
        
        AGSRequestOperation.sharedOperationQueue().addOperation(op)
    }

    // Executes a search using a suggestion.
    //
    func findSuggestion(suggestion: AGSLocatorSuggestion, params: AGSLocatorFindParameters, completion: (results: [AGSLocatorSuggestionFindResult]?, error: NSError?) -> Void) {
        
        let paramsDictionary = NSMutableDictionary(objectsAndKeys: "json", "f", suggestion.magicKey, "magicKey")
        paramsDictionary.addEntriesFromDictionary(params.encodeToJSON())
        
        let op = AGSJSONRequestOperation(URL: self.URL, resource: "find", queryParameters: paramsDictionary)
        op.securedResource = self
        op.requestCachePolicy = self.requestCachePolicy
        op.timeoutInterval = self.timeoutInterval
        
        op.completionHandler = { (obj: AnyObject!) -> Void in
            
            var results = [AGSLocatorSuggestionFindResult]()
            if let json = obj as? NSDictionary {
                if let array = json["locations"] as? [NSDictionary] {
                    for locationJson in array {
                        results.append(AGSLocatorSuggestionFindResult(JSON: locationJson))
                    }
                }
            }
            completion(results: results, error: nil)
        }
        
        op.errorHandler = { (err: NSError!) -> Void in
            completion(results: nil, error: err)
        }
        
        AGSRequestOperation.sharedOperationQueue().addOperation(op)
    }

}


