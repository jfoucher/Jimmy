//
//  Tab.swift
//  jimmy
//
//  Created by Jonathan Foucher on 17/02/2022.
//

import Foundation
import SwiftUI
import CryptoKit

class Tab: ObservableObject, Hashable, Identifiable {
    @Published var url: URL
    @Published var content: [LineView]
    @Published var id: UUID
    @Published var loading: Bool = false
    @Published var history: [URL]
    @Published var status = ""
    @Published var icon = ""
    @Published var fontSize = 14.0

    
    private var client: Client
    
    init(url: URL) {
        self.url = url
        self.content = []
        self.id = UUID()
        self.history = []
        self.client = Client(host: "localhost", port: 1965, validateCert: true)
    }
    
    static func == (lhs: Tab, rhs: Tab) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func stop() {
        self.client.stop()
        self.loading = false;
    }
    
    func load() {
        self.client.stop()
        
        guard let host = self.url.host else {
            return
        }
        
        self.icon = Emojis(host).emoji
        
        if (host == "about") {
            if let asset = NSDataAsset(name: "home") {
                let data = asset.data
                if let text = String(bytes: data, encoding: .utf8) {
                    cb(error: nil, message: Data(("20 text/gemini\r\n" + text).utf8))
                    return
                }
            }
        }
        
        
        self.loading = true
        self.status = "Loading " + url.absoluteString
        
        self.client = Client(host: host, port: 1965, validateCert: host != "gemini.6px.eu")
        self.client.start()
        self.client.dataReceivedCallback = cb(error:message:)
        
        self.client.send(data: (url.absoluteString + "\r\n").data(using: .utf8)!)
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
        DispatchQueue.main.async {
            self.content = []
        }
        if let error = error {
            print("request error", (error as NSError).hash)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.content = [
                    LineView(data: Data("# ERROR".utf8), type: "text/gemini", tab: self),
                    LineView(data: Data(error.localizedDescription.utf8), type: "text/plain", tab: self)
                ]
                
                self.loading = false
                self.status = ""
            }
        }
        
        if let message = message {
            // Parse the request response
            let parsedMessage = ContentParser(content: message, tab: self)
            print(parsedMessage.header.code)
            print(parsedMessage.header.contentType)
            if (20...29).contains(parsedMessage.header.code) && !parsedMessage.header.contentType.starts(with: "text/") && !parsedMessage.header.contentType.starts(with: "image/") {
                // If we have a success response but not of a type we can handle, let ContentParser trigger the file save dialog
                self.loading = false
                self.status = ""
                return
            }
            DispatchQueue.main.async {
                // Clear the contents now so that everything refreshes when we load new content
                self.content = []
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                // Clear status bar
                self.status = ""
                // stop loading indicator
                self.loading = false
                
                if (10...19).contains(parsedMessage.header.code) {
                    // Input, show answer input box
                    self.content = [
                        LineView(data: Data(parsedMessage.header.contentType.utf8), type: "text/gemini", tab: self),
                        LineView(data: Data(), type: "text/answer", tab: self),
                    ]
                    // Add to history
                    self.history.append(self.url)
                } else if (20...29).contains(parsedMessage.header.code) {
                    // Success, show parsed content
                    self.content = parsedMessage.parsed
                    // Add to history
                    self.history.append(self.url)
                } else if (30...39).contains(parsedMessage.header.code) {
                    // Redirect
                    if let redirect = URL(string: parsedMessage.header.contentType) {
                        self.url = redirect
                        self.load()
                    }
                } else {
                    // Server Error
                    self.history.append(self.url)
                    self.content = [
                        LineView(data: Data(("#" + String(parsedMessage.header.code) + " SERVER ERROR").utf8), type: "text/gemini", tab: self),
                        LineView(data: Data(), type: "text/gemini", tab: self),
                        LineView(data: Data(("#" + parsedMessage.header.contentType).utf8), type: "text/gemini", tab: self)
                    ]
                }
            }
        }
    }
}

