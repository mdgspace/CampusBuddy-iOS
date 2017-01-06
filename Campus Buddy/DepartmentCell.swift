//
//  DepartmentCell.swift
//  cBuddy
//
//  Created by Kush Taneja on 27/08/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import Foundation
class DepartmentCell
{
    var DepartmentNAME = ""
    var DepartmentPhotoUrl = ""
    var DepartmentContacts = [NSDictionary]()
    
    init(Departmentname: String, DepartmentPhotourl: String, Departmentcontacts: [NSDictionary])    {
        DepartmentNAME = Departmentname
        DepartmentPhotoUrl = DepartmentPhotourl
        DepartmentContacts = Departmentcontacts
        
    }
}
