//
//  SettingsViewController.swift
//  Invite
//
//  Created by Ryan Jennings on 4/22/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit
import StoreKit

enum RemindMe: Int {
    case UseDefault = 0
    case AtTimeOfEvent
    case FiveMinutesBefore
    case FifteenMinutesBefore
    case ThirtyMinutesBefore
    case OneHourBefore
    case TwoHoursBefore
}

enum SettingsSection: Int {
    case DefaultRemindMe = 0
    case AdFree
    case Count
}

@objc(SettingsViewController) class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver
{
    @IBOutlet weak var tableView: UITableView!
    
    var productsArray = [SKProduct]()
    var upgradePurchased = false
    
    let kInAppPurchaseAdFreeProductId = "invite_adfree"
    
    override func viewDidLoad()
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        if UserDefaults.objectForKey("DefaultRemindMe") == nil {
            UserDefaults.setInteger(RemindMe.FifteenMinutesBefore.rawValue, key: "DefaultRemindMe")
        }
        
        if UserDefaults.boolForKey("adFree") {
            self.upgradePurchased = true
        }
        requestProductInfo()
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        
        self.tableView.tableFooterView = tableFooterView()
    }
    
    private func tableFooterView() -> UIView
    {
        let label = UILabel(frame: CGRectMake(0, 0, 0, 50))
        label.textColor = UIColor.inviteTableHeaderColor()
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont.inviteTableSmallFont()
        label.backgroundColor = UIColor.clearColor()
        label.text = "Invite for iOS, version \(NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]!) (\(NSBundle.mainBundle().infoDictionary!["CFBundleVersion"]!))"
        return label
    }
    
    func requestProductInfo()
    {
        if SKPaymentQueue.canMakePayments() {
            let productIdentifiers = Set([kInAppPurchaseAdFreeProductId])
            let productRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
            
            productRequest.delegate = self
            productRequest.start()
        }
        else {
            print("Cannot perform In App Purchases.")
        }
    }
    
    @IBAction func close(sender: UIBarButtonItem)
    {
        NSNotificationCenter.defaultCenter().postNotificationName(CLOSING_SETTINGS_NOTIFICATION, object: nil)
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel!.textColor = UIColor.inviteTableHeaderColor()
        headerView.textLabel!.font = UIFont.inviteTableHeaderFont()
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        switch (section) {
        case SettingsSection.DefaultRemindMe.rawValue:
            return "Remind Me"
        case SettingsSection.AdFree.rawValue:
            return "Remove Ads"
        default:
            return nil
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return self.productsArray.count > 0 ? SettingsSection.Count.rawValue : 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == SettingsSection.DefaultRemindMe.rawValue {
            return 1
        } else {
            return self.upgradePurchased ? 1 : 3
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if indexPath.section == SettingsSection.AdFree.rawValue {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier(BASIC_CELL_IDENTIFIER, forIndexPath: indexPath) as! BasicCell
                cell.backgroundColor = UIColor.clearColor()
                
                let product = self.productsArray[0]
                    
                let style = NSMutableParagraphStyle()
                style.lineSpacing = 4
                let string = self.upgradePurchased ? "You have already purchased this upgrade!" : product.localizedDescription
                let att = NSAttributedString(string: string, attributes: [NSForegroundColorAttributeName: UIColor.inviteTableHeaderColor(), NSFontAttributeName: UIFont.inviteTableSmallFont(), NSParagraphStyleAttributeName: style])
                cell.textLabel?.attributedText = att

                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCellWithIdentifier(BUTTON_CELL_IDENTIFIER, forIndexPath: indexPath) as! ButtonCell

                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.backgroundColor = UIColor.clearColor()
                
                let product = self.productsArray[0]

                let numberFormatter = NSNumberFormatter()
                numberFormatter.formatterBehavior = NSNumberFormatterBehavior.Behavior10_4
                numberFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
                numberFormatter.locale = product.priceLocale
                
                cell.button.setTitle("Upgrade now for \(numberFormatter.stringFromNumber(product.price)!)!", forState: UIControlState.Normal)
                cell.button.addTarget(self, action: "upgrade", forControlEvents: UIControlEvents.TouchUpInside)

                cell.contentView.backgroundColor = UIColor.clearColor()
                
                return cell
            } else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCellWithIdentifier(BUTTON_CELL_IDENTIFIER, forIndexPath: indexPath) as! ButtonCell
                
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.backgroundColor = UIColor.clearColor()
                
                cell.button.titleLabel?.font = UIFont.proximaNovaRegularFontOfSize(16)
                cell.button.setTitle("Already upgraded? Restore purchase.", forState: UIControlState.Normal)
                cell.button.addTarget(self, action: "restore", forControlEvents: UIControlEvents.TouchUpInside)

                cell.contentView.backgroundColor = UIColor.clearColor()
                
                return cell
            }
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(BASIC_RIGHT_CELL_IDENTIFIER, forIndexPath: indexPath) as! BasicCell
        cell.textLabel?.font = UIFont.inviteTableSmallFont()
        cell.textLabel?.textColor = UIColor.inviteTableHeaderColor()
        
        cell.textLabel?.text = "Default remind me"
        cell.detailTextLabel?.font = UIFont.inviteTableSmallFont()
        cell.detailTextLabel?.textColor = UIColor.inviteGrayColor()
        cell.detailTextLabel?.text = textForCurrentRemindMe()
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if indexPath.section == SettingsSection.DefaultRemindMe.rawValue {
            var nextValue = UserDefaults.integerForKey("DefaultRemindMe")
            nextValue++
            if nextValue > RemindMe.TwoHoursBefore.rawValue {
                nextValue = RemindMe.AtTimeOfEvent.rawValue
            }
            UserDefaults.setInteger(nextValue, key: "DefaultRemindMe")
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! BasicCell
            cell.detailTextLabel?.text = textForCurrentRemindMe()
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if indexPath.section == SettingsSection.AdFree.rawValue {
            if indexPath.row > 0 {
                return 59
            } else {
                return self.upgradePurchased ? 44 : 54
            }
        } else {
            return 44
        }
    }
    
    func textForCurrentRemindMe() -> String
    {
        switch RemindMe(rawValue: UserDefaults.integerForKey("DefaultRemindMe"))! {
        case .UseDefault: return ""
        case .AtTimeOfEvent: return "At time of event"
        case .FiveMinutesBefore: return "5 minutes before"
        case .FifteenMinutesBefore: return "15 minutes before"
        case .ThirtyMinutesBefore: return "30 minutes before"
        case .OneHourBefore: return "1 hour before"
        case .TwoHoursBefore: return "2 hours before"
        }
    }
    
    @IBAction func logout(button: UIBarButtonItem)
    {
        NSNotificationCenter.defaultCenter().postNotificationName(USER_LOGGED_OUT_NOTIFICATION, object: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - SKProductRequestDelegate
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse)
    {
        if response.products.count != 0 {
            self.tableView.beginUpdates()
            for product in response.products {
                self.productsArray.append(product)
            }
            self.tableView.insertSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.Fade)
            self.tableView.endUpdates()
        }
        else {
            print("There are no products.")
        }
        if response.invalidProductIdentifiers.count != 0 {
            print(response.invalidProductIdentifiers.description)
        }
    }
    
    func upgrade()
    {
        let payment = SKPayment(product: self.productsArray[0] as SKProduct)
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    func restore()
    {
        if SKPaymentQueue.canMakePayments() {
            SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
        }
    }
    
    // MARK: - SKPaymentTransactionObserver
    
    func recordTransaction(transaction: SKPaymentTransaction)
    {
        if transaction.payment.productIdentifier == kInAppPurchaseAdFreeProductId {
            let url = NSBundle.mainBundle().appStoreReceiptURL
            if let url = url, data = NSData(contentsOfURL: url) {
                UserDefaults.setObject(data, key: kInAppPurchaseAdFreeProductId)
            }
        }
    }
    
    func provideContent(productId: String)
    {
        if productId == kInAppPurchaseAdFreeProductId {
            UserDefaults.setBool(true, key: "adFree")
        }
    }
    
    func finishTransaction(transaction: SKPaymentTransaction, wasSuccessful: Bool)
    {
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    }
    
    func purchasedTransaction(transaction: SKPaymentTransaction)
    {
        print("Transaction completed successfully")
        
        self.recordTransaction(transaction)
        self.provideContent(transaction.payment.productIdentifier)
        self.finishTransaction(transaction, wasSuccessful: true)
        
        self.upgradePurchased = true
        self.tableView.reloadData()
    }
    
    func restoredTransaction(transaction: SKPaymentTransaction)
    {
        print("Transaction restored successfully")
        
        if let originalTransaction = transaction.originalTransaction {
            self.recordTransaction(originalTransaction)
            self.provideContent(originalTransaction.payment.productIdentifier)
        }
        self.finishTransaction(transaction, wasSuccessful: true)
        
        self.upgradePurchased = true
        self.tableView.reloadData()

        let alert = UIAlertController(title: nil, message: "Your purchase has been restored.", preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func failedTransaction(transaction: SKPaymentTransaction)
    {
        print("Transaction failed");
        
        if transaction.error?.code != SKErrorPaymentCancelled {
            // error!
            finishTransaction(transaction, wasSuccessful: false)
        } else {
            // this is fine, the user just cancelled, so don’t notify
            SKPaymentQueue.defaultQueue().finishTransaction(transaction)
        }

        let alert = UIAlertController(title: "Error", message: transaction.error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction])
    {
        for transaction in transactions
        {
            switch transaction.transactionState
            {
            case SKPaymentTransactionState.Purchased:
                purchasedTransaction(transaction)
                
            case SKPaymentTransactionState.Failed:
                failedTransaction(transaction)
                
            default:
                print(transaction.transactionState.rawValue)
            }
        }
    }
    
    func paymentQueue(queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: NSError)
    {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue)
    {
        if queue.transactions.count == 0 {
            let alert = UIAlertController(title: nil, message: "You have not yet purchased this upgrade.", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            alert.addAction(okAction)
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        for transaction in queue.transactions
        {
            switch transaction.transactionState
            {
            case SKPaymentTransactionState.Purchased:
                purchasedTransaction(transaction)
                
            case SKPaymentTransactionState.Failed:
                failedTransaction(transaction)
                
            case SKPaymentTransactionState.Restored:
                restoredTransaction(transaction)
                
            default:
                print(transaction.transactionState.rawValue)
            }
        }
    }
}
