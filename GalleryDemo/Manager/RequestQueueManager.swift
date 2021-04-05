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
    
    private(set) var imageCache = NSCache<NSURL, UIImage>()
    
    init() {
        self.session = self.customSession
    }
    
    /// 取圖片
    func fetchPhotoImage(data: PhotoData, _ completionHandler: @escaping (PhotoData) -> ()) {
        self.mainQueueRunning = true
        self.requestImage(data) { photoData in
            completionHandler(photoData)
            self.mainQueueRunning = false
        }
        
    }
    
    /// 預取使用者還沒滑到時的圖片
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
    
    /// 預取使用者還沒滑到時的圖片，當didPreFetchCount等於資料數後停止
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
        self.requestImage(data) { _ in
            self.didPreFetchCount += 1
            self.startPreFetchPhotos(self.willFetchData)
        }
    }
    
    
    /// 從url取得圖片
    /// - Parameters:
    ///   - data: PhotoData
    ///   - withEtag: 是否檢查Etag, 若第一次返回304但cache找不到圖片，則第二次不檢查
    ///   - completionHandler: 返回PhotoData之closure
    private func requestImage(_ data:  PhotoData, withEtag: Bool = true, _ completionHandler: @escaping (PhotoData) -> ()) {
        // Etag
        let headers: HTTPHeaders =
            withEtag
            ? ["if-None-Match":  self.loadEtagUserDefault(keyValue: "\(data.photo.id)")]
            : [:]
        
        session?.request(data.photo.thumbnailUrl, headers: headers).responseImage { response in
            switch response.result {
            case .success (let image):
                if let etag =  response.response?.allHeaderFields["Etag"] as? String {
                    self.saveEtagUserDefault(etagValue: etag, key: "\(data.photo.id)")
                }
                if let url = NSURL(string: response.request?.url?.absoluteString ?? "") {
                    self.imageCache.setObject(image, forKey: url)
                }
                if response.request?.url?.absoluteString == data.photo.thumbnailUrl {
                    data.cacheImage(image: image)
                    completionHandler(data)
                }
                return
            case .failure(let error):
                guard let statusCode = response.response?.statusCode else {
                    print(error)
                    return
                }
                if statusCode == 304 {
                    if data.cachedImage != nil {
                        completionHandler(data)
                    }else {
                        self.requestImage(data, withEtag: false) { (newData) in
                            completionHandler(newData)
                        }
                    }
                    
                    return
                }else {
                    print(error)
                }
                
            }
        }
        
    }
    
    /// 因圖片URL SSL過期，故自定義Session以取得圖片
    private var customSession: Session {
        let manager = ServerTrustManager(evaluators: ["via.placeholder.com": DisabledTrustEvaluator()])
        let configuration = URLSessionConfiguration.af.default
        return Session(configuration: configuration, serverTrustManager: manager)
    }
    
    /// 將Etag存至UserDefault
    private func saveEtagUserDefault(etagValue: String, key: String) -> Void {
        UserDefaults.standard.set(etagValue, forKey:key)
        UserDefaults.standard.synchronize()
    }
    
    /// 至UserDefault取出Etag
    private func loadEtagUserDefault(keyValue: String) -> String {
        return UserDefaults.standard.object(forKey: keyValue) as? String ?? "0"
    }
    
}


extension Collection {
    subscript (exist index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
