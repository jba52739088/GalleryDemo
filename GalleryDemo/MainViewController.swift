//
//  MainViewController.swift
//  GalleryDemo
//
//  Created by 黃恩祐 on 2021/3/27.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var viewModel: MainViewModelInterface?
    private var photoList: [PhotoData] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
        self.subscriptVM()
    }
}

extension MainViewController {
    
    private func initView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(nibName: "PhotoItem", bundle: nil), forCellWithReuseIdentifier: "imgItem")
    }
    
    private func subscriptVM() {
        self.viewModel = MainViewModel()
        
        self.viewModel?.photoListSubject.bind({ [weak self] photoList in
            self?.photoList = photoList ?? []
        })
        
        self.viewModel?.getImageSubject.bind({ [weak self] _data in
            guard let photoData = _data else { return }
            self?.onGetImageData(photoData)
        })
        
        self.viewModel?.getPhotoList()
    }
    
    private func onGetImageData(_ data: PhotoData) {
        if let cell = self.collectionView.cellForItem(at: IndexPath(item: data.photo.id - 1, section: 0)) as? PhotoItem,
           cell.photoData?.photo.id == data.photo.id {
            cell.updateItem(data)
        }else {
            self.collectionView.visibleCells.forEach { _item in
                if let correctItem = _item as? PhotoItem,
                   correctItem.photoData?.photo.id == data.photo.id {
                    correctItem.updateItem(data)
                }
            }
        }
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = collectionView.dequeueReusableCell(withReuseIdentifier: "imgItem", for: indexPath) as? PhotoItem
            else { return UICollectionViewCell() }
        item.configItem(self.photoList[indexPath.item], delegate: self)
        
        return item
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalWidth = min(self.view.frame.width, self.view.frame.height)
        return CGSize(width: totalWidth / 4, height: totalWidth / 4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
//    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            if !collectionView.indexPathsForVisibleItems.contains(indexPath) {
//                print("cancel fetch item: \(indexPath.item)")
//                self.viewModel?.cancelFetchImage(data: self.photoList[indexPath.item])
//            }
//        }
//    }
}

extension MainViewController: PhotoItemDelegate {
    func requestImage(_ data: PhotoData) {
        self.viewModel?.getPhotoImage(data: data)
    }
}
