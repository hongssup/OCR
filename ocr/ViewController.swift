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
    @IBAction func onClickBtn(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            let vc = MLKitOCRViewController(nibName: "MLKitOCRViewController", bundle: nil)
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 2:
            let vc = TesseractOCRViewController(nibName: "TesseractOCRViewController", bundle: nil)
            self.navigationController?.pushViewController(vc, animated: true)
            break
        default:
            let vc = ClovaOCRViewController(nibName: "ClovaOCRViewController", bundle: nil)
            self.navigationController?.pushViewController(vc, animated: true)
            break
        }
    }
}

