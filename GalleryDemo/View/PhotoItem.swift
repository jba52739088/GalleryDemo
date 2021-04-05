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
            self.updateView(data)
        }else {
            print("💔💔💔💔💔💔💔💔💔💔")
        }
    }
}

extension PhotoItem {
    
    private func initView(_ data: PhotoData) {
        self.lbImgID.text = "\(data.photo.id)"
        self.lbImgTitle.text = data.photo.title
        if let tempImage = data.tempImage {
            self.imgView.image = tempImage
        }else {
            self.imgView.image = data.cachedImage
            self.delegate?.requestImage(data)
        }
    }
    
    private func updateView(_ data: PhotoData) {
        self.lbImgID.text = "\(data.photo.id)"
        self.lbImgTitle.text = data.photo.title
        self.imgView.image = data.cachedImage
        self.imgView.setNeedsDisplay()
    }
}
