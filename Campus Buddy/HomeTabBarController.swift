//
//  HomeTabBarController.swift
//  Campus Buddy
//
//  Created by Kush Taneja on 15/01/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit
import GooglePlacePicker

class HomeTabBarController: UITabBarController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem){
        switch item.tag{
        case 3:
            debugPrint("tapped")
            let config = GMSPlacePickerConfig(viewport: nil)
            let placePicker = GMSPlacePicker(config: config)
            // Present it fullscreen.
            placePicker.pickPlace { (place, error) in
                
                // Handle the selection if it was successful.
                if let place = place {
                    // Create the next view controller we are going to display and present it.
                    //  self.mapViewController?.coordinate = place.coordinate
                    let nextScreen = PlaceDetailViewController(place: place)
                   // let controller = tabBar.viewWithTag(item.tag) as! UINavigationController
//                    let home = UIStoryboard.home()
//                    let third = home.viewControllers?[2]
//                    //controller.show(nextScreen, sender: self)
//                    third?.show(nextScreen, sender: self)
                    UIApplication.topViewController()?.show(nextScreen, sender: self)
                    
                    //  push(viewController: nextScreen, animated: false)
                    
                } else if error != nil {
                    // In your own app you should handle this better, but for the demo we are just going to log
                    // a message.
                    NSLog("An error occurred while picking a place: \(error)")
                } else {
                    NSLog("Looks like the place picker was canceled by the user")
                }
                
                // Release the reference to the place picker, we don't need it anymore and it can be freed.
                //   self.placePicker = nil
            }
        default:
            break
        }
    
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
