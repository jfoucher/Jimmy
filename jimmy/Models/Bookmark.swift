//
//  Bookmark.swift
//  jimmy
//
//  Created by Jonathan Foucher on 19/02/2022.
//

import Foundation

struct Bookmark: Identifiable, Decodable, Encodable {
    var id: UUID
    
    var url: URL
    
    init (url: URL) {
        self.url = url
        self.id = UUID()
    }
}
