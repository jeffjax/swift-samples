//
//  AGSMapView.swift
//  swift-samples
//
//  Created by Jeff Jackson on 7/23/14.
//  Copyright (c) 2014 Esri. All rights reserved.
//

import ArcGIS

extension AGSMapView {
    
    // Expand the specified envelope by a factor and then zoom to it.
    //
    func zoomToExpandedEnvelope(envelope: AGSEnvelope, factor: Double) {
        let copy = envelope.mutableCopy() as AGSMutableEnvelope
        copy.expandByFactor(factor)  // TODO: - offset the envelope to account for toolbars, other views
        self.zoomToEnvelope(copy, animated: true)
    }
}

