//
//  LocationResultsViewController.swift
//  Invite
//
//  Created by Ryan Jennings on 3/28/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit
import AddressBookUI

@objc class LocationResultsViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate
{
    var delegate: LocationResultsViewControllerDelegate?
    var locations = [AnyObject]()
    {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: BASIC_CELL_IDENTIFIER)
    }

    // MARK: - UITableView
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return locations.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let placemark = locations[indexPath.row] as! CLPlacemark
        
        var cell = tableView.dequeueReusableCellWithIdentifier(BASIC_CELL_IDENTIFIER, forIndexPath: indexPath) as! UITableViewCell
        
        var attributedText = NSMutableAttributedString(string: placemark.name, attributes: [NSForegroundColorAttributeName: UIColor.inviteDarkBlueColor(), NSFontAttributeName: UIFont.proximaNovaRegularFontOfSize(15)])
        attributedText.appendAttributedString(NSAttributedString(string: "\n"))
        attributedText.appendAttributedString(NSAttributedString(string: placemark.addressDictionary["FormattedAddressLines"]!.componentsJoinedByString(", "), attributes: [NSForegroundColorAttributeName: UIColor.inviteTableLabelColor(), NSFontAttributeName: UIFont.proximaNovaRegularFontOfSize(12)]))
            
        var style = NSMutableParagraphStyle()
        style.lineSpacing = 3
        attributedText.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, count(attributedText.string)))
        
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.attributedText = attributedText

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if let d = delegate {
            d.didSelectPlacemark(locations[indexPath.row] as! CLPlacemark)
        }
    }
}

protocol LocationResultsViewControllerDelegate
{
    func didSelectPlacemark(placemark: CLPlacemark)
}
