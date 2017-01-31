//
//  DepartmentsTableViewController.swift
//  Telephone Directory
//
//  Created by Kush Taneja on 27/01/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit
import MessageUI

extension DepartmentsTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController){
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
}

class DepartmentsTableViewController: UIViewController,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var searchContainer: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var selectedDepartment = ContactGroupDepartment()
    
    var departmentContacts = [Contact]()
    var filteredDepartmentContacts = [Contact]()
    
    var resdoffstdcode = "0133228 " // std code for roorkee and starting landline
    let std_code_bsnl = "01332"  //std code for roorkee
    var bsnlPhone = ""
    var LandlineorMobiledata = ""
    var bsnltocall = ""
    
    var appThemeColor: UIColor = UIColor(rgb: 0x462D8A)
    var searchController = UISearchController(searchResultsController: nil)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        departmentContacts = selectedDepartment.contacts
        
        //search
        searchController.searchResultsUpdater = self
        self.searchContainer.addSubview(searchController.searchBar)
        searchController.searchBar.tintColor = UIColor(rgb: 0x462D8A)
        // searchController.searchBar.barTintColor = UIColor.white
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        if let option: Bool = UserDefaults.standard.value(forKey: "hindi") as! Bool?{
            switch option {
            case true:
                self.navigationItem.title = selectedDepartment.name["hindi"]
            default:
                self.navigationItem.title = selectedDepartment.name["english"]?.lowercased().capitalized
            }
        }else{
            self.navigationItem.title = selectedDepartment.name["english"]?.lowercased().capitalized
        }
        
        departmentContacts.sort{$0.name! < $1.name!}
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        var frame = searchController.searchBar.bounds
        frame.size.width = self.view.bounds.size.width
        searchController.searchBar.frame = frame
        
    }
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if let option: Bool = UserDefaults.standard.value(forKey: "hindi") as! Bool?{
            switch option {
            case true:
                return selectedDepartment.name["hindi"]
            default:
                return selectedDepartment.name["english"]
            }
            
        }else{
            return selectedDepartment.name["english"]
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(searchController.isActive && searchController.searchBar.text != "") {
            return filteredDepartmentContacts.count
        }else{
            return departmentContacts.count
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfContactCell", for: indexPath) as! ProfContactTableViewCell
        
        var contact = Contact()
        
        if(searchController.isActive && searchController.searchBar.text != "") {
            contact = filteredDepartmentContacts[indexPath.row]
        }else{
            contact = departmentContacts[indexPath.row]
        }
        
        cell.ProfessorName.text = contact.name
        
        cell.ProfImageView.image = #imageLiteral(resourceName: "person")
        
        if let option: Bool = UserDefaults.standard.value(forKey: "hindi") as! Bool?{
            switch option {
            case true:
                cell.Profdesignation.text = contact.designation["hindi"]
            default:
                cell.Profdesignation.text = contact.designation["english"]
            }
        }else{
            cell.Profdesignation.text = contact.designation["english"]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.isSelected = false
        
        var contact = Contact()
        
        if(searchController.isActive && searchController.searchBar.text != "") {
            contact = filteredDepartmentContacts[indexPath.row]
        }else{
            contact = departmentContacts[indexPath.row]
        }
        
        
        let contactInfoScreen = UIStoryboard.ContactInfoScreen() as! ContactInfoTableViewController
        
        contactInfoScreen.selectedContact = contact
        
        self.navigationController?.pushViewController(contactInfoScreen, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        var contact = Contact()
        
        if(searchController.isActive && searchController.searchBar.text != "") {
            contact = filteredDepartmentContacts[indexPath.row]
        }else{
            contact = departmentContacts[indexPath.row]
        }
        
        let call = UITableViewRowAction(style: .default, title: "Call") { action, index in
            let CallAlertView = UIAlertController( title: "Call", message: "Choose number to Call", preferredStyle: .actionSheet)
            
            self.LandlineorMobiledata =  contact.phoneBSNL!
            
            
            if ( self.LandlineorMobiledata != "" ){
                if (self.LandlineorMobiledata.characters.count == 10) {
                    
                    self.bsnlPhone = "Mobile: " + self.LandlineorMobiledata
                    self.bsnltocall = self.LandlineorMobiledata
                    
                }
                else{
                    self.bsnlPhone = "BSNL: " + self.std_code_bsnl + self.LandlineorMobiledata
                    self.bsnltocall = self.std_code_bsnl + self.LandlineorMobiledata
                }
            }
            
            let mobileaction = UIAlertAction(title: "Mobile: " + (contact.mobile!).removeWhitespace(), style: .default, handler: { (alert: UIAlertAction!) -> Void in
                self.callProf(number: (contact.mobile!).removeWhitespace())
            })
            let offcieaction = UIAlertAction(title: "Office: " + (self.resdoffstdcode + contact.office!).removeWhitespace(), style: .default, handler: { (alert: UIAlertAction!) -> Void in
                self.callProf(number: (self.resdoffstdcode + contact.office!).removeWhitespace())
            })
            let residenceaction = UIAlertAction(title: "Residence: " + (self.resdoffstdcode + contact.residence!).removeWhitespace() , style: .default, handler: { (alert: UIAlertAction!) -> Void in
                self.callProf(number: (self.resdoffstdcode + contact.residence!).removeWhitespace())
                
            })
            let bsnlmobileaction = UIAlertAction(title: self.bsnlPhone, style: .default, handler: { (alert: UIAlertAction!) -> Void in
                self.callProf(number: (self.bsnltocall).removeWhitespace())
            })
            let cancelaction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert: UIAlertAction!) -> Void in
            })
            if(contact.mobile! != "")
            {
                CallAlertView.addAction(mobileaction)
            }
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
                CallAlertView.addAction(bsnlmobileaction)
            }
            CallAlertView.addAction(cancelaction)
            
            self.present(CallAlertView, animated: true, completion: nil)
        }
        call.backgroundColor = self.appThemeColor
        
        let message = UITableViewRowAction(style: .normal, title: "Message") { action, index in
            
            self.LandlineorMobiledata =  contact.phoneBSNL!
            
            
            if ( self.LandlineorMobiledata != "" ){
                if (self.LandlineorMobiledata.characters.count == 10) {
                    
                    self.bsnlPhone = "Mobile: " + self.LandlineorMobiledata
                    self.bsnltocall = self.LandlineorMobiledata
                    
                }
                else{
                    self.bsnlPhone = "BSNL: " + self.std_code_bsnl + self.LandlineorMobiledata
                    self.bsnltocall = self.std_code_bsnl + self.LandlineorMobiledata
                }
            }
            
            let MessageAlertView = UIAlertController( title: "Send Message", message: "Choose any number to text", preferredStyle: .actionSheet)
            
            let mobileaction = UIAlertAction(title: "Mobile: " + (contact.mobile!).removeWhitespace(), style: .default, handler: { (alert: UIAlertAction!) -> Void in
                self.messageProf(number: (contact.mobile!).removeWhitespace())
            })
            
            let offcieaction = UIAlertAction(title: "Office: " + (self.resdoffstdcode + contact.office!).removeWhitespace(), style: .default, handler: { (alert: UIAlertAction!) -> Void in
                self.messageProf(number: (self.resdoffstdcode + contact.office!).removeWhitespace())
            })
            let residenceaction = UIAlertAction(title: "Residence: " + (self.resdoffstdcode + contact.residence!).removeWhitespace() , style: .default, handler: { (alert: UIAlertAction!) -> Void in
                self.messageProf(number: (self.resdoffstdcode + contact.residence!).removeWhitespace())
                
            })
            let bsnlmobileaction = UIAlertAction(title: self.bsnlPhone, style: .default, handler: { (alert: UIAlertAction!) -> Void in
                self.messageProf(number: (self.bsnltocall).removeWhitespace())
            })
            let cancelaction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert: UIAlertAction!) -> Void in
            })
            
            if(contact.mobile! != "")
            {
                MessageAlertView.addAction(mobileaction)
            }
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
                MessageAlertView.addAction(bsnlmobileaction)
            }
            MessageAlertView.addAction(cancelaction)
            
            self.present(MessageAlertView, animated: true, completion: nil)
        }
        message.backgroundColor = UIColor.gray
        
        let mail = UITableViewRowAction(style: .normal, title: "Mail") { action, index in
            
            if (contact.email != "" && !((contact.email?.contains(".com"))!)){
                
                UIApplication.shared.openURL(URL(string :"mailto:\(contact.email)@iitr.ac.in")!)
                
            }else if (contact.email != "" && (contact.email?.contains(".com"))!){
                
                UIApplication.shared.openURL(URL(string :"mailto:\(contact.email)")!)
                
            }else {
                let  passwordAlert = UIAlertController(title: "No Email Found", message: "Sorry , Cannot Mail :(", preferredStyle: UIAlertControllerStyle.alert)
                passwordAlert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: { action in
                }))
                self.present(passwordAlert, animated: true, completion: nil)
            }
        }
        mail.backgroundColor = self.appThemeColor
        return [mail,message,call]
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 63.0
    }
    
    //MARK: Private Functions
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        
        filteredDepartmentContacts = departmentContacts.filter({ (contact) -> Bool in
            
            return (contact.name?.lowercased().contains(searchText.lowercased()))!
        })
        self.tableView.reloadData()
        
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
    
    //MARK: Message Controller Delegate
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    //MARK:Mail Controller Delegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
}
