//
//  PageCoreDataService.swift
//  Campus Buddy
//
//  Created by Kush Taneja on 19/01/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import Foundation
import UIKit
import CoreData

public protocol PageCoreDataServiceDelegate {
    func PagesCoreDataContentChanged()
    func selectedPageContentDidChange()
}

public class PageCoreDataService: NSObject,NSFetchedResultsControllerDelegate{
    
    public var delegate: PageCoreDataServiceDelegate?

    public class var sharedInstance : PageCoreDataService {
        struct PageCoreDataServiceSingleton {
            static let instance = PageCoreDataService()
        }
        return PageCoreDataServiceSingleton.instance
    }
    
    public class var pagesList: NSFetchedResultsController<NSFetchRequestResult>{
        return PageCoreDataService.sharedInstance.fetchedResultsController()!
    }
    public class var selectedPagesList: NSFetchedResultsController<NSFetchRequestResult>{
        return PageCoreDataService.sharedInstance.selectedPages()!
    }


    public func fetchedResultsController()-> NSFetchedResultsController<NSFetchRequestResult>? {
        
        var fetchedResultsControllerVar: NSFetchedResultsController<NSFetchRequestResult>?

        let moc = getContext()
        
        let entity =  NSEntityDescription.entity(forEntityName: "FacebookPagesCoreDataObject", in: moc)
        let sd1 = NSSortDescriptor(key: "name", ascending: true)
        let sortDescriptors = [sd1]
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        
        fetchRequest.entity = entity
        fetchRequest.sortDescriptors = sortDescriptors
        
//        fetchRequest.fetchBatchSize = 20
        
        fetchedResultsControllerVar = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsControllerVar?.delegate = self
        delegate?.PagesCoreDataContentChanged()
        
        do {
            try fetchedResultsControllerVar!.performFetch()
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            abort()
        }
        
        return fetchedResultsControllerVar!
    }
    
    public func selectedPages() -> NSFetchedResultsController<NSFetchRequestResult>?{
        
        var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
        
        let moc = getContext()
        
        let entity =  NSEntityDescription.entity(forEntityName: "FacebookPagesCoreDataObject", in: moc)
        let sd1 = NSSortDescriptor(key: "name", ascending: true)
        let sortDescriptors = [sd1]
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        
        fetchRequest.entity = entity
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = NSPredicate(format: "isSelected = %@", true as CVarArg)

        
        //        fetchRequest.fetchBatchSize = 20
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController?.delegate = self
        delegate?.selectedPageContentDidChange()
        
        do {
            try fetchedResultsController!.performFetch()
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            abort()
        }
        
        return fetchedResultsController!
        
    }
    
    
    public func pageCoreDataIsEmptyFor(pageId: String) -> Bool {
        let moc = getContext()
        let entity =  NSEntityDescription.entity(forEntityName: "FacebookPagesCoreDataObject", in: moc)
        let request = NSFetchRequest<NSFetchRequestResult>()
        
        
        request.predicate = NSPredicate(format: "pageId = %@", pageId)
        request.entity = entity
        
        do {
            let results = try moc.fetch(request)
            
            if (results.count == 0){
                debugPrint("** PageCoreData Is Empty For ")
                return true
            }
            else {
                return false
            }
            
        } catch _ {
            //catch fetch error here
        }
        return false
    }
    
    
    public func addPagetoCoreData(_ page: FacebookPage){
        
        let moc = getContext()
        let entity =  NSEntityDescription.entity(forEntityName: "FacebookPagesCoreDataObject", in: moc)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FacebookPagesCoreDataObject")
        request.predicate = NSPredicate(format: "pageId = %@", page.pageId!)
        
        request.entity = entity
        
        do {
            let results = try moc.fetch(request)
            
            if (results.count == 0){
                
                let transc = NSManagedObject(entity: entity!, insertInto: moc)
                //set the entity values
                transc.setValue(page.pageId!, forKey: "pageId")
                transc.setValue(page.name!, forKey: "name")
                transc.setValue(page.picUrl!, forKey: "pic_url")
                
            }else if (results.count == 1){
                
                let result = results[0] as! FacebookPagesCoreDataObject
                
                if(result.name != page.name){
                   result.name = page.name
                }
                if(result.pic_url != page.picUrl){
                    result.pic_url = page.picUrl
                }
            }else if (results.count > 1){
                
                for result in results{
                    moc.delete(result as! NSManagedObject)
                }
                let transc = NSManagedObject(entity: entity!, insertInto: moc)
                //set the entity values
                transc.setValue(page.pageId!, forKey: "pageId")
                transc.setValue(page.name!, forKey: "name")
                transc.setValue(page.picUrl!, forKey: "pic_url")
            }
            do {
                try moc.save()
                    print("Saved!")
                } catch let error as NSError  {
                    print("Could not save \(error), \(error.userInfo)")
                }
            } catch _ {
            //catch fetch error here
        }
    }
    
    
    


    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.PagesCoreDataContentChanged()
        delegate?.selectedPageContentDidChange()
    }
    
    
    func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }

}
