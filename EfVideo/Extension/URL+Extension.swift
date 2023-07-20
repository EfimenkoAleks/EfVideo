//
//  URL+Extension.swift
//  EfVideo
//
//  Created by user on 19.07.2023.
//

import Foundation

extension URL {
    func append(params: [String: String]) -> String {
        guard var urlComponents = URLComponents(string: absoluteString) else { return absoluteURL.absoluteString }

        // Create array of existing query items
        var queryItems: [URLQueryItem] = urlComponents.queryItems ?? []

        for (key, value) in params {
            // Create query item
            let queryItem = URLQueryItem(name: key, value: value)

            // Append the new query item in the existing query items array
            queryItems.append(queryItem)
        }

        // Append updated query items array in the url component object
        urlComponents.queryItems = queryItems

        // Returns the url from new url components
        return urlComponents.url?.absoluteString ?? ""
    }
}
