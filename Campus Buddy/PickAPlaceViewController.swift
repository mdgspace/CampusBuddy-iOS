/*
 * Copyright 2016 Google Inc. All rights reserved.
 *
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
 * file except in compliance with the License. You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under
 * the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
 * ANY KIND, either express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

import UIKit
import GoogleMaps
import GooglePlacePicker

/// A view controller which displays a UI for opening the Place Picker. Once a place is selected
/// it navigates to the place details screen for the selected location.
class PickAPlaceViewController: UIViewController,GMSMapViewDelegate,GMSPanoramaViewDelegate{
  private var placePicker: GMSPlacePicker?
  var mapViewController: BackgroundMapViewController?

  override func viewDidLoad() {
    super.viewDidLoad()
        setupView()
     }
    func setupView(){
        let camera = GMSCameraPosition.camera(withLatitude: 29.865088, longitude: 77.896547, zoom: 12)
        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.isMyLocationEnabled = false
        mapView.delegate = self
        
        let position = CLLocationCoordinate2D(latitude: 29.865088, longitude: 77.896547)
        let marker = GMSMarker(position: position)
        
        
        // Add the marker to a GMSMapView object named mapView
        marker.map = mapView
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.isDraggable = true
        marker.tracksInfoWindowChanges = true
        marker.title = "IIT Roorkee"
        marker.tracksViewChanges = true
        marker.snippet = "Tap to Explore"
        mapView.selectedMarker = marker
        
        //self.view = panoView
        self.view = mapView

    }
 func buttonTapped() {
    // Create a place picker.
    
    let center = CLLocationCoordinate2DMake(29.865088, 77.896547)
    let northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001)
    let southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001)
    let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
    
    let config = GMSPlacePickerConfig(viewport: viewport)
    
    let placePicker = GMSPlacePicker(config: config)
    
    // Present it fullscreen.
    placePicker.pickPlace { (place, error) in

      // Handle the selection if it was successful.
      if let place = place {
        // Create the next view controller we are going to display and present it.
        let nextScreen = PlaceDetailViewController(place: place)
        self.show(nextScreen, sender: self)
        //self.splitPaneViewController?.push(viewController: nextScreen, animated: false)
        self.mapViewController?.coordinate = place.coordinate
      } else if error != nil {
        // In your own app you should handle this better, but for the demo we are just going to log
        // a message.
        NSLog("An error occurred while picking a place: \(error)")
      } else {
        NSLog("Looks like the place picker was canceled by the user")
      }

      // Release the reference to the place picker, we don't need it anymore and it can be freed.
      self.placePicker = nil
    }

    // Store a reference to the place picker until it's finished picking. As specified in the docs
    // we have to hold onto it otherwise it will be deallocated before it can return us a result.
    self.placePicker = placePicker
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

   func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
    }
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
        let  Alert = UIAlertController(title: "Explore IIT R", message:
            "We have two options", preferredStyle: UIAlertControllerStyle.alert)
        
        
        Alert.addAction(UIAlertAction(title: "3D IITR", style: .default , handler: { action in
            
            let panoView = GMSPanoramaView(frame: self.view.frame)
            panoView.delegate = self
            panoView.moveNearCoordinate(CLLocationCoordinate2DMake(29.865088, 77.896547))
            let position = CLLocationCoordinate2D(latitude: 29.865088, longitude: 77.896547)
            let marker = GMSMarker(position: position)
        
            // Add the marker to a GMSMapView object named mapView
            marker.panoramaView = panoView
            marker.appearAnimation = kGMSMarkerAnimationPop
            marker.isDraggable = true
            marker.tracksInfoWindowChanges = true
            marker.title = "IIT Roorkee"
            marker.tracksViewChanges = true
            marker.snippet = "Tap to Explore"
            panoView.moveNearCoordinate(CLLocationCoordinate2DMake(29.865088, 77.896547), radius: UInt.init(bitPattern: 1000))
            panoView.streetNamesHidden = false
            panoView.setAllGesturesEnabled(true)
            self.view = panoView
            
        }))
        Alert.addAction(UIAlertAction(title: "Pick A Place in IIT R", style: .default, handler: { (action) in
            self.buttonTapped()
        }))
        
        Alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
     self.present(Alert, animated: true, completion: nil)
        
    }

    func panoramaView(_ panoramaView: GMSPanoramaView, didTap marker: GMSMarker) -> Bool {
        self.setupView()
        return true
    }
    

}
