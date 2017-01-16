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

class FacebookPagesSelectionTableViewController: UITableViewController {
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBOutlet weak var selectedPagesView: UICollectionView!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var accessToken = AccessToken(appId:"772744622840259",authenticationToken:"772744622840259|63e7300f4f21c5f430ecb740b428a10e",userId:"797971310246511",grantedPermissions: nil, declinedPermissions:nil)
    var fbPageList = [FacebookPage]()
    var selectedPages = [FacebookPage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getSelectedPages()
        self.tableView.tableFooterView?.frame = CGRect.zero
        selectedPagesView.delegate = self
        selectedPagesView.dataSource = self
        doneButton.isEnabled = false
        ActivityIndicator.shared.showProgressView(uiView: self.view)
        AccessToken.current = accessToken
        
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
                    let currentPage = FacebookPage.init(name: name, pageId: id, picUrl: url)
                    self.fbPageList.append(currentPage)
                    self.tableView.reloadData()
                case .failed(let error):
                    print("Custom Graph Request Failed: \(error)")
                }
            })
        }
        connection.start()

    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if fbPageList.count == 0{
            self.tableView.tableFooterView?.frame = CGRect.zero
            print("Unable to get the list")
            
        }else{
            
            ActivityIndicator.shared.hideProgressView()
            
        }

        return fbPageList.count
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if fbPageList.count == 0{
            return UITableViewAutomaticDimension
        }else{
            return 60.0
        }
    }
   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PageSelectionCell", for: indexPath) as! SelectFBPageTableViewCell
        cell.pageName?.text = fbPageList[indexPath.row].name
        cell.pageImageView.sd_setImage(with: URL(string:fbPageList[indexPath.row].picUrl!))
        cell.pageImageView.layer.cornerRadius = cell.pageImageView.frame.width*0.5
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedrow = tableView.cellForRow(at: indexPath)!
        let selectedPage = fbPageList[indexPath.row]
        
        if (selectedrow.accessoryType == UITableViewCellAccessoryType.none){
            selectedrow.accessoryType = UITableViewCellAccessoryType.checkmark
            debugPrint("ZZZ \(selectedrow.textLabel?.text)")
            selectedPages.append(selectedPage)
            selectedPagesView.frame.size = CGSize(width: self.view.frame.width, height: 110.0)
            self.tableView.tableHeaderView = selectedPagesView
            for name in selectedPages{
                debugPrint("BBB *** \(name.name) \n")
            }
        }else{
            debugPrint("ZZZ \(selectedrow.textLabel?.text)")
            selectedrow.accessoryType = UITableViewCellAccessoryType.none
            selectedPages.remove(at: selectedPages.index(where:  { $0.pageId == selectedPage.pageId! })!)
            for name in selectedPages{
            debugPrint("BBB *** \(name.name) \n")
            }
        }
        
        if (selectedPages.count == 0){
            doneButton.isEnabled = false
            self.tableView.tableHeaderView = nil
        }else if (selectedPages.count > 5){
            doneButton.isEnabled = true
            self.selectedPagesView.reloadData()
            let lastIndexPath = IndexPath(item: selectedPages.count-1, section: 0)
            selectedPagesView.scrollToItem(at: lastIndexPath, at: .right, animated: true)
        }else{
            self.selectedPagesView.reloadData()
            doneButton.isEnabled = true
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        for selectedPage in selectedPages{
            updateFacebookPageCoreData(with: selectedPage.pageId!)

                FIRMessaging.messaging().subscribe(toTopic: "/topics/ios_\((selectedPage.pageId)!)")
            
        }
       
        let nav = UIStoryboard.postDisplayScreen()
        self.navigationController?.show(nav, sender: self)
        
        
    }
   
    
    
    //MARK: CoreDataStack
    
    func updateFacebookPageCoreData(with pageId:String){
        let moc = getContext()
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SelectedFacebookPagesCoreDataObject")
        request.predicate = NSPredicate(format: "pageId = %@", pageId)
        
        do {
            let pages = try moc.fetch(request)
                    if pages.count == 0 {
                        //retrieve the entity that we just created
                        let entity =  NSEntityDescription.entity(forEntityName: "SelectedFacebookPagesCoreDataObject", in: moc)
                        let transc = NSManagedObject(entity: entity!, insertInto: moc)
                        
                        //set the entity values
                        transc.setValue(pageId, forKey: "pageId")
                        debugPrint("Succesfully saved")
                        
                        //save the object
                        do {
                            try moc.save()
                            print("Saved!")
                        } catch let error as NSError  {
                            print("Could not save \(error), \(error.userInfo)")
                        }
                    }else{
                        debugPrint("Already have it")
                            }
        }catch let error as NSError  {
            print("Could not execute fetch Request \(error), \(error.userInfo)")
        }
}
}

func getSelectedPages(){
    var array = [FacebookPage]()
    let moc = getContext()
    
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SelectedFacebookPagesCoreDataObject")
    
    var sd1 = NSSortDescriptor(key: "pageId", ascending: true)
    
    request.sortDescriptors = [sd1]
    
        do {
        let pages = try moc.fetch(request)
            
        for page in pages{
            let page = page as! SelectedFacebookPagesCoreDataObject
            print("Found **** \(page.pageId)")
//            array.append(page)
        }
        
        }catch let error as NSError  {
        print("Could not get pages \(error), \(error.userInfo)")
        }
        //save the object
        do {
        try moc.save()
        print("Saved!")
        } catch let error as NSError  {
        print("Could not save \(error), \(error.userInfo)")
        }
}

func getContext() -> NSManagedObjectContext {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    return appDelegate.managedObjectContext
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
        return selectedPages.count
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath){
        let cell = cell as! SelectedPageCollectionViewCell
        cell.contentView.layer.cornerRadius = cell.contentView.frame.width*0.5
        cell.contentView.layer.borderWidth = CGFloat(integerLiteral: 1)
        cell.contentView.layer.borderColor = UIColor.gray.cgColor
        cell.pageImageView.layer.cornerRadius = cell.pageImageView.frame.width*0.5
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectedPageCollectionViewCell", for: indexPath) as! SelectedPageCollectionViewCell
        cell.pageImageView.sd_setImage(with: URL(string:selectedPages[indexPath.row].picUrl!)!, placeholderImage: #imageLiteral(resourceName: "person"))
        return cell
    }
    
}

