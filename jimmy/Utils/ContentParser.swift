//
//  ContentParser.swift
//  jimmy
//
//  Created by Jonathan Foucher on 17/02/2022.
//

import Foundation

import SwiftUI

enum BlockType {
    case text
    case pre
    case list
    case link
    case title1
    case title2
    case title3
    case quote
    case end
}


class ContentParser {
    var parsed: [LineView] = []
    var header: Header
    var attrStr: NSAttributedString
    let tab: Tab
    
    init(content: Data, tab: Tab) {
        print("got response")
        print(content)
        self.attrStr = NSAttributedString(string: "")
        self.tab = tab
        self.parsed = []
        self.header = Header(line: "")
        
        if let range = content.firstRange(of: Data("\r\n".utf8)) {
            let headerRange = content.startIndex..<range.lowerBound
            let firstLineData = content.subdata(in: headerRange)
            let firstlineString = String(decoding: firstLineData, as: UTF8.self)
            self.header = Header(line: firstlineString)
            
            let contentRange = range.upperBound..<content.endIndex
            let contentData = content.subdata(in: contentRange)
            
            if (20...29).contains(self.header.code) {
                // if we have a success response code
                if self.header.contentType.starts(with: "image/") {
                    self.parsed = [LineView(data: contentData, type: self.header.contentType, tab: tab)]
                } else if self.header.contentType.starts(with: "text/gemini") {
                    
                    self.attrStr = parseGemText(String(decoding: contentData, as: UTF8.self).replacingOccurrences(of: "\r", with: ""))
                    
                } else if self.header.contentType.starts(with: "text/") {
                    self.attrStr = NSMutableAttributedString(string: String(decoding: contentData, as: UTF8.self))
                        //.font(.system(size: 14, weight: .light, design: .monospaced))
                } else {
                    // Download unknown file type
                    DispatchQueue.main.async {
                        let mySave = NSSavePanel()
                        mySave.prompt = "Save"
                        mySave.title = "Saving " + tab.url.lastPathComponent
                        mySave.nameFieldStringValue = tab.url.lastPathComponent

                        mySave.begin { (result: NSApplication.ModalResponse) -> Void in
                            if result == NSApplication.ModalResponse.OK {
                                if let fileurl = mySave.url {
                                    print("file url is", fileurl)
                                    do {
                                        try contentData.write(to: fileurl)
                                    } catch {
                                        print("error writing")
                                    }
                                } else {
                                    print("no file url")
                                }
                            } else {
                                print ("cancel")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func parseGemText(_ content: String) -> NSAttributedString {
        let lines = content.split(separator: "\n")
        let result = NSMutableAttributedString(string: "")
        var str: String = ""
        var pre = false
        for (index, line) in lines.enumerated() {
            let blockType = getBlockType(String(line))
            if blockType == .pre {
                pre = !pre
                
                if !pre {
                    print ("PRE___________________ ", str)
                    let attr = getAttributesForType(.pre, link: nil)
                    let pstr = NSAttributedString(string: "\n" + str + "\n", attributes: attr)

                    result.append(pstr)
                    
                    str = ""
                }
                continue
            }

            str += line + "\n"
            if pre {
                continue
            }
            
            let nextBlockType: BlockType = index+1 < lines.count ? getBlockType(String(lines[index+1])) : .end
            
            
            if (blockType != nextBlockType) || blockType == .link || blockType == .title1 || blockType == .title2 || blockType == .title3 {
                // output previous block
                
                let font = NSFont.systemFont(ofSize: tab.fontSize)
                var url: URL? = nil
                if blockType == .link {
                    let link = parseLink(str)
                    if let label = link.label {
                        str = label
                    }
                    url = link.link
                }
                let attr = getAttributesForType(blockType, link: url)
                
                let pstr = NSAttributedString(string: str.replacingOccurrences(of: "#", with: "").trimmingCharacters(in: .whitespacesAndNewlines) + "\n", attributes: attr)
                result.append(pstr)
                str.removeLast()
                self.parsed.append(LineView(data: Data(str.utf8), type: self.header.contentType, tab: self.tab))
                str = ""
            }
        }
        
        return result
    }
    
    func getBlockType(_ line: String) -> BlockType {
        if line.starts(with: "###") {
            return .title3
        } else if line.starts(with: "##") {
            return .title2
        } else if line.starts(with: "#") {
            return .title1
        } else if line.starts(with: "=>") {
            return .link
        } else if line.starts(with: "* ") {
            return .list
        } else if line.starts(with: ">") {
            return .quote
        } else if line.starts(with: "```") {
           return .pre
        } else {
            return .text
        }
    }
    
    func getAttributesForType(_ type: BlockType, link: URL?) -> [NSAttributedString.Key: Any] {
        let fontManager: NSFontManager = NSFontManager.shared
        
        switch type {
        case .text:
            let font = NSFont.systemFont(ofSize: tab.fontSize)
            return [
                .font: font,
                .foregroundColor: NSColor.white
            ]
        case .pre:
            let pst = NSMutableParagraphStyle()
            pst.alignment = .left
            pst.paragraphSpacing = 0
            pst.paragraphSpacingBefore = 0
            let tabInterval : CGFloat = 75.0
            var tabs = [NSTextTab]()
            for i in 1...20 { tabs.append(NSTextTab(textAlignment: .left, location: tabInterval * CGFloat(i))) }
            pst.tabStops = tabs
            return [
                .font: NSFont.monospacedSystemFont(ofSize: tab.fontSize, weight: NSFont.Weight.light),
                .foregroundColor: NSColor.white,
                .paragraphStyle: pst
            ]
        case .list:
            let font = NSFont.systemFont(ofSize: tab.fontSize)
            return [
                .font: font,
                .foregroundColor: NSColor.white
            ]
        case .link:
            let pst = NSMutableParagraphStyle()
            pst.alignment = .left
            pst.paragraphSpacingBefore = tab.fontSize
            let font = NSFont.systemFont(ofSize: tab.fontSize)

            return [
                .font: font,
                .link: link,
                .foregroundColor: NSColor.systemGray,
                .cursor: NSCursor.pointingHand,
                .paragraphStyle: pst,
            ]
        case .title1:
            let pst = NSMutableParagraphStyle()
            pst.alignment = .center
            pst.lineSpacing = 0
            pst.paragraphSpacing = tab.fontSize * 1.4
            pst.paragraphSpacingBefore = tab.fontSize * 3
            let italic: NSFont = fontManager.font(withFamily: ".AppleSystemUIFontSerif", traits: NSFontTraitMask.unitalicFontMask, weight: 400, size: tab.fontSize * 2) ?? NSFont.systemFont(ofSize: tab.fontSize * 2, weight: .heavy)
            
            return [
                .font: italic,
                .paragraphStyle: pst,
                .foregroundColor: NSColor.white
            ]
        case .title2:
            let italic: NSFont = fontManager.font(withFamily: ".AppleSystemUIFontSerif", traits: NSFontTraitMask.italicFontMask, weight: 0, size: tab.fontSize * 1.5) ?? NSFont.systemFont(ofSize: tab.fontSize * 1.5, weight: .thin)
            let pst = NSMutableParagraphStyle()
            pst.alignment = .left
            pst.paragraphSpacing = tab.fontSize * 0.8
            pst.paragraphSpacingBefore = tab.fontSize * 1.2

            return [
                .font: italic,
                .paragraphStyle: pst,
                .foregroundColor: NSColor.white
            ]
        case .title3:
            let italic: NSFont = fontManager.font(withFamily: ".AppleSystemUIFont", traits: NSFontTraitMask.unitalicFontMask, weight: 0, size: tab.fontSize * 1.3) ?? NSFont.systemFont(ofSize: tab.fontSize * 1.3, weight: .thin)
            let pst = NSMutableParagraphStyle()
            pst.alignment = .left
            pst.paragraphSpacing = tab.fontSize * 0.8
            pst.paragraphSpacingBefore = tab.fontSize * 1.2

            return [
                .font: italic,
                .paragraphStyle: pst,
                .foregroundColor: NSColor.white
            ]
        case .quote:
            let font = NSFont.systemFont(ofSize: tab.fontSize)
            return [
                .font: font,
                .foregroundColor: NSColor.blue
            ]
        case .end:
            return [:]
        }
    }
    
    private func parseLink(_ l: String) -> Link {
        let line = l.replacingOccurrences(of: "=>", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        let start = line.startIndex
        var end = line.endIndex
        if let endRange = line.range(of: "\t") {
            end = endRange.upperBound
        } else if let endRange = line.range(of: " ") {
            end = endRange.upperBound
        }
        

        
        let linkString = line[start..<end].trimmingCharacters(in: .whitespaces)
        let original = linkString
        var link = URLParser(baseURL: tab.url, link: linkString).toAbsolute()
        if linkString.starts(with: "gemini://") {
            if let p = URL(string: linkString) {
                link = p
            }
        }
        
        var label = String(line[end..<line.endIndex]).trimmingCharacters(in: .whitespaces)
        if end == line.endIndex {
            label = link.absoluteString
        }
        
        return Link(link: link, label: label, original: original)
    }
}



struct Link {
    var link: URL
    var label: String?
    var original: String
}
