//
//  AGSLocator.swift
//  swift-samples
//
//  Created by Jeff Jackson on 7/23/14.
//  Copyright (c) 2014 Esri. All rights reserved.
//

import ArcGIS

// Represents the result of a request to retrieve suggestions.
//
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

// Extends the AGSLocatorFindParameters class and adds the magicKey.
//
class AGSLocatorMagicFindParameters : AGSLocatorFindParameters {
    
    var magicKey : String!
    
    init() {
        super.init()
    }
    
    override func decodeWithJSON(json: [NSObject : AnyObject]!) {
        super.decodeWithJSON(json)
        magicKey = json["magicKey"]! as String
    }
    
    override func encodeToJSON() -> [NSObject : AnyObject]! {
        var result = NSMutableDictionary(dictionary: super.encodeToJSON())
        result["magicKey"] = magicKey
        return result
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
}


