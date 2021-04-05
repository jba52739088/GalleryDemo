//
//  Subject.swift
//  GalleryDemo
//
//  Created by 黃恩祐 on 2021/3/28.
//

import Foundation

class Subject<T> {
    
    typealias Listener = (T?) -> Void
    
    var listener: Listener?
    
    func bind(_ listener: Listener?) {
        self.listener = listener
    }
    
    func bindAndFire(_ listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
    
    var value: T? {
        didSet {
            listener?(value)
        }
    }
    
    init(_ v: T? = nil) {
        value = v
    }
}
