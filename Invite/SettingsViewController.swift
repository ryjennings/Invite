//
//  SettingsViewController.swift
//  Invite
//
//  Created by Ryan Jennings on 4/22/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit

@objc(SettingsViewController) class SettingsViewController: UIViewController
{
    @IBAction func close(sender: UIBarButtonItem)
    {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
