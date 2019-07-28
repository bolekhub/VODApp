//
//  DServiceSessionDelegate.swift
//  VODApp
//
//  Created by Boris Chirino on 22/07/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

/// inform about downloading completion or failed
protocol DSSessionDelegateConformable: class {
    
    /// called when a file have been completely downloaded and saved to documents.
    ///
    /// - Parameter download: Download instance of the item just downloaded
    func didFinishDownloading(_ download: Download)
    
    /// called for every failed download.
    ///
    /// - Parameters:
    ///   - download: the item failed
    ///   - isFileOversized: if this property is true, the download is canceled and removed from the
    /// downloads stack. On the class DownloadService
    func didFailDownloading(_ download: Download, isFileOversized: Bool )
}


class DSSessionDelegate: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDownloadDelegate  {
    
    weak var delegate: DSSessionDelegateConformable?
    
    /// where downloaded files must be saved
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    
    func localFilePath(for url: URL) -> URL {
        return documentsPath.appendingPathComponent(url.lastPathComponent)
    }
    
    
    //MARK: - URLSessionDelegate
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        debugPrint("URLdidBecomeInvalidWithError .. \(String(describing: error?.localizedDescription))")
    }
    
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        debugPrint("urlSessionDidFinishEvents ")
    }
    
    //MARK: - URLSessionTaskDelegate
    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        debugPrint("taskIsWaitingForConnectivity")
    }
    
    
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        if error != nil {
            var resumingData: Data?
            
            guard let failingUrl = (error as NSError?)?.userInfo[NSURLErrorFailingURLStringErrorKey] as? String else {
                return
            }
            
            if let resumeData = (error as NSError?)?.userInfo[NSURLSessionDownloadTaskResumeData] as? Data
            {
                resumingData = resumeData
            }
            
            if let dld = DownloadService.default.findDownloads(byStringUrl: failingUrl) {
                dld.resumeData = resumingData
                self.delegate?.didFailDownloading(dld, isFileOversized: false)
            }

            debugPrint("/n URL Session failed, \(String(describing: error?.localizedDescription))")
        }
        
    }
    
    
    //MARK: - URLSessionDownloadDelegate
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let written  = ByteCountFormatter.string(fromByteCount: totalBytesWritten, countStyle: .file)
        let total  = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: .file)
        
        if (totalBytesExpectedToWrite > maxDownloadSize) {
            if let strUrl = downloadTask.originalRequest?.url?.absoluteString,
                let download = DownloadService.default.findDownloads(byStringUrl: strUrl) {
                downloadTask.cancel()
                self.delegate?.didFailDownloading(download, isFileOversized: true)
            }
        }
        debugPrint("write \(written) of \(total)")
    }
    
    
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL)
    {
        debugPrint("finished \(location.absoluteString)")
        
        //original request is nill when resuming
        guard let sourceURL = downloadTask.originalRequest?.url else { return }
        
        let destinationURL = localFilePath(for: sourceURL)
        
        let fileManager = FileManager.default
        try? fileManager.removeItem(at: destinationURL)
        do {
            try fileManager.copyItem(at: location, to: destinationURL)
        } catch let error {
            print("Could not copy file to disk: \(error.localizedDescription)")
        }
        
        if let download = DownloadService.default.findDownloads(byStringUrl: sourceURL.absoluteString) {
            self.delegate?.didFinishDownloading(download)
        }
        
    }
    
}
