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
        let p = line.split(separator: " ")
        if p.count >= 2 {
            self.code = Int(p[0])!
            self.contentType = String(p[1]).replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "")
            return
        }
        if p.count >= 1 {
            self.code = Int(p[0])!
            self.contentType = "unknown"
            return
        }
        
        self.code = 50;
        self.contentType = "unknown"
    }
}
