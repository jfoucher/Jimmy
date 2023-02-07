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
    var attrStr: NSAttributedString?
    var id: UUID
    
    @State var answer = ""
    
    init(data: Data, type: String, tab:Tab) {
        self.line = String(decoding: data, as: UTF8.self)
        self.data = data
        
        self.type = type
        self.id = UUID()
        self.tab = tab
    }
    
    init(attributed: NSAttributedString, tab: Tab) {
        self.id = UUID()
        self.tab = tab
        self.type = "text"
        self.line = ""
        self.data = Data([])
        self.attrStr = attributed
    }
    
    var body: some View {
        textView
    }
    
    @ViewBuilder
    private var textView: some View {
        if type.starts(with: "text/ignore-cert") {
            let format = NSLocalizedString("Ignore certificate validation for %@%@", comment:"Button label to ignore certificate validation for this host")
            
            Button(action: {
                if let host = tab.url.host {
                    certs.items.append(host)
                    tab.certs.items = certs.items
                    certs.save()
                    tab.load()
                }
            }, label: {
                Text(String(format: format, tab.emojis.emoji(tab.url.host ?? ""), (tab.url.host ?? "")))
            })
        } else if type.starts(with: "text/answer") {
            // Line for an answer. The question should be above this
            HStack {
                TextField("Answer", text: $answer)
                    .textFieldStyle(.roundedBorder)
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
            if let a = attrStr {
                AttributedText(a)
            }
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
