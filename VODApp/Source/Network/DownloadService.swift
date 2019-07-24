//
//  DownloadService.swift
//  VODApp
//
//  Created by Boris Chirino on 22/07/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

/// Handle all network related task
class DownloadService: NSObject, DSSessionDelegateConformable {

    /// its a bag containing all downloads that this class is handling.
    private var downloads = Set<Download>()
    
    private var playListItems: [PlayListItemVO] {
        let r = downloads.compactMap { (dld) -> PlayListItemVO? in
            return dld.item
        }
        return r
    }
    
    /// coordinate the network requests
    private var session : URLSession!
    
    /// hold a reference to UIBackgroundFetchResult gathered form appdelegate. It will be invoqued
    /// once all download task are finished.
    private var remoteNotificationHandler: ((UIBackgroundFetchResult) -> Void )!
    
    /// callbacks for the session
    private lazy var sessionDelegate : DSSessionDelegate = {
        let _sessionDelegate = DSSessionDelegate()
        _sessionDelegate.delegate = self
        return _sessionDelegate
    }()
    
    /// perform a predicate against all elements inside downloads property evaluating complete property of
    /// download class.
    private var allDownloadsCompleted : Bool {
        return downloads.allSatisfy { (dld) -> Bool in
            return dld.complete == true
        }
    }
    
    /// return downloads marked as failed, not in progress
    fileprivate var failedDownloads: [Download]? {
        let failed = downloads.filter { (dld) -> Bool in
            return dld.failed == true  && dld.inProgress == false
        }
        return failed.compactMap({$0})
    }
    
    
    fileprivate init(_ sessionconfiguration : URLSessionConfiguration = URLSessionConfiguration.default) {
        super.init()
        session = URLSession(configuration: sessionconfiguration,
                             delegate: self.sessionDelegate,
                             delegateQueue: nil)
    }
    
    /// default instance
    public static let `default`: DownloadService = {
        var configuration = URLSessionConfiguration.background(withIdentifier: "com.bcf.wservice")
        configuration.networkServiceType = .background
        configuration.sessionSendsLaunchEvents = true
        if #available(iOS 11, *) {
            configuration.waitsForConnectivity = true
        }
        let _ps = DownloadService(configuration)
        return _ps
    }()
    
    
    /// find if download exist referencing by url
    ///
    /// - Parameter url: url of the download
    /// - Returns: Download if any match
    func findDownloads(byStringUrl url: String ) -> Download? {
        let existingDownloadItem = downloads.filter { (dld) -> Bool in
            return dld.item.url == url
        }
        return existingDownloadItem.first
    }
    
    
    func didFinishDownloading(_ download: Download) {
        download.inProgress = false
        download.complete = true
        if (self.allDownloadsCompleted == true ) {
            debugPrint("ALL DOWNLOADS READY")
            DispatchQueue.main.async {
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                    return
                }
                appDelegate.fireDownloadReadyNotification()
                appDelegate.dataStore.batchSave(items: self.playListItems)
                self.remoteNotificationHandler( .newData)
            }
        } else {
            debugPrint("completed \(download.item.title)")
        }
    }
    
    func didFailDownloading(_ download: Download, isFileOversized: Bool) {
        download.failed = true
        download.cancel(oversized: isFileOversized)
        if (isFileOversized == true) {
            self.downloads.remove(download)
        }
        debugPrint("failed \(download.item.title)")
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [unowned self] (timer) in
            self.retryFailedDownloads()
        }
    }
}


//MARK: - service methods
extension DownloadService {
    
    /// Receive all items to be downloaded
    ///
    /// - Parameters:
    ///   - items: array of items to be downloaded
    ///   - completionHandler: this completion handler is called afger all downloads
    func downloadItems(items: [PlayListItemVO], completionHandler: @escaping (UIBackgroundFetchResult) -> Void)  {
        self.remoteNotificationHandler = completionHandler
        items.forEach { (playListItem) in
            self.downloadPlayListItem(playListItem)
        } 
    }
    
    /// Download the passed item.
    ///
    /// - Parameter item: The item to be downloaded. If the item already exist on the downloads stack
    /// it will be reused, taking resume data if it exist.
    private func downloadPlayListItem(_ item: PlayListItemVO ) {
        
        var download: Download
        
        let existingDownloadItem = downloads.filter { (dld) -> Bool in
            return dld.item.id == item.id
            }.first
        
        // in case of an error during download task, check if resumeData available
        if let dl = existingDownloadItem {
            download = dl
            if let resumeData = dl.resumeData {
                download.resumeData = dl.resumeData
                download.task = self.session.downloadTask(withResumeData: resumeData)
            } else {
                download.task = self.session.downloadTask(with: download.item.sourceURL()!)
            }
            
        } else { // new task
            download = Download(item: item)
            download.task = self.session.downloadTask(with: item.sourceURL()!)
        }
        
        download.inProgress = true
        download.task?.resume()
        downloads.update(with: download)
        debugPrint("/n Performing request to \(item.sourceURL()!) ")
    }
    
    /// if there are any download that have failed, retry the proccess.
    private func retryFailedDownloads() {
        if let failed = self.failedDownloads {
            failed.forEach { (dld) in
                self.downloadPlayListItem(dld.item)
            }
        }
    }
    
    
}
