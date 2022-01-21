//
//  ClovaOCRViewController.swift
//  ocr
//
//  Created by SeoYeon Hong on 2022/01/18.
//

import UIKit

class ClovaOCRViewController: UIViewController {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var btnLibrary: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "CLOVA OCR Test"
        picker.delegate = self
    }
    
    @IBAction func onClickBtn(_ sender: UIButton) {
        if sender == btnCamera {
            openCamera()
        } else {
            openLibrary()
        }
    }
    
    func openLibrary() {
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: false, completion: nil)
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
            picker.allowsEditing = true
            present(picker, animated: false, completion: nil)
        } else {
            print("Camera not available")
        }
    }
    
    func sendImage(image: UIImage) {
        var params: [String:Any] = [:]
        var imgParams: [String:Any] = [:]
        imgParams.updateValue("png", forKey: "format")
        imgParams.updateValue("demo", forKey: "name")
        params.updateValue([imgParams], forKey: "images")
        params.updateValue("\(UUID().uuidString)", forKey: "requestId")
        params.updateValue("V2", forKey: "version")
        params.updateValue(Int64(Date().timeIntervalSince1970 * 1000), forKey: "timestamp")
        
        APIManager.requestWithNameMultiPart(requestName: apigwURL, image: image, parameters: params, progress: false) { (isSuccess, responseData) in
            do {
                if (isSuccess) {
                    let decoder = JSONDecoder()
                    let str = try JSONSerialization.data(withJSONObject: responseData!, options: .prettyPrinted)
                    let data = try decoder.decode(ClovaOCRModel.self, from:str)
                    if data != nil {
                        let num = data.images[0].fields.count
                        for i in 0...num-1 {
                            let text = data.images[0].fields[i].inferText
                            let y = data.images[0].fields[i].boundingPoly.vertices[0].y
                            let height = data.images[0].fields[i].boundingPoly.vertices[2].y - data.images[0].fields[i].boundingPoly.vertices[0].y
                        }
                    }
                } else {
                    print("실패")
                }
            } catch {
                
            }
        }
    }
}

extension ClovaOCRViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imgView.image = pickedImage
            sendImage(image: pickedImage)

        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
