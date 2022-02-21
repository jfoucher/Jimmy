//
//  Header.swift
//  jimmy
//
//  Created by Jonathan Foucher on 17/02/2022.
//

import Foundation


class Header {
    var code: Int
    var contentType: String
    
    init(line: String) {
        if line .isEmpty {
            self.code = 50
            self.contentType = "text/plain"
        } else {
            var p = line.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "").split(separator: " ")
            self.code = Int(p.removeFirst()) ?? 50
            
            self.contentType = p.joined(separator: " ")
        }
    }
}
