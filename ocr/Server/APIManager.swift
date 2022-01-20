//
//  APIManager.swift
//  ocr
//
//  Created by SeoYeon Hong on 2022/01/18.
//

import Foundation
import Alamofire

func LOG(_ msg: Any?, file: String = #file, function: String = #function, line: Int = #line) {
    #if DEBUG
        let fileName = file.split(separator: "/").last ?? ""
        let funcName = function.split(separator: "(").first ?? ""
        print("[\(fileName)] \(funcName)(\(line)): \(msg ?? "")")
    #endif
}

class APIManager: NSObject {
    internal static func requestWithNameMultiPart(requestName : String, image : UIImage, parameters : [String: Any]?, progress : Bool, response: @escaping (Bool, Any?) ->Void) {
        if progress {
            //LoadingPopupView.sharedInstance.startAnimation()
        }
        
        let url = URL(string: requestName)
        var hTTPHeaders = HTTPHeaders()
        hTTPHeaders["Content-Type"] = "multipart/form-data"
        hTTPHeaders["X-OCR-SECRET"] = secretKey
        
        LOG("request url : ['\(String(describing: url))]")
        LOG("REQUEST Params: '\(String(describing: parameters))")
        
        let jsonData = try? JSONSerialization.data(withJSONObject: parameters!, options: [])
        let jsonString = String(data: jsonData!, encoding: String.Encoding.utf8)
        
        AF.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append((jsonString?.data(using: .utf8))!, withName: "message")

            multipartFormData.append(image.pngData()!, withName: "file", fileName: "image.png", mimeType: "image/png")

        }, to: requestName, usingThreshold: .init(), method: .post, headers: hTTPHeaders).responseJSON { (responseData) in
            if progress {
                //LoadingPopupView.sharedInstance.stopAnimation()
            }
            LOG("Response url : ['\(requestName))]")
            LOG("JSON: '\(responseData)")
            
            switch responseData.result {
            case .success(let successData):
                response(true,successData)
                break;
            case .failure(let error):
                response(false,error)
                break;
            }
        }
    }
}
