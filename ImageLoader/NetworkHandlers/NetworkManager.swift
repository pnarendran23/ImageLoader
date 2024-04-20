//
//  NetworkManager.swift
//  ImageLoader
//
//  Created by PradheepNarendran on 18/04/24.
//

import Foundation
import Foundation
import SystemConfiguration

public class Reachability {
  static let shared = Reachability()
  
  func isConnectedToNetwork(completion: @escaping (Bool) -> Void){
        let url = URL(string: "https://google.com/")
        var request = URLRequest(url: url!)
        request.httpMethod = "HEAD"
    let config = URLSessionConfiguration.default
    config.waitsForConnectivity = true
    
    let session = URLSession(configuration: config)

      let data = session.dataTask(with: request, completionHandler: {data, response, error in
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 200 {
                completion(true)
            }
        }
        else
        {         
          completion(false)
        }
      })
      data.resume()
    }
}

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case invalidData
}

class NetworkManager {
    static let shared = NetworkManager()
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil

        config.timeoutIntervalForRequest = 5
        config.timeoutIntervalForResource = 5
        self.session = URLSession(configuration: config)
    }
    
    func request<T: Decodable>(url: URL, completion: @escaping (Result<T, Error>) -> Void) {
        let task = session.dataTask(with: url) { data, response, error in
            guard let data = data else {
              completion(.failure(NetworkError.invalidData))
                return
            }
            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(NetworkError.invalidData))
            }
        }
        task.resume()
    }
}
