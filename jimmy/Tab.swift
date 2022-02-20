//
//  Tab.swift
//  jimmy
//
//  Created by Jonathan Foucher on 17/02/2022.
//

import Foundation
import SwiftUI

class Tab: ObservableObject, Hashable, Identifiable {
    @Published var url = ""
    @Published var content: [LineView]
    @Published var id: UUID
    @Published var loading: Bool = false
    @Published var history: [String]
    
    private var client: Client
    
    init(url: String) {
        self.url = url
        self.content = []
        self.id = UUID()
        self.history = []
        self.client = Client(host: "localhost", port: 1965)
    }
    
    static func == (lhs: Tab, rhs: Tab) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func load() {
        self.client.stop()
        if self.url.isEmpty {
            return
        }
        
        // When copying the link with "gemini://" in the beginning to Tab area -
        // remove the protocol and leave only the link
        if self.url.contains("gemini://") {
            self.url = self.url.replacingOccurrences(of: "gemini://", with: "")
        }

        if (self.url == "about") {
            if let asset = NSDataAsset(name: "home") {
                let data = asset.data
                if let text = String(bytes: data, encoding: .utf8) {
                    cb(error: nil, message: Data(("20 text/gemini\r\n" + text).utf8))
                    return
                }
            }
        }
        if let link = URL(string: "gemini://" + self.url) {
            self.loading = true
            if let host = link.host {
                self.client = Client(host: host, port: 1965)
                self.client.start()
                self.client.dataReceivedCallback = cb(error:message:)
                
                self.client.send(data: (link.relativeString + "\r\n").data(using: .utf8)!)
            }
        }
    }
    
    func back() {
        self.client.stop()
        if self.history.count > 1 {
            self.history.removeLast()
            let url = self.history.removeLast()
            self.url = url;
            self.load()
        }
    }
    
    func cb(error: Error?, message: Data?) {
        if let error = error {
            DispatchQueue.main.async {
                self.content = [
                    LineView(data: Data("# ERROR".utf8), type: "text/gemini", tab: self),
                    LineView(data: Data(error.localizedDescription.utf8), type: "text/plain", tab: self)
                ]
                
                self.loading = false
            }
        }
        
        if let message = message {
            DispatchQueue.main.async {
                let parsedMessage = ContentParser(content: message, tab: self)
                
                print(parsedMessage.header.code)
                print(parsedMessage.header.contentType)
                self.loading = false
                
                if parsedMessage.header.code >= 10 && parsedMessage.header.code < 20 {
                    // Input
                    self.content = [
                        LineView(data: Data(parsedMessage.header.contentType.utf8), type: "text/gemini", tab: self),
                        LineView(data: Data(), type: "text/answer", tab: self),
                    ]
                    // Add to history
                    self.history.append(self.url)
                } else if parsedMessage.header.code >= 20 && parsedMessage.header.code < 30 {
                    // Success
                    self.content = parsedMessage.parsed
                    // Add to history
                    self.history.append(self.url)
                } else if parsedMessage.header.code >= 30 && parsedMessage.header.code < 40 {
                    // Redirect
                    // TODO Handle relative URLs
                    self.url = parsedMessage.header.contentType.replacingOccurrences(of: "gemini://", with: "")

                    self.load()
                } else {
                    self.history.append(self.url)
                    self.content = [
                        LineView(data: Data(("#" + String(parsedMessage.header.code) + " SERVER ERROR").utf8), type: "text/gemini", tab: self),
                        LineView(data: Data("The server responded with an error code".utf8), type: "text/plain", tab: self),
                        LineView(data: Data(parsedMessage.header.contentType.utf8), type: "text/gemini", tab: self)
                    ]
                }
            }
        }
    }
}
