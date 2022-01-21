//
//  ClovaOCRModel.swift
//  ocr
//
//  Created by SeoYeon Hong on 2022/01/20.
//

struct ClovaOCRModel: Codable {
    let images: [Fields]
}

struct Fields: Codable {
    let fields: [ImageField]
}

struct ImageField: Codable {
    let inferText: String //OCR text
    var boundingPoly: BoundingPoly
}

struct BoundingPoly:Codable {
    let vertices: [Vertices]
}

struct Vertices: Codable {
    let x: Float
    let y: Float
}
