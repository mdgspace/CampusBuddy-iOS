//
//  FbPost.swift
//  Campus Buddy
//
//  Created by Kush Taneja on 12/01/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import Foundation

class FbPost{
    
    var content: String?
    var createdRelativeTime: String?
    var id: String?
    var link: URL?
    var fullPictureUrl: URL?
    
    var date: Date?
    
    var groupName: String?
    var groupImage: String?
    var groupId: String?
    
    var type: String?
    
    
    
    
    //init
    init(postContent:String? = nil,postCreatedTime:String? = nil,postId:String? = nil,postFullPictureUrl:String? = nil, postLink:String? = nil,postGroupName:String? = nil,postGroupImage:String? = nil,postGroupId:String? = nil,postType:String? = nil){
        
        content = postContent != nil ? postContent! : nil
        createdRelativeTime = postCreatedTime != nil ? Date().getRelativeDate(from: postCreatedTime!) : nil
        
        date = Date().convertStringtoDate(startTimeString: postCreatedTime!)
        
        id = postId != nil ? postId! : nil
        link = postLink != nil ? URL(string: postLink!)! : nil
        fullPictureUrl = postFullPictureUrl != nil ? URL(string: postFullPictureUrl!)! : nil
        
        groupName = postGroupName
        groupImage = postGroupImage
        groupId = postGroupId
        type = postType
        
    }
   





}
