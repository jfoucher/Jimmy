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
    var pre = false
    let tab: Tab
    
    init(content: String, tab: Tab) {
        var lines = content.replacingOccurrences(of: "\r", with: "").split(separator: "\n")
        self.tab = tab
        self.header = Header(line: String(lines[0]))
        
        lines.removeFirst()
        
        
        self.parsed = lines.map { str -> LineView? in
            if str.starts(with: "```") {
                self.pre = !self.pre
                return nil
            }
            
            return LineView(line: String(str), type: self.pre ? "text/pre" : self.header.contentType, tab: self.tab)
        }.filter { $0 != nil }.map { line -> LineView in
            return line!
        }
    }
}
