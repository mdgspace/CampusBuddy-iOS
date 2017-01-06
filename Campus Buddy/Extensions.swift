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
    
    
    class func postDisplayNavigationScreen() -> UINavigationController {
        return (MainStoryboard().instantiateViewController(withIdentifier: "PostDisplayNavigationController") as? UINavigationController)!
        
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
