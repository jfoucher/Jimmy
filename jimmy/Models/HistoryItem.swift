//
//  HistoryItem.swift
//  jimmy
//
//  Created by Jonathan Foucher on 02/03/2022.
//

import Foundation

class HistoryItem: Codable, Equatable, Hashable {
    var url: URL
    var date: Date
    var snippet: String
    
    init(url: URL, date: Date, snippet: String) {
        self.url = url
        self.date = date
        self.snippet = snippet
    }
    
    static func == (lhs: HistoryItem, rhs: HistoryItem) -> Bool {
        return lhs.url == rhs.url
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
}
