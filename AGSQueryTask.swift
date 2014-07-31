//
//  AGSQueryTask.swift
//  swift-samples
//
//  Created by Eric Ito on 7/28/14.
//  Copyright (c) 2014 Esri. All rights reserved.
//

import ArcGIS

// this enum will have our closure types
enum AGSQueryTaskClosureType {
    case Execute(Container<(featureSet: AGSFeatureSet?, error: NSError?) -> ()>)
    case ExecuteWithIDs(Container<(objectIDs: [Int]?, error: NSError?) -> ()>)
    case ExecuteWithRelatedFeatures(Container<(relatedFeatures: [Int:[AGSFeatureSet]]?, error: NSError?) -> ()>)
    case ExecuteFeatureCount(Container<(featureCount: Int?, error: NSError?) -> ()>)
}

extension AGSQueryTask {
    
    public func executeQuery(query: AGSQuery, withCompletion completion: (featureSet: AGSFeatureSet?, error: NSError?) -> ()) -> NSOperation? {
        let op = self.executeWithQuery(query)
        AGSQueryTaskDelegateHandler.sharedInstance().registerCallback(.Execute(Container(closure: completion)), withTask:self, forOperation: op)
        return op
    }
    
    public func executeForIDsWithQuery(query: AGSQuery, withCompletion completion:(objectIDs: [Int]?, error: NSError?) -> ()) -> NSOperation? {
        let op = self.executeForIdsWithQuery(query)
        AGSQueryTaskDelegateHandler.sharedInstance().registerCallback(.ExecuteWithIDs(Container(closure: completion)), withTask:self, forOperation: op)
        return op
    }
    
    public func executeWithRelationshipQuery(query: AGSRelationshipQuery, withCompletion completion:(relatedFeatures: [Int: [AGSFeatureSet]]?, error: NSError?) -> ()) -> NSOperation? {
        let op = self.executeWithRelationshipQuery(query)
        AGSQueryTaskDelegateHandler.sharedInstance().registerCallback(.ExecuteWithRelatedFeatures(Container(closure: completion)), withTask:self, forOperation: op)
        return op
    }
    
    public func executeFeatureCountWithQuery(query: AGSQuery, withCompletion completion:(count: Int?, error: NSError?) -> ()) -> NSOperation? {
        let op = self.executeFeatureCountWithQuery(query)
        AGSQueryTaskDelegateHandler.sharedInstance().registerCallback(.ExecuteFeatureCount(Container(closure: completion)), withTask:self, forOperation: op)
        return op
    }
    
    private enum AGSQueryTaskResultsType {
        case Execute((AGSFeatureSet?, NSError?))
        case ExecuteWithIDs(([Int]?, NSError?))
        case ExecuteWithRelatedFeatures(([Int:[AGSFeatureSet]]?, NSError?))
        case ExecuteFeatureCount((Int?, NSError?))
    }
    
    // MARK: Internal Delegate Handler
    
    private class AGSQueryTaskDelegateHandler: NSObject, AGSQueryTaskDelegate {
        
        // create a shared instance so any query task can take advantange of this
        class func sharedInstance()->AGSQueryTaskDelegateHandler{
            struct Static{
                static let instance = AGSQueryTaskDelegateHandler();
            }
            return Static.instance;
        }
        
        // this will map our operation to our callback
        private var callbacks = [NSOperation:AGSQueryTaskClosureType]()
        
        internal func registerCallback(callback: AGSQueryTaskClosureType, withTask task: AGSQueryTask, forOperation op: NSOperation) -> () {
            task.delegate = self
            self.callbacks[op] = callback
        }
        
        // MARK: AGSQueryTaskDelegate
        
        public func queryTask(queryTask: AGSQueryTask!, operation op: NSOperation!, didExecuteWithFeatureSetResult featureSet: AGSFeatureSet!) {
            unpackAndFireCallbackForOperation(op, resultType: .Execute((featureSet, nil)))
        }
        
        public func queryTask(queryTask: AGSQueryTask!, operation op: NSOperation!, didFailWithError error: NSError!) {
            unpackAndFireCallbackForOperation(op, resultType: .Execute((nil, error)))
        }
        
        public func queryTask(queryTask: AGSQueryTask!, operation op: NSOperation!, didExecuteWithObjectIds objectIds: [AnyObject]!) {
            unpackAndFireCallbackForOperation(op, resultType: .ExecuteWithIDs((objectIds as? [Int], nil)))
        }
        
        public func queryTask(queryTask: AGSQueryTask!, operation op: NSOperation!, didFailQueryForIdsWithError error: NSError!) {
            unpackAndFireCallbackForOperation(op, resultType: .ExecuteWithIDs((nil, error)))
        }
        
        public func queryTask(queryTask: AGSQueryTask!, operation op: NSOperation!, didExecuteWithRelatedFeatures relatedFeatures: [NSObject : AnyObject]!) {
            unpackAndFireCallbackForOperation(op, resultType: .ExecuteWithRelatedFeatures((relatedFeatures as? [Int:[AGSFeatureSet]], nil)))
        }
        
        public func queryTask(queryTask: AGSQueryTask!, operation op: NSOperation!, didFailRelationshipQueryWithError error: NSError!) {
            unpackAndFireCallbackForOperation(op, resultType: .ExecuteWithRelatedFeatures((nil, error)))
        }
        
        public func queryTask(queryTask: AGSQueryTask!, operation op: NSOperation!, didExecuteWithFeatureCount count: Int) {
            unpackAndFireCallbackForOperation(op, resultType: .ExecuteFeatureCount((count, nil)))
        }
        
        public func queryTask(queryTask: AGSQueryTask!, operation op: NSOperation!, didFailQueryFeatureCountWithError error: NSError!) {
            unpackAndFireCallbackForOperation(op, resultType: .ExecuteFeatureCount((nil, error)))
        }
        
        private func unpackAndFireCallbackForOperation(operation: NSOperation, resultType: AGSQueryTaskResultsType) {
            switch resultType {
            case .Execute(let (featureSet, error)):
                fireCallbackForOperation(operation, values: (featureSet, error))
            case .ExecuteWithIDs(let (objectIDs, error)):
                fireCallbackForOperation(operation, values: (objectIDs, error))
            case .ExecuteWithRelatedFeatures(let (relatedFeatures, error)):
                fireCallbackForOperation(operation, values: (relatedFeatures, error))
            case .ExecuteFeatureCount(let (count, error)):
                fireCallbackForOperation(operation, values: (count, error))
            }
        }
        
        private func fireCallbackForOperation(operation: NSOperation, values: (Any?, Any?)) {
            if let callbackType = self.callbacks[operation] as? AGSQueryTaskClosureType {
                switch callbackType {
                case .Execute(let container):
                    let (featureSet, error) = values
                    container.closure(featureSet: featureSet as? AGSFeatureSet, error: error as? NSError)
                case .ExecuteWithIDs(let container):
                    let (objectIDs, error) = values
                    container.closure(objectIDs: objectIDs as? [Int], error: error as? NSError)
                case .ExecuteWithRelatedFeatures(let container):
                    container.closure(relatedFeatures: values.0 as? [Int:[AGSFeatureSet]], error: values.1 as? NSError)
                case .ExecuteFeatureCount(let container):
                    container.closure(featureCount: values.0 as? Int, error: values.1 as? NSError)
                }
                self.callbacks[operation] = nil
            }
        }
    }
}