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
    case end
}


class ContentParser {
    var parsed: [LineView] = []
    var header: Header

    let tab: Tab
    
    init(content: Data, tab: Tab) {
        print("got response")
        print(content)
        
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
                } else if self.header.contentType.starts(with: "text/") {
                    let lines = String(decoding: contentData, as: UTF8.self).replacingOccurrences(of: "\r", with: "").split(separator: "\n")
                    var str: String = ""
                    var pre = false
                    for (index, line) in lines.enumerated() {
                        let blockType = getBlockType(String(line))
                        if blockType == .pre {
                            pre = !pre
                            
                            if !pre {
                                self.parsed.append(LineView(data: Data(str.utf8), type: "text/pre", tab: self.tab))
                                str = ""
                            }
                            continue
                        }

                        str += line + "\n"
                        if pre {
                            continue
                        }
                        
                        let nextBlockType: BlockType = index+1 < lines.count ? getBlockType(String(lines[index+1])) : .end
                        
                        if (blockType != nextBlockType) || blockType == .link {
                            // output previous block
                            str.removeLast()
                            self.parsed.append(LineView(data: Data(str.utf8), type: self.header.contentType, tab: self.tab))
                            str = ""
                        }
                    }
                } else {
                    // Download unknown file type
                    DispatchQueue.main.async {
                        let mySave = NSSavePanel()
                        mySave.prompt = "Save"
                        mySave.title = "Saving " + tab.url.lastPathComponent
                        mySave.nameFieldStringValue = tab.url.lastPathComponent

                        mySave.begin { (result: NSApplication.ModalResponse) -> Void in
                            if result == NSApplication.ModalResponse.OK {
                                print("ok")
                                
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
        } else if line.starts(with: "```") {
           return .pre
        } else {
            return .text
        }
    }
}
