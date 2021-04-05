//
//  MainViewModel.swift
//  GalleryDemo
//
//  Created by 黃恩祐 on 2021/3/28.
//

import Foundation
import Alamofire
import AlamofireImage
import Moya

protocol MainViewModelInterface {
    
    var photoListSubject: Subject<[PhotoData]>{get}
    var getImageSubject: Subject<PhotoData>{get}
    
    func getPhotoList()
    func getPhotoImage(data: PhotoData)
}
class MainViewModel{
    
    let provider = MoyaProvider<APIManager>()
    let photoListSubject = Subject<[PhotoData]>()
    let getImageSubject = Subject<PhotoData>()
    
    init() {
        
    }
}
extension MainViewModel: MainViewModelInterface{
    
    func getPhotoList() {
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
                    self?.photoListSubject.value = dataList
                    RequestQueueManager.shared.preFetchPhotos(dataList: dataList)
                } catch(let error) {
                    print(".....")
                    print(error)
                }
            case .failure:
                print("failure")
            }
        }
        
    }
    
    func getPhotoImage(data: PhotoData) {
        if data.cachedImage != nil {
            self.getImageSubject.value = data
        }else {
            RequestQueueManager.shared.fetchPhotoImage(data: data) { photoData in
                self.getImageSubject.value = data
            }
        }
    }
}
