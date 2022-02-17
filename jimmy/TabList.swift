//
//  TabList.swift
//  jimmy
//
//  Created by Jonathan Foucher on 17/02/2022.
//

import Foundation
import SwiftUI

class TabList: ObservableObject {
    @Published var tabs: [Tab] = []
    @Published var activeTab: Tab
    @Published var loading: Bool = false
    
    init() {
        let tab = Tab(url: "localhost/");
        self.tabs = [tab]
        self.activeTab = tab
        self.load()
    }
    
    
    func load() {
        if let link = URL(string: "gemini://" + self.activeTab.url) {
            loading = true
            
            if let host = link.host {
                let client = Client(host: host, port: 1965)
                client.start()
                client.dataReceivedCallback = cb(error:message:)
                
                client.send(data: (link.relativeString + "\r\n").data(using: .utf8)!)
            }
        }
    }
    
    func back() {
        if self.activeTab.history.count > 1 {
            self.activeTab.history.removeLast()
            let url = self.activeTab.history.removeLast()
            self.activeTab.url = url;
            self.load()
        }
    }
    
    
    func cb(error: Error?, message: String?) {

        if let error = error {
            DispatchQueue.main.async {
                self.loading = false
                self.activeTab.content = [
                    LineView(line:"# ERROR", type: "text/gemini"),
                    LineView(line: error.localizedDescription, type: "text/plain")
                ]
            }
        }
        if let message = message {
            DispatchQueue.main.async {
                print("message received")
                print(message)
                let parsedMessage = ContentParser(content: message)
                
                print(parsedMessage.header.code)
                print(parsedMessage.header.contentType)
                self.loading = false
                if parsedMessage.header.code == 20 {
                    // Success
//                    print("success")
//                    print(parsedMessage.parsed)
                    self.activeTab.content = parsedMessage.parsed
                    self.tabs[self.tabs.firstIndex(of: self.activeTab)!] = self.activeTab
                    // Add to history
                    self.activeTab.history.append(self.activeTab.url)
                } else if parsedMessage.header.code == 31 {
                    // Redirect
                    print("redirect to")
                    print(parsedMessage.header.contentType.replacingOccurrences(of: "gemini://", with: ""))
                    self.activeTab.url = parsedMessage.header.contentType.replacingOccurrences(of: "gemini://", with: "")

                    self.load()
                } else {
                    self.activeTab.history.append(self.activeTab.url)
                    self.activeTab.content = [
                        LineView(line:"#" + String(parsedMessage.header.code) + " SERVER ERROR", type: "text/gemini"),
                        LineView(line: "The server responded with an error code", type: "text/plain")
                    ]
                }
            }
        }
    }
}
