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
        print("parsing", self.baseURL, self.link)
        var link = self.link
        var base = self.baseURL
        var absoluteUrl = ""
        if link.starts(with: "//") {
            link = link.replacingOccurrences(of: "//", with: "gemini://")
        }
        if !link.starts(with: "/") && !link.starts(with: "./") {
            link = "./" + link
        }
        if link.starts(with: "./") {
            link = link.replacingOccurrences(of: "./", with: "")
            let i = base.lastIndex(of: "/") ?? base.endIndex
            base = String(base[base.startIndex..<i]) + "/"
        }
        // If link start with gemini, replace everything
        if link.contains("gemini://") {
            absoluteUrl = link.replacingOccurrences(of: "gemini://", with: "")
        } else if let lnk = URL(string: "gemini://" + base) {
            var url = "gemini://" + base + link
            if link.starts(with: "/") {
                url = "gemini://" + lnk.host! + link
            }
            if let parsedUrl = URL(string: url) {
                absoluteUrl = parsedUrl.absoluteString.replacingOccurrences(of: "gemini://", with: "")
            }
        }
        
        print("absoluteURL", absoluteUrl)
        
        return absoluteUrl
    }
}
