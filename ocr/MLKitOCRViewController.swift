//
//  MLKitOCRViewController.swift
//  ocr
//
//  Created by SeoYeon Hong on 2021/11/23.
//

import UIKit
import MLKit

class MLKitOCRViewController: UIViewController {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var btnLibrary: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "MLKit OCR Test"
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
        let koreanOptions = KoreanTextRecognizerOptions()
        let textRecognizer = TextRecognizer.textRecognizer(options: koreanOptions)
        
        let visionImage = VisionImage(image: image)
        visionImage.orientation = image.imageOrientation
        
        textRecognizer.process(visionImage) { result, error in
            guard error == nil, let result = result else {
                //error handling
                print("error")
                return
            }
            //recognized text
            let Str = result.text
            print(Str)

            let datePattern  = "(?<year>(19|20)[0-9]{2})[-/.](?<month>(0[1-9]|1[0-2]))[-/.](?<date>(0[1-9]|1[0-9]|2[0-9]|3[0-1]))"
            let dateRegex = try? NSRegularExpression(pattern: datePattern, options: [])
            if let dateResult = dateRegex?.matches(in: Str, options: [], range: NSRange(location: 0, length: Str.count)) {
                let dateStrings = dateResult.map { (element) -> String in
                    let yearRange = Range(element.range(withName: "year"), in: Str)!
                    let monthRange = Range(element.range(withName: "month"), in: Str)!
                    let dateRange = Range(element.range(withName: "date"), in: Str)!
                    return "\(Str[yearRange])년 \(Str[monthRange])월 \(Str[dateRange])일"
                }
                print("날짜: \(dateStrings)")
                if !(dateStrings.isEmpty) {
                    DispatchQueue.main.async {
                        self.dateLabel.text = "날짜: \(dateStrings[0])"
                    }
                }
            }
            
            let pricePattern = "([0-9]{0,3})[,.]?([0-9]{0,3})[,.]([0-9]{3})"
            let priceRegex = try? NSRegularExpression(pattern: pricePattern, options: [])
            if let priceResult = priceRegex?.matches(in: Str, options: [], range: NSRange(location: 0, length: Str.count)) {
                let priceStrings = priceResult.map { (element) -> String in
                    let range = Range(element.range, in: Str)!
                    return String(Str[range]).replacingOccurrences(of: ",", with: "").replacingOccurrences(of: ".", with: "")
                }
                print("priceStrings: \(priceStrings)")
                if !(priceStrings.isEmpty) {
                    let priceInt = priceStrings.map { Int($0)!}
                    print("합계: \(priceInt.max()!)")
                    DispatchQueue.main.async {
                        self.priceLabel.text = "합계: \(priceInt.max()!)원"
                    }
                }
            }
        }
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

extension MLKitOCRViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
