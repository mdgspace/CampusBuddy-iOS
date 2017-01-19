//
//  FacebookPage.swift
//  Campus Buddy
//
//  Created by Kush Taneja on 07/01/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import Foundation

public class FacebookPage{
    
    var name: String?
    var pageId: String?
    var picUrl: String?
    var iSelected: Bool?
    
    init(name: String?,pageId:String?,picUrl:String?,isSelected:Bool?){
        self.name = name
        self.pageId = pageId
        self.picUrl = picUrl
        self.iSelected = isSelected
    }
    
    init(_ name: String?,_ pageId:String?){
        self.name = name
        self.pageId = pageId
    }



}

