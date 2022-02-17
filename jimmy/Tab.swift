//
//  Tab.swift
//  jimmy
//
//  Created by Jonathan Foucher on 17/02/2022.
//

import Foundation
import SwiftUI

class Tab: ObservableObject, Hashable {
    @Published var url = ""
    @Published var content: [LineView]
    @Published var id: UUID
    @Published var history: [String]
    
    init(url: String) {
        self.url = url
        self.content = [LineView(line: "nothing here", type:"text/plain")]
        self.id = UUID()
        self.history = []
    }
    
    static func == (lhs: Tab, rhs: Tab) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
