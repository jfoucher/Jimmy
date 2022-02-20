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
    var link: URL
    var original: String
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

        let linkString = line[start..<end].trimmingCharacters(in: .whitespaces)
        self.original = linkString
        self.link = URLParser(baseURL: tab.url, link: linkString).toAbsolute()
        self.label = String(line[end..<line.endIndex]).trimmingCharacters(in: .whitespaces)
        if end == line.endIndex {
            self.label = self.link.absoluteString
        }
    }
    
    var body: some View {
        Button (action: ac) {
            Image(systemName: "arrow.right")
            Text(label)
        }
        .frame(alignment: .leading)
        .buttonStyle(.plain)
        .foregroundColor(Color.blue)
        .padding(.bottom, 4)
        .help("This link goes to " + original)
        .contextMenu {
            LinkContextMenu(link: self.link)
        }
        .onHover(perform: { hovered in
            let loadingStatus = tab.loading ? "Loading " + tab.url.absoluteString : ""
            tab.status = hovered ? self.link.absoluteString.replacingOccurrences(of: "gemini://", with: "") : loadingStatus
        })
    }
    
    func ac(){
        // if link starts with // assume gemini
        tab.url = self.link
        
        print("link clicked: ", tab.url.absoluteString)

        tab.load()
    }
    

}

