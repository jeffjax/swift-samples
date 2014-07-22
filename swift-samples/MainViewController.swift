//
//  MainViewControllerTableViewController.swift
//  swift-samples
//
//  Created by Jeff Jackson on 7/22/14.
//  Copyright (c) 2014 Esri. All rights reserved.
//

import UIKit


class MainViewController: UITableViewController {

    // a simple class to represent a sample - a name and a constructor to create the view controller
    //
    class Sample {
        var name: String
        var constructor: () -> UIViewController
        init(name: String, constructor: () -> UIViewController) {
            self.name = name
            self.constructor = constructor
        }
    }

    // all of the samples contained in the project, organized into an array
    //
    let samples = [
        Sample(name: "Simple Map") { return SimpleMapViewController()},
        Sample(name: "Point Along Polyline") { return PointAlongViewController()}
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "CONTENT")
        navigationItem.title = "Swift Samples"
    }

    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return samples.count
    }

    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier("CONTENT", forIndexPath: indexPath) as UITableViewCell

        cell.textLabel.text = samples[indexPath.row].name

        return cell
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        // create the sample view controller and push it onto the nav stack
        //
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        navigationController.pushViewController(samples[indexPath.row].constructor(), animated: true)
    }
 
}
