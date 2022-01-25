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
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var productLabel: UILabel!
    
    let picker = UIImagePickerController()
    var textArr = [String]()
    var verticeArr = [[Float]]()
    var linesArr = [[String]]()
    
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
                        self.textArr = []
                        self.verticeArr = [[Float]]()
                        self.linesArr = [[String]]()
                        for i in 0...num-1 {
                            let text = data.images[0].fields[i].inferText
                            let y = data.images[0].fields[i].boundingPoly.vertices[0].y
                            let y2 = data.images[0].fields[i].boundingPoly.vertices[2].y
                            let height = data.images[0].fields[i].boundingPoly.vertices[2].y - data.images[0].fields[i].boundingPoly.vertices[0].y
                            self.textArr.append(text)
                            self.verticeArr.append([y, y2, height])
                        }
                        self.readLines()
                    }
                } else {
                    print("실패")
                }
            } catch {
                
            }
        }
    }
    
    func readLines() {
        linesArr.append([textArr[0]])
        var j = 0
        for i in 0...verticeArr.count-2 {
            //같은 줄
            if (verticeArr[i][0] <= verticeArr[i+1][0] + verticeArr[i+1][2]/2) && (verticeArr[i+1][0] + verticeArr[i+1][2]/2 <= verticeArr[i][1]) {
                linesArr[j].append(textArr[i+1])
            } else { //다음 줄
                linesArr.append([textArr[i+1]])
                j+=1
            }
        }
        print(linesArr)
        dateLabel.text = ""
        productLabel.text = ""
        for i in 0...linesArr.count-2 {
            if linesArr[i].contains("수량") {
                if priceCheck(linesArr[i+1].last!) {
                    for j in (i+1)...linesArr.count-1 {
                        if koCheck(linesArr[j][0]) {
                            print("상품: \(linesArr[j].first!), 가격: \(linesArr[j].last!)원")
                            DispatchQueue.main.async {
                                self.productLabel.text = (self.productLabel.text ?? "") + "상품: \(self.linesArr[j].first!), 가격: \(self.linesArr[j].last!)원\n"
                            }
                        } else {
                            print("상품: \(linesArr[j][1]), 가격: \(linesArr[j].last!)원")
                            DispatchQueue.main.async {
                                self.productLabel.text = (self.productLabel.text ?? "") + "상품: \(self.linesArr[j][1]), 가격: \(self.linesArr[j].last!)원\n"
                            }
                        }
                        if (linesArr[j+1].joined().contains("금액")) || linesArr[j+1].first!.contains("공급가") || linesArr[j+1].first!.contains("부가세") || linesArr[j+1].first!.contains("합계") {
                            break
                        }
                    }
                } else if priceCheck(linesArr[i+2].last!) {
                    for j in stride(from: i+1, through: linesArr.count-1, by: 2) {
                        if koCheck(linesArr[j][0]) {
                            print("상품: \(linesArr[j][0]), 가격: \(linesArr[j+1].last!)원")
                            DispatchQueue.main.async {
                                self.productLabel.text = (self.productLabel.text ?? "") + "상품: \(self.linesArr[j][0]), 가격: \(self.linesArr[j+1].last!)원\n"
                            }
                        } else {
                            print("상품: \(linesArr[j][1]), 가격: \(linesArr[j+1].last!)원")
                            DispatchQueue.main.async {
                                self.productLabel.text = (self.productLabel.text ?? "") + "상품: \(self.linesArr[j][1]), 가격: \(self.linesArr[j+1].last!)원\n"
                            }
                        }
                        if (linesArr[j+2].joined().contains("금액")) || linesArr[j+2].first!.contains("공급가") || linesArr[j+2].first!.contains("부가세") || linesArr[j+2].first!.contains("합계") {
                            break
                        }
                    }
                }
            }
        }
        for i in linesArr {
            let date = dateCheck(i.joined())
            if !(date.isEmpty) {
                print(date)
                DispatchQueue.main.async {
                    self.dateLabel.text = "날짜: \(date)"
                }
                break
            }
        }
    }
    
    func koCheck(_ text: String) -> Bool {
        let koPattern = "[가-힣]"
        let koRegex = try? NSRegularExpression(pattern: koPattern, options: [])
        if let koResult = koRegex?.matches(in: text, options: [], range: NSRange(location: 0, length: 1)) {
            let koStrings = koResult.map { (element) -> String in
                return text
            }
            if !(koStrings.isEmpty) {
                return true
            }
        }
        return false
    }
    
    func priceCheck(_ text: String) -> Bool {
        let pricePattern = "([0-9]{0,3})[,.]?([0-9]{0,3})[,.]([0-9]{3})"
        let priceRegex = try? NSRegularExpression(pattern: pricePattern, options: [])
        if let priceResult = priceRegex?.matches(in: text, options: [], range: NSRange(location: 0, length: text.count)) {
            let priceStrings = priceResult.map { (element) -> String in
                return text
            }
            if !(priceStrings.isEmpty) {
                return true
            }
        }
        return false
    }
    
    func dateCheck(_ text: String) -> String {
        let datePattern  = "(?<year>(19|20)[0-9]{2})[-/.](?<month>(0[1-9]|1[0-2]))[-/.](?<date>(0[1-9]|1[0-9]|2[0-9]|3[0-1]))"
        let dateRegex = try? NSRegularExpression(pattern: datePattern, options: [])
        if let dateResult = dateRegex?.matches(in: text, options: [], range: NSRange(location: 0, length: text.count)) {
            let dateStrings = dateResult.map { (element) -> String in
                let yearRange = Range(element.range(withName: "year"), in: text)!
                let monthRange = Range(element.range(withName: "month"), in: text)!
                let dateRange = Range(element.range(withName: "date"), in: text)!
                return "\(text[yearRange])년 \(text[monthRange])월 \(text[dateRange])일"
            }
            if !(dateStrings.isEmpty) {
                return dateStrings[0]
            }
        }
        return ""
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
