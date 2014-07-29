//
//  AGSQueryTask.swift
//  swift-samples
//
//  Created by Eric Ito on 7/28/14.
//  Copyright (c) 2014 Esri. All rights reserved.
//

import ArcGIS

// workaround for accessing closure wrapped in an enum
// https://devforums.apple.com/message/986308#986308
struct Container<T> {
    var closure: T
}

// this enum will have our closure types
enum QueryCallbackType {
    case ExecuteClosure(Container<(featureSet: AGSFeatureSet?, error: NSError?) -> ()>)
}

extension AGSQueryTask: AGSQueryTaskDelegate {
    
    // create a private struct to hold our Dictionary
    private struct Static {
        static var instance: [Int:QueryCallbackType]! = nil
        static var token: dispatch_once_t = 0
    }
    
    // this will map our operation to our callback
    var callbacks: [Int:QueryCallbackType]! {
    get {
        dispatch_once(&Static.token) { Static.instance = [Int:QueryCallbackType]() }
        return Static.instance!
    }
    set {
        Static.instance = newValue
    }
    }
    
    public func executeQuery(query: AGSQuery, withCompletion completion: (featureSet: AGSFeatureSet?, error: NSError?) -> ()) -> NSOperation? {

        
        // get callbacks so we can call completion
        self.delegate = self
        
        let op = self.executeWithQuery(query)
        
        if var cbs = self.callbacks {
            cbs[op.hash] = .ExecuteClosure(Container(closure: completion))
            self.callbacks = cbs
        }
        
        return op
    }
    
    // MARK: AGSQueryTaskDelegate
    
    // TODO: Why do we have to mark these delegate methods public??
    public func queryTask(queryTask: AGSQueryTask!, operation op: NSOperation!, didExecuteWithFeatureSetResult featureSet: AGSFeatureSet!) {
        fireCallbackForOperation(op, featureSet: featureSet, error: nil)
    }
    
    public func queryTask(queryTask: AGSQueryTask!, operation op: NSOperation!, didFailWithError error: NSError!) {
        fireCallbackForOperation(op, featureSet: nil, error: error)
    }
    
    private func fireCallbackForOperation(operation:NSOperation, featureSet: AGSFeatureSet?, error: NSError?) {
        
        
        // attempt 1
//                switch self.callbacks[operation.hash] as QueryCallbackType {
//                case .ExecuteClosure(let callback):
//                    callback(featureSet: featureSet, error: error)
//                default:
//                    println("unexpected result -- this is to workaround compiler bug")
//                }
        // clear out callback
//                self.callbacks[operation.hash] = nil
        
        
        // attempt 2
        if var cb = self.callbacks {
            if let callbackType = self.callbacks[operation.hash] as? QueryCallbackType {
                switch callbackType {
                case .ExecuteClosure(let container):
                    container.closure(featureSet: featureSet, error: error)
                }
                cb[operation.hash] = nil
                self.callbacks = cb
            }
        }
        
    }
}
