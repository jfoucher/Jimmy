//
//  Emojis.swift
//  jimmy
//
//  Created by Jonathan Foucher on 20/02/2022.
//

import Foundation
import CryptoKit
import SwiftUI

struct Emoji: Codable {
    var host: String
    var time: String
    var emoji: String
}


class Emojis {
    var emojis: [Emoji] = []
    var officalEmojis: [Emoji] = []
    var requestInProgress: Bool = false
    
    private var codepoints = [
        0x1F300...0x1F5FF, // Misc Symbols and Pictographs
        0x1F680...0x1F6FF, // Transport and Map
        0x1F600...0x1F64F, // Emoticons
        0x1F1E6...0x1F1FF, // Regional country flags
        0x2600...0x26FF,   // Misc symbols 9728 - 9983
        0x2700...0x27BF,   // Dingbats
        0x1F900...0x1F9FF,  // Supplemental Symbols and Pictographs 129280 - 129535
        65024...65039, // Variation selector
        9100...9300, // Misc items
    ]
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "emojis"), let decoded = try? JSONDecoder().decode([Emoji].self, from: data) {
            emojis = decoded
        } else {
            emojis = []
        }

        if let data = UserDefaults.standard.data(forKey: "officialemojis"), let decoded = try? JSONDecoder().decode([Emoji].self, from: data) {
            officalEmojis = decoded
        } else {
            officalEmojis = []
        }
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(emojis) {
            UserDefaults.standard.set(encoded, forKey: "emojis")
        }
        if let encoded = try? JSONEncoder().encode(officalEmojis) {
            UserDefaults.standard.set(encoded, forKey: "officialemojis")
        }
    }
    
    func emoji(_ host: String) -> String {
        if let emo = officalEmojis.first(where: {$0.host == host}) {
            if let d = emo.time.toDate() {
                let now = Date()
                
                let interval = now.timeIntervalSince(d)
                if interval > 3600.0 && requestInProgress == false {
                    print("Updating cached emoji")
                    
                    self.requestEmoji(host)
                }
            }
            return emo.emoji
        }
        
        if let emo = emojis.first(where: {$0.host == host}) {
            if let d = emo.time.toDate() {
                let now = Date()
                
                let interval = now.timeIntervalSince(d)
                // Only cache generated emojis for 10 seconds
                if interval > 10.0 && requestInProgress == false {
                    self.requestEmoji(host)
                }
            }
            
            return emo.emoji
        }
        
        // nothing found for this host, so generate it now.
        return generateEmoji(host)
    }
    
    func generateEmoji(_ host: String) -> String {
        let hashed = SHA256.hash(data: Data(host.utf8))
        
        let m = hashed.map( { byte in
            return String(format: "%02x", byte)
        }).joined(separator: "")
        let hs = m[m.startIndex..<String.Index(utf16Offset: 8, in: m)]
        
        for codepoint in codepoints {
            let count = UInt32(codepoint.upperBound - codepoint.lowerBound)
            
            let index = UInt32(hs, radix: 16)! % count + UInt32(codepoint.lowerBound)
            
            guard let scalar = UnicodeScalar(index) else {
                continue
            }
            if Character(scalar).unicodeAvailable() {
                DispatchQueue.main.async {
                    self.emojis.removeAll(where: {$0.host == host})
                    
                    let t = Date()
                    
                    self.emojis.append(Emoji(host: host, time: t.toString(), emoji: String(scalar)))
                    
                    self.save()
                }
                
                return String(scalar)
                
            }
        }
        return "❓"
    }
    
    func requestEmoji(_ host: String) {
        requestInProgress = true
        let certs = IgnoredCertificates()
        let client = Client(host: host, port: 1965, validateCert: !certs.items.contains(host))
        client.start()
        client.dataReceivedCallback = resp(host)
        
        client.send(data: ("gemini://" + host + "/favicon.txt\r\n").data(using: .utf8)!)
    }
    
    func resp(_ host: String) -> (Error?, Data?) -> Void {
        return  { error, message in
            if let message = message {
                if let range = message.firstRange(of: Data("\r\n".utf8)) {
                    let headerRange = message.startIndex..<range.lowerBound
                    let firstLineData = message.subdata(in: headerRange)
                    let firstlineString = String(decoding: firstLineData, as: UTF8.self)
                    let header = Header(line: firstlineString)
                    
                    print("emoji request headers", header.code, header.contentType)
                    
                    let contentRange = range.upperBound..<message.endIndex
                    let contentData = message.subdata(in: contentRange)
                    
                    if header.code == 20 && header.contentType.starts(with: "text/plain") {
                        let emo = String(decoding: contentData, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
                        print("emoji from server is ", emo)
                        DispatchQueue.main.async {
                            self.officalEmojis.removeAll(where: {$0.host == host})
                            
                            let t = Date()
                            
                            self.officalEmojis.append(Emoji(host: host, time: t.toString(), emoji: emo))
                            self.save()
                            
                            
                        }
                    } else {
                        print("emoji response from server is ", String(decoding: message, as: UTF8.self))
                        self.generateEmoji(host)
                    }
                } else {
                    self.generateEmoji(host)
                }
            } else {
                self.generateEmoji(host)
            }
            
            self.requestInProgress = false
        }
    }
    
    
}

extension Date {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let stringDate: String = dateFormatter.string(from: self)
        return stringDate
    }
}

extension String {
    func toDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let d = dateFormatter.date(from: self)
        
        return d
    }
}


extension Character {
    private static let refUnicodeSize: CGFloat = 8
    private static let refUnicodePng =
    Character("\u{1f588}").png(ofSize: Character.refUnicodeSize)
    
    func unicodeAvailable() -> Bool {
        if let refUnicodePng = Character.refUnicodePng,
           let myPng = self.png(ofSize: Character.refUnicodeSize) {
            return refUnicodePng != myPng
        }
        return false
    }
    
    func png(ofSize fontSize: CGFloat) -> Data? {
        let str = String(self)
        let size = str.size(withAttributes: [.font: NSFont.systemFont(ofSize: 16.0)])
        
        let img = NSImage(size: size, flipped: false, drawingHandler: { rect in
            str.draw(in: rect, withAttributes: [.font: NSFont.systemFont(ofSize: 16.0)])
            return true
        })
        
        if let png = img.tiffRepresentation {
            return png
        }
        
        return nil
    }
}
