//
//  AllContactViewController.swift
//  Telephone Directory
//
//  Created by Kush Taneja on 30/01/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit

extension AllContactViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController){
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
}

class AllContactViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchContainerView: UIView!
    
    var departments = [ContactGroupDepartment]()
    
    var filteredDepartments = [ContactGroupDepartment]()
    var groupName = ["english":String(),"hindi":String()]
    
    var searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        //search
        searchController.searchResultsUpdater = self
        self.searchContainerView.addSubview(searchController.searchBar)
        searchController.searchBar.tintColor = UIColor(rgb: 0x462D8A)
        // searchController.searchBar.barTintColor = UIColor.white
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        departments.sort{$0.name["english"]! < $1.name["english"]!}
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var frame = searchController.searchBar.bounds
        frame.size.width = self.view.bounds.size.width
        searchController.searchBar.frame = frame
        
        if let option: Bool = UserDefaults.standard.value(forKey: "hindi") as! Bool?{
            switch option {
            case true:
                self.title = groupName["hindi"]
            default:
                self.title = groupName["english"]
            }
        }else{
            self.title = groupName["english"]
        }
    }
    
    
    //MARK: Tableview DataSource
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(searchController.isActive && searchController.searchBar.text != "") {
            return filteredDepartments.count
        }else{
            return departments.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var department = ContactGroupDepartment()
        
        
        if(searchController.isActive && searchController.searchBar.text != "") {
            department = filteredDepartments[indexPath.row]
            
        }else{
            department = departments[indexPath.row]
            
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! DepartmentTableViewCell
        cell.departmentImageView.clipsToBounds = true
        cell.departmentImageView.image = #imageLiteral(resourceName: "department")
        cell.departmentImageView.layer.cornerRadius = (cell.departmentImageView.frame.width)/2
        if let option: Bool = UserDefaults.standard.value(forKey: "hindi") as! Bool?{
            
            switch option {
            case true:
                cell.Title?.text = department.name["hindi"]
            default:
                cell.Title?.text = department.name["english"]?.lowercased().capitalized
            }
        }else{
            cell.Title?.text = department.name["english"]?.lowercased().capitalized
        }
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.isSelected = false
        
        var department = ContactGroupDepartment()
        
        if(searchController.isActive && searchController.searchBar.text != "") {
            department = filteredDepartments[indexPath.row]
            
        }else{
            department = departments[indexPath.row]
            
        }
        let departmentScreen = UIStoryboard.departmentsScreen() as! DepartmentsTableViewController
        departmentScreen.selectedDepartment = department
        self.navigationController?.pushViewController(departmentScreen, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    
    //MARK: Private Functions
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        
        filteredDepartments = departments.filter({ (department) -> Bool in
            return (department.name["english"]?.lowercased().contains(searchText.lowercased()))!
        })
        
        self.tableView.reloadData()
        
    }
    
    
    
    
    
}
