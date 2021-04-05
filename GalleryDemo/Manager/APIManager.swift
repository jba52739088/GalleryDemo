//
//  APIManager.swift
//  GalleryDemo
//
//  Created by 黃恩祐 on 2021/3/25.
//

import Moya

enum APIManager {
    case getPhotos
}

extension APIManager: TargetType {
    var baseURL: URL {
        return URL(string: "https://jsonplaceholder.typicode.com") ?? URL(string: "about:blank")!
    }
    
    var path: String {
        switch self {
            case .getPhotos:
                return "/photos"
            }
    }
    
    var method: Method {
        switch self {
            case .getPhotos:
                return .get
            }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        return .requestPlain
    }
    
    var headers: [String : String]? {
        switch self {
            case .getPhotos:
                return nil
            }
    }
    
    
}

