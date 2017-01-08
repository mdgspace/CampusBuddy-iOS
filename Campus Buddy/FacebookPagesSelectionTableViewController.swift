//
//  FacebookPagesSelectionTableViewController.swift
//  Campus Buddy
//
//  Created by Kush Taneja on 07/01/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit
import SDWebImage
import FacebookCore

class FacebookPagesSelectionTableViewController: UITableViewController {
    @IBOutlet weak var selectedPagesView: UICollectionView!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    var accessToken = AccessToken(appId:"772744622840259",authenticationToken:"772744622840259|63e7300f4f21c5f430ecb740b428a10e",userId:"797971310246511",grantedPermissions: nil, declinedPermissions:nil)
    var fbPageList = [FacebookPage]()
    var selectedPages = [FacebookPage]()
    
    //var imageView = UIView(frame: CGRect(x: 20, y: 20, width: 20, height: 20))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedPagesView.delegate = self
        selectedPagesView.dataSource = self
        
        doneButton.isEnabled = false
        ActivityIndicator.shared.showProgressView(uiView: self.view)
        AccessToken.current = accessToken
        
        let pageList = FacebookResources().getPageIDList()
        AccessToken.current = accessToken
        let connection = GraphRequestConnection()
        
        for pageId in pageList{
            
            let graphPath = "/\((pageId))"
            let parameters: [String : Any]? = ["fields": "picture.type(normal), name"]
            let httpMethod: GraphRequestHTTPMethod = .GET
            let apiVersion: GraphAPIVersion = .defaultVersion
            let request = GraphRequest(graphPath: graphPath, parameters: parameters!, accessToken:  AccessToken.current, httpMethod: httpMethod, apiVersion: apiVersion)
            connection.add(request, batchEntryName: nil) { (response, result) in
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
                
            }
        }
        
        connection.start()
        ActivityIndicator.shared.hideProgressView()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fbPageList.count
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 60.0
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
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
    }

}
extension FacebookPagesSelectionTableViewController : UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource{
    //1
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

