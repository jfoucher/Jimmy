//
//  ContentParser.swift
//  jimmy
//
//  Created by Jonathan Foucher on 17/02/2022.
//

import Foundation

import SwiftUI


class ContentParser {
    var parsed: [LineView] = []
    var header: Header
    var pre = false
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
            
            if self.header.code >= 20 && self.header.code < 30 {
                if self.header.contentType.starts(with: "image/") {
                    self.parsed = [LineView(data: contentData, type: self.header.contentType, tab: tab)]
                } else if self.header.contentType.starts(with: "text/") {
                    let lines = String(decoding: contentData, as: UTF8.self).replacingOccurrences(of: "\r", with: "").split(separator: "\n")
                    self.parsed = lines.map { str -> LineView? in
                        if str.starts(with: "```") {
                            self.pre = !self.pre
                            return nil
                        }
                        let type = self.pre ? "text/pre" : self.header.contentType

                        return LineView(data: Data(str.utf8), type: type, tab: self.tab)
                    }.filter { $0 != nil }.map { line -> LineView in
                        return line!
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
}
