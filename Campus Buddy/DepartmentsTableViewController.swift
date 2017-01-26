//
//  DepartmentsTableViewController.swift
//  cBuddy
//
//  Created by Kush Taneja on 27/08/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//


import UIKit
import LocalAuthentication
import MessageUI
import SDWebImage

extension DepartmentsTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController){
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}

class DepartmentsTableViewController: UITableViewController, UIAlertViewDelegate,MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate{
    
    var DepartmentsArray :NSMutableArray = []
    let searchController = UISearchController(searchResultsController: nil)
    var Departments = [DepartmentCell]()
    var Professors = [ProfContactCell]()
    var filterProfessors = [ProfContactCell]()
    var resdoffstdcode = "0133228 " // std code for roorkee and starting landline
    let std_code_bsnl = "01332"  //std code for roorkee
    var LandlineorMobiledata = ""
    var bsnlPhone = ""
    var bsnltocall = ""
    
    var alphabeticalIndexTitles = ["A", "B", "C", "D","E", "F", "G", "H","I", "J", "K", "L", "M","N","O","P","Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    
    
    var profSections : [(index: Int, length :Int, title: String)] = Array()
    var departmentSections: [(index: Int, length :Int, title: String)] = Array()

    
    @IBOutlet var Switch : UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.searchController.searchBar.isTranslucent = false
        
        self.tableView.sectionIndexBackgroundColor = UIColor.clear
        
        ActivityIndicator.shared.showProgressView(uiView: self.view)
        
        
        tableView.tableHeaderView = searchController.searchBar
        // Search Bars
        searchController.searchResultsUpdater = self
        searchController.searchBar.backgroundColor = ColorCode().appThemeColor
        searchController.searchBar.tintColor = UIColor.white
        searchController.searchBar.barTintColor = ColorCode().appThemeColor
        searchController.searchBar.inputView?.tintColor = ColorCode().appThemeColor
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        self.navigationController?.navigationBar.translatesAutoresizingMaskIntoConstraints = true
        
        //JSON Parsing
        jsonParsingFromFile()
        
        for department in DepartmentsArray{
            
            let department = department as! NSDictionary
            let departmentname = department.value(forKey: "name") as! String
            
            let photourl = department.value(forKey:"photo") != nil ? department.value(forKey:"photo")  as! String : ""
            let departmentContacts = department.value(forKey:"contacts") as! [NSMutableDictionary]
            
            for departmentContact in departmentContacts{
                let profname = departmentContact.value(forKey: "name") as! String?
                let profdesignation = departmentContact.value(forKey: "designation") as! String?
                let profoffice = departmentContact.value(forKey: "iitr_o") as! String?
                let profresidence = departmentContact.value(forKey: "iitr_r") as! String?
                let profphoneBSNL = departmentContact.value(forKey: "phoneBSNL") as! String?
                let profemail = departmentContact.value(forKey: "email") as! String?
                let profprofilePic = departmentContact.value(forKey: "profilePic") as! String?
                
                Professors.append(ProfContactCell(namedata: profname, designationdata: profdesignation, officedata: profoffice, residencedata: profresidence, phoneBSNLdata: profphoneBSNL, emaildata: profemail, profilePicdata: profprofilePic, department: departmentname))
                
            }
            
            Departments.append(DepartmentCell(Departmentname:departmentname , DepartmentPhotourl: photourl, Departmentcontacts: departmentContacts))
        }
        
        //sorting
        Departments.sort{$0.DepartmentNAME < $1.DepartmentNAME}
        Professors.sort{$0.name! < $1.name!}
        
        
        var index = 0
        
        for i in 0..<Departments.count {
            
            let commonPrefix = Departments[i].DepartmentNAME.commonPrefix(with: Departments[index].DepartmentNAME, options: .caseInsensitive)
            
            if (commonPrefix.characters.count == 0) {
                
                let string = Departments[index].DepartmentNAME.uppercased()
                
                let firstCharacter = string[string.startIndex]
                
                let title = "\(firstCharacter)"
                
                let newSection = (index: index, length: i - index, title: title)
                
                departmentSections.append(newSection)
                
                index = i
                
            }
            
        }
        
        var proIndex = 0
        
        for j in 0..<Professors.count {
            
            let name = Professors[j].name!
            let commonProfPrefix = name.commonPrefix(with: Professors[proIndex].name!, options: .caseInsensitive)
            
            if (commonProfPrefix.characters.count == 0) {
                
                let stringName = Professors[proIndex].name!
                
                let spring =  stringName.uppercased()
                
                let character = spring[spring.startIndex]
                
                let newTitle = "\(character)"
                
                let newprofSection = (index: proIndex, length: j - proIndex, title: newTitle)
                
                profSections.append(newprofSection)
                
                proIndex = j
                
            }
            
        }
        
        self.tableView.reloadData()
    }
    
   
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.resignFirstResponder()
    }
    
    // Search Filters
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        
        filterProfessors = Professors.filter {
            Professor in
            return Professor.name!.lowercased().contains(searchText.lowercased()) || Professor.profdepartment!.lowercased().contains(searchText.lowercased())
        }
        self.tableView.reloadData()
    }
    
    func jsonParsingFromFile(){
        
        /*
 if(Reachability.isConnectedToNetwork()){
            
            let json_url = "https://www.sdsmdg.ml/cb/contacts.json"
            
            Network().getRequestWithoutHeader(json_url, params: ["":"" as AnyObject], completion: { (result:Any, code:Int) in
                self.DepartmentsArray = result as! NSMutableArray
              //  self.DepartmentsArray = result.arrayValue
            }, failed: { (error) in
                debugPrint("\(error)")
                
                let path: NSString = Bundle.main.path(forResource: "ProfessorContactatIItR", ofType: ".json")! as NSString
                let Departmentdata : Data = try! NSData(contentsOfFile: path as String, options: Data.ReadingOptions.dataReadingMapped) as Data
                let jsonarray: NSArray!=(try! JSONSerialization.jsonObject(with: Departmentdata, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSArray
                self.DepartmentsArray = jsonarray as! NSMutableArray
                
            })
            
        }else{
            */
        let path: NSString = Bundle.main.path(forResource: "ProfessorContactatIItR", ofType: ".json")! as NSString
        let Departmentdata : Data = try! NSData(contentsOfFile: path as String, options: Data.ReadingOptions.dataReadingMapped) as Data
        let jsonarray: NSArray!=(try! JSONSerialization.jsonObject(with: Departmentdata, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSArray
        DepartmentsArray = jsonarray as! NSMutableArray
        
        ActivityIndicator.shared.hideProgressView()
        
        }
    
   // }
    
    override  func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int{
        
        if (searchController.isActive && searchController.searchBar.text != ""){
            
            return 1
            
        }else{
            switch Switch.selectedSegmentIndex {
            case 0:
                return departmentSections.count
            case 1:
                return profSections.count
            default:
                return 0
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        if (searchController.isActive && searchController.searchBar.text != ""){
            return "Top Name Matches"
        }else{
        switch Switch.selectedSegmentIndex {
        case 0:
            return departmentSections[section].title
        case 1:
            return profSections[section].title
        default:
            return ""
        }
    }
    }
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if (searchController.isActive && searchController.searchBar.text != ""){
            return nil
        }else{
        switch Switch.selectedSegmentIndex {
        case 0:
            return departmentSections.map { $0.title }
        case 1:
            return profSections.map { $0.title }
        default:
            return nil
        }
        }
    }
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int{
        return index
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        if (searchController.isActive && searchController.searchBar.text != ""){
            return filterProfessors.count
        }else{
            
        switch Switch.selectedSegmentIndex {
        case 0:
            return departmentSections[section].length
        case 1:
            return profSections[section].length
        default:
            return 0
        }
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DepartmentCell", for: indexPath) as! DepartmentTableViewCell
        let department : DepartmentCell
        var professor : ProfContactCell
        
        if (searchController.isActive && searchController.searchBar.text != ""){
            
            professor = filterProfessors[indexPath.row]
            cell.Subtitle.isHidden = false
            cell.Title.text = professor.name
            cell.Subtitle.text = professor.profdepartment
            
            if (professor.profilePic! != "default.jpg" || professor.profilePic! !=  ""){
                cell.departmentImageView.sd_setImage(with: URL(string:"http://people.iitr.ernet.in/facultyphoto/\(professor.profilePic!)")!, placeholderImage: #imageLiteral(resourceName: "person"))
            }else{
                cell.departmentImageView.image = #imageLiteral(resourceName: "person")
            }
             cell.departmentImageView.layer.cornerRadius = (cell.departmentImageView.frame.width)/2
        }else{
            switch Switch.selectedSegmentIndex
            {
            case 0:
                cell.Subtitle.isHidden = true
                department = Departments[departmentSections[indexPath.section].index + indexPath.row]
                cell.Title.text = department.DepartmentNAME
                if ((department.DepartmentPhotoUrl).characters.count <= 4){
                cell.departmentImageView.sd_setImage(with: URL(string:"http://www.iitr.ac.in/departments/\(department.DepartmentPhotoUrl)/assets/images/top1.jpg")!, placeholderImage:#imageLiteral(resourceName: "department"))
            }else{
                cell.departmentImageView.sd_setImage(with: URL(string:"\(department.DepartmentPhotoUrl)")!, placeholderImage:#imageLiteral(resourceName: "department"))
            }
                cell.departmentImageView.layer.cornerRadius = (cell.departmentImageView.frame.width)/2
            case 1:
                cell.Subtitle.isHidden = false
                professor = Professors[profSections[indexPath.section].index + indexPath.row]
                cell.Title.text = professor.name
                cell.Subtitle.text = professor.profdepartment
                if (professor.profilePic! != "default.jpg"){
                    cell.departmentImageView.sd_setImage(with: URL(string:"http://people.iitr.ernet.in/facultyphoto/\(professor.profilePic!)")!, placeholderImage: #imageLiteral(resourceName: "person"))
                }else{
                    cell.departmentImageView.image = #imageLiteral(resourceName: "person")
                }

                cell.departmentImageView.layer.cornerRadius = (cell.departmentImageView.frame.width)/2
                
            default:
                cell.Title.text = ""
            }
        }
        cell.departmentImageView.isHidden = false
        return cell
    }
    
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if ((identifier == "ShowDepartmentContacts" && Switch.selectedSegmentIndex == 1 )){   performSegue(withIdentifier: "ShowAZProf", sender: UITableViewCell.self)
            return false
        } else if ((identifier == "ShowDepartmentContacts" && searchController.isActive && searchController.searchBar.text != "")){
            performSegue(withIdentifier: "ShowAZProf", sender: UITableViewCell.self)
            return false
        }
        else{
            return true
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "ShowDepartmentContacts"){
            let ProfListView = segue.destination as! DepartmentProfTableViewController
            if let indexPath = self.tableView.indexPathForSelectedRow{
                let Department : DepartmentCell = Departments[departmentSections[indexPath.section].index + indexPath.row]
                ProfListView.DepartmentProfcontacts = Department.DepartmentContacts
                ProfListView.DepartmentName = Department.DepartmentNAME
            }
            
        }
        if(segue.identifier == "ShowAZProf"){
           
            let ContactView = segue.destination as! ContactInfoTableViewController
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let contact : ProfContactCell
                if (searchController.isActive && searchController.searchBar.text != ""){
                    contact = filterProfessors[indexPath.row]
                } else{
                    contact = Professors[profSections[indexPath.section].index + indexPath.row]
                }
                ContactView.namedata = contact.name!
                ContactView.LandlineorMobiledata = "\(contact.phoneBSNL!)"
                ContactView.officemobiledata = "\(contact.office!)"
                ContactView.residancemobiledata = "\(contact.residence!)"
                ContactView.designationData = contact.designation!
                ContactView.emaildata = contact.email!
                ContactView.imagrurldata = contact.profilePic!
                ContactView.departmentname = contact.profdepartment!
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        var contact : ProfContactCell
        
        if (searchController.isActive && searchController.searchBar.text != ""){
            contact = filterProfessors[indexPath.row]
        }else{
            contact = Professors[profSections[indexPath.section].index + indexPath.row]
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
                contact = self.filterProfessors[indexPath.row]
            }else{
                contact = self.Professors[indexPath.row]
                
            }
            if (contact.email != ""){
                
                UIApplication.shared.openURL(URL(string :"mailto:\(contact.email!)")!)

            //    if MFMailComposeViewController.canSendMail() {
                
//                    let mail = MFMailComposeViewController()
//                    mail.mailComposeDelegate = self
//                    mail.setToRecipients(["\(contact.email!)"])
//                    mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)
//                    UIApplication.topViewController()?.present(mail, animated: true, completion: nil)
//                } else {
//                    print("CANNOT SEND MAIL")
//                }
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
    
    //Message Controller Delegate
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    //Mail Controller Delegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (searchController.isActive && searchController.searchBar.text != ""){
            return true
        }else{
            switch Switch.selectedSegmentIndex
            {
            case 0:
                return false
            case 1:
                return true
            default:
                return false
                
            }
        }
        
        
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

    
    @IBAction func SwitchChanged(sender: AnyObject) {
        ActivityIndicator.shared.showProgressView(uiView: self.view)
        self.tableView.reloadData()
        ActivityIndicator.shared.hideProgressView()
    }
    
}
