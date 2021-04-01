//
//  photoItem.swift
//  GalleryDemo
//
//  Created by 黃恩祐 on 2021/3/28.
//

import UIKit
import Alamofire
import AlamofireImage

protocol PhotoItemDelegate {
    func requestImage(_ data: PhotoData)
}

class PhotoItem: UICollectionViewCell {
    @IBOutlet weak var viewText: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lbImgID: UILabel!
    @IBOutlet weak var lbImgTitle: UILabel!
    
    private var delegate: PhotoItemDelegate?
    private(set) var photoData: PhotoData?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configItem(_ data: PhotoData, delegate: PhotoItemDelegate) {
        self.photoData = data
        self.delegate = delegate
        self.initView(data)
    }
    
    func updateItem(_ data: PhotoData) {
        if self.photoData?.photo.id == data.photo.id {
            self.photoData = data
            self.initView(data)
        }else {
            print("💔💔💔💔💔💔💔💔💔💔")
        }
    }
}

extension PhotoItem {
    
    private func initView(_ data: PhotoData) {
        self.lbImgID.text = "\(data.photo.id)"
        self.lbImgTitle.text = data.photo.title
        if data.cachedImage == nil {
            self.imgView.image = nil
            self.delegate?.requestImage(data)
        }else {
            self.imgView.image = data.cachedImage
        }
    }
    
    private func getImage(_ data: PhotoData) {
        if let image = data.cachedImage {
            print("get img from cachedImage, id: \(data.photo.id)")
            self.imgView.image = image
        }else {
            self.imgView.image = nil
            AF.request(data.photo.thumbnailUrl).responseImage { response in
                switch response.result {
                case .success(let image):
                    if response.request?.url?.absoluteString == self.photoData?.photo.thumbnailUrl {
                        self.imgView.image = image
                        self.photoData?.cacheImage(image: image)
                    }else if let photoData = self.photoData{
                        self.getImage(photoData)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
