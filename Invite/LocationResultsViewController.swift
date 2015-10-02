//
//  LocationResultsViewController.swift
//  Invite
//
//  Created by Ryan Jennings on 3/28/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit
import AddressBookUI

@objc class LocationResultsViewController: UITableViewController
{
    var delegate: LocationResultsViewControllerDelegate?
    var locations = [Location]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
    }

    // MARK: - UITableView
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.locations.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(LOCATION_CELL_IDENTIFIER, forIndexPath: indexPath) as! LocationCell
        let location = self.locations[indexPath.row]
        
        cell.nameLabel.text = indexPath.row == 0 ? location.formattedAddress! : location.name!
        cell.nameLabel.textColor = UIColor.inviteTableHeaderColor()
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 1
        let att = NSMutableAttributedString(string: indexPath.row == 0 ? "Use exactly what I've typed as the location" : location.formattedAddress!, attributes: [NSForegroundColorAttributeName: UIColor.inviteGrayColor(), NSFontAttributeName: UIFont.proximaNovaRegularFontOfSize(14), NSParagraphStyleAttributeName: style])
        cell.addressLabel.attributedText = att
        
        if indexPath.row == 0 {
            cell.backgroundColor = UIColor.inviteLighterBackgroundSlateColor()
        } else {
            cell.backgroundColor = UIColor.whiteColor()
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! LocationCell
        cell.backgroundColor = UIColor.inviteLightSlateColor()
        cell.nameLabel.textColor = UIColor.whiteColor()
        cell.addressLabel.textColor = UIColor.whiteColor()
        self.delegate?.didSelectLocation(self.locations[indexPath.row])
    }
}

protocol LocationResultsViewControllerDelegate
{
    func didSelectLocation(location: Location)
}
