//
//  IITRLocation.swift
//  Campus Buddy
//
//  Created by Kush Taneja on 15/01/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import Foundation

public class IITRLocation {
    
    
    var locationName: String?
    var latitude: Double?
    var longitude: Double?
    
    init(_ name:String, latitude:Double, longitude:Double){
    
        self.locationName = name
        self.latitude = latitude
        self.longitude = longitude

    }
    
    
    
    
}
