//
//  CoreDataRepository.swift
//  VODApp
//
//  Created by Boris Chirino on 23/07/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation
import CoreData

/// specific implementation to save items with coreData. Due to persistent container must be
/// the same along all app. This class representing coredata storage its a singleton.
class CoreDataDAO: PlayListRepositoryConformable  {

    /// singleton instance
    static let shared: CoreDataDAO = CoreDataDAO()
    
    /// object representing core data stack.
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "VODApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                debugPrint("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()


    private init(){}
    
    /// context to be used by main thread
    private lazy var mainContext: NSManagedObjectContext? = {
        [unowned self] in
        return self.persistentContainer.viewContext
    }()
    
    /// background context
    private lazy var privateContext: NSManagedObjectContext? = {
        return self.persistentContainer.newBackgroundContext()
    }()
    
    /// return the specified fetch request
    ///
    /// - Parameter name: the name of the fetchrequest declared in the model
    /// see (VODAppTest.xcdatamodel) FETCH REQUESTS section for more detail
    /// - Returns: NSFetchRequest<NSFetchRequestResult>?
    private func fetchTemplate(withname name : String) -> NSFetchRequest<NSFetchRequestResult>? {
        return self.persistentContainer.managedObjectModel.fetchRequestTemplate(forName: name)
    }
    
    func batchSave(items: [PlayListItemVO]) {
        
        guard let ctx = self.privateContext else {
            return
        }
        
        ctx.perform { [unowned self] in
            
            items.forEach { (playListItem) in
                
                if let existingEntity = self.getBy(id: playListItem.id!) {
                    
                    existingEntity.title = playListItem.title
                    existingEntity.subtitle = playListItem.subtitle ?? ""
                    existingEntity.url = playListItem.url
                    existingEntity.identifier = playListItem.id
                    existingEntity.fileName = playListItem.sourceURL()!.lastPathComponent
                    
                } else {
                    let entity = Video(context: ctx)
                    entity.title = playListItem.title
                    entity.subtitle = playListItem.subtitle ?? ""
                    entity.url = playListItem.url
                    entity.identifier = playListItem.id
                    entity.fileName = playListItem.sourceURL()!.lastPathComponent
                }
  
            }
            
            self.saveContext(context: ctx)
        }
    }
    

    func getBy(id: String) -> Video? {
        
        let context = Thread.isMainThread ? self.mainContext : self.privateContext
        let findFetchRequest =
        self.persistentContainer.managedObjectModel.fetchRequestFromTemplate(withName: "getById",
                                                                    substitutionVariables: ["id" : id])
        var result: Video?
        do {
            
            let fetch_result = try context?.fetch(findFetchRequest!) as? [Video]
            guard !(fetch_result?.isEmpty)! else {
                return nil
            }
            result = fetch_result?.first
        } catch {
            
            print("A problem occured while getting entity. Error : \(error)")
        }
        
        return result
    }
    
    func getAll() -> [Video]? {
        
        let getAllCachedRequest = self.fetchTemplate(withname: "getAllCached")
        var result: [Video]?
        
        do {
           let fetch_result = try self.mainContext?.fetch(getAllCachedRequest!) as? [Video]
           result = fetch_result
        } catch {
           print("A problem occured while getting entity. Error : \(error)")
        }
        return result
    }
    
    
    private func saveContext (context :NSManagedObjectContext) {
        
        if context.parent != nil {
            do {
                try context.save()
                context.parent?.performAndWait({
                    
                    do{
                        try context.parent?.save()
                    }catch{
                        fatalError("Error saving main context \(error)")
                    }
                    
                })
            } catch  {
                fatalError("Error saving private context \(error)")
                
            }
        }else {
            
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
            
            
        }
    }
    
}
