//
//  UserDefaults.swift
//  Invite
//
//  Created by Ryan Jennings on 5/9/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit

@objc(UserDefaults) class UserDefaults: NSObject
{
    class func removeObjectForKey(key: String)
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey(key)
        defaults.synchronize()
    }
    
    class func setObject(object: AnyObject, key: String)
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(object, forKey: key)
        defaults.synchronize()
    }
    
    class func setInteger(value: Int, key: String)
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(value, forKey: key)
        defaults.synchronize()
    }
    
    class func setBool(b: Bool, key: String)
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(b, forKey: key)
        defaults.synchronize()
    }
    
    class func objectForKey(key: String) -> AnyObject?
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let object: AnyObject = defaults.objectForKey(key) {
            return object
        }
        return nil
    }
    
    class func boolForKey(key: String) -> Bool
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.boolForKey(key)
    }
    
    class func integerForKey(key: String) -> Int
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.integerForKey(key)
    }
}
