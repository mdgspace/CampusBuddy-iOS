//
//  ContactsTableViewController.swift
//  Telephone Directory
//
//  Created by Kush Taneja on 25/01/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit

extension ContactsTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController){
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
}


class ContactsTableViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var languageSwitch: UISwitch!
    
    @IBOutlet weak var searchContainerView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var contactsMutableArray : NSMutableArray = []
    
    var contactGroups = [ContactGroup]()
    
    var filteredContacts = [Contact]()
    var allContacts = [Contact]()
    
    
    var searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        
        //json Parsing
        jSONParsing()
        
        //array initialization
        configureIt()
        
        //search
        self.searchController.searchBar.isTranslucent = false
        searchController.searchResultsUpdater = self
        self.searchContainerView.addSubview(searchController.searchBar)
        searchController.searchBar.tintColor = UIColor(rgb: 0x462D8A)
        //searchController.searchBar.barTintColor = UIColor.white
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        contactGroups.sort{$0.name["english"]! < $1.name["english"]!}
        allContacts.sort{$0.name! < $1.name!}
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var frame = searchController.searchBar.bounds
        frame.size.width = self.view.bounds.size.width
        searchController.searchBar.frame = frame
        
        if let option: Bool = UserDefaults.standard.value(forKey: "hindi") as! Bool?{
            switch option {
            case true:
                languageSwitch.isOn = true
                self.title = "टेलीफोन डायरेक्टरी"
            default:
                languageSwitch.isOn = false
                self.title = "Telephone Directory"
            }
        }else{
            languageSwitch.isOn = false
            self.title = "Telephone Directory"
        }
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if(searchController.isActive && searchController.searchBar.text != "") {
            return 1
        }else{
            return contactGroups.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        
        
        if(searchController.isActive && searchController.searchBar.text != "") {
            
            return "TOP NAME MATCHES"
            
        }else{
            let group = contactGroups[section]
            
            if let option: Bool = UserDefaults.standard.value(forKey: "hindi") as! Bool?{
                switch option {
                case true:
                    return group.name["hindi"]
                default:
                    return group.name["english"]
                }
                
            }else{
                return group.name["english"]
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(searchController.isActive && searchController.searchBar.text != "") {
            return filteredContacts.count
        }else{
            return 4
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(searchController.isActive && searchController.searchBar.text != "") {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfContactCell", for: indexPath) as! ProfContactTableViewCell
            
            let contact = filteredContacts[indexPath.row]
            
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
            
        }else{
            var group = contactGroups[indexPath.section]
            if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReadStoriesTableViewCell", for: indexPath) as! ReadStoriesTableViewCell
                if let option: Bool = UserDefaults.standard.value(forKey: "hindi") as! Bool?{
                    switch option {
                    case true:
                        cell.readTextLabel.text = "सी आल"
                    default:
                        cell.readTextLabel.text = "See all"
                    }
                }else{
                    cell.readTextLabel.text = "See all"
                }
                
                
                cell.separatorInset = UIEdgeInsets.init(top: 0.0, left: self.view.frame.width, bottom: 0.0, right: 0.0)
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! DepartmentTableViewCell
                cell.departmentImageView.clipsToBounds = true
                cell.departmentImageView.image = #imageLiteral(resourceName: "department")
                cell.departmentImageView.layer.cornerRadius = (cell.departmentImageView.frame.width)/2
                if let option: Bool = UserDefaults.standard.value(forKey: "hindi") as! Bool?{
                    
                    switch option {
                    case true:
                        cell.Title?.text = group.departments[indexPath.row].name["hindi"]
                    default:
                        cell.Title?.text = group.departments[indexPath.row].name["english"]?.lowercased().capitalized
                    }
                }else{
                    cell.Title?.text = group.departments[indexPath.row].name["english"]?.lowercased().capitalized
                }
                
                
                return cell
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        var group = ContactGroup()
        let cell = tableView.cellForRow(at: indexPath)
        cell?.isSelected = false
        
        if(searchController.isActive && searchController.searchBar.text != "") {
            
            let contact = filteredContacts[indexPath.row]
            
            let contactInfoScreen = UIStoryboard.ContactInfoScreen() as! ContactInfoTableViewController
            
            contactInfoScreen.selectedContact = contact
            
            self.navigationController?.pushViewController(contactInfoScreen, animated: true)
            
            
        }else{
            
            group = contactGroups[indexPath.section]
            
            if indexPath.row == 3 {
                
                let departmentContent = UIStoryboard.DepartmentTableViewScreen() as! AllContactViewController
                
                departmentContent.departments = contactGroups[indexPath.section].departments
                departmentContent.groupName = contactGroups[indexPath.section].name
                
                self.navigationController?.pushViewController(departmentContent, animated: true)
                
            }else{
                
                let departmentScreen = UIStoryboard.departmentsScreen() as! DepartmentsTableViewController
                departmentScreen.selectedDepartment = group.departments[indexPath.row]
                self.navigationController?.pushViewController(departmentScreen, animated: true)
                
            }
        }
        
        
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(searchController.isActive && searchController.searchBar.text != "") {
            return 63.0
        }else{
            if indexPath.row == 3{
                return 36.0
            }else{
                return 60.0
            }
            
        }
    }
    
    //MARK: Outlet Functions
    
    @IBAction func languageChanged(_ sender: UISwitch) {
        
        if sender.isOn{
            UserDefaults.standard.set(true, forKey: "hindi")
            self.title = "टेलीफोन डायरेक्टरी"
            tableView.reloadData()
        }else{
            UserDefaults.standard.set(false, forKey: "hindi")
            self.title = "Telephone Directory"
            tableView.reloadData()
        }
        
        
    }
    
    //MARK: Private Functions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.resignFirstResponder()
    }
    
    func jSONParsing(){
        
        let path: NSString = Bundle.main.path(forResource: "contacts_min", ofType: ".json")! as NSString
        let Departmentdata : Data = try! NSData(contentsOfFile: path as String, options: Data.ReadingOptions.dataReadingMapped) as Data
        
        let jsonarray: NSArray!=(try! JSONSerialization.jsonObject(with: Departmentdata, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSArray
        
        contactsMutableArray = jsonarray as! NSMutableArray
        
    }
    
    func configureIt(){
        
        for contacts in contactsMutableArray{
            
            let contacts = contacts as! NSDictionary
            
            let groupNameEnglish: String? = contacts.value(forKey: "group_name") != nil ? contacts.value(forKey: "group_name") as? String : ""
            let groupNameHindi: String? = contacts.value(forKey: "group_name_hindi") != nil ? contacts.value(forKey: "group_name_hindi") as? String : groupNameEnglish
            
            let groupName = ["english":groupNameEnglish!,"hindi":groupNameHindi!]
            
            let groupDepartments = contacts.value(forKey:"depts") as! [NSMutableDictionary]
            var departments = [ContactGroupDepartment]()
            
            
            for department in groupDepartments{
                
                let departNameEnglish: String? = department.value(forKey: "dept_name") != nil ? department.value(forKey: "dept_name") as? String : ""
                
                let departNameHindi: String? = department.value(forKey: "dept_name_hindi") != nil ? department.value(forKey: "dept_name_hindi") as? String : departNameEnglish
                
                
                let depatmentName = ["english":departNameEnglish!,"hindi":departNameHindi!]
                
                let departmentContacts = department.value(forKey:"contacts") as! [NSMutableDictionary]
                var singletonContacts = [Contact]()
                
                
                for contact in departmentContacts{
                    
                    let name = contact.value(forKey: "name") as! String
                    
                    let residance:String? = (contact.value(forKey: "iitr_r") as? [String])?.first
                    let office:String? = (contact.value(forKey: "iitr_o") as? [String])?.first
                    
                    let bsnl:String?  = (contact.value(forKey: "bsnl_res") as? [String])?.first
                    
                    let email:String? = (contact.value(forKey: "email") as? [String])?.first
                    
                    let mobile:String? = (contact.value(forKey: "mobile") as? [String])?.first
                    
                    
                    let designationEnglish: String? = contact.value(forKey: "desg") != nil ? contact.value(forKey: "desg") as? String : ""
                    let designationHindi: String? = contact.value(forKey: "desgHindi") != nil ? contact.value(forKey: "desgHindi") as? String : designationEnglish
                    
                    let designation: Dictionary<String, String>? = ["english":designationEnglish!,"hindi":designationHindi!]
                    
                    
                    
                    let currentContact = Contact(namedata: name, designationdata: designation!, officedata: office, residencedata: residance, phoneBSNLdata: bsnl, emaildata: email, profilePicdata: nil, profdepartmentName: depatmentName,profMobile:mobile)
                    
                    singletonContacts.append(currentContact)
                    
                    self.allContacts.append(currentContact)
                    
                }
                
                let currentDepartment = ContactGroupDepartment(departmentName: depatmentName, departmentContacts: singletonContacts)
                departments.append(currentDepartment)
                
            }
            
            let currentGroup = ContactGroup(groupName: groupName, groupDepartments: departments)
            self.contactGroups.append(currentGroup)
            
        }
    }
    
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        
        filteredContacts = allContacts.filter({ (contact) -> Bool in
            
            return (contact.name?.lowercased().contains(searchText.lowercased()))! || (contact.departmentName?["english"]?.lowercased().contains(searchText.lowercased()))!
        })
        
        self.tableView.reloadData()
        
        
    }
    
    
}

