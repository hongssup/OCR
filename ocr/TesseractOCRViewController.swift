//
//  TesseractOCRViewController.swift
//  ocr
//
//  Created by SeoYeon Hong on 2021/11/29.
//

import UIKit
import TesseractOCR

class TesseractOCRViewController: UIViewController, G8TesseractDelegate {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var btnLibrary: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "TesseractOCR Test"
        picker.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
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
    
    func getText(_ image: UIImage) {
        if let tesseract = G8Tesseract(language: "kor") {
            tesseract.delegate = self
            //tesseract.engineMode = .tesseractCubeCombined
            tesseract.engineMode = .tesseractOnly
            tesseract.pageSegmentationMode = .auto
            tesseract.image = image
            tesseract.recognize()
            textView.text = tesseract.recognizedText
        }
    }
    
    func progressImageRecognition(for tesseract: G8Tesseract) {
        print("progress \(tesseract.progress)%")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow() {
        self.view.frame.origin.y = -100
    }
    @objc func keyboardWillHide() {
        self.view.frame.origin.y = 0
    }
}

extension TesseractOCRViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imgView.contentMode = .scaleAspectFill
            imgView.image = pickedImage
            print("info: \(info)")
            getText(pickedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
