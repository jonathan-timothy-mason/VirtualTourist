//
//  ErrorResponse.swift
//  VirtualTourist
//
//  Created by Jonathan Mason on 04/10/2021.
//

import Foundation

/// JSON response object for Flickr API error.
struct ErrorResponse: Codable {
    let stat: String
    let code: Int
    let message: String
}

extension ErrorResponse: LocalizedError {
    var errorDescription: String? {
        return message
    }
}
