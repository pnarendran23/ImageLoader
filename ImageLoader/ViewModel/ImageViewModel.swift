//
//  ImageViewModel.swift
//  ImageLoader
//
//  Created by PradheepNarendran on 18/04/24.
//

import Foundation
import UIKit

class ImageViewModel {
  private var imageModel: ImageDataModel  
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  
  init(imageModel: ImageDataModel) {
    self.imageModel = imageModel
  }
  
  var imageURL: URL {
    return imageModel.imageURL
  }
  
  func loadImage(indexPath: IndexPath) async -> (UIImage?, URL, IndexPath)? {
    do {
      let config = URLSessionConfiguration.default
      config.waitsForConnectivity = true
      
      let session = URLSession(configuration: config)
      let (data, _) = try await session.data(from: imageModel.imageURL)
      if let image = UIImage(data: data) {
        return (image, imageModel.imageURL, indexPath)
      }
    } catch {
      print("Failed to load image from URL: \(imageModel.imageURL), error: \(error)")
    }
    
    return (nil, imageModel.imageURL, indexPath)
  }
}
