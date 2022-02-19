//
//  Bookmarks.swift
//  jimmy
//
//  Created by Jonathan Foucher on 19/02/2022.
//

import Foundation

class Bookmarks: ObservableObject {
    @Published var items: [Bookmark]
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "bookmarks") {
            if let decoded = try? JSONDecoder().decode([Bookmark].self, from: data) {
                items = decoded
                return
            }
        }

        items = []
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: "bookmarks")
        }
    }
    
    func remove(bookmark: Bookmark) {
        self.items = self.items.filter({$0.id != bookmark.id})
        self.save();
    }
}
