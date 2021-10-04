//
//  PhotoURLsResponse.swift
//  VirtualTourist
//
//  Created by Jonathan Mason on 04/10/2021.
//

import Foundation

/// Overall JSON response object for photo URLs of Flickr API.
struct PhotoURLsResponse: Codable {
    let stat: String
    let photos: PhotosResponseSubObject
}

/// Part of JSON response object for photo URLs of Flickr API.
struct PhotosResponseSubObject: Codable {
    let page: Int
    let pages: Int
    let perPage: Int
    let total: Int
    let photo: [PhotoURLResonseSubObject]
}

/// Part of JSON response object for photo URLs of Flickr API.
struct PhotoURLResonseSubObject: Codable {
    let title: String
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case url = "url_n"
    }
}
