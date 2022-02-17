//
//  ContentParser.swift
//  jimmy
//
//  Created by Jonathan Foucher on 17/02/2022.
//

import Foundation

import SwiftUI


class ContentParser {
    var parsed: [LineView] = []
    var header: Header
    
    init(content: String) {
//        print("parsing")
//        print(content.replacingOccurrences(of: "\n", with: "\\n\n").replacingOccurrences(of: "\r", with: "\\r\r"))
        var lines = content.replacingOccurrences(of: "\r", with: "").split(separator: "\n")
        
        self.header = Header(line: String(lines[0]))
        
        lines.removeFirst()
        
        
        self.parsed = lines.map { str -> LineView in
            return LineView(line: String(str), type: self.header.contentType)
        }
    }
}
