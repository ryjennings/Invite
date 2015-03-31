//
//  DashboardEventCell.swift
//  Invite
//
//  Created by Ryan Jennings on 3/31/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit
import MapKit

@objc(DashboardEventCell) class DashboardEventCell: UICollectionViewCell
{
    @IBOutlet weak var eventView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    
    let cornerRadius: CGFloat = 10
    
    override func awakeFromNib()
    {
        eventView.layer.cornerRadius = cornerRadius
        eventView.clipsToBounds = true
    }
}
