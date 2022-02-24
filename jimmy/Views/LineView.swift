//
//  LineView.swift
//  jimmy
//
//  Created by Jonathan Foucher on 17/02/2022.
//

import SwiftUI

struct LineView: View, Hashable {
    @EnvironmentObject var certs: IgnoredCertificates
    var line: String
    var data: Data
    var type: String
    var tab: Tab
    
    var id: UUID
    
    @State var answer = ""
    
    init(data: Data, type: String, tab:Tab) {
        self.line = String(decoding: data, as: UTF8.self)
        self.data = data
        
        self.type = type
        self.id = UUID()
        self.tab = tab
    }
    var body: some View {
        textView
    }
    
    @ViewBuilder
    private var textView: some View {
        if type.starts(with: "text/gemini") {
            if self.line.starts(with: "=>") {
                LinkView(line: self.line, tab: tab).frame(alignment: .leading).padding(.leading, 12)
            } else if line.starts(with: "* ") {
                Text(line.replacingOccurrences(of: "* ", with: "• "))
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.system(size: tab.fontSize))
                    .lineSpacing(tab.fontSize * 0.5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 24)
                    .padding(.bottom, 8)
                    .padding(.top, 3)
            }  else if self.line.starts(with: "###") {
                Text(line.replacingOccurrences(of: "#", with: "").trimmingCharacters(in: .whitespacesAndNewlines))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: tab.fontSize*1.4, weight: .thin, design: .default))
                    .padding(.bottom, 5)
            } else if self.line.starts(with: "##") {
                Text(line.replacingOccurrences(of: "#", with: "").trimmingCharacters(in: .whitespacesAndNewlines))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: tab.fontSize*1.6, weight: .thin, design: .serif).italic())
                    .padding(.bottom, 5)
            } else if self.line.starts(with: "#") {
                Text(line.replacingOccurrences(of: "#", with: "").trimmingCharacters(in: .whitespacesAndNewlines))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(.system(size: tab.fontSize * 2, weight: .heavy, design: .serif))
                    .padding(.bottom, tab.fontSize)
                    .padding(.top, tab.fontSize)
            } else if self.line.starts(with: ">") {
                
                HStack(alignment: .top) {
                    Image(systemName: "quote.opening")
                        .resizable()
                        .imageScale(.large)
                        .foregroundColor(Color.gray)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .padding(.top, tab.fontSize * 3)
                        .padding(.leading, 24)
                    Text(line.replacingOccurrences(of: ">", with: "").trimmingCharacters(in: .whitespaces))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(.system(size: tab.fontSize * 1.4, weight: .thin, design: .serif).italic())
                        .padding(.bottom, tab.fontSize * 3)
                        .padding(.top, tab.fontSize * 3)
                        .padding(.leading, 12)
                        .padding(.trailing, 24)
                        .fixedSize(horizontal: false, vertical: true)
                    Image(systemName: "quote.closing")
                        .resizable()
                        .imageScale(.large)
                        .foregroundColor(Color.gray)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .padding(.top, tab.fontSize * 3)
                        .padding(.trailing, 24)
                }
                
            } else {
                Text(line)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.system(size: tab.fontSize))
                    .lineSpacing(tab.fontSize * 0.5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 5)
                    .background(Color.red)
            }
        } else if type.starts(with: "text/pre") {
            Text(line)
                
                .fixedSize(horizontal: false, vertical: true)
                .font(Font.custom("Source Code Pro", size: 18))

                .padding(.leading, 12)
                .padding(.bottom, 5)
                .background(Color.green)
                

        } else if type.starts(with: "text/ignore-cert") {
            Button(action: {
                if let host = tab.url.host {
                    certs.items.append(host)
                    tab.certs.items = certs.items
                    certs.save()
                    tab.load()
                }
            }, label: {
                Text("Ignore certificate validation for " + (Emojis(tab.url.host ?? "").emoji) + " " + (tab.url.host ?? ""))
            })
        } else if type.starts(with: "text/answer") {
            // Line for an answer. The question should be above this
            HStack {
                TextField("Answer", text: $answer)
                    .onSubmit {
                        send()
                    }
                Button(action: send) {
                    Text("Send")
                }
            }
        } else if type.starts(with: "image/") {
            // Line for an answer. The question should be above this
            if let img = NSImage(data: Data(self.data)) {
                Image(nsImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .layoutPriority(-1)
            } else {
                Image(systemName: "xmark")
            }
        } else {
            Text(line)
                .font(.system(size: tab.fontSize))
                .lineSpacing(tab.fontSize * 0.5)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 5)
                .padding(.leading, 12)
        }
    }
    
    func send () {
        if let url = URL(string: tab.url.absoluteString + "?" + (answer.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")) {
            tab.url = url
            tab.load()
        }
    }
    
    static func == (lhs: LineView, rhs: LineView) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
