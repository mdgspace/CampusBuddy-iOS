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
import SDWebImage

class ContactInfoTableViewController: UITableViewController,CNContactViewControllerDelegate, MFMailComposeViewControllerDelegate , MFMessageComposeViewControllerDelegate,UIAlertViewDelegate{
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
    var cells = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.isScrollEnabled = false
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.title = "Contact Info"
        cells.append("Name")
        
        if(officemobiledata != "")
        {
            cells.append((resdoffstdcode + officemobiledata).removeWhitespace())
        }
        if(residancemobiledata  != "")
        {
            cells.append((resdoffstdcode + residancemobiledata).removeWhitespace())
        }
        
        if ( LandlineorMobiledata != "" )
           {
            if (String(LandlineorMobiledata[LandlineorMobiledata.startIndex]) == "9" ||  String(LandlineorMobiledata[LandlineorMobiledata.startIndex]) == "8") {
                bsnlPhone = "Mobile: " + LandlineorMobiledata
                bsnltocall = LandlineorMobiledata
                
            }
            else
            {
                bsnlPhone = "BSNL: " + std_code_bsnl + LandlineorMobiledata
                bsnltocall = std_code_bsnl + LandlineorMobiledata
            }
            
            cells.append((resdoffstdcode + LandlineorMobiledata).removeWhitespace())
            
        }
        cells.append("Send Message")
        cells.append("Save to Contacts")
        cells.append("Mail ")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        // #warning Incomplete implementation, return the number of rows
        return cells.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell = UITableViewCell()
        var cello = ContactInfoTableViewCell()
        
        if (indexPath.row == 0){
            cello = tableView.dequeueReusableCell(withIdentifier: "ProfCell", for: indexPath) as! ContactInfoTableViewCell
            cello.ProfDesignatonLabel.text = designationData
            cello.ProfNameLabel.text = namedata
            cello.ProfNameLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
            cello.ProfDepartmentLabel.text = departmentname
            cello.ImageView.sd_setImage(with: URL(string:"http://people.iitr.ernet.in/facultyphoto/\(self.imagrurldata)")!,placeholderImage:#imageLiteral(resourceName: "person"))
            cello.ImageView.layer.cornerRadius = (cello.ImageView.frame.width)/2
            return cello
            
        }
 
        if ((cells.count == 5 && (indexPath.row == 1)) || (cells.count == 6 && (indexPath.row == 1 || indexPath.row == 2)) || (cells.count == 7 && (indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3)))
        {
            cell = tableView.dequeueReusableCell(withIdentifier: "CallCell", for: indexPath)
            
        }
        else
        
        { cell = tableView.dequeueReusableCell(withIdentifier: "SaveCell", for: indexPath) }
        
      
        
        if (cells.count == 5)
        {
            
        
            if (indexPath.row == 1)
                
            {
                
                switch cells[1]
                {
                case (resdoffstdcode + officemobiledata).removeWhitespace():
                    cell.textLabel?.text = "Office"
                case (resdoffstdcode + residancemobiledata).removeWhitespace():
                    cell.textLabel?.text = "Residance"
                case (resdoffstdcode + LandlineorMobiledata).removeWhitespace():
                    cell.textLabel?.text = "Phone"
                default :
                    cell.textLabel?.text = "Office"
                    
                break
                }
                
                cell.detailTextLabel?.text = cells[1]
              
            }
            else if (indexPath.row == 2)
                
            {
                
                
                if ( officemobiledata != "" || bsnltocall != "" || residancemobiledata != "")
                {
                    cell.textLabel?.text = "Send Message"
                }
                else
                {
                    cell.textLabel?.text = "No Number to Send Message"
                    cell.textLabel?.textColor = UIColor.init(red: CGFloat(128.0/255.0), green:CGFloat(128.0/255.0), blue:CGFloat(128.0/255.0), alpha: CGFloat(1.0))
                    cell.isUserInteractionEnabled = false
                    
                }
                
             

                
            }
            else if (indexPath.row == 3)
            {
                
                
                
                if ( officemobiledata != "" || bsnltocall != "" || residancemobiledata != "")
                {
                    cell.textLabel?.text = "Save to Contacts"
                }
                else
                {
                    cell.textLabel?.text = "No Contact found"
                    cell.textLabel?.textColor = UIColor.init(red: CGFloat(128.0/255.0), green:CGFloat(128.0/255.0), blue:CGFloat(128.0/255.0), alpha: CGFloat(1.0))
                    cell.isUserInteractionEnabled = false
                    
                }
                
               
            }
                
            else if (indexPath.row == 4)
            {
                if ( emaildata != "")
                {
                    cell.textLabel?.text = "Mail " + emaildata + "@iitr.ac.in"
                }
                else {
                    
                    cell.textLabel?.text = "No Email found"
                    cell.textLabel?.textColor = UIColor.init(red: CGFloat(128.0/255.0), green:CGFloat(128.0/255.0), blue:CGFloat(128.0/255.0), alpha: CGFloat(1.0))
                    cell.isUserInteractionEnabled = false
                    
                }
                
          
                
            }
           
            
  
                
                return cell
            
        }
        else if (cells.count == 6)
        {
           
            
            if (indexPath.row == 1)
                
            {
                
                switch cells[1]
                {
                case (resdoffstdcode + officemobiledata).removeWhitespace():
                    cell.textLabel?.text = "Office"
                case (resdoffstdcode + residancemobiledata).removeWhitespace():
                    cell.textLabel?.text = "Residance"
                case (resdoffstdcode + LandlineorMobiledata).removeWhitespace():
                    cell.textLabel?.text = "Phone"
                default :
                    cell.textLabel?.text = "Office"
                    
                    break
                }
                
                cell.detailTextLabel?.text = cells[1]
                
                return cell
            }
            else if (indexPath.row == 2)
                
            {
                
                switch cells[2]
                {
                case (resdoffstdcode + officemobiledata).removeWhitespace():
                    cell.textLabel?.text = "Office"
                case (resdoffstdcode + residancemobiledata).removeWhitespace():
                    cell.textLabel?.text = "Residance"
                case (resdoffstdcode + LandlineorMobiledata).removeWhitespace():
                    cell.textLabel?.text = "Phone"
                default :
                    cell.textLabel?.text = "Office"
                    
                    break
                }
                
                cell.detailTextLabel?.text = cells[2]
                
                return cell
                
            }
            else if (indexPath.row == 3)
            {
                if ( officemobiledata != "" || bsnltocall != "" || residancemobiledata != "")
                {
                    cell.textLabel?.text = "Send Message"
                }
                else
                {
                    cell.textLabel?.text = "No Number to Send Message"
                    cell.textLabel?.textColor = UIColor.init(red: CGFloat(128.0/255.0), green:CGFloat(128.0/255.0), blue:CGFloat(128.0/255.0), alpha: CGFloat(1.0))
                    cell.isUserInteractionEnabled = false
                    
                }
                
                return cell
                

                
               
            }
                
            else if (indexPath.row == 4)
            {
                
                if ( officemobiledata != "" || bsnltocall != "" || residancemobiledata != "")
                {
                    cell.textLabel?.text = "Save to Contacts"
                }
                else
                {
                    cell.textLabel?.text = "No Contact found"
                    cell.textLabel?.textColor = UIColor.init(red: CGFloat(128.0/255.0), green:CGFloat(128.0/255.0), blue:CGFloat(128.0/255.0), alpha: CGFloat(1.0))
                    cell.isUserInteractionEnabled = false
                    
                }
                
                return cell
                
            }
            
            else if (indexPath.row == 5)
            {
            
                if ( emaildata != "")
                {
                    cell.textLabel?.text = "Mail " + emaildata + "@iitr.ac.in"
                }
                else {
                    
                    cell.textLabel?.text = "No Email found"
                    cell.textLabel?.textColor = UIColor.init(red: CGFloat(128.0/255.0), green:CGFloat(128.0/255.0), blue:CGFloat(128.0/255.0), alpha: CGFloat(1.0))
                    cell.isUserInteractionEnabled = false
                    
                }
                
                return cell

            
            }
            
            
            
            else {
                
                return cell
            }
            
        }
        else if (cells.count == 7)
        {
            if (indexPath.row == 1)
                
            {
                            switch cells[1]
                {
                case (resdoffstdcode + officemobiledata).removeWhitespace():
                    cell.textLabel?.text = "Office"
                case (resdoffstdcode + residancemobiledata).removeWhitespace():
                    cell.textLabel?.text = "Residance"
                case (resdoffstdcode + LandlineorMobiledata).removeWhitespace():
                    cell.textLabel?.text = "Phone"
                default :
                    cell.textLabel?.text = "Office"
                    
                    break
                }
                
                cell.detailTextLabel?.text = cells[1]
                
                return cell
            }
            else if (indexPath.row == 2)
                
            {
                
                switch cells[2]
                {
                case (resdoffstdcode + officemobiledata).removeWhitespace():
                    cell.textLabel?.text = "Office"
                case (resdoffstdcode + residancemobiledata).removeWhitespace():
                    cell.textLabel?.text = "Residance"
                case (resdoffstdcode + LandlineorMobiledata).removeWhitespace():
                    cell.textLabel?.text = "Phone"
                default :
                    cell.textLabel?.text = "Office"
                    
                    break
                }
                
                cell.detailTextLabel?.text = cells[2]
                
                return cell
                
            }
            else if ( indexPath.row == 3)
                
            {
                
                switch cells[3]
                {
                case (resdoffstdcode + officemobiledata).removeWhitespace():
                    cell.textLabel?.text = "Office"
                case (resdoffstdcode + residancemobiledata).removeWhitespace():
                    cell.textLabel?.text = "Residance"
                case (resdoffstdcode + LandlineorMobiledata).removeWhitespace():
                    cell.textLabel?.text = "Phone"
                default :
                    cell.textLabel?.text = "Office"
                    
                    break
                }
                
                cell.detailTextLabel?.text = cells[3]
                
                return cell
            
            }
            else if (indexPath.row == 4)
            {
                if ( officemobiledata != "" || bsnltocall != "" || residancemobiledata != "")
                {
                    cell.textLabel?.text = "Send Message"
                }
                else
                {
                    cell.textLabel?.text = "No Number to Send Message"
                    cell.textLabel?.textColor = UIColor.init(red: CGFloat(128.0/255.0), green:CGFloat(128.0/255.0), blue:CGFloat(128.0/255.0), alpha: CGFloat(1.0))
                    cell.isUserInteractionEnabled = false
                    
                }
                
                return cell
                
                
                
                
            }
                
            else if (indexPath.row == 5)
            {
                
                if ( officemobiledata != "" || bsnltocall != "" || residancemobiledata != "")
                {
                    cell.textLabel?.text = "Save to Contacts"
                }
                else
                {
                    cell.textLabel?.text = "No Contact found"
                    cell.textLabel?.textColor = UIColor.init(red: CGFloat(128.0/255.0), green:CGFloat(128.0/255.0), blue:CGFloat(128.0/255.0), alpha: CGFloat(1.0))
                    cell.isUserInteractionEnabled = false
                    
                }
                
                return cell
                
            }
                
            else if (indexPath.row == 6)
            {
                
                if ( emaildata != "")
                {
                    cell.textLabel?.text = "Mail " + emaildata + "@iitr.ac.in"
                }
                else {
                    
                    cell.textLabel?.text = "No Email found"
                    cell.textLabel?.textColor = UIColor.init(red: CGFloat(128.0/255.0), green:CGFloat(128.0/255.0), blue:CGFloat(128.0/255.0), alpha: CGFloat(1.0))
                    cell.isUserInteractionEnabled = false
                    
                }
                
                return cell
                
            }
        
        else {
            
            return cell
        }

        }
        else {
            
            return cell
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (cells.count == 5)
        {
            if ( indexPath.row == 0)
            {
                
            }
            if ( indexPath.row == 1)
            {
                self.callProf(number: cells[1])
                
                
            }
            if ( indexPath.row == 2)
            {
                let MessageAlertView = UIAlertController( title: "Send Message", message: "Choose any number to text", preferredStyle: .actionSheet)
                let number = resdoffstdcode + officemobiledata
                
                let offcieaction = UIAlertAction(title: "Office: " + resdoffstdcode + officemobiledata, style: .default, handler: { (alert: UIAlertAction!) -> Void in
                    self.messageProf(number: number)
                })
                let residenceaction = UIAlertAction(title: "Residence: " + resdoffstdcode + residancemobiledata , style: .default, handler: { (alert: UIAlertAction!) -> Void in
                    self.messageProf(number: self.resdoffstdcode + self.residancemobiledata)
                    
                })
                
                let mobileaction = UIAlertAction(title: bsnlPhone, style: .default, handler: { (alert: UIAlertAction!) -> Void in
                    self.messageProf(number: self.bsnltocall)
                })
                let cancelaction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert: UIAlertAction!) -> Void in
                })
                
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
                    MessageAlertView.addAction(mobileaction)
                }
                MessageAlertView.addAction(cancelaction)
                
                self.present(MessageAlertView, animated: true, completion: nil)
                
            }
            if ( indexPath.row == 3){
                
                contact.givenName = namedata
                let email = "\(emaildata)@iitr.ac.in"
                
                let workemail = CNLabeledValue(label: "Work Email", value:email as NSString)
                contact.emailAddresses = [workemail]
                
                var phonenumbers : [CNLabeledValue<CNPhoneNumber>] = []
                
                let OfficeNumber = CNLabeledValue(
                    label:CNLabelWork,
                    value:CNPhoneNumber(stringValue:resdoffstdcode + officemobiledata))
                
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

    
            }
            if ( indexPath.row == 4)
            {
                if MFMailComposeViewController.canSendMail() {
                    let mail = MFMailComposeViewController()
                    mail.mailComposeDelegate = self
                    mail.setToRecipients([emaildata+"@iitr.ac.in"])
                    mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)
                    UIApplication.topViewController()?.present(mail, animated: true, completion: nil)
                } else {
                    print("CANNOT SEND MAIL")
                }
            }
            
            
        }
        if (cells.count == 6)
        {
            
            if ( indexPath.row == 0)
            {
                
            }
            if ( indexPath.row == 1)
            {
                self.callProf(number: cells[1])
                
            }
            if ( indexPath.row == 2)
            {
                self.callProf(number: cells[2])
                
                
            }
            if ( indexPath.row == 3)
            {
                let MessageAlertView = UIAlertController( title: "Send Message", message: "Choose any number to text", preferredStyle: .actionSheet)
                let number = resdoffstdcode + officemobiledata
                
                let offcieaction = UIAlertAction(title: "Office: " + resdoffstdcode + officemobiledata, style: .default, handler: { (alert: UIAlertAction!) -> Void in
                    self.messageProf(number: number)
                })
                let residenceaction = UIAlertAction(title: "Residence: " + resdoffstdcode + residancemobiledata , style: .default, handler: { (alert: UIAlertAction!) -> Void in
                    self.messageProf(number: self.resdoffstdcode + self.residancemobiledata)
                    
                })
                
                let mobileaction = UIAlertAction(title: bsnlPhone, style: .default, handler: { (alert: UIAlertAction!) -> Void in
                    self.messageProf(number: self.bsnltocall)
                })
                let cancelaction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert: UIAlertAction!) -> Void in
                })
                
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
                    MessageAlertView.addAction(mobileaction)
                }
                MessageAlertView.addAction(cancelaction)
                
                self.present(MessageAlertView, animated: true, completion: nil)
                
            }
            if ( indexPath.row == 4)
            {
                
                contact.givenName = namedata
                let email = "\(emaildata)@iitr.ac.in"
                
                let workemail = CNLabeledValue(label: "Work Email", value:email as NSString)
                contact.emailAddresses = [workemail]
                
                var phonenumbers : [CNLabeledValue<CNPhoneNumber>] = []
                
                let OfficeNumber = CNLabeledValue(
                    label:CNLabelWork,
                    value:CNPhoneNumber(stringValue:resdoffstdcode + officemobiledata))
                
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
            }
            if ( indexPath.row == 5)
            {
                if MFMailComposeViewController.canSendMail() {
                    let mail = MFMailComposeViewController()
                    mail.mailComposeDelegate = self
                    mail.setToRecipients([emaildata+"@iitr.ac.in"])
                    mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)
                    
                    UIApplication.topViewController()?.present(mail, animated: true, completion: nil)
                } else {
                    print("CANNOT SEND MAIL")
                }
            }
        }
        if (cells.count == 7)
        {
            
            if ( indexPath.row == 0)
            {
                
            }
            if ( indexPath.row == 1)
            {
                self.callProf(number: cells[1])
                
            }
            if ( indexPath.row == 2)
            {
                self.callProf(number: cells[2])
                
                
            }
            if ( indexPath.row == 3)
            {
                self.callProf(number: cells[3])
                
                
            }
            if ( indexPath.row == 4)
            {
                let MessageAlertView = UIAlertController( title: "Send Message", message: "Choose any number to text", preferredStyle: .actionSheet)
                let number = resdoffstdcode + officemobiledata
                
                let offcieaction = UIAlertAction(title: "Office: " + resdoffstdcode + officemobiledata, style: .default, handler: { (alert: UIAlertAction!) -> Void in
                    self.messageProf(number: number)
                })
                let residenceaction = UIAlertAction(title: "Residence: " + resdoffstdcode + residancemobiledata , style: .default, handler: { (alert: UIAlertAction!) -> Void in
                    self.messageProf(number: self.resdoffstdcode + self.residancemobiledata)
                    
                })
                
                let mobileaction = UIAlertAction(title: bsnlPhone, style: .default, handler: { (alert: UIAlertAction!) -> Void in
                    self.messageProf(number: self.bsnltocall)
                })
                let cancelaction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert: UIAlertAction!) -> Void in
                })
                
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
                    MessageAlertView.addAction(mobileaction)
                }
                MessageAlertView.addAction(cancelaction)
                
                self.present(MessageAlertView, animated: true, completion: nil)
                
            }
            if ( indexPath.row == 5)
            {
                
                
                contact.givenName = namedata
                let email = "\(emaildata)@iitr.ac.in"
                
                let workemail = CNLabeledValue(label: "Work Email", value:email as NSString)
                contact.emailAddresses = [workemail]
                
                var phonenumbers : [CNLabeledValue<CNPhoneNumber>] = []
                
                let OfficeNumber = CNLabeledValue(
                    label:CNLabelWork,
                    value:CNPhoneNumber(stringValue:resdoffstdcode + officemobiledata))
                
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

            }
            if ( indexPath.row == 6)
            {
                if MFMailComposeViewController.canSendMail() {
                    let mail = MFMailComposeViewController()
                    mail.mailComposeDelegate = self
                    mail.setToRecipients([emaildata+"@iitr.ac.in"])
                    mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)
                    UIApplication.topViewController()?.present(mail, animated: true, completion: nil)
                } else {
                    print("CANNOT SEND MAIL")
                }
            }
            
        }
    }
    
    
    
    
    //Choose your custom row height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if(indexPath.row == 0) {
            return 100
        }
        else if ((cells.count == 5 && (indexPath.row == 1)) || (cells.count == 6 && (indexPath.row == 1 || indexPath.row == 2)) || (cells.count == 7 && (indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3)))
        {
            return 54.0;
        }
            
        else {
            return 44.0;
            
        }
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
