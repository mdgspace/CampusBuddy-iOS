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
import SKPhotoBrowser
import Foundation


class FbPostsTableViewController: UITableViewController,UIGestureRecognizerDelegate{

     var accessToken = AccessToken(appId:"772744622840259",authenticationToken:"772744622840259|63e7300f4f21c5f430ecb740b428a10e",userId:"797971310246511",grantedPermissions: nil, declinedPermissions:nil)
     var selectedPageIds = [String]()
     var fbPosts = [FbPost]()
    
    var refreshcontrol: UIRefreshControl = UIRefreshControl()
    
    var refreshcontrolbottom: UIRefreshControl = UIRefreshControl()

    
    func addrefreshcontrol() {
        refreshcontrol.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        refreshcontrol.tintColor = ColorCode().appThemeColor
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshcontrol
        } else {
            tableView.addSubview(refreshcontrol)
        }
        
    }
    
    
    func removerefreshcontrol() {
        refreshcontrol.removeTarget(self, action: #selector(self.refresh), for: .valueChanged)
        refreshcontrol.removeFromSuperview()
    }
    
    func hideInfiniteScrollIndicator() {
        if (self.refreshcontrol.isRefreshing) {
            self.refreshcontrol.endRefreshing()
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        addrefreshcontrol()
        UserDefaults.standard.set(true, forKey: "selected")
        
        self.tableView.estimatedRowHeight = 341.0
        
       
        
        AccessToken.current = accessToken
        
        selectedPageIds =  getSelectedPages()
        
        self.getFacebookPosts()

    }
    override func viewDidAppear(_ animated: Bool) {
        self.navigationItem.hidesBackButton = true
        self.getFacebookPosts()
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
        
        let post = fbPosts[indexPath.row]
        cell.imageConstraint.constant = 175.0
        cell.groupNameLabel.text = post.groupName
        cell.postContentTextView.text = post.content
        cell.imageWidthConstraint.constant = UIScreen.main.bounds.width
        cell.postImageView.contentMode = .scaleAspectFill
        
        if (post.content == nil){
            cell.postImageFromProfile.constant = 0.0
            cell.imageAndPostCOntent.constant = 0.0
        }else{
            cell.postImageFromProfile.constant = 4.0
            cell.imageAndPostCOntent.constant = 4.0
        }
        
        cell.timeLabel.text = post.createdRelativeTime
        cell.groupImageView.sd_setImage(with: URL(string:(post.groupImage)!)!, placeholderImage: #imageLiteral(resourceName: "Rectangle"))
        
        if post.fullPictureUrl != nil {
            
            cell.postImageView.sd_setImage(with: post.fullPictureUrl, placeholderImage: #imageLiteral(resourceName: "Rectangle"), options: .avoidAutoSetImage) { (image, error, type, url) in
                var tapGesture: UITapGestureRecognizer?
                
                if (image != nil){
                    
                    if (post.content == nil){
                        cell.postImageFromProfile.constant = 0.0
                        cell.imageAndPostCOntent.constant = 0.0
                    }else{
                        cell.postImageFromProfile.constant = 4.0
                        cell.imageAndPostCOntent.constant = 4.0
                    }
                    
                    if ((image?.size.width)! > UIScreen.main.bounds.width){
                         cell.imageConstraint.constant = ((image?.size.height)!/(image?.size.width)!)*UIScreen.main.bounds.width
                         cell.imageWidthConstraint.constant = UIScreen.main.bounds.width
                         cell.postImageView.contentMode = .scaleAspectFit
                    }else{
                         cell.postImageView.contentMode = .scaleAspectFill
                         cell.imageConstraint.constant = (image?.size.height)!
                         cell.imageWidthConstraint.constant = (image?.size.width)!
                    }
                    
                    cell.postImageView.image = image
                    
                    if(post.type == "link"){
                        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.openURL))
                    }else{
                        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.ShowGalleryImageViewController(_:)))
                    }
                    cell.postImageView.isUserInteractionEnabled = true
                    cell.postImageView.addGestureRecognizer(tapGesture!)
                    
                }else{
                    
                    if(post.type == "link"){
                        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.openURL))
                    }else{
                        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.ShowGalleryImageViewController(_:)))
                    }
                    cell.postImageView.isUserInteractionEnabled = true
                    cell.postImageView.addGestureRecognizer(tapGesture!)
                    
                }
                debugPrint("I ** HEight \(cell.postImageView.frame.size.height)** Width \(cell.postImageView.frame.size.width)")

            }
            
        } else{
            cell.imageConstraint.constant = 0.0
        }
        return cell
    }
    
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    
    @IBAction func editButtonTapped(_ sender: Any) {
        
        UserDefaults.standard.set(false, forKey: "selected")
        
        self.navigationController?.show(UIStoryboard.pageSelectionScreen(), sender: self)
        
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
        
        ActivityIndicator.shared.showProgressView(uiView: self.view)
        
        if (Reachability.isConnectedToNetwork()){
            
        for pageId in selectedPageIds {
            var parameters: [String : Any]?
            debugPrint("Entered")
            let graphPath = "/\(pageId)"
            
            if (selectedPageIds.count == 1){
                parameters = ["fields": "posts{message,created_time,id,full_picture, link,type},name,picture"]
            }else if (selectedPageIds.count > 1 && selectedPageIds.count <= 3){
                parameters = ["fields": "posts.limit(15){message,created_time,id,full_picture, link,type},name,picture"]
            }else{
                parameters = ["fields": "posts.limit(10){message,created_time,id,full_picture, link,type},name,picture"]
            }
            
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
                        let postType = post["type"] != nil ? post["type"] as! String : nil
                        
                        let postLinkUrl = post["link"] != nil ? post["link"] as! String : nil
                        var fullPictureUrl: String? = post["full_picture"] as? String
                        
                        
                        
                        let currentPost = FbPost(postContent: postContent, postCreatedTime: postCreatedTime, postId: postId, postFullPictureUrl: fullPictureUrl, postLink: postLinkUrl,postGroupName:groupName,postGroupImage:imageUrl,postGroupId:id,postType:postType)
                        
                        if (!(self.fbPosts.contains(where: { $0.id == currentPost.id }))){
                            self.fbPosts.append(currentPost)
                        }
                        self.fbPosts.sort{$0.date! > $1.date!}
                    }
                    
                    if self.fbPosts.count > 5 {
                        self.tableView.reloadData()
                    }
                    
                case .failed(let error):
                    
                    Utils().alertViewWithButton(self, title: "Their was a problem connecting to Facebook", message: "Try again After Some time", buttonText: "Retry", action: { (alert) in
                        ActivityIndicator.shared.showProgressView(uiView: self.view)
                        self.getFacebookPosts()
                    })
                    
                    print("Custom Graph Request Failed: \(error)")
                }
            })
       
        }
        connection.start()
        }else{
            Utils().alertView(self, title: "You are not connected to Internet", message: "Please try Again")
        }

    }
    
    func refresh(){
        
        var initialCount = fbPosts.count
        
        let connection = GraphRequestConnection()
        
        if (Reachability.isConnectedToNetwork()){
            
            for pageId in selectedPageIds {
                
                debugPrint("Entered")
                let graphPath = "/\(pageId)"
                
                
                let parameters: [String : Any] = ["fields": "posts.limit(1){message,created_time,id,full_picture, link,type},name,picture"]
                
                let httpMethod: GraphRequestHTTPMethod = .GET
                let apiVersion: GraphAPIVersion = .defaultVersion
                
                let request = GraphRequest(graphPath: graphPath, parameters: parameters, accessToken:  AccessToken.current, httpMethod: httpMethod, apiVersion: apiVersion)
                
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
                            let postType = post["type"] != nil ? post["type"] as! String : nil
                            
                            let postLinkUrl = post["link"] != nil ? post["link"] as! String : nil
                            var fullPictureUrl: String? = post["full_picture"] as? String
                            
                            
                            
                            let currentPost = FbPost(postContent: postContent, postCreatedTime: postCreatedTime, postId: postId, postFullPictureUrl: fullPictureUrl, postLink: postLinkUrl,postGroupName:groupName,postGroupImage:imageUrl,postGroupId:id,postType:postType)
                            
                            if (!(self.fbPosts.contains(where: { $0.id == currentPost.id }))){
                                self.fbPosts.insert(currentPost, at: 0)
                            }
                            self.fbPosts.sort{$0.date! > $1.date!}
                        }
                        
                        if (self.fbPosts.count > initialCount) {
                            self.tableView.reloadData()
                        }
                        
                    case .failed(let error):
                        
                        Utils().alertViewWithButton(self, title: "Their was a problem connecting to Facebook", message: "Try again After Some time", buttonText: "Retry", action: { (alert) in
                            ActivityIndicator.shared.showProgressView(uiView: self.view)
                            self.getFacebookPosts()
                        })
                        
                        print("Custom Graph Request Failed: \(error)")
                    }
                })
                
            }
            connection.start()
        }else{
            Utils().alertView(self, title: "You are not connected to Internet", message: "Please try Again")
            view.makeToast(message:"No Internet Connection")
        }
        hideInfiniteScrollIndicator()
    
    }
    func getContext() -> NSManagedObjectContext {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            return appDelegate.managedObjectContext
    }
    
    func ShowGalleryImageViewController(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: self.tableView)
        
        //using the tapLocation, we retrieve the corresponding indexPath
        let indexPath = self.tableView.indexPathForRow(at: tapLocation)
        
        let cell = self.tableView.cellForRow(at: indexPath!) as! PostTableViewCell
        
        let photo = SKPhoto.photoWithImage(cell.postImageView.image!)
        photo.caption = cell.postContentTextView.text
        photo.shouldCachePhotoURLImage = true
        
        let browser = SKPhotoBrowser(photos: [photo])
        browser.initializePageIndex(0)
        UIApplication.topViewController()?.present(browser, animated: true, completion: {})
        
    }
    func openURL(_ sender: UITapGestureRecognizer){
        
        let tapLocation = sender.location(in: self.tableView)
        
        //using the tapLocation, we retrieve the corresponding indexPath
        let indexPath = self.tableView.indexPathForRow(at: tapLocation)
        let post = fbPosts[(indexPath?.row)!]
        
        UIApplication.shared.openURL(post.link!)
    }
    
}
