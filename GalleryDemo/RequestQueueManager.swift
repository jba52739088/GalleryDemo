//
//  RequestQueueManager.swift
//  GalleryDemo
//
//  Created by 黃恩祐 on 2021/3/30.
//

import Foundation
import Alamofire
import AlamofireImage

class RequestQueueManager {
    
    static let shared = RequestQueueManager()
    private var session: Session?
    private var delayTimer: Timer?
    private var didPreFetchCount = 0
    private var dataList: [PhotoData] = [] {
        didSet {
            self.didPreFetchCount = 0
        }
    }
    private var willFetchData: PhotoData {
        return dataList[exist: didPreFetchCount] ?? dataList[dataList.count - 1]
    }
    
    private var mainQueueRunning = false {
        didSet {
            self.mainQueueDidChange()
        }
    }
    
    init() {
        self.session = self.customSession
    }
    
    func fetchPhotoImage(data: PhotoData, _ completionHandler: @escaping (PhotoData) -> ()) {
        self.mainQueueRunning = true
        self.requestImage(data) { photoData in
            completionHandler(photoData)
            self.mainQueueRunning = false
        }
        
    }
    
    func preFetchPhotos(dataList: [PhotoData]) {
        self.dataList = dataList
    }
}

extension RequestQueueManager {
    
    private func mainQueueDidChange() {
        self.delayTimer?.invalidate()
        self.delayTimer = nil
        if !self.mainQueueRunning && self.didPreFetchCount < self.dataList.count {
            self.delayTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { _ in
                self.delayTimer?.invalidate()
                self.startPreFetchPhotos(self.willFetchData)
            })
        }
    }
    
    private func startPreFetchPhotos(_ data: PhotoData) {
        if mainQueueRunning || (self.delayTimer?.isValid ?? false) || (self.didPreFetchCount >= self.dataList.count) {
            self.delayTimer?.invalidate()
            self.delayTimer = nil
            return
        }
        
        if data.cachedImage != nil {
            self.didPreFetchCount += 1
            self.startPreFetchPhotos(self.willFetchData)
            return
        }
        print("DispatchQueue: \(data.photo.id)")
        self.requestImage(data) { _ in
            self.didPreFetchCount += 1
            self.startPreFetchPhotos(self.willFetchData)
        }
    }
    
    private func requestImage(_ data: PhotoData, _ completionHandler: @escaping (PhotoData) -> ()) {
        
        session?.request(data.photo.thumbnailUrl).responseImage { response in
            switch response.result {
            case .success ( let image) :
                if response.request?.url?.absoluteString == data.photo.thumbnailUrl {
                    data.cacheImage(image: image)
                    completionHandler(data)
                }
            case .failure(let error):
                print(error)
                
            }
        }
    }
    
    private var customSession: Session {
        let manager = ServerTrustManager(evaluators: ["via.placeholder.com": DisabledTrustEvaluator()])
        let configuration = URLSessionConfiguration.af.default
        return Session(configuration: configuration, serverTrustManager: manager)
    }

}


extension Collection {
    subscript (exist index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
