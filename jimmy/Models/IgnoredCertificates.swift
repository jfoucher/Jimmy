//
//  IgnoredCertificates.swift
//  jimmy
//
//  Created by Jonathan Foucher on 23/02/2022.
//

import Foundation


class IgnoredCertificates: ObservableObject {
    @Published var items: [String]
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "ignored-certs") {
            if let decoded = try? JSONDecoder().decode([String].self, from: data) {
                items = decoded
                return
            }
        }

        items = []
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: "ignored-certs")
        }
    }
    
    func remove(item: String) {
        self.items = self.items.filter({$0 != item})
        self.save();
    }
}
