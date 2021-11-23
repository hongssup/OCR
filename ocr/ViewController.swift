//
//  ViewController.swift
//  ocr
//
//  Created by SeoYeon Hong on 2021/11/19.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    @IBAction func onClickBtn(_ sender: Any) {
        let vc = MLKitOCRViewController(nibName: "MLKitOCRViewController", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

