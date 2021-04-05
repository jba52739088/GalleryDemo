//
//  GalleryAPITests.swift
//  GalleryDemoTests
//
//  Created by 黃恩祐 on 2021/4/5.
//

import XCTest
import Moya
@testable import GalleryDemo

class GalleryAPITests: XCTestCase {
    
    var apiManager: APIManager!
    
    override func setUp() {
        super.setUp()
        self.apiManager = APIManager.shared
    }
    
    func testGetPhotoList() {
        var expected = true
        self.apiManager.getPhotoList { result in
            if let subject = result,
               let dataList = subject.value{
                print("data count: \(dataList.count)")
                dataList.forEach { data in
                    let checkID = (data.photo.id != -1)
                    let checkTitle = (data.photo.title != "")
                    let checkUrl = (data.photo.thumbnailUrl != "")
                    if !checkID || !checkTitle || !checkUrl {
                        print("data error id: \(data.photo.id)")
                        expected = false
                    }
                }
                
            }
        }
        XCTAssert(expected)
    }
}
