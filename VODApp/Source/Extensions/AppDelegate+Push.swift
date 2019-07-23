//
//  AppDelegate+RemoteNotifications.swift
//  VODApp
//
//  Created by Boris Chirino on 23/07/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

//MARK: Remote notifications
extension AppDelegate {
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        //comming from simulator
        if let playList = userInfo["playlist"] as? NSDictionary {
            var plItems = Set<PlayListItemVO>()
            for (k, v) in playList  {
                if let item = PlayListItemVO.fromDictionary(v as! NSDictionary, identifier: k as! String) {
                    plItems.update(with: item)
                }
            }
            var arr = plItems.compactMap({$0})
            arr.sort { (a, b) -> Bool in
                return a < b
            }
            DownloadService.default.downloadItems(items: arr, completionHandler: completionHandler)
            debugPrint("parsed \(plItems.count)")
        }
        
        
        //comming from oneSignal
        if let custom = userInfo["custom"] as? NSDictionary {
            
            guard let plEnvelop = custom.object(forKey: "a") as? NSDictionary else { return }
            guard let playListString = plEnvelop.allValues.first as? String  else { return }
            
            let playlistStringDictionaryAsData = playListString.data(using: .utf8)
            let playListAsDictionary = try! JSONSerialization.jsonObject(with: playlistStringDictionaryAsData!,
                                                                         options: .allowFragments)
            var plItems = Set<PlayListItemVO>()
            
            for (k, v) in (playListAsDictionary as! NSDictionary) {
                if let item = PlayListItemVO.fromDictionary(v as! NSDictionary, identifier: k as! String) {
                    plItems.update(with: item)
                }
            }
            
            var arr = plItems.compactMap({$0})
            arr.sort { (a, b) -> Bool in
                return a < b
            }
            
            DownloadService.default.downloadItems(items: arr, completionHandler: completionHandler)
        }
        
    }

    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("Device Token : -> \(deviceTokenString)")
    }
    
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint("Failed registering for push \(error.localizedDescription)")
    }
    
}
