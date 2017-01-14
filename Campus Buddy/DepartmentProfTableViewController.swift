//
//  DepartmentProfTableViewController.swift
//  Campus Buddy
//
//  Created by Kush Taneja on 27/08/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import UIKit
import LocalAuthentication
import MessageUI
import SystemConfiguration

extension DepartmentProfTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController){
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}

class DepartmentProfTableViewController: UITableViewController , UIAlertViewDelegate,MFMailComposeViewControllerDelegate , MFMessageComposeViewControllerDelegate {
    let searchController = UISearchController(searchResultsController: nil)
    var ProfContacts = [ProfContactCell]()
    var filterdcontacts = [ProfContactCell]()
    var DepartmentProfcontacts = [NSDictionary]()
    var DepartmentProfs = [String]()
    var DepartmentName = String()
    var resdoffstdcode = "0133228 " // std code for roorkee and starting landline
    let std_code_bsnl = "01332"  //std code for roorkee
    var bsnlPhone = ""
    var LandlineorMobiledata = ""
    var bsnltocall = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem?.image = UIImage(named: "back")
        // Search Bar
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        searchController.searchBar.backgroundColor = ColorCode().appThemeColor
        searchController.searchBar.tintColor = UIColor.white
        searchController.searchBar.barTintColor = ColorCode().appThemeColor
        searchController.searchBar.inputView?.tintColor = ColorCode().appThemeColor
        searchController.searchBar.showsCancelButton = false

        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        self.navigationItem.title = DepartmentName
        
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        for departmentContact in DepartmentProfcontacts{
            let profname = departmentContact.value(forKey: "name") as! String?
            let profdesignation = departmentContact.value(forKey: "designation") as! String?
            let profoffice = departmentContact.value(forKey: "iitr_o") as! String?
            let profresidence = departmentContact.value(forKey: "iitr_r") as! String?
            let profphoneBSNL = departmentContact.value(forKey: "phoneBSNL") as! String?
            let profemail = departmentContact.value(forKey: "email") as! String?
            let profprofilePic = departmentContact.value(forKey: "profilePic") as! String?
            
            ProfContacts.append(ProfContactCell(namedata: profname, designationdata: profdesignation, officedata: profoffice, residencedata: profresidence, phoneBSNLdata: profphoneBSNL, emaildata: profemail, profilePicdata: profprofilePic, department: DepartmentName))
            
        }
        ProfContacts.sort{$0.name! < $1.name!}
        self.tableView.reloadData()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.resignFirstResponder()
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filterdcontacts = ProfContacts.filter { ProfContactCell in
            if (ProfContactCell.designation != nil){
                return ProfContactCell.name!.lowercased().contains(searchText.lowercased()) || ProfContactCell.designation!.lowercased().contains(searchText.lowercased())
            }
            else {
                return ProfContactCell.name!.lowercased().contains(searchText.lowercased())
            }
        }
        self.tableView.reloadData()
    }
    
    override  func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (searchController.isActive && searchController.searchBar.text != ""){
            return filterdcontacts.count
        }else{
            return ProfContacts.count
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfContactCell", for: indexPath) as! ProfContactTableViewCell
        let contact : ProfContactCell
        
        if (searchController.isActive && searchController.searchBar.text != ""){
            contact = filterdcontacts[indexPath.row]
        }else{
            contact = ProfContacts[indexPath.row]
        }
        cell.ProfessorName.text = contact.name!
        cell.ProfImageView.sd_setImage(with: URL(string:"http://people.iitr.ernet.in/facultyphoto/\((contact.profilePic)!)")!,placeholderImage:#imageLiteral(resourceName: "person"))
        cell.ProfImageView.layer.cornerRadius = (cell.ProfImageView.frame.width)/2
        if (contact.designation != nil){
            cell.Profdesignation.text = contact.designation!
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        var contact : ProfContactCell = self.ProfContacts[indexPath.row]
        
        if (self.searchController.isActive && self.searchController.searchBar.text != ""){
            contact = self.filterdcontacts[indexPath.row]
        }else{
            contact = self.ProfContacts[indexPath.row]
        }
        
        let call = UITableViewRowAction(style: .default, title: "Call") { action, index in
            let CallAlertView = UIAlertController( title: "Call", message: "Choose any number to call", preferredStyle: .actionSheet)
            
            self.LandlineorMobiledata =  contact.phoneBSNL!
            if ( self.LandlineorMobiledata != "" )
            {
                if (String(self.LandlineorMobiledata[self.LandlineorMobiledata.startIndex]) == "9" ||  String(self.LandlineorMobiledata[self.LandlineorMobiledata.startIndex]) == "8") {
                    self.bsnlPhone = "Mobile: " + self.LandlineorMobiledata
                    self.bsnltocall = self.LandlineorMobiledata
                }
                else {
                    self.bsnlPhone = "BSNL: " + self.std_code_bsnl + self.LandlineorMobiledata
                    self.bsnltocall = self.std_code_bsnl + self.LandlineorMobiledata
                }
            }
            
            let offcieaction = UIAlertAction(title: "Office: " + (self.resdoffstdcode + contact.office!).removeWhitespace(), style: .default, handler: { (alert: UIAlertAction!) -> Void in
                self.callProf(number: (self.resdoffstdcode + contact.office!).removeWhitespace())
            })
            let residenceaction = UIAlertAction(title: "Residence: " + (self.resdoffstdcode + contact.residence!).removeWhitespace() , style: .default, handler: { (alert: UIAlertAction!) -> Void in
                self.callProf(number: (self.resdoffstdcode + contact.residence!).removeWhitespace())
                
            })
            
            let mobileaction = UIAlertAction(title: self.bsnlPhone.removeWhitespace(), style: .default, handler: { (alert: UIAlertAction!) -> Void in
                self.callProf(number: self.bsnltocall.removeWhitespace())
            })
            let cancelaction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert: UIAlertAction!) -> Void in
            })
            
            if(contact.office! != "")
            {
                CallAlertView.addAction(offcieaction)
            }
            if(contact.residence!  != "")
            {
                CallAlertView.addAction(residenceaction)
            }
            if(self.LandlineorMobiledata != "")
            {
                CallAlertView.addAction(mobileaction)
            }
            CallAlertView.addAction(cancelaction)
            
            self.present(CallAlertView, animated: true, completion: nil)
        }
        call.backgroundColor = ColorCode().appThemeColor
        
        let message = UITableViewRowAction(style: .normal, title: "Message") { action, index in
            let messageViewontroller = MFMessageComposeViewController()
            var recipents = [String]()
            self.LandlineorMobiledata =  contact.phoneBSNL!
            if ( self.LandlineorMobiledata != "" )
            {
                if (String(self.LandlineorMobiledata[self.LandlineorMobiledata.startIndex]) == "9" ||  String(self.LandlineorMobiledata[self.LandlineorMobiledata.startIndex]) == "8") {
                    self.bsnlPhone = "Mobile: " + self.LandlineorMobiledata
                    self.bsnltocall = self.LandlineorMobiledata
                }
                else {
                    self.bsnlPhone = "BSNL: " + self.std_code_bsnl + self.LandlineorMobiledata
                    self.bsnltocall = self.std_code_bsnl + self.LandlineorMobiledata
                } }
            
            
            if (self.searchController.isActive && self.searchController.searchBar.text != ""){
                contact = self.filterdcontacts[indexPath.row]
            }else{
                contact = self.ProfContacts[indexPath.row]
            }
            let MessageAlertView = UIAlertController( title: "Send Message", message: "Choose any number to text", preferredStyle: .actionSheet)
            let number = self.resdoffstdcode + contact.office!
            
            let offcieaction = UIAlertAction(title: "Office: " + self.resdoffstdcode + contact.office!, style: .default, handler: { (alert: UIAlertAction!) -> Void in
                self.messageProf(number: number)
            })
            let residenceaction = UIAlertAction(title: "Residence: " + self.resdoffstdcode + contact.residence! , style: .default, handler: { (alert: UIAlertAction!) -> Void in
                self.messageProf(number: self.resdoffstdcode + contact.residence!)
                
            })
            let mobileaction = UIAlertAction(title: self.bsnlPhone, style: .default, handler: { (alert: UIAlertAction!) -> Void in
                self.messageProf(number: self.bsnltocall)
            })
            let cancelaction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert: UIAlertAction!) -> Void in
            })
            
            if(contact.office! != "")
            {
                MessageAlertView.addAction(offcieaction)
            }
            if(contact.residence!  != "")
            {
                MessageAlertView.addAction(residenceaction)
            }
            if(self.LandlineorMobiledata != "")
            {
                MessageAlertView.addAction(mobileaction)
            }
            MessageAlertView.addAction(cancelaction)
            
            self.present(MessageAlertView, animated: true, completion: nil)
        }
        message.backgroundColor = UIColor.gray
        
        let mail = UITableViewRowAction(style: .normal, title: "Mail") { action, index in
            var recipents = [String]()
            
            if (self.searchController.isActive && self.searchController.searchBar.text != ""){
                contact = self.filterdcontacts[indexPath.row]
            }else{
                contact = self.ProfContacts[indexPath.row]
            }
           
            if (contact.email != ""){
                if MFMailComposeViewController.canSendMail() {
                    let mail = MFMailComposeViewController()
                    mail.mailComposeDelegate = self
                    mail.setToRecipients(["\(contact.email!)"])
                    mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)
                    UIApplication.topViewController()?.present(mail, animated: true, completion: nil)
                } else {
                    print("CANNOT SEND MAIL")
                }
                
            }else {
                let  passwordAlert = UIAlertController(title: "No Email Found", message: "Sorry , Cannot Mail :(", preferredStyle: UIAlertControllerStyle.alert)
                passwordAlert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: { action in
                }))
                self.present(passwordAlert, animated: true, completion: nil)
            }
        }
        mail.backgroundColor = ColorCode().appThemeColor
        return [mail,message,call]
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func callProf(number: String){
        UIApplication.shared.openURL(URL(string: "tel://" + number)!)
    }
    
    func messageProf(number: String){
        let messageViewontroller = MFMessageComposeViewController()
        let recipents = [number]
        messageViewontroller.recipients = recipents
        messageViewontroller.messageComposeDelegate = self
        self.present(messageViewontroller, animated: true, completion: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ShowProfContact"){
           // searchController.searchBar.isHidden = true
            let ContactView = segue.destination as! ContactInfoTableViewController
            if let indexPath = self.tableView.indexPathForSelectedRow{
                let contact : ProfContactCell
                if (searchController.isActive && searchController.searchBar.text != "")
                {
                    contact = filterdcontacts[indexPath.row]
                }
                else {
                    
                    contact = ProfContacts[indexPath.row]
                    
                }
                ContactView.namedata = contact.name!
                ContactView.LandlineorMobiledata = "\(contact.phoneBSNL!)"
                ContactView.officemobiledata = "\(contact.office!)"
                ContactView.residancemobiledata = "\(contact.residence!)"
                ContactView.designationData = contact.designation!
                ContactView.emaildata = contact.email!
                ContactView.departmentname = DepartmentName
            }
        }
    }
    //Message Controller Delegate
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    //Mail Controller Delegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
  
    
}
