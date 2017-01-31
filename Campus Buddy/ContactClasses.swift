//
//  ContactClasses.swift
//  Telephone Directory
//
//  Created by Kush Taneja on 25/01/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import Foundation

public class ContactGroup{
    var name = ["english":String(),"hindi":String()]
    var departments = [ContactGroupDepartment]()
    
    init(groupName:Dictionary<String, String>,groupDepartments:[ContactGroupDepartment]) {
        self.name = groupName
        self.departments = groupDepartments
    }
    init(){
        
    }
    
}


public class ContactGroupDepartment{
    var name = ["english":String(),"hindi":String()]
    var contacts = [Contact]()
    
    init(departmentName:Dictionary<String, String>,departmentContacts:[Contact]) {
        self.name = departmentName
        self.contacts = departmentContacts
    }
    init() {
        
    }
   
    
}

public class Contact{
    
    var name: String?
    
    var designation = ["english":String(),"hindi":String()]
    
    var office: String?
    var residence: String?
    
    var mobile: String?
    
    var phoneBSNL: String?
    
    var email: String?
    
    var profilePic: String?
    
    var departmentName: Dictionary<String, String>?
   
    
    init (namedata: String?,designationdata:Dictionary<String, String>,officedata: String?,residencedata: String?,phoneBSNLdata: String?,emaildata: String?,profilePicdata: String?,profdepartmentName: Dictionary<String, String>?,profMobile: String?){
        
        self.name = namedata
        
        if (designationdata["english"] == nil){
            self.designation["english"] = ""
        }else if(designationdata["hindi"] == nil){
            self.designation["hindi"] = ""
        }
        self.designation = designationdata
        
        if ( officedata == nil ){
            self.office = ""
        }else{
            self.office = officedata
        }
        if ( residencedata == nil ){
            self.residence = ""
        }else{
            self.residence = residencedata
        }
        if ( emaildata == nil ){
            self.email = ""
        }else{
            self.email = emaildata
        }
        if ( profMobile == nil ){
            self.mobile = ""
        }
        else{
            self.mobile = profMobile
        }
        if ( phoneBSNLdata == nil ){
            self.phoneBSNL = ""
        }
        else{
            self.phoneBSNL = phoneBSNLdata
        }
        if ( profilePicdata == nil ){
            self.profilePic = ""
        }else{
            self.profilePic = profilePicdata
        }
        self.departmentName = profdepartmentName!
        
    }
    
    init() {
    }
}
