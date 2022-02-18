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
        self.link = URLParser(baseURL: tab.url, link: linkString).toAbsolute()
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
        .contextMenu {
            Button(action: newTab)
            {
                Label("Open in new tab", systemImage: "plus.rectangle")
            }
                .buttonStyle(.plain)
        }
    }
    
    func ac(){
        // if link starts with // assume gemini
        tab.url = self.link
        
        print("link clicked: ", tab.url)

        tab.load()
    }
    
    func newTab() {
        let nt = Tab(url: self.link)
        tabList.tabs.append(nt)
        tabList.activeTabId = nt.id
        nt.load()
    }
}

