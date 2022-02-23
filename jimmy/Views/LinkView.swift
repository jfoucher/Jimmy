//
//  LinkView.swift
//  jimmy
//
//  Created by Jonathan Foucher on 17/02/2022.
//

import SwiftUI

struct LinkView: View {
    @Environment(\.openURL) var openURL
    @EnvironmentObject private var tabList: TabList
    var label: String
    var link: URL
    var original: String
    var tab: Tab
    @State private var isHoveringURL: Bool = false
    
    init(line: String, tab: Tab) {
        var line = line.replacingOccurrences(of: "\n", with: "")
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
        if linkString.starts(with: "gemini://") {
            if let p = URL(string: linkString) {
                self.link = p
            }
        }
        
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
//        .help(original)
        .foregroundColor(Color.blue)
        .padding(.bottom, 4)
        .contextMenu {
            LinkContextMenu(link: self.link)
        }
        .onHover(perform: { hovered in
            let loadingStatus = tab.loading ? "Loading " + tab.url.absoluteString : ""
            tab.status = hovered ? self.link.absoluteString.replacingOccurrences(of: "gemini://", with: "") : loadingStatus
            
            // Checking if we hovering URL or not
            self.isHoveringURL = hovered
            DispatchQueue.main.async {
                if (self.isHoveringURL) {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
        })
    }
    
    func ac(){
        if (link.scheme == "http" || link.scheme == "https") {
            openURL(link)
        }
        // if link starts with // assume gemini
        tab.url = self.link
        
        
        
        print("link clicked: ", tab.url.absoluteString)
        
        tab.load()
    }
    
    
}

