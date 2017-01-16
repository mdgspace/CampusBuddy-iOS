//
//  SettingsTableViewController.swift
//  Campus Buddy
//
//  Created by Kush Taneja on 26/09/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import UIKit
import Social
import MessageUI

class SettingsTableViewController: UITableViewController, MFMessageComposeViewControllerDelegate {
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int{
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        // #warning Incomplete implementation, return the number of rows
        return 4
    }
    
    @IBAction func RateUS(sender: AnyObject) {
        
    }
    @IBAction func FbLink(sender: AnyObject) {
        UIApplication.shared.openURL(URL(string :"https://www.facebook.com/mdgiitr/")!)
        
    }
    
    @IBAction func GitLink(sender: AnyObject) {
        UIApplication.shared.openURL(URL(string :"https://github.com/sdsmdg")!)
    }
    
    @IBAction func openit(_ sender: UITapGestureRecognizer) {
        UIApplication.shared.openURL(URL(string :"https://mdg.sdslabs.co/")!)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath)
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Share with Friends"
        case 1:
            cell.textLabel?.text = "Open our Website"
        case 2:
            cell.textLabel?.text = "Disclaimer"
        case 3:
            cell.textLabel?.text = "How to use app?"
            
        default:
            cell.textLabel?.text = ""
            
        }
        cell.textLabel?.textAlignment = .center
        return cell
        
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.isSelected = false
        
        switch  indexPath.row {
        case 0:
            let ShareAlert = UIAlertController(title: "Loved our App", message: "Share with your friends", preferredStyle: .alert)
            ShareAlert.addAction(UIAlertAction(title: "Send Message" , style: .default, handler: { action in
                let messageVC = MFMessageComposeViewController()
                messageVC.body = "Hey There, Campus BUddy App"
                messageVC.messageComposeDelegate = self
                self.present(messageVC, animated: true, completion: nil)
                
            }))
            ShareAlert.addAction(UIAlertAction(title: "Facebook" , style: .default, handler: { action in
                
                if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook){
                    
                    let Facebooksheet: SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                    Facebooksheet.setInitialText("Hello Friends, Checkout the new Campus Buddy iOS App.")
                    self.present(Facebooksheet, animated: true, completion: nil)
                    
                    
                }else{
                    
                    let AccountAlert = UIAlertController(title: "Accounts", message: "Please Login Facebook in your settings", preferredStyle: .alert)
                    AccountAlert.addAction(UIAlertAction(title: "OK" , style: .default, handler: { action in
                        
                        self.present(AccountAlert, animated: true, completion: nil)
                        
                    }))
                }
                
            }))
            
            ShareAlert.addAction(UIAlertAction(title: "Whatsapp" , style: .default, handler: { action in
                
                var urlString = "Hello Friends, Checkout the new Campus Buddy iOS App."
                var urlStringEncoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                var url  = URL(string: "whatsapp://send?text=\(urlStringEncoded!)")
                
                //  if UIApplication.shared.canOpenURL(url!) {
                UIApplication.shared.openURL(url!)
                // }
                
                
            }))
            ShareAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel , handler: { action in
                
                
            }))
            
            self.present(ShareAlert, animated: true, completion: nil)
            
        case 1:
            UIApplication.shared.openURL(
                URL(string :"https://mdg.sdslabs.co/")!)
            
        case 2:
            let  Alert = UIAlertController(title: "Disclaimer", message:
                "This is a test app made by a student's group and we don't take any responsibility for any information present in the app." + "\n" + "However, we welcome any feedback.", preferredStyle: UIAlertControllerStyle.alert)
            
            
            Alert.addAction(UIAlertAction(title: "Mail us", style: .default , handler: { action in
                UIApplication.shared.openURL(URL(string :"mailto:sdsmobilelabs@gmail.com")!)
                
            }))
            
//            Alert.addAction(UIAlertAction(title: "Academic Calendar", style: .default , handler: { action in
//                UIApplication.shared.openURL(URL(string :"http://www.iitr.ac.in/academics/pages/Academic_Calender.html")!)
//                
//            }))
            Alert.addAction(UIAlertAction(title: "Telephone Directory", style: .default , handler: { action in
                UIApplication.shared.openURL(URL(string :"http://www.iitr.ac.in/Main/pages/Telephone+Telephone_Directory.html")!)
                
            }))
            Alert.addAction(UIAlertAction(title: "Cancel", style: .destructive , handler: { action in
                
                
            }))
            
            self.present(Alert, animated: true, completion: nil)
        case 3:
            UIApplication.shared.openURL(URL(string :"https://mdg.sdslabs.co/")!)
        default:
            UIApplication.shared.openURL(URL(string :"https://mdg.sdslabs.co/")!)
        }
    }
    
    //Message Controller Delegate
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
