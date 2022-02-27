//
//  Tab.swift
//  jimmy
//
//  Created by Jonathan Foucher on 17/02/2022.
//

import Foundation
import SwiftUI
import CryptoKit
import Network

class Tab: ObservableObject, Hashable, Identifiable {
    var certs: IgnoredCertificates
    @Published var url: URL
    @Published var content: [LineView]
    @Published var textContent: NSAttributedString
    @Published var id: UUID
    @Published var loading: Bool = false
    @Published var history: [URL]
    @Published var status = ""
    @Published var icon = ""
    @Published var fontSize = 16.0
    private var globalHistory: History = History()
    
    
    private var client: Client
    
    init(url: URL) {
        self.url = url
        self.content = []
        self.id = UUID()
        self.history = []
        self.client = Client(host: "localhost", port: 1965, validateCert: true)
        self.certs = IgnoredCertificates()
        self.textContent = NSAttributedString(string: "")
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
        self.status = ""
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
        
        
        DispatchQueue.main.async {
            self.loading = true
            self.status = "Loading " + self.url.absoluteString.replacingOccurrences(of: "gemini://", with: "")
        }
        
        self.client = Client(host: host, port: 1965, validateCert: !certs.items.contains(url.host ?? ""))
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
    
    func cb(error: NWError?, message: Data?) {
        DispatchQueue.main.async {
            self.loading = false
            self.status = ""
            self.content = []
            self.textContent = NSAttributedString(string: "")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            
            if let error = error {
                self.history.append(self.url)
                self.globalHistory.addItem(self.url)
                
                if error == NWError.tls(-9808) {
                    
                    self.content = [
                        LineView(data: Data("# Invalid certificate".utf8), type: "text/gemini", tab: self),
                        
                        LineView(data: Data(("### 😔 The SSL certificate for " + Emojis(self.url.host ?? "").emoji + " " + (self.url.host ?? "") + " is invalid.").utf8), type: "text/gemini", tab: self),
                        
                        LineView(data: Data("".utf8), type: "text/ignore-cert", tab: self)
                    ]
                    
                } else if error == NWError.dns(-65554) {
                    
                    self.content = [
                        LineView(data: Data("# Could not connect".utf8), type: "text/gemini", tab: self),
                        LineView(data: Data(("### Please make sure your internet conection is working properly.").utf8), type: "text/gemini", tab: self)
                    ]
                    
                } else {
                    
                    self.content = [
                        LineView(data: Data("# ERROR".utf8), type: "text/gemini", tab: self),
                        LineView(data: Data(error.localizedDescription.utf8), type: "text/plain", tab: self)
                    ]
                    
                }
                
            } else if let message = message {
                // Parse the request response
                let parsedMessage = ContentParser(content: message, tab: self)
                //            print(parsedMessage.header.code)
                //            print(parsedMessage.header.contentType)
                if (20...29).contains(parsedMessage.header.code) && !parsedMessage.header.contentType.starts(with: "text/") && !parsedMessage.header.contentType.starts(with: "image/") {
                    // If we have a success response but not of a type we can handle, let ContentParser trigger the file save dialog
                    // Add to history
                    self.history.append(self.url)
                    self.globalHistory.addItem(self.url)
                    return
                }
                
                if (10...19).contains(parsedMessage.header.code) {
                    // Input, show answer input box
                    self.content = [
                        LineView(data: Data(parsedMessage.header.contentType.utf8), type: "text/gemini", tab: self),
                        LineView(data: Data(), type: "text/answer", tab: self),
                    ]
                    // Add to history
                    self.history.append(self.url)
                    self.globalHistory.addItem(self.url)
                } else if (20...29).contains(parsedMessage.header.code) {
                    // Success, show parsed content
                    self.content = parsedMessage.parsed
                    self.textContent = parsedMessage.attrStr
                    // Add to history
                    self.history.append(self.url)
                    self.globalHistory.addItem(self.url)
                } else if (30...39).contains(parsedMessage.header.code) {
                    // Redirect
                    if let redirect = URL(string: parsedMessage.header.contentType) {
                        self.url = redirect
                        self.load()
                    }
                } else if parsedMessage.header.code == 51 {
                    // Server Error
                    self.history.append(self.url)
                    self.globalHistory.addItem(self.url)
                    
                    var msg = "### Sorry, the page " + self.url.path + " was not found"
                    if let host = self.url.host {
                        msg = "### Sorry, the page " + self.url.path + " was not found on " + host
                    }
                    self.content = [
                        LineView(data: Data(("#" + String(parsedMessage.header.code) + " Not found").utf8), type: "text/gemini", tab: self),
                        LineView(data: Data(), type: "text/gemini", tab: self),
                        LineView(data: Data(msg.utf8), type: "text/gemini", tab: self)
                    ]
                } else {
                    // Server Error
                    self.history.append(self.url)
                    self.content = [
                        LineView(data: Data(("#" + String(parsedMessage.header.code) + " Server Error").utf8), type: "text/gemini", tab: self),
                        LineView(data: Data(), type: "text/gemini", tab: self),
                        LineView(data: Data(("#" + parsedMessage.header.contentType).utf8), type: "text/gemini", tab: self)
                    ]
                }
            }
        }
    }
}

