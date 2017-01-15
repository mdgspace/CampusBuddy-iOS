//
//  Extensions.swift
//  Campus Buddy
//
//  Created by Kush Taneja on 02/12/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import Foundation
import UIKit

extension UIStoryboard {
    
    class func MainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: Bundle.main) }
    
    class func pageSelectionScreen() -> UIViewController {
        return MainStoryboard().instantiateViewController(withIdentifier: "PageSelectionScreen")
    }
    class func noticeNavigationScreen() -> UINavigationController{
        return MainStoryboard().instantiateViewController(withIdentifier: "FbPostsTableNavigationController") as! UINavigationController
    }
    class func home() -> UITabBarController{
        return MainStoryboard().instantiateViewController(withIdentifier: "HomeTabBar") as! UITabBarController
        
    }
    class func postDisplayScreen() -> UIViewController {
        return MainStoryboard().instantiateViewController(withIdentifier: "FbPostsTableViewController")
    }
    class func demoNavigation() -> UINavigationController{
        return MainStoryboard().instantiateViewController(withIdentifier: "DempNavigation") as! UINavigationController
    }
    
    class func mapNavigation() -> UINavigationController{
        return MainStoryboard().instantiateViewController(withIdentifier: "MapsNavigationController") as! UINavigationController
    }
    
   
    
}

extension String {
 
    func removeWhitespace() -> String {
            return String(self.characters.filter { !" ".characters.contains($0) })
        }
    
    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = self.characters.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.characters.index(startIndex, offsetBy: r.upperBound - r.lowerBound)
            
            return self[(startIndex..<endIndex)]
        }
    }
    
    func fromBase64() -> String {
        let data = Data(base64Encoded: self, options: Data.Base64DecodingOptions(rawValue: 0))
        return String(data: data!, encoding: String.Encoding.utf8)!
    }
    
    func toBase64() -> String {
        let data = self.data(using: String.Encoding.utf8)
        return data!.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
    }
}
extension Date {
    
    func convertStringtoDate(startTimeString: String) -> Date{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from: startTimeString)!
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        let finalDate = calendar.date(from: components)
        
        return finalDate!
    }
    
    func dayDifferenceFromDate(date : Date) -> String{
        let calendar = NSCalendar.current
        if calendar.isDateInYesterday(date) { return "Yesterday" }
        else if calendar.isDateInToday(date) { return "Today" }
        else if calendar.isDateInTomorrow(date) { return "Tomorrow" }
        else {
            let startOfNow = calendar.startOfDay(for: Date())
            let startOfTimeStamp = calendar.startOfDay(for: date)
            let components = calendar.dateComponents([.day], from: startOfNow, to: startOfTimeStamp)
            let day = components.day
            if day! < 1 { return "\(abs(day!)) days ago" }
            else { return "In \(day) days" }
        }
    }
    
    func getRelativeDate(from string: String)-> String{
        
        let convertedDate = convertStringtoDate(startTimeString: string)
        
        return dayDifferenceFromDate(date: convertedDate)
    }

}
