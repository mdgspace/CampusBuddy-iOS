//
//  FacebookPagesSelectionTableViewController.swift
//  Campus Buddy
//
//  Created by Kush Taneja on 07/01/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit
import CoreData
import SDWebImage
import FacebookCore
import FirebaseMessaging

class FacebookPagesSelectionTableViewController: UITableViewController,PageCoreDataServiceDelegate{
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBOutlet weak var selectedPagesView: UICollectionView!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var accessToken = AccessToken(appId:"772744622840259",authenticationToken:"772744622840259|63e7300f4f21c5f430ecb740b428a10e",userId:"797971310246511",grantedPermissions: nil, declinedPermissions:nil)
    var pageList: NSFetchedResultsController<NSFetchRequestResult>?
    var selectedPages: NSFetchedResultsController<NSFetchRequestResult>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        AccessToken.current = accessToken

        self.tableView.tableFooterView?.frame = CGRect.zero
        
        getListOfPages()
        
        ActivityIndicator.shared.showProgressView(uiView: self.view)
        
        presentPages()

        
        if (UserDefaults.standard.value(forKey: "selected") != nil){
            if ((UserDefaults.standard.value(forKey: "selected") as! Bool) == false){
                cancelButton = nil
            }else{
                
            }
        }

        selectedPagesView.delegate = self
        selectedPagesView.dataSource = self
        
        doneButton.isEnabled = false
 
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        pageList = PageCoreDataService.pagesList
        presentPages()

    }

    

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if pageList?.sections == nil{
            self.tableView.tableFooterView?.frame = CGRect.zero
            print("Unable to get the list")
            return 0
        }else{
            print("able to get the list with \((pageList?.sections![section].numberOfObjects)!)")
            ActivityIndicator.shared.hideProgressView()
            
            return (pageList?.sections![section].numberOfObjects)!
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
            return 60.0
    }
   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PageSelectionCell", for: indexPath) as! SelectFBPageTableViewCell
        let currentPage = pageList?.object(at: indexPath) as! FacebookPagesCoreDataObject
        print("NAME *** \(currentPage.name)")
        cell.pageName?.text = currentPage.name
        cell.pageImageView.sd_setImage(with: URL(string:currentPage.pic_url!))
        cell.pageImageView.layer.cornerRadius = cell.pageImageView.frame.width*0.5
        
        if (currentPage.isSelected){
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedrow = tableView.cellForRow(at: indexPath) as! SelectFBPageTableViewCell
        
        selectedrow.isSelected = false
        
        let selectedPage = pageList?.object(at: indexPath) as! FacebookPagesCoreDataObject

        if (selectedrow.accessoryType == .none){
            updateFacebookPageCoreData(with: selectedPage.pageId!, isSelected: true)
            selectedPagesView.frame.size = CGSize(width: self.view.frame.width, height: 110.0)
            self.tableView.tableHeaderView = selectedPagesView
        }else{
            updateFacebookPageCoreData(with: selectedPage.pageId!, isSelected: false)
        }
        
        if selectedPages?.sections == nil{
            print("NONE Selected")
        }else{
            self.selectedPagesView.reloadData()
            doneButton.isEnabled = true
            let lastIndexPath = IndexPath(item: (selectedPages?.sections![0].numberOfObjects)!-1, section: 0)
            selectedPagesView.scrollToItem(at: lastIndexPath, at: .right, animated: true)
        }
        
        tableView.deselectRow(at: indexPath,animated:false)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        
        let selects = selectedPages?.fetchedObjects
        
        for selected in selects!{
            let selected = selected as! FacebookPagesCoreDataObject
            FIRMessaging.messaging().subscribe(toTopic: "/topics/ios_\((selected.pageId)!)")
        }
        
        let nav = UIStoryboard.postDisplayScreen()
        self.navigationController?.show(nav, sender: self)
        
        
    }
    
    
    
    //MARK: CoreDataStack
    
    func updateFacebookPageCoreData(with pageId:String,isSelected: Bool){
        
        let moc = getContext()
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FacebookPagesCoreDataObject")
        request.predicate = NSPredicate(format: "pageId = %@", pageId)
        
        do {
            let pages = try moc.fetch(request)
            
                    if pages.count != 0 {
                        //retrieve the entity that we just created
                        for page in pages{
                        let page = page as! FacebookPagesCoreDataObject
                        page.isSelected = isSelected
                        
                            do {
                                try moc.save()
                                print("update Success!")
                            } catch let error as NSError  {
                                print("Could not save \(error), \(error.userInfo)")
                            }
                        }
                        
                    }else{
                        debugPrint("No Page in Core Data")
                    }
        }catch let error as NSError  {
            print("Could not execute fetch Request \(error), \(error.userInfo)")
        }
}


func getListOfPages(){
    
    if Reachability.isConnectedToNetwork(){
    let pageList = FacebookResources().getPageIDList()
    let connection = GraphRequestConnection()
    
    for pageId in pageList{
                let graphPath = "/\(pageId)"
                let parameters: [String : Any]? = ["fields": "picture.type(normal), name"]
                let httpMethod: GraphRequestHTTPMethod = .GET
                let apiVersion: GraphAPIVersion = .defaultVersion
                let request = GraphRequest(graphPath: graphPath, parameters: parameters!, accessToken:  AccessToken.current, httpMethod: httpMethod, apiVersion: apiVersion)
                
                connection.add(request, batchParameters: ["":""], completion: { (response, result) in
                    switch result {
                    case .success(let response):
                        
                        let name = response.dictionaryValue?["name"] as! String
                        let id = response.dictionaryValue?["id"] as! String
                        
                        let value = response.dictionaryValue?["picture"] as! NSDictionary
                        let data = value["data"] as! NSDictionary
                        let url = data["url"] as! String
                        
                        let currentPage = FacebookPage.init(name: name, pageId: id, picUrl: url, isSelected: false)
                        
                        PageCoreDataService.sharedInstance.addPagetoCoreData(currentPage)
                    case .failed(let error):
                        print("Custom Graph Request Failed: \(error)")
                    }
                })
    }
    connection.start()
    }else{
        Utils().alertView(self, title: "You are not connected to Internet", message: "Please try Again")
    }
    self.pageList = PageCoreDataService.pagesList
    self.selectedPages = PageCoreDataService.selectedPagesList
    
    if selectedPages?.sections == nil{
        print("NONE Selected")
    }else if ((selectedPages?.sections![0].numberOfObjects)! == 0){
        doneButton.isEnabled = false
        self.tableView.tableHeaderView = nil
    }else{
        
        selectedPagesView.frame.size = CGSize(width: self.view.frame.width, height: 110.0)
        self.tableView.tableHeaderView = selectedPagesView
        self.selectedPagesView.reloadData()
        doneButton.isEnabled = true
    }
 
}

func presentPages(){
        self.tableView.reloadData()
        self.navigationItem.title = "Subscribe a Page"
        
    }
func PagesCoreDataContentChanged() {
        ActivityIndicator.shared.showProgressView(uiView: self.view)
        self.tableView.reloadData()
    }
    func selectedPageContentDidChange(){
        self.selectedPagesView.reloadData()

    }

func getContext() -> NSManagedObjectContext {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    return appDelegate.managedObjectContext
}


}

// MARK: CollectionVeiw Extension
extension FacebookPagesSelectionTableViewController : UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellLength = UIScreen.main.bounds.size.width/5-CGFloat(10.0)
        let width:Double = Double(75.0)
        let height:Double = Double(75.0)
        return CGSize(width: width, height: height)
        
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int{
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        
        if selectedPages?.sections == nil{
            print("NONE Selected")
        }else if ((selectedPages?.sections![0].numberOfObjects)! == 0){
            doneButton.isEnabled = false
            self.tableView.tableHeaderView = nil
        }
//        }else if ((selectedPages?.sections![0].numberOfObjects)! > 5){
//            doneButton.isEnabled = true

//        }
        
        if selectedPages?.sections == nil{
            return 0
        }else{
            return (selectedPages?.sections![section].numberOfObjects)!
        }
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath){
        
        let cell = cell as! SelectedPageCollectionViewCell
        cell.contentView.layer.cornerRadius = cell.contentView.frame.width*0.5
        cell.contentView.layer.borderWidth = CGFloat(integerLiteral: 1)
        cell.contentView.layer.borderColor = UIColor.gray.cgColor
        cell.pageImageView.layer.cornerRadius = cell.pageImageView.frame.width*0.5
        cell.pageImageView.clipsToBounds = true
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectedPageCollectionViewCell", for: indexPath) as! SelectedPageCollectionViewCell
        
        let currentSelectedPage = selectedPages?.object(at: indexPath) as! FacebookPagesCoreDataObject
        
        cell.pageImageView.sd_setImage(with: URL(string:currentSelectedPage.pic_url!)!, placeholderImage: #imageLiteral(resourceName: "person"))
        
        cell.pageImageView.layer.cornerRadius = cell.pageImageView.frame.width*0.5
        cell.pageImageView.clipsToBounds = true
        return cell
    }
    
    
}

