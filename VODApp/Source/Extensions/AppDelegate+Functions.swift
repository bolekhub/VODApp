//
//  AppDelegate+Common.swift
//  VODApp
//
//  Created by Boris Chirino on 23/07/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation
import UserNotifications

extension AppDelegate {
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
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
    
    
    func registerForLocalNotifications() {
        let options: UNAuthorizationOptions = [.alert, .sound];
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: options) {
            (granted, error) in
            if !granted {
                print("Something went wrong")
            }
        }
    }
    
    
    func fireDownloadReadyNotification() {
        let center = UNUserNotificationCenter.current()
        center.add(self.downloadReadyNotification) { (error) in
            if (error != nil) {
                debugPrint("something went wrong with Local notif.")
            }
        }
    }
}
