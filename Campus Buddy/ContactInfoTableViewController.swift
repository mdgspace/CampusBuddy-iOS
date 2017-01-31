//
//  ContactInfoTableViewController.swift
//  cBuddy
//
//  Created by Kush Taneja on 28/08/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import MessageUI



enum cellProperty: Int {
    
    case nameProfile
    case mobileCall
    case officeCall
    case residanceCall
    case bsnlCall
    case sendMessage
    case save
    case mail
    
    static func numberOfProperties() -> Int {
        return 8
    }
}



class ContactInfoTableViewController: UITableViewController,CNContactViewControllerDelegate, MFMailComposeViewControllerDelegate , MFMessageComposeViewControllerDelegate,UIAlertViewDelegate{
    
    var selectedContact = Contact()
    let contact = CNMutableContact()
    var namedata = String()
    var designationData = String()
    var officemobiledata = String()
    var residancemobiledata = String()
    var LandlineorMobiledata = String()
    var emaildata = String()
    var resdoffstdcode = "0133228 " // std code for roorkee and starting landline
    let std_code_bsnl = "01332"  //std code for roorkee
    var bsnlPhone = ""
    var bsnltocall = ""
    var imagdata : UIImage?
    var imagrurldata = ""
    var departmentname = ""
    var mobileData = String()
    var cells = [String]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.isScrollEnabled = false
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.title = "Contact Info"
        
        self.addValues()
        
        if ( LandlineorMobiledata != "" ){
            if (LandlineorMobiledata.characters.count == 10) {
                
                bsnlPhone = "Mobile: " + LandlineorMobiledata
                bsnltocall = LandlineorMobiledata
                
            }
            else{
                bsnlPhone = "BSNL: " + std_code_bsnl + LandlineorMobiledata
                bsnltocall = std_code_bsnl + LandlineorMobiledata
            }
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let option: Bool = UserDefaults.standard.value(forKey: "hindi") as! Bool?{
            switch option {
            case true:
                self.title = "कांटेक्ट इन्फो"
            default:
                self.title = "Contact Info"
            }
        }else{
            self.title = "Contact Info"
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return cellProperty.numberOfProperties()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if let propertyType = cellProperty(rawValue: indexPath.row) {
            
            switch propertyType {
                
            case .nameProfile:
                tableView.rowHeight = 99.0
                var cello = tableView.dequeueReusableCell(withIdentifier: "ProfCell", for: indexPath) as! ContactInfoTableViewCell
                cello.ProfDesignatonLabel.text = designationData
                cello.ProfNameLabel.text = namedata
                cello.ProfNameLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
                cello.ProfDepartmentLabel.text = departmentname
                cello.ImageView.image = #imageLiteral(resourceName: "person")
                cello.ImageView.layer.cornerRadius = (cello.ImageView.frame.width)/2
                cello.isUserInteractionEnabled = false
                return cello
                
            case .mobileCall:
                tableView.rowHeight = 54.0
                var cell = tableView.dequeueReusableCell(withIdentifier: "CallCell", for: indexPath)
                if (mobileData == ""){
                    cell.isHidden = true
                    cell.contentView.frame = CGRect.zero
                    tableView.rowHeight = 0.0
                    
                }else{
                    tableView.rowHeight = 54.0
                    cell.textLabel?.text = "Mobile"
                    cell.detailTextLabel?.text = mobileData.removeWhitespace()
                }
                return cell
                
            case .officeCall:
                tableView.rowHeight = 54.0
                var cell = tableView.dequeueReusableCell(withIdentifier: "CallCell", for: indexPath)
                if (officemobiledata == ""){
                    cell.isHidden = true
                    cell.contentView.frame = CGRect.zero
                    tableView.rowHeight = 0.0
                    
                }else{
                    tableView.rowHeight = 54.0
                    cell.textLabel?.text = "Office"
                    cell.detailTextLabel?.text = (resdoffstdcode + officemobiledata).removeWhitespace()
                }
                return cell
                
            case .residanceCall:
                tableView.rowHeight = 54.0
                var cell = tableView.dequeueReusableCell(withIdentifier: "CallCell", for: indexPath)
                if (residancemobiledata == ""){
                    cell.isHidden = true
                    cell.contentView.frame = CGRect.zero
                    tableView.rowHeight = 0.0
                    
                }else{
                    tableView.rowHeight = 54.0
                    cell.textLabel?.text = "Residence"
                    cell.detailTextLabel?.text = (resdoffstdcode + residancemobiledata).removeWhitespace()
                }
                return cell
                
            case .bsnlCall:
                var cell = tableView.dequeueReusableCell(withIdentifier: "CallCell", for: indexPath)
                cells.append((bsnltocall).removeWhitespace())
                if (LandlineorMobiledata == ""){
                    cell.isHidden = true
                    cell.contentView.frame = CGRect.zero
                    tableView.rowHeight = 0.0
                    
                }else{
                    tableView.rowHeight = 54.0
                    
                    if (LandlineorMobiledata.characters.count == 10) {
                        cell.textLabel?.text = "Mobile"
                        bsnltocall = LandlineorMobiledata
                    }
                    else{
                        cell.textLabel?.text = "BSNL"
                        bsnltocall = std_code_bsnl + LandlineorMobiledata
                    }
                    cell.detailTextLabel?.text = (bsnltocall).removeWhitespace()
                }
                return cell
            case .sendMessage:
                tableView.rowHeight = 37.0
                var cell = tableView.dequeueReusableCell(withIdentifier: "SaveCell", for: indexPath)
                
                if ( officemobiledata != "" || bsnltocall != "" || residancemobiledata != "" || mobileData != ""){
                    cell.textLabel?.text = "Send Message"
                }else{
                    cell.isHidden = true
                    cell.contentView.frame = CGRect.zero
                    tableView.rowHeight = 0.0
                }
                return cell
                
            case .save:
                tableView.rowHeight = 37.0
                var cell = tableView.dequeueReusableCell(withIdentifier: "SaveCell", for: indexPath)
                
                if ( officemobiledata != "" || bsnltocall != "" || residancemobiledata != "" || mobileData != "")
                {
                    cell.textLabel?.text = "Save to Contacts"
                }else{
                    cell.isHidden = true
                    cell.contentView.frame = CGRect.zero
                    tableView.rowHeight = 0.0
                }
                return cell
            case .mail:
                tableView.rowHeight = 37.0
                var cell = tableView.dequeueReusableCell(withIdentifier: "SaveCell", for: indexPath)
                
                if (emaildata != "" && !(emaildata.contains(".com"))){
                    
                    cell.textLabel?.text = "Mail " + emaildata + "@iitr.ac.in"
                    
                }else if (emaildata != "" && emaildata.contains(".com")){
                    
                    cell.textLabel?.text = "Mail " + emaildata
                    
                }else{
                    
                    cell.isHidden = true
                    cell.contentView.frame = CGRect.zero
                    tableView.rowHeight = 0.0
                }
                return cell
                
            default:
                break
            }
            
        }else{
            var cell = tableView.dequeueReusableCell(withIdentifier: "SaveCell", for: indexPath)
            cell.isHidden = true
            cell.contentView.frame = CGRect.zero
            tableView.rowHeight = 0.0
            return cell
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.isSelected = false
        
        if let propertyType = cellProperty(rawValue: indexPath.row) {
            
            switch propertyType {
                
            case .nameProfile:
                break
                
            case .mobileCall:
                self.callProf(number: mobileData.removeWhitespace())
                
            case .officeCall:
                self.callProf(number: (resdoffstdcode + officemobiledata).removeWhitespace())
                
            case .residanceCall:
                self.callProf(number: (resdoffstdcode + residancemobiledata).removeWhitespace())
                
            case .bsnlCall:
                self.callProf(number: (bsnltocall).removeWhitespace())
                
            case .sendMessage:
                
                let MessageAlertView = UIAlertController( title: "Send Message", message: "Choose any number to text", preferredStyle: .actionSheet)
                
                let mobileaction = UIAlertAction(title: "Mobile: " + self.mobileData.removeWhitespace(), style: .default, handler: { (alert: UIAlertAction!) -> Void in
                    self.messageProf(number: self.mobileData.removeWhitespace())
                })
                
                let offcieaction = UIAlertAction(title: "Office: " + (resdoffstdcode + officemobiledata).removeWhitespace(), style: .default, handler: { (alert: UIAlertAction!) -> Void in
                    self.messageProf(number: (self.resdoffstdcode + self.officemobiledata).removeWhitespace())
                })
                let residenceaction = UIAlertAction(title: "Residence: " + resdoffstdcode + residancemobiledata , style: .default, handler: { (alert: UIAlertAction!) -> Void in
                    self.messageProf(number: (self.resdoffstdcode + self.residancemobiledata).removeWhitespace())
                    
                })
                let bsnlmobileaction = UIAlertAction(title: bsnlPhone, style: .default, handler: { (alert: UIAlertAction!) -> Void in
                    self.messageProf(number: (self.bsnltocall).removeWhitespace())
                })
                let cancelaction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert: UIAlertAction!) -> Void in
                })
                
                if(mobileData != "")
                {
                    MessageAlertView.addAction(mobileaction)
                }
                if(officemobiledata != "")
                {
                    MessageAlertView.addAction(offcieaction)
                }
                if(residancemobiledata  != "")
                {
                    MessageAlertView.addAction(residenceaction)
                }
                if(LandlineorMobiledata != "")
                {
                    MessageAlertView.addAction(bsnlmobileaction)
                }
                MessageAlertView.addAction(cancelaction)
                
                self.present(MessageAlertView, animated: true, completion: nil)
                
            case .save:
                
                contact.givenName = namedata
                
                var email = String()
                
                if (!(emaildata.contains(".com"))){
                    
                    email = "\(emaildata)@iitr.ac.in"
                    
                }else if (emaildata != "" && emaildata.contains(".com")){
                    
                    email = "\(emaildata)"
                    
                }
                
                let workemail = CNLabeledValue(label: "Work Email", value:email as NSString)
                
                contact.emailAddresses = [workemail]
                
                var phonenumbers : [CNLabeledValue<CNPhoneNumber>] = []
                
                let OfficeNumber = CNLabeledValue(
                    label:CNLabelWork,
                    value:CNPhoneNumber(stringValue:resdoffstdcode + officemobiledata))
                
                if(mobileData != ""){
                    phonenumbers.append(CNLabeledValue(
                        label:CNLabelPhoneNumberMobile,
                        value:CNPhoneNumber(stringValue:mobileData)))
                }
                if (officemobiledata != ""){
                    phonenumbers.append(OfficeNumber)
                }
                let HomeNumber = CNLabeledValue(
                    label:CNLabelHome,
                    value:CNPhoneNumber(stringValue:resdoffstdcode + residancemobiledata))
                
                if (residancemobiledata != ""){
                    phonenumbers.append(HomeNumber)
                }
                phonenumbers.append(CNLabeledValue(
                    label:CNLabelPhoneNumberMain,
                    value:CNPhoneNumber(stringValue:bsnltocall)))
                
                contact.phoneNumbers = phonenumbers
                let store = CNContactStore()
                
                let controller = CNContactViewController.init(forNewContact: contact)
                controller.contactStore = store
                controller.delegate = self
                let nav = UINavigationController.init(rootViewController: controller)
                self.present(nav, animated: true, completion: nil)
                
            case .mail:
                if (emaildata != "" && !(emaildata.contains(".com"))){
                    
                    UIApplication.shared.openURL(URL(string :"mailto:\(emaildata)@iitr.ac.in")!)
                    
                }else if (emaildata != "" && emaildata.contains(".com")){
                    
                    UIApplication.shared.openURL(URL(string :"mailto:\(emaildata)")!)
                    
                }
                
            }
            
        }
    }
    
    
    //start
    func addValues(){
        
        self.namedata = selectedContact.name!
        
        if let option: Bool = UserDefaults.standard.value(forKey: "hindi") as! Bool?{
            switch option {
            case true:
                self.designationData = selectedContact.designation["hindi"]!
                self.departmentname = (selectedContact.departmentName?["hindi"]!)!
                
            default:
                self.designationData = (selectedContact.designation["english"]?.lowercased().capitalized)!
                self.departmentname  = (selectedContact.departmentName?["english"]?.lowercased().capitalized)!
            }
        }else{
            self.navigationItem.title = selectedContact.designation["english"]?.lowercased().capitalized
        }
        
        self.officemobiledata = selectedContact.office!
        self.residancemobiledata = selectedContact.residence!
        self.LandlineorMobiledata = selectedContact.phoneBSNL!
        self.emaildata = selectedContact.email!
        self.mobileData = selectedContact.mobile!
        
    }
    // Call Function
    func callProf(number: String)
    {
        UIApplication.shared.openURL(
            URL(string: "tel://" + number)!)
    }
    //Message Function
    func messageProf(number: String){
        let messageViewontroller = MFMessageComposeViewController()
        let recipents = [number]
        messageViewontroller.recipients = recipents
        messageViewontroller.messageComposeDelegate = self
        self.present(messageViewontroller, animated: true, completion: nil)
        
        
    }
    //Message Controller Delegate
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    //Mail Controller Delegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    //contacts
    func contactViewController(_ viewController: CNContactViewController, shouldPerformDefaultActionFor property: CNContactProperty) -> Bool{
        return true
    }
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        viewController.dismiss(animated: true)
    }
}
