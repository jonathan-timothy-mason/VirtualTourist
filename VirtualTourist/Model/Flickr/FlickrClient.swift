//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Jonathan Mason on 04/10/2021.
//

import Foundation

/// Provides access to Flickr API.
class FlickrClient {

    /// Endpoints of Flickr API.
    enum Endpoints {
        
        static let baseURL = "https://www.flickr.com/services/rest/?method=flickr.photos.search"
        static let apiKey = "xxx"
        
        case getPhotoURLsForLocation(Double, Double)
        
        /// Construct endpoint according to current case.
        /// - Returns: Endpoint URL as string.
        func constructURL() -> String {
            switch(self) {
            case .getPhotoURLsForLocation(let latitude, let longitude):
                // extras=url_t: include URL for thumbnail-sized photo (100w x 75h). (https://www.flickr.com/services/api/flickr.photos.getSizes.html).
                // nojsoncallback=1: exclude top-level function wrapper from JSON response (https://www.flickr.com/services/api/response.json.html).
                return "\(Endpoints.baseURL)&api_key=\(Endpoints.apiKey)&lat=\(latitude)&lon=\(longitude)&page=1&per_page=25&format=json&nojsoncallback=1&extras=url_t"
            }
        }
        
        /// Endpoint of current case.
        /// - Returns: Endpoint URL.
        var url: URL {
            return URL(string: constructURL())!
        }
    }

    /// Send GET request to retrieve photo URLs for supplied location from Flickr API.
    /// - Parameters:
    ///   - latitude: Latitude of photo URLs to retrieve.
    ///   - longitude: Lomgitude of photo URLs to retrieve.
    ///   - completion: Function to call upon completion.
    class func getPhotoURLsForLocation(latitude: Double, longitude: Double, completion: @escaping ([String], Error?) -> Void) {
        taskForGetRequest(url: Endpoints.getPhotoURLsForLocation(latitude, longitude).url, responseType: PhotoURLsResponse.self) { response, error in
            if let response = response {
                // Extract array of URLs from response.
                // Based on "Transforming a Dictionary with Swift Map" of "How to Use Swift Map to Transforms Arrays, Sets, and Dictionaries" by Bart Jacobs:
                // https://cocoacasts.com/swift-essentials-1-how-to-use-swift-map-to-transforms-arrays-sets-and-dictionaries
                let urls = response.photos.photo.map { $0.url }
                
                completion(urls, nil)
            }
            else {
                completion([], error)
            }
        }
    }
    
    /// Send GET request.
    /// - Parameters:
    ///   - url: URL endpoint of API.
    ///   - responseType: Type of JSON response object.
    ///   - completion: Function to call upon completion.
    class func taskForGetRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(responseType, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    let errorResponseObject = try decoder.decode(ErrorResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(nil, errorResponseObject)
                    }
                }
                catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
    }
}
