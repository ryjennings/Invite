//
//  LocationResultsTableViewController.swift
//  Invite
//
//  Created by Ryan Jennings on 3/28/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit

public class LocationResultsTableViewController: UITableViewController
{
    public var locations: NSArray!
    
    required public init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    public override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clearColor()
    }
}