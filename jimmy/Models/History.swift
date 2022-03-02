//
//  History.swift
//  jimmy
//
//  Created by Jonathan Foucher on 23/02/2022.
//


import Foundation

class History: ObservableObject {
    @Published var items: [HistoryItem]
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "history") {
            if let decoded = try? JSONDecoder().decode([HistoryItem].self, from: data) {
                items = decoded
                return
            }
        }
        
        items = []
    }
    
    private func load() -> [HistoryItem] {
        if let data = UserDefaults.standard.data(forKey: "history") {
            if let decoded = try? JSONDecoder().decode([HistoryItem].self, from: data) {
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
    
    func addItem(_ item: HistoryItem) {
        items = load()
        if self.items.contains(item) {
            let oldItem = self.items.first(where: {$0 == item})!
            oldItem.date = Date()
            self.items = self.items.map { i in
                return i == oldItem ? oldItem : i
            }
        } else {
            self.items.append(item)
        }
        
        self.save()
    }
    
    func remove(item: HistoryItem) {
        items = load()
        self.items = self.items.filter({$0 != item})
        self.save();
    }
    
    func clear() {
        self.items = []
        self.save()
    }
}
