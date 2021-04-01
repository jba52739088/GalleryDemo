//
//  Photo.swift
//  GalleryDemo
//
//  Created by 黃恩祐 on 2021/3/27.
//

import Foundation
import AlamofireImage



struct PhotoData {
    let photo: Photo
    let imageCache = AutoPurgingImageCache()
    
    var cachedImage: UIImage? {
        get {
            return self.getCachedImage()
        }
    }
    
    init(_ photo: Photo) {
        self.photo = photo
    }
    
    func cacheImage(image: UIImage) {
        imageCache.add(image, withIdentifier: self.photo.thumbnailUrl)
    }
    
    private func getCachedImage() -> UIImage? {
        return (imageCache.image(withIdentifier: self.photo.thumbnailUrl))
    }
}

struct Photo: Codable {
    let albumId, id: Int
    let title, url, thumbnailUrl: String
    
    enum Keys: String, CodingKey {
        case albumId
        case id
        case title
        case url
        case thumbnailUrl
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        albumId = try container.decodeIfPresent(Int.self, forKey: .albumId) ?? -1
        id = try container.decodeIfPresent(Int.self, forKey: .id) ?? -1
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        url = try container.decodeIfPresent(String.self, forKey: .url) ?? ""
        thumbnailUrl = try container.decodeIfPresent(String.self, forKey: .thumbnailUrl) ?? ""
    }
}
