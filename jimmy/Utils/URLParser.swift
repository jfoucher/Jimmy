//
//  LinkParser.swift
//  jimmy
//
//  Created by Jonathan Foucher on 18/02/2022.
//

import Foundation

class URLParser {
    var baseURL: URL
    var link: String
    
    init(baseURL: URL, link: String) {
        self.baseURL = baseURL
        self.link = link
    }
    
    func toAbsolute() -> URL {
        // If link start with gemini, replace everything
        if link.contains("gemini://") {
            if let url = URL(unicodeString: link) {
                return url
            }
        } else {
            if let parsedUrl = URL(unicodeString: link, relativeTo: baseURL) {
                return parsedUrl
            }
        }
        return URL(string: "gemini://about")!
    }
}
