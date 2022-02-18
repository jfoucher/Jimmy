//
//  LinkView.swift
//  jimmy
//
//  Created by Jonathan Foucher on 17/02/2022.
//

import SwiftUI

struct LinkView: View {
    
    var label: String
    var link: String
    var tab: Tab
    
    init(line: String, tab: Tab) {
        var line = line
        self.tab = tab
        if line.range(of: "=> ") != nil {
            line = line.replacingOccurrences(of: "=> ", with: "=>")
        }
        let range = line.range(of: "=>")
        let start = range!.upperBound
        
        var end = line.endIndex
        if let endRange = line.range(of: "\t") {
            end = endRange.upperBound
        } else if let endRange = line.range(of: " ") {
            end = endRange.upperBound
        }

        self.link = line[start..<end].trimmingCharacters(in: .whitespaces)
        self.label = String(line[end..<line.endIndex]).trimmingCharacters(in: .whitespaces)
        if end == line.endIndex {
            self.label = self.link
        }
        
    }
    
    var body: some View {
        Button (action: ac) {
            Text(label)
        }
        .frame(alignment: .leading)
        .buttonStyle(.plain)
        .foregroundColor(Color.blue)
        .padding(.bottom, 4)
        .help(link)
    }
    func ac(){
        // If link start with gemini, replace everything
        if self.link.contains("gemini://") {
            tab.url = self.link.replacingOccurrences(of: "gemini://", with: "")
        } else if let link = URL(string: "gemini://" + tab.url) {
            var url = "gemini://" + tab.url + self.link
            if self.link.starts(with: "/") {
                url = "gemini://" + link.host! + self.link
            }
            if let parsedUrl = URL(string: url) {
                
                print("link clicked")
                print(parsedUrl.host! + parsedUrl.relativePath)
                
                tab.url = parsedUrl.host! + parsedUrl.relativePath
            }
        }

        tab.load()
    }
}

