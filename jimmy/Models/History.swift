//
//  History.swift
//  jimmy
//
//  Created by Jonathan Foucher on 23/02/2022.
//


import Foundation

class History: ObservableObject {
    @Published var items: [URL]
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "history") {
            if let decoded = try? JSONDecoder().decode([URL].self, from: data) {
                items = decoded
                return
            }
        }
        
        items = []
    }
    
    private func load() -> [URL] {
        if let data = UserDefaults.standard.data(forKey: "history") {
            if let decoded = try? JSONDecoder().decode([URL].self, from: data) {
                return decoded
            }
        }
        return []
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: "history")
        }
    }
    
    func addItem(_ url: URL) {
        items = load()
        if !self.items.contains(url) {
            self.items.append(url)
            self.save()
        }
    }
    
    func remove(item: URL) {
        items = load()
        self.items = self.items.filter({$0.absoluteString != item.absoluteString})
        self.save();
    }
}
