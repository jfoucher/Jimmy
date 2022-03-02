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
    @Published var ignoredCertValidation = false
    @Published var fontSize = 16.0
    var emojis = Emojis()
    private var globalHistory: History = History()
    
    
    private var client: Client
    private var ranges: [Range<String.Index>]?
    private var selectedRangeIndex = 0
    
    
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
        selectedRangeIndex = 0
        self.ranges = []
        guard let host = self.url.host else {
            return
        }
        
        
        
        self.icon = emojis.emoji(host)
        
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
            self.ignoredCertValidation = self.certs.items.contains(self.url.host ?? "")
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
                
                
                let contentParser = ContentParser(content: Data([]), tab: self)
                if error == NWError.tls(-9808) || error == NWError.tls(-9813) {
                    
                    
                    let ats = NSMutableAttributedString(string: String(localized: "Invalid certificate"), attributes: contentParser.title1Style)
                    
                    let format = NSLocalizedString("😔 The SSL certificate for %@%@ is invalid.", comment:"SSL certificate invalid for this host. first argument is the emoji, the second the host name")

                    let ats2 = NSMutableAttributedString(string: String(format: format, self.emojis.emoji(self.url.host ?? ""), (self.url.host ?? "")), attributes: contentParser.title3Style)
                    
                    self.content = [
                        LineView(attributed: ats, tab: self),
                        LineView(attributed: ats2, tab: self),
                        LineView(data: Data("".utf8), type: "text/ignore-cert", tab: self)
                    ]
                    
                } else if error == NWError.dns(-65554) || error == NWError.dns(0)  {
                    let ats = NSMutableAttributedString(string: String(localized: "Could not connect"), attributes: contentParser.title1Style)
                    
                    let ats2 = NSMutableAttributedString(string: String(localized: "Please make sure your internet conection is working properly"), attributes: contentParser.title3Style)
                    self.content = [
                        LineView(attributed: ats, tab: self),
                        LineView(attributed: ats2, tab: self),
                    ]
                    
                } else {
                    let ats = NSMutableAttributedString(string: String(localized: "Unknown Error"), attributes: contentParser.title1Style)
                    
                    let ats2 = NSMutableAttributedString(string: error.localizedDescription, attributes: contentParser.title1Style)
                    
                    self.content = [
                        LineView(attributed: ats, tab: self),
                        LineView(attributed: ats2, tab: self),
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
                    let ats = NSMutableAttributedString(string: parsedMessage.header.contentType, attributes: parsedMessage.title1Style)
                    self.content = [
                        LineView(attributed: ats, tab: self),
                        LineView(data: Data(), type: "text/answer", tab: self),
                    ]
                    // Add to history
                    self.history.append(self.url)
                    self.globalHistory.addItem(self.url)
                } else if (20...29).contains(parsedMessage.header.code) {
                    // Success, show parsed content
                    self.textContent = parsedMessage.attrStr
                    self.content = parsedMessage.parsed
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

                    let format = NSLocalizedString("%d Page Not Found", comment:"page not found title. First argument is the error code")

                    let ats = NSMutableAttributedString(string: String(format: format, parsedMessage.header.code), attributes: parsedMessage.title1Style)
                    
                    let format2 = NSLocalizedString("Sorry, the page %@ was not found on %@%@", comment:"Page not found error subtitle. first argument is the path, second the icon, third the host name")

                    let ats2 = NSMutableAttributedString(string: String(format: format2, self.url.path, self.emojis.emoji(self.url.host ?? ""), (self.url.host ?? "")), attributes: parsedMessage.title3Style)
                    
                    self.content = [
                        LineView(attributed: ats, tab: self),
                        LineView(attributed: ats2, tab: self),
                    ]
                } else {
                    // Server Error
                    self.history.append(self.url)
                    self.globalHistory.addItem(self.url)
                    
                    let format1 = NSLocalizedString("%d Server Error", comment:"Generic server error title. First param is the error code")
                    
                    let ats = NSMutableAttributedString(string: String(format: format1, parsedMessage.header.code), attributes: parsedMessage.title1Style)
                    
                    let format = NSLocalizedString("Could not load %@", comment:"Generic server error subtitle. First param is full url")

                    let ats2 = NSMutableAttributedString(string: String(format: format, self.url.absoluteString), attributes: parsedMessage.title2Style)
                    
                    ats2.append(NSAttributedString(string: "\n" + parsedMessage.header.contentType, attributes: parsedMessage.title3Style))
                    
                    self.content = [
                        LineView(attributed: ats, tab: self),
                        LineView(attributed: ats2, tab: self),
                    ]
                }
            }
        }
    }
    
    func search(_ str: String) -> [Range<String.Index>] {
        let wholeRange = NSRange(location: 0, length: self.textContent.string.count + 1)
        let content = NSMutableAttributedString("")
        content.append(self.textContent)
        content.removeAttribute(.backgroundColor, range: wholeRange)
        
        if content.string.contains(str) {
            self.ranges = content.string.ranges(of: str, options: [])

            for range in ranges! {
                content.addAttribute(.backgroundColor, value: NSColor.systemGray.blended(withFraction: 0.5, of: NSColor.textBackgroundColor) ?? NSColor.gray, range: range.nsRange(in: content.string))
            }
            self.textContent = content
            return ranges!
        }
        
        self.textContent = content
        
        return []
    }
    
    func enterSearch() {
        if let ranges = self.ranges {
            let content = NSMutableAttributedString("")
            content.append(self.textContent)
            for range in ranges {
                content.addAttribute(.backgroundColor, value: NSColor.systemGray.blended(withFraction: 0.5, of: NSColor.textBackgroundColor) ?? NSColor.gray, range: range.nsRange(in: content.string))
            }
            
            if selectedRangeIndex >= ranges.count {
                selectedRangeIndex = 0
            }
            
            let range = ranges[selectedRangeIndex]
            
            content.addAttribute(.backgroundColor, value: NSColor.green, range: range.nsRange(in: content.string))
            
            selectedRangeIndex += 1

            
            self.textContent = content
        }
        

    }
    
}

extension RangeExpression where Bound == String.Index  {
    func nsRange<S: StringProtocol>(in string: S) -> NSRange { .init(self, in: string) }
}

extension String {
    func ranges(of substring: String, options: CompareOptions = [], locale: Locale? = nil) -> [Range<Index>] {
        var ranges: [Range<Index>] = []
        while let range = range(of: substring, options: options, range: (ranges.last?.upperBound ?? self.startIndex)..<self.endIndex, locale: locale) {
            ranges.append(range)
        }
        return ranges
    }
}

