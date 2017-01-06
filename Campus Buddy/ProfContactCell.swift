//
//  ProfContactCell.swift
//  cBuddy
//
//  Created by Kush Taneja on 27/08/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import Foundation
class ProfContactCell

{
    var name: String?
    var designation: String?
    var office: String?
    var residence: String?
    var phoneBSNL: String?
    var email: String?
    var profilePic: String?
    var profdepartment: String?
    init (namedata: String?,designationdata: String?,officedata: String?,residencedata: String?,phoneBSNLdata: String?,emaildata: String?,profilePicdata: String?,department: String?){
        
        self.name = namedata
        if ( designationdata == nil )
        { self.designation = ""
        }
        else
        {
        self.designation = designationdata
        }
        if ( officedata == nil )
        { self.office = ""
        }
        else
        {
            self.office = officedata
        }
        if ( residencedata == nil )
        { self.residence = ""
        }
        else
        {
            self.residence = residencedata
        }
        if ( emaildata == nil )
        { self.email = ""
        }
        else
        {
            self.email = emaildata
        }
        if ( phoneBSNLdata == nil )
        { self.phoneBSNL = ""
        }
        else
        {
            self.phoneBSNL = phoneBSNLdata

        }
        if ( profilePicdata == nil )
        { self.profilePic = ""
        }
        else
        {
         self.profilePic = profilePicdata
            
        }
        self.profdepartment = department
        
        
        
    }




}
