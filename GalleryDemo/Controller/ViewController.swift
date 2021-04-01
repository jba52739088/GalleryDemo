//
//  ViewController.swift
//  GalleryDemo
//
//  Created by 黃恩祐 on 2021/3/24.
//

import UIKit
import Alamofire
import Moya

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func onClickButton(_ sender: UIButton) {
        if let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "MainVC") as? MainViewController {
            self.navigationController?.pushViewController(mainVC, animated: true)
        }
    }
    
}

