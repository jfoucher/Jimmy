//
//  LinkParser.swift
//  jimmy
//
//  Created by Jonathan Foucher on 18/02/2022.
//

import Foundation


class URLParser {
    var baseURL: String
    var link: String
    
    init(baseURL: String, link: String) {
        self.baseURL = baseURL
        self.link = link
    }
    
    func toAbsolute() -> String {
        // If link start with gemini, replace everything
        if link.contains("gemini://") {
            return link.replacingOccurrences(of: "gemini://", with: "")
        } else if let root = URL(string: "gemini://" + baseURL) {
            if let parsedUrl = URL(string: link, relativeTo: root) {
                return parsedUrl.absoluteString.replacingOccurrences(of: "gemini://", with: "")
            }
        }
        
        return baseURL
    }
}
