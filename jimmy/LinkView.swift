//
//  LinkView.swift
//  jimmy
//
//  Created by Jonathan Foucher on 17/02/2022.
//

import SwiftUI

struct LinkView: View {
    @EnvironmentObject private var tabList: TabList
    
    var label: String
    var link: String
    
    init(line: String) {
        var line = line
        print("line", line)
        
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
    }
    func ac(){
        // If link start with gemini, replace everything
        if self.link.contains("gemini://") {
            tabList.activeTab.url = self.link.replacingOccurrences(of: "gemini://", with: "")
        } else if let link = URL(string: "gemini://" + tabList.activeTab.url) {
            var url = "gemini://" + tabList.activeTab.url + self.link
            if self.link.starts(with: "/") {
                url = "gemini://" + link.host! + self.link
            }
            if let parsedUrl = URL(string: url) {
                
                print("link clicked")
                print(parsedUrl.host! + parsedUrl.relativePath)
                
                tabList.activeTab.url = parsedUrl.host! + parsedUrl.relativePath
            }
        }

        tabList.load()
    }
}

