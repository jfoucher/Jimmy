//
//  LineView.swift
//  jimmy
//
//  Created by Jonathan Foucher on 17/02/2022.
//

import SwiftUI

struct LineView: View, Hashable {
    
    var line: String
    var data: Data
    var type: String
    var tab: Tab
    
    var id: UUID
    
    @State var answer = ""
    
    init(data: Data, type: String, tab:Tab) {
        self.line = String(decoding: data, as: UTF8.self)
        self.data = data
        
        self.type = type
        self.id = UUID()
        self.tab = tab
    }
    var body: some View {
        textView
    }
    
    @ViewBuilder
    private var textView: some View {
        
        if type.starts(with: "text/gemini") {
            if let range = self.line.range(of: "=>"), range.lowerBound == self.line.startIndex {
                LinkView(line: self.line, tab: tab).frame(alignment: .leading).padding(.leading, 12)
            } else if let range = self.line.range(of: "* "), range.lowerBound == self.line.startIndex {
                Text(line.replacingOccurrences(of: "* ", with: "• ")).frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 24).padding(.bottom, 5)
            }  else if let range = self.line.range(of: "###"), range.lowerBound == self.line.startIndex {
                Text(line.replacingOccurrences(of: "#", with: "")).frame(maxWidth: .infinity, alignment: .leading).font(.title3).padding(.bottom, 5)
            } else if let range = self.line.range(of: "##"), range.lowerBound == self.line.startIndex {
                Text(line.replacingOccurrences(of: "#", with: "")).frame(maxWidth: .infinity, alignment: .leading).font(.title2).padding(.bottom, 5)
            } else if self.line[self.line.startIndex] == "#" {
                Text(line.replacingOccurrences(of: "#", with: "")).frame(maxWidth: .infinity, alignment: .center).font(.title).padding(.bottom, 5).padding(.top, 12)
            } else {
                Text(line).frame(maxWidth: .infinity, alignment: .leading).padding(.bottom, 5).padding(.leading, 12)
            }
        } else if type.starts(with: "text/pre") {
            Text(line).frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 24).font(.system(size: 14, weight: .light).monospaced())
        } else if type.starts(with: "text/answer") {
            // Line for an answer. The question should be above this
            HStack {
                TextField("Answer", text: $answer)
                Button(action: send) {
                    Text("Send")
                }
            }
        }  else if type.starts(with: "image/") {
            // Line for an answer. The question should be above this
            if let img = NSImage(data: Data(self.data)) {
                Image(nsImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .layoutPriority(-1)
            } else {
                Image(systemName: "xmark")
            }
        } else {
            Text(line).frame(maxWidth: .infinity, alignment: .leading).padding(.bottom, 5).padding(.leading, 12)
        }
    }
    
    func send () {
        let url = tab.url + "?" + answer;
        tab.url = url;
        tab.load()
    }
    
    static func == (lhs: LineView, rhs: LineView) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
