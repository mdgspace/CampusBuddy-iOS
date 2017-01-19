//
//  FbPostsTableViewController.swift
//  Campus Buddy
//
//  Created by Kush Taneja on 11/01/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit
import CoreData
import SDWebImage
import FacebookCore


class FbPostsTableViewController: UITableViewController{

     var accessToken = AccessToken(appId:"772744622840259",authenticationToken:"772744622840259|63e7300f4f21c5f430ecb740b428a10e",userId:"797971310246511",grantedPermissions: nil, declinedPermissions:nil)
     var selectedPageIds = [String]()
     var fbPosts = [FbPost]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.set(true, forKey: "selected")

        self.tableView.estimatedRowHeight = 350.0
        ActivityIndicator.shared.showProgressView(uiView: self.view)
        AccessToken.current = accessToken
        selectedPageIds =  getSelectedPages()
        
        Utils().delay(1.0) {
            self.getFacebookPosts()
        }
      
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        self.tableView.tableFooterView?.frame = CGRect.zero
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if fbPosts.count == 0{
            self.tableView.tableFooterView?.frame = CGRect.zero
        }else{
            ActivityIndicator.shared.hideProgressView()
        }

        return fbPosts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell", for: indexPath) as! PostTableViewCell
        
        cell.postImageView.image = nil
        
        let fbPost = fbPosts[indexPath.row]
        
        cell.groupNameLabel.text = fbPost.groupName
        cell.postContentTextView.text = fbPost.content
        cell.timeLabel.text = fbPost.createdRelativeTime
        cell.groupImageView.sd_setImage(with: URL(string:(fbPost.groupImage)!)!, placeholderImage: #imageLiteral(resourceName: "Rectangle"))
        
        if fbPost.fullPictureUrl != nil {
            cell.postImageView.sd_setImage(with: fbPost.fullPictureUrl, placeholderImage: #imageLiteral(resourceName: "Rectangle"), options: .allowInvalidSSLCertificates) { (image, error, type, url) in
                let height = image?.size.height
                let width = image?.size.width
                    let aspectRatio = height!/width!
                    let newHeight = aspectRatio*(self.view.frame.size.width)
                    cell.contentView.addConstraint(NSLayoutConstraint(item: cell.postImageView, attribute:.height, relatedBy: .equal, toItem: cell.postImageView, attribute: .height, multiplier: 1.0, constant: newHeight))
            }
        } else{
            cell.postImageView.image = nil
        }
        return cell
    }
    
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    
    @IBAction func editButtonTapped(_ sender: Any) {
        
        UserDefaults.standard.set(false, forKey: "selected")
       UIApplication.topViewController()?.present(UIStoryboard.pageSelectionScreen(), animated: true)
    }
  
    
    
    
    
    //MARK: Facebook Methods
    
    func getSelectedPages()->[String]{
        
        var selectedPages = [String]()
        
        let selects = PageCoreDataService.selectedPagesList.fetchedObjects
        for selected in selects!{
            let selected = selected as! FacebookPagesCoreDataObject
            selectedPages.append(selected.pageId!)
        }
        
        return selectedPages
    }
    
    
    
    func getFacebookPosts(){
        
        let connection = GraphRequestConnection()
        
        for pageId in selectedPageIds {
            
            debugPrint("Entered")
            
            let graphPath = "/\(pageId)"
            let parameters: [String : Any]? = ["fields": "posts{message,created_time,id,full_picture, link},name,picture"]
            let httpMethod: GraphRequestHTTPMethod = .GET
            let apiVersion: GraphAPIVersion = .defaultVersion
            let request = GraphRequest(graphPath: graphPath, parameters: parameters!, accessToken:  AccessToken.current, httpMethod: httpMethod, apiVersion: apiVersion)
            
            connection.add(request, batchParameters: ["":""], completion: { (httpResponse, graphRequestRsesult) in
                
                switch graphRequestRsesult {
                case .success(let response):
                    let posts = response.dictionaryValue?["posts"] as! NSDictionary
                    
                    let groupName = response.dictionaryValue?["name"] as! String
                    let id = response.dictionaryValue?["id"] as! String
                    
                    let value = response.dictionaryValue?["picture"] as! NSDictionary
                    let data = value["data"] as! NSDictionary
                    let imageUrl = data["url"] as! String
                    
                    let postsArray = posts["data"] as! NSArray
                    for post in postsArray{
                        let post = post as! NSDictionary
                        let postContent = post["message"] != nil ? post["message"] as! String : nil
                        let postCreatedTime = post["created_time"] != nil ? post["created_time"] as! String : nil
                        let postId = post["id"] != nil ? post["id"] as! String : nil
                    
                        
                        let postLinkUrl = post["link"] != nil ? post["link"] as! String : nil
                        let fullPictureUrl = post["full_picture"] != nil ? post["full_picture"] as! String : nil
                        
                        let currentPost = FbPost(postContent: postContent, postCreatedTime: postCreatedTime, postId: postId, postFullPictureUrl: fullPictureUrl, postLink: postLinkUrl,postGroupName:groupName,postGroupImage:imageUrl,postGroupId:id)
                        
                        self.fbPosts.append(currentPost)
                    }
                    self.tableView.reloadData()
                    
                case .failed(let error):
                    print("Custom Graph Request Failed: \(error)")
                }
            })
       
        }
        connection.start()

    }
    func getContext() -> NSManagedObjectContext {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            return appDelegate.managedObjectContext
    }
    
    
}
