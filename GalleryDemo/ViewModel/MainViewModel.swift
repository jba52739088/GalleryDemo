//
//  MainViewModel.swift
//  GalleryDemo
//
//  Created by 黃恩祐 on 2021/3/28.
//

import Foundation
import Alamofire
import AlamofireImage

protocol MainViewModelInterface {
    
    var photoListSubject: Subject<[PhotoData]>{get}
    var getImageSubject: Subject<PhotoData>{get}
    
    func getPhotoList()
    func getPhotoImage(data: PhotoData)
}
class MainViewModel{
    
    let apiManager: APIManager!
    let photoListSubject = Subject<[PhotoData]>()
    let getImageSubject = Subject<PhotoData>()
    
    init(apiManager: APIManager = APIManager.shared) {
        self.apiManager = apiManager
    }
}
extension MainViewModel: MainViewModelInterface{
    
    func getPhotoList() {
        self.apiManager.getPhotoList { [weak self] result in
            if let subject = result {
                self?.photoListSubject.value = subject.value
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
