//
//  UIViewController.swift
//  swift-samples
//
//  Created by Jeff Jackson on 7/23/14.
//  Copyright (c) 2014 Esri. All rights reserved.
//

import UIKit

var popoverHandle : UInt8 = 0  // TODO: - make this a private class variable

extension UIViewController : UIPopoverControllerDelegate {
    
    var popover : UIPopoverController? {
    
    set {
        objc_setAssociatedObject(self, &popoverHandle, newValue, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
    }
    get {
        return objc_getAssociatedObject(self, &popoverHandle) as? UIPopoverController
    }
    }
    
    func presentPopoverForController(viewController: UIViewController, barButtonItem: UIBarButtonItem, size: CGSize) {
        presentPopoverForController(viewController, barButtonItem: barButtonItem, size: size, includeNavController: true)
    }
    
    func presentPopoverForController(viewController: UIViewController, barButtonItem: UIBarButtonItem, size: CGSize, includeNavController: Bool) {
        let root = includeNavController ? UINavigationController(rootViewController: viewController) : viewController
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            
            root.preferredContentSize = size
            self.popover = UIPopoverController(contentViewController: root)
            self.popover!.popoverContentSize = size
            self.popover!.delegate = self
            self.popover!.presentPopoverFromBarButtonItem(barButtonItem, permittedArrowDirections:UIPopoverArrowDirection.Any , animated: true)
            
            self.popover!.passthroughViews = nil
            
        } else {
            presentViewController(root, animated: true, completion: nil)
        }
    }
    
    func dismissPopover() {
        if self.popover {
            self.popover!.dismissPopoverAnimated(true)
            self.popover = nil
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
