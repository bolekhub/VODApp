//
//  CoreDataRepository.swift
//  VODApp
//
//  Created by Boris Chirino on 23/07/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation
import CoreData

/// specific implementation to save items with coreData
class CoreDataDAO: PlayListRepositoryConformable  {
    
    private lazy var appDelegate : AppDelegate? = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        return appDelegate
    }()
    
    private lazy var persitentContainer: NSPersistentContainer? = {
        [unowned self] in
        return self.appDelegate?.persistentContainer
    }()
    
    private lazy var mainContext: NSManagedObjectContext? = {
        [unowned self] in
        return self.appDelegate?.persistentContainer.viewContext
    }()
    
    private lazy var privateContext: NSManagedObjectContext? = {
        return self.persitentContainer?.newBackgroundContext()
    }()
    
    private func fetchTemplate(withname name : String) -> NSFetchRequest<NSFetchRequestResult>? {
        return self.appDelegate?.persistentContainer.managedObjectModel.fetchRequestTemplate(forName: name)
    }
    
    

    func batchSave(items: [PlayListItemVO]) {
        
        guard let ctx = self.privateContext else {
            return
        }
        
        ctx.perform { [unowned self] in
            
            items.forEach { (playListItem) in
                
                var entity: Video
                
                if let existingEntity = self.getBy(id: playListItem.id!) {
                    
                    entity = existingEntity
                    entity.title = playListItem.title
                    entity.subtitle = playListItem.subtitle ?? ""
                    entity.url = playListItem.url
                    entity.identifier = playListItem.id
                    entity.fileName = playListItem.sourceURL()!.lastPathComponent
                    
                } else {
                    
                    entity = Video(context: ctx)
                }
                
                entity.title = playListItem.title
                entity.subtitle = playListItem.subtitle ?? ""
                entity.url = playListItem.url
                entity.identifier = playListItem.id
                entity.fileName = playListItem.sourceURL()!.lastPathComponent
                
            }
            
            self.saveContext(context: ctx)
        }
        
        
    }
    

    func getBy(id: String) -> Video? {
        
        let context = Thread.isMainThread ? self.mainContext : self.privateContext
        let findFetchRequest = self.persitentContainer?.managedObjectModel.fetchRequestFromTemplate(withName: "getById", substitutionVariables: ["id" : id])
        
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
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
            
            
        }
    }
    
}
