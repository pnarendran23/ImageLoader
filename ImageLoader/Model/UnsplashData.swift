//
//  UnsplashData.swift
//  ImageLoader
//
//  Created by PradheepNarendran on 18/04/24.
//

import Foundation

struct UnsplashData: Codable {
  let urls: URLObject
  var isImageLoaded: Bool? = false
}

struct URLObject: Codable {
    let regular: String
}

