//
//  APIManager.swift
//  GalleryDemo
//
//  Created by 黃恩祐 on 2021/4/5.
//

import Foundation
import Moya

class APIManager {
    
    static let shared = APIManager()
    let provider = MoyaProvider<APIService>()
    
    func getPhotoList(_ completion: @escaping (Subject<[PhotoData]>?) -> Void){
        provider.request(.getPhotos) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case .success(let response):
                do {
                    let data = response.data
                    let photoList = try JSONDecoder().decode([Photo].self, from: data)
                    let dataList: [PhotoData] = photoList.map { data in
                        return PhotoData(data)
                    }
                    completion(Subject(dataList))
                    RequestQueueManager.shared.preFetchPhotos(dataList: dataList)
                } catch(let error) {
                    print(error)
                }
            case .failure:
                completion(nil)
            }
        }
        
    }
}
