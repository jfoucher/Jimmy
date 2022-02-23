//
//  LinkContectMenu.swift
//  jimmy
//
//  Created by Jonathan Foucher on 19/02/2022.
//

import SwiftUI

struct LinkContextMenu: View {
    @Environment(\.openURL) var openURL
    @EnvironmentObject private var tabList: TabList
    var link: URL
    
    init(link: URL) {
        self.link = link
    }
    var body: some View {
        VStack {
            Button(action: newTab)
            {
                Label("Open in new tab", systemImage: "plus.rectangle")
            }
                .buttonStyle(.plain)
            Button(action: copyLink)
            {
                Label("Copy link address", systemImage: "link")
            }
                .buttonStyle(.plain)
        }
    }
    
    func newTab() {
        openURL(link)
    }
    
    func copyLink() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(self.link.absoluteString, forType: .string)
    }
}
