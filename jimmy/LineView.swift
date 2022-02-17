//
//  LineView.swift
//  jimmy
//
//  Created by Jonathan Foucher on 17/02/2022.
//

import SwiftUI

struct LineView: View, Hashable {
    var line: String
    var type: String
    
    var id: UUID
    
    init(line: String, type: String) {
        self.line = line
        self.type = type
        self.id = UUID()
    }
    var body: some View {
        textView
    }
    
    @ViewBuilder
    private var textView: some View {
        if type.contains("text/gemini") {
            if let range = self.line.range(of: "=>"), range.lowerBound == self.line.startIndex {
                LinkView(line: self.line).frame(alignment: .leading)
            } else if let range = self.line.range(of: "* "), range.lowerBound == self.line.startIndex {
                Text(line.replacingOccurrences(of: "* ", with: "• ")).frame(maxWidth: .infinity, alignment: .leading).padding(.leading).padding(.bottom, 5)
            }  else if let range = self.line.range(of: "###"), range.lowerBound == self.line.startIndex {
                Text(line.replacingOccurrences(of: "#", with: "")).frame(maxWidth: .infinity, alignment: .leading).font(.system(size: 16, weight: .bold)).padding(.bottom, 5)
            } else if let range = self.line.range(of: "##"), range.lowerBound == self.line.startIndex {
                Text(line.replacingOccurrences(of: "#", with: "")).frame(maxWidth: .infinity, alignment: .leading).font(.system(size: 16, weight: .bold)).padding(.bottom, 5)
            } else if self.line[self.line.startIndex] == "#" {
                Text(line.replacingOccurrences(of: "#", with: "")).frame(maxWidth: .infinity, alignment: .leading).font(.system(size: 20, weight: .bold)).padding(.bottom, 5)
            } else {
                Text(line).frame(maxWidth: .infinity, alignment: .leading).padding(.bottom, 5)
            }
        } else {
            Text(line).frame(maxWidth: .infinity, alignment: .leading).padding(.bottom, 5)
        }
        
        
    }
}
