//
//  ImageGridViewModel.swift
//  ImageLoader
//
//  Created by PradheepNarendran on 20/04/24.
//

import Foundation
import UIKit


class ImageGridViewModel {
  // Closure to notify the view controller about data updates
  var onDataUpdate: ((Result<[UnsplashData], Error>) -> Void)?
  
  // Flag to track if all data is loaded
  var isAllLoaded = false
  
  // Flag to track if data is currently being loaded
  var isLoading = false
  
  // Array to store index paths of newly inserted items
  var indexPaths: [IndexPath] = []
  
  // Array to store image data
  var images: [UnsplashData] = []
  
  // Cache to store downloaded images
  let cache = NSCache<NSString, UIImage>()
  
  // Current page number for paginated API requests
  var currentPage = 1
  
  // Number of items per page for paginated API requests
  let pageSize = 100
  
  // Function to fetch data from the API
  func fetchData() {
    // Check if data is already being loaded
    guard !isLoading else { return }
    isLoading = true
    
    // Construct URL for API request with pagination parameters
    // Make network request to fetch data for the given page
    guard let url = URL(string: "\(URLConstants.URLEndpoint)/?page=\(currentPage)&per_page=\(pageSize)&client_id=\(URLConstants.clientID)"), !isAllLoaded else { return }
    NetworkManager.shared.request(url: url) { (result: Result<[UnsplashData], Error>) in
      switch result {
      case .success(let responseData):
        // Update flags and data arrays
        self.isAllLoaded = responseData.isEmpty
        let startIndex = self.images.count
        self.images.append(contentsOf: responseData)
        self.currentPage += 1
        let endIndex = self.images.count - 1
        // Generate index paths for newly inserted items
        self.indexPaths = (startIndex...endIndex).map { IndexPath(item: $0, section: 0) }
        self.isLoading = false
        // Notify the view controller about data update
        self.onDataUpdate?(.success(responseData))
      case .failure(let error):
        // Handle failure
        print("Error: \(error)")
        self.onDataUpdate?(.failure(error))
      }
    }
  }
}
