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
import GooglePlaces

enum PlaceProperty: Int {
  case placeID
  case coordinate
  case phoneNumber
  case website
  case formattedAddress
  case rating
  case types

  static func numberOfProperties() -> Int {
    return 7
  }
}

/// The data source and delegate for the Place Detail |UITableView|. Beyond just displaying the
/// details of the place, this class also manages the floating section title containing the place
/// name and takes into account the presence of the back button if it's visible.
class PlaceDetailTableViewDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
  // MARK: - Properties
  private let place: GMSPlace
  private let blueCellIdentifier = "BlueCellIdentifier"
  private let extensionConstraint: NSLayoutConstraint
  private let noneText = "No Info Found"
  private let tableView: UITableView
  // Additional margin padding to use during layout. This is 0 for iOS versions 8.0 and above, while
  // on iOS 7 this needs to be hardcoded to 8 to ensure the correct layout.
  private let additionalMarginPadding: CGFloat = {
    if #available(iOS 8.0, *) {
      return 0
    } else {
      return 8
    }
  }()

  var compactHeader = false {
    didSet {
      if #available(iOS 9.0, *) {
        tableView.beginUpdates()
        updateNavigationBar()
        tableView.endUpdates()
      } else {
        // We'd really rather not call reloadData(), but on iOS 8.x begin/endUpdates tend to crash
        // for this particular tableView.
        tableView.reloadData()
      }
    }
  }

  var offsetNavigationTitle = false

  // MARK: Init/Deinit

  /// Create a |PlaceDetailTableViewDataSource| with the specified |GMSPlace| and constraint.
  ///
  /// - parameter place The |GMSPlace| to show details for.
  /// - parameter extensionConstraint The |NSLayoutConstraint| to update when scrolling so that
  /// the header view shrinks/grows to fill the gap between the map/photo and the details.
  /// - parameter tableView The UITableView for this data.
  init(place: GMSPlace, extensionConstraint: NSLayoutConstraint, tableView: UITableView) {
    self.place = place
    self.extensionConstraint = extensionConstraint
    self.tableView = tableView

    // Register the |UITableViewCell|s.
    tableView.register(PlaceAttributeCell.nib,
                      forCellReuseIdentifier: PlaceAttributeCell.reuseIdentifier)
    tableView.register(PlaceNameHeader.nib,
                      forHeaderFooterViewReuseIdentifier: PlaceNameHeader.reuseIdentifier)
    tableView.register(UITableViewCell.self,
                      forCellReuseIdentifier: blueCellIdentifier)

    // Configure some other properties.
    tableView.estimatedRowHeight = 44
    tableView.estimatedSectionHeaderHeight = 44
    tableView.sectionHeaderHeight = UITableViewAutomaticDimension
  }

  // MARK: - Public Methods

  func updateNavigationTextOffset() {
    updateNavigationBar()
  }

  // MARK: - UITableView DataSource/Delegate

  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return PlaceProperty.numberOfProperties() + 1
  }

  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // The first cell is special, this is a small blue spacer we use to pad out the place name
    // header.
    if indexPath.item == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: blueCellIdentifier,
                                               for: indexPath)
      cell.backgroundColor = Colors.blue2
      cell.selectionStyle = .none
      return cell
    }

    // For all the other cells use the same class.

    let untyped = tableView.dequeueReusableCell(withIdentifier: PlaceAttributeCell.reuseIdentifier,
                                                for: indexPath)
    let cell = untyped as! PlaceAttributeCell

    // Disable selection.
    cell.selectionStyle = .gray

    // Set the relevant values.
    if let propertyType = PlaceProperty(rawValue: indexPath.item - 1) {
      cell.propertyIcon.image = propertyType.icon()

      switch propertyType {
      case .placeID:
        cell.propertyName.text = "Place ID"
        cell.propertyValue.text = place.placeID
      case .coordinate:
        cell.propertyName.text = "Get Directions"
        cell.propertyValue.text = "\(place.coordinate.latitude) | \(place.coordinate.longitude)"
      case .phoneNumber:
        cell.propertyName.text = "Phone Number"
        cell.propertyValue.text = place.phoneNumber ?? noneText
      case .website:
        cell.propertyName.text = "Website"
        cell.propertyValue.text = place.website?.absoluteString ?? noneText
      case .formattedAddress:
        cell.propertyName.text = "Address"
        cell.propertyValue.text = place.formattedAddress ?? noneText
      case .rating:
        cell.propertyName.text = "Ratings"
        let rating = place.rating
        // As specified in the documentation for |GMSPlace|, a rating of 0.0 signifies that there
        // have not yet been any ratings for this location.
        if rating > 0 {
          cell.propertyValue.text = "\(rating)"
        } else {
          cell.propertyValue.text = noneText
        }
      case .types:
        cell.propertyName.text = "Type"
        cell.propertyValue.text = place.types.joined(separator: ", ")
    }
    } else {
      print("ERRORRR ")
    }

    return cell
  }
    
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = self.tableView.cellForRow(at: indexPath) as! PlaceAttributeCell
    
    cell.isSelected = false
    
    if let propertyType = PlaceProperty(rawValue: indexPath.item - 1) {
        switch propertyType {
        case .coordinate:
            
           UIApplication.shared.openURL(URL(string: "comgooglemaps://?q=\(place.name.removeWhitespace())&center=\(Double(place.coordinate.latitude)),\(Double(place.coordinate.longitude))")!)
            
        case .phoneNumber:
            if let number = place.phoneNumber {
                
                UIApplication.shared.openURL(
                    URL(string: "tel://" + number.removeWhitespace())!)
            }
        case .website:
            if let website = place.website?.absoluteString {
                UIApplication.shared.openURL(URL(string: "\(website.removeWhitespace())")!)
            }
        default:
            break
        }
    
    }
    }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return place.name
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view =
      tableView.dequeueReusableHeaderFooterView(withIdentifier: PlaceNameHeader.reuseIdentifier)
    let header = view as! PlaceNameHeader
    updateNavigationBar(header)
    return header
  }

  func tableView(_ tableView: UITableView,
                 heightForRowAt indexPath: IndexPath) -> CGFloat {
    // Our first cell has a fixed height, all the rest are automatic.
    if indexPath.item == 0 {
      return compactHeader ? 0 : 20
    }
    else {
      if #available(iOS 8.0, *) {
        return UITableViewAutomaticDimension
      } else {
        // This means that on iOS 7 we only get the first line of text.
        return 55
      }
    }
  }

  /// Only needed for iOS 7, explodes if this is not provided.
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if #available(iOS 8.0, *) {
      return UITableViewAutomaticDimension
    } else {
      // This means that on iOS 7 we only get the first line of text.
      return 65
    }
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    // Update the extensionConstraint and the navigation title offset when the tableView scrolls.
    extensionConstraint.constant = max(0, -scrollView.contentOffset.y)

    updateNavigationTextOffset()
  }

  // MARK: - Utilities

  /// Return the appropriate text string for the specified |GMSPlacesOpenNowStatus|.
  private func text(for status: GMSPlacesOpenNowStatus) -> String {
    switch status {
    case .no: return NSLocalizedString("Places.OpenNow.No",
                                       comment: "Closed/Open state for a closed location")
    case .yes: return NSLocalizedString("Places.OpenNow.Yes",
                                        comment: "Closed/Open state for an open location")
    case .unknown: return NSLocalizedString("Places.OpenNow.Unknown",
                                            comment: "Closed/Open state for when it is unknown")
    }
  }

  /// Return the appropriate text string for the specified |GMSPlacesPriceLevel|.
  private func text(for priceLevel: GMSPlacesPriceLevel) -> String {
    switch priceLevel {
    case .free: return NSLocalizedString("Places.PriceLevel.Free",
                                         comment: "Relative cost for a free location")
    case .cheap: return NSLocalizedString("Places.PriceLevel.Cheap",
                                          comment: "Relative cost for a cheap location")
    case .medium: return NSLocalizedString("Places.PriceLevel.Medium",
                                           comment: "Relative cost for a medium cost location")
    case .high: return NSLocalizedString("Places.PriceLevel.High",
                                         comment: "Relative cost for a high cost location")
    case .expensive: return NSLocalizedString("Places.PriceLevel.Expensive",
                                              comment: "Relative cost for an expensive location")
    case .unknown: return NSLocalizedString("Places.PriceLevel.Unknown",
                                            comment: "Relative cost for when it is unknown")
    }
  }

  private func updateNavigationBar() {
    // Grab the header.
    if let header = tableView.headerView(forSection: 0) as? PlaceNameHeader {
      updateNavigationBar(header)
    }
  }

  private func updateNavigationBar(_ header: PlaceNameHeader) {
    // Check to see if we should be offsetting the navigation title.
    if offsetNavigationTitle {
      // If so offset it by at most 36 pixels, relative to how much we've scrolled past 160px.
      let offset = max(0, min(36, tableView.contentOffset.y - 160))
      header.leadingConstraint.constant = offset + additionalMarginPadding
    } else {
      // Otherwise don't offset.
      header.leadingConstraint.constant = additionalMarginPadding
    }

    // Update the compact status.
    header.compact = compactHeader
  }
}

extension PlaceProperty {
  func localizedDescription() -> String {
    switch self {
    case .placeID:
      return NSLocalizedString("Places.Property.PlaceID",
                               comment: "Name for the Place ID property")
    case .coordinate:
      return NSLocalizedString("Places.Property.Coordinate",
                               comment: "Name for the Coordinate property")
    case .phoneNumber:
      return NSLocalizedString("Places.Property.PhoneNumber",
                               comment: "Name for the Phone number property")
    case .website:
      return NSLocalizedString("Places.Property.Website",
                               comment: "Name for the Website property")
    case .formattedAddress:
      return NSLocalizedString("Places.Property.FormattedAddress",
                               comment: "Name for the Formatted address property")
    case .rating:
      return NSLocalizedString("Places.Property.Rating",
                               comment: "Name for the Rating property")
    case .types:
      return NSLocalizedString("Places.Property.Types",
                               comment: "Name for the Types property")
    }
  }

  func icon() -> UIImage? {
    switch self {
    case .placeID:
      return UIImage(named: "place_id")
    case .coordinate:
      return UIImage(named: "coordinate")
    case .phoneNumber:
      return UIImage(named: "phone_number")
    case .website:
      return UIImage(named: "website")
    case .formattedAddress:
      return UIImage(named: "address")
    case .rating:
      return UIImage(named: "rating")
    case .types:
      return UIImage(named: "types")
    }
  }
}
