//
//  Emojis.swift
//  jimmy
//
//  Created by Jonathan Foucher on 20/02/2022.
//

import Foundation
import CryptoKit
import SwiftUI


struct Emojis {
    var emoji: String
    
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
    
    
    init(_ host: String) {
        let hashed = SHA256.hash(data: Data(host.utf8))
        
        let m = hashed.map( { byte in
            return String(format: "%02x", byte)
        }).joined(separator: "")
        let hs = m[m.startIndex..<String.Index(utf16Offset: 8, in: m)]
        
        self.emoji = "❓"
        
        for codepoint in codepoints {
            let count = UInt32(codepoint.upperBound - codepoint.lowerBound)
            
            let index = UInt32(hs, radix: 16)! % count + UInt32(codepoint.lowerBound)
            
            print(String(format: "%06x", index))
            
            guard let scalar = UnicodeScalar(index) else {
                print("could not get scalar")
                self.emoji = "❓"
                continue
            }
            if Character(scalar).unicodeAvailable() {
                print("emoji available")
                self.emoji = String(scalar)
                return
            }
        }
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
        print(size)
        let img = NSImage(size: size, flipped: false, drawingHandler: { rect in
            str.draw(in: rect, withAttributes: [.font: NSFont.systemFont(ofSize: 16.0)])
            return true
        })

        if let png = img.tiffRepresentation {
            print("image ok")
            return png
        }

        return nil
    }
}
